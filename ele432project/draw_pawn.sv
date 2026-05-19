// draw_pawn.sv

module draw_pawn #(
    parameter BLACK_RGB = 24'h000000,
    parameter PAWN_1_RGB = 24'hFF0000,
    parameter PAWN_2_RGB = 24'h00FF00,
    parameter PAWN_3_RGB = 24'h0000FF,
    parameter PAWN_4_RGB = 24'hFFFF00,
    parameter PAWN_1_BORDER_RGB = 24'h00FFFF;   //24'h7F0000,
    parameter PAWN_2_BORDER_RGB = 24'hFF00FF;   //24'h007F00,
    parameter PAWN_3_BORDER_RGB = 24'hFF9F3F;   //24'h00007F,
    parameter PAWN_4_BORDER_RGB = 24'hFF0000;   //24'h7F7F00,
    parameter PAWN_SIZE = 12,
    parameter TILE_SIZE = 50
) (
    input  logic [9:0] x, y,
    input  logic [1:0] pawn_id,                 // 2-bit ID for up to 4 pawns
    input  logic       pawn_enabled,            // pawn is enabled (on the board)
    input  logic [4:0] pawn_tile,               // 5-bit tile number (0-31)
    input  logic       pawn_selected,           // whether this pawn is currently selected
    input  logic       pawn_in_makeup,          // whether this pawn is in the makeup area
    input  logic       pawn_sprite_mode,        // whether to draw the pawn sprite or just a box
    output logic [7:0] r, g, b
);

    // Internal signals for pawn drawing
    logic [9:0]  pawn_left, pawn_top;
    logic        in_pawn, on_pawn_border;
    logic [23:0] pawn_color, pawn_border_color, pawn_sprite_color;

    // Calculate position based on the tile value and pawn ID
    always_comb begin
        // Default coordinates (off-screen)
        pawn_left = 10'd512;
        pawn_top  = 10'd512;

        if (pawn_enabled) begin
            if (pawn_in_makeup) begin
                pawn_left = 10'(10'd16 + (pawn_id * PAWN_SIZE));
                pawn_top  = 10'd452;
            end else begin
                unique case (1'b1) 
                    (pawn_tile >= 5'd0 && pawn_tile <= 5'd7) : begin
                        pawn_left = 10'(10'd66 + ((5'd7 - pawn_tile) * TILE_SIZE) + (pawn_id * PAWN_SIZE));
                        pawn_top  = 10'd467;
                    end 
                    (pawn_tile >= 5'd8 && pawn_tile <= 5'd15) : begin
                        pawn_left = 10'd1;
                        pawn_top  = 10'(10'd66 + ((5'd15 - pawn_tile) * TILE_SIZE) + (pawn_id * PAWN_SIZE));
                    end
                    (pawn_tile >= 5'd16 && pawn_tile <= 5'd24) : begin
                        pawn_left = 10'(10'd16 + ((pawn_tile - 5'd16) * TILE_SIZE) + ((2'd3 - pawn_id) * PAWN_SIZE));
                        pawn_top  = 10'd1;
                    end
                    (pawn_tile >= 5'd25 && pawn_tile <= 5'd31) : begin
                        pawn_left = 10'd467;
                        pawn_top  = 10'(10'd66 + ((pawn_tile - 5'd25) * TILE_SIZE) + ((2'd3 - pawn_id) * PAWN_SIZE));
                    end
                    default : begin
                        pawn_left = 10'd512;
                        pawn_top  = 10'd512;
                    end
                endcase
            end
        end else begin
            pawn_left = 10'd512;
            pawn_top  = 10'd512;
        end
    end

    // Draw pawn without sprite first
    rectgen pawn_rect (
        .x(x), .y(y),
        .left(pawn_left), .top(pawn_top), .right(10'(pawn_left + PAWN_SIZE)), .bot(10'(pawn_top + PAWN_SIZE)),
        .inrect(in_pawn), .onborder(on_pawn_border)
    );

    // Determine pawn color based on ID
    always_comb begin
        case (pawn_id)
            2'b00 : begin 
                pawn_color = PAWN_1_RGB; 
                pawn_border_color = PAWN_1_BORDER_RGB;
            end
            2'b01 : begin 
                pawn_color = PAWN_2_RGB; 
                pawn_border_color = PAWN_2_BORDER_RGB;
            end
            2'b10 : begin 
                pawn_color = PAWN_3_RGB; 
                pawn_border_color = PAWN_3_BORDER_RGB;
            end
            2'b11 : begin 
                pawn_color = PAWN_4_RGB; 
                pawn_border_color = PAWN_4_BORDER_RGB;
            end
            default : begin 
                pawn_color = PAWN_1_RGB; 
                pawn_border_color = PAWN_1_BORDER_RGB;
            end
        endcase
    end


    // Draw pawn sprite
    draw_pawn_sprite pawn_sprite (
        .x(x), .y(y),
        .sprite_x(10'(pawn_left + 1)), .sprite_y(10'(pawn_top + 1)), // +1 to account for border
        .r(pawn_sprite_color[23:16]), .g(pawn_sprite_color[15:8]), .b(pawn_sprite_color[7:0])
    );

    // Final pixel color logic
    always_comb begin
        if (in_pawn && pawn_enabled) begin
            if (on_pawn_border && pawn_selected) {r, g, b} = pawn_border_color;
            else begin
                if (pawn_sprite_mode && pawn_sprite_color != BLACK_RGB) begin
                    {r, g, b} = pawn_sprite_color;
                end else {r, g, b} = pawn_color;
            end
        end else {r, g, b} = BLACK_RGB; // Default to black
    end

endmodule



module draw_pawn_sprite #(
    parameter BLACK_RGB = 24'h000000,
    parameter PAWN_SPRITE_PRIMARY_RGB = 24'hFFFFFF,     // 01 : primary color
    parameter PAWN_SPRITE_SECONDARY_RGB = 24'h00DFFF,   // 10 : secondary color
    parameter PAWN_SPRITE_LINE_RGB = 24'h010101         // 11: line color
) (
    input  logic [9:0] x, y,
    input  logic [9:0] sprite_x, sprite_y,  // top-left corner of the sprite
    output logic [7:0] r, g, b
);

    // Internal signals for sprite generation
    logic [19:0] sprite_data [9:0];  // 10x10 sprite in 2-bit color information (0=transparent, 1=primary, 2=secondary, 3=line)
    logic [9:0] pawn_x, pawn_y;
    logic in_pawn_bounds;
    logic [1:0] pawn_pixel_type; // 00=transparent, 01=primary, 10=secondary, 11=line

    // Intermediate variable to safely pre-calculate the bit select index
    int bit_index;

    always_comb begin
        sprite_data[0]  = 20'b00_00_11_11_11_11_00_00_00_00; // Row 0 TTLLLLTTTT
        sprite_data[1]  = 20'b00_11_00_00_00_00_11_00_00_00; // Row 1 TLTTTTLTTT
        sprite_data[2]  = 20'b00_11_11_11_11_00_00_11_00_00; // Row 2 TLLLLTTLTT
        sprite_data[3]  = 20'b11_01_01_10_10_11_00_11_11_11; // Row 3 LPPSSLTLLL
        sprite_data[4]  = 20'b11_10_10_10_10_11_00_11_00_11; // Row 4 LSSSSLTLTL
        sprite_data[5]  = 20'b00_11_11_11_11_00_00_11_00_11; // Row 5 TLLLLTTLTL
        sprite_data[6]  = 20'b00_11_00_00_00_00_00_11_00_11; // Row 6 TLTTTTTLTL
        sprite_data[7]  = 20'b00_11_00_00_11_00_00_11_11_11; // Row 7 TLTTLTTLLL
        sprite_data[8]  = 20'b00_11_00_00_11_00_00_11_00_00; // Row 8 TLTTLTTLTT
        sprite_data[9]  = 20'b00_11_11_11_11_11_11_11_00_00; // Row 9 TTLLLLLLTT
    end

    always_comb begin
        pawn_x = x - sprite_x;
        pawn_y = y - sprite_y;
 
        // Check if we are inside the 10x10 square
        in_pawn_bounds = (x >= sprite_x && x < sprite_x + 10) &&
                         (y >= sprite_y && y < sprite_y + 10);
    end
 
    always_comb begin
        // Default to transparent
        pawn_pixel_type = 2'b00;
        bit_index       = 0;

        if (in_pawn_bounds) begin 
            // SystemVerilog reads MSB to LSB (left to right), we subtract from 9. and group it by 2
            // Pre-calculate index safely outside the vector slice brackets
            bit_index = (9 - int'(pawn_x)) * 2;

            // Explicitly use a 4-bit index constraint [3:0] for a 10-row array 
            // to stop static analysis warnings.
            pawn_pixel_type = sprite_data[pawn_y[3:0]][bit_index +: 2];
        end
    end

    always_comb begin
        case (pawn_pixel_type)
            2'b00: {r, g, b} = BLACK_RGB; // transparent
            2'b01: {r, g, b} = PAWN_SPRITE_PRIMARY_RGB; // primary color
            2'b10: {r, g, b} = PAWN_SPRITE_SECONDARY_RGB; // secondary color
            2'b11: {r, g, b} = PAWN_SPRITE_LINE_RGB; // line color
            default: {r, g, b} = BLACK_RGB; // default to transparent
        endcase
    end

endmodule