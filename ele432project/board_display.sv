// board_display.sv

// add other signals later
module board_display #(
    parameter BLACK_RGB = 24'h000000
) (
    // Inputs
    input  logic        clk,
    input  logic [9:0]  x, y,
    // Dynamic boxes and texts
    input  logic [3:0]  pawn_enabled,           // which pawns are enabled (for tile and text coloring)
    // Dynamic boxes
    input  logic [19:0] pawn_tile,              // 5-bit tile number (0-31)
    input  logic [3:0]  pawn_selected,          // whether this pawn is currently selected
    input  logic [3:0]  pawn_in_makeup,         // whether this pawn is in the makeup area
    input  logic [2:0]  tile_ownership [31:0],  // bit-2 is enable signal, bits 0-1 are player IDs
    input  logic [5:0]  dice_info,              // info for one dice 3 bits
    input  logic [1:0]  vending_machine [31:0], // number of vending machines (0-3) on a tile
    // Dynamic texts
    input  logic [4:0]  card_id,                // Which card to read (1 to 21)
    input  logic [31:0] player_money,           // 32-bit vector of player money 8 bits each    
    input  logic [15:0] active_price,           // 16-bit vector of active price
    input  logic [7:0]  current_vga_cmd,        // 8-bit vector of current VGA command
    input  logic        debug_on,               // Debug mode
    // Outputs
    output logic [7:0]  r, g, b
);

    logic [7:0] box_static_r, box_static_g, box_static_b;
    logic [7:0] text_static_r, text_static_g, text_static_b;
    logic [7:0] box_dynamic_r, box_dynamic_g, box_dynamic_b;
    logic [7:0] text_dynamic_r, text_dynamic_g, text_dynamic_b;

    board_boxes_static boxes_static(
        .x(x), .y(y),
        .r(box_static_r), .g(box_static_g), .b(box_static_b)
    );

    board_texts_static texts_static(
        .x(x), .y(y),
        .r(text_static_r), .g(text_static_g), .b(text_static_b)
    );

    board_boxes_dynamic boxes_dynamic(
        .x(x), .y(y),
        .pawn_enabled(pawn_enabled),        // Connect pawn enabled signals
        .pawn_tile(pawn_tile),              // Connect pawn tile signals   
        .pawn_selected(pawn_selected),      // Connect pawn selected signals
        .pawn_in_makeup(pawn_in_makeup),    // Connect pawn in makeup signals
        .tile_ownership(tile_ownership),    // Connect tile ownership signals
        .dice_info(dice_info),              // Connect dice info
        .vending_machine(vending_machine),  // Connect vending machine signals
        .r(box_dynamic_r), .g(box_dynamic_g), .b(box_dynamic_b)
    );

    board_texts_dynamic texts_dynamic(
        .x(x), .y(y),
        .clk(clk),
        .pawn_selected(pawn_selected),
        .pawn_in_makeup(pawn_in_makeup),
        .pawn_tile(pawn_tile),
        .pawn_enabled(pawn_enabled),
        .card_id(card_id),                  // Which card to read
        .player_money(player_money),        // 32-bit vector of player money 8 bits each
        .active_price(active_price),
        .current_vga_cmd(current_vga_cmd),
        .debug_on(debug_on),
        .r(text_dynamic_r), .g(text_dynamic_g), .b(text_dynamic_b)
    );

    always_comb begin
        // Simple priority: if text is on, show text. Otherwise, show boxes.
        // Dynamic drawn on top of static, so check dynamic before static.
        // BLACK_RGB check is for transparency in upper layers.
        // If you want to print black use 24'h010101 (not for static boxes).
        if ({text_dynamic_r, text_dynamic_g, text_dynamic_b} != BLACK_RGB) begin
            {r, g, b} = {text_dynamic_r, text_dynamic_g, text_dynamic_b};
        end else if ({text_static_r, text_static_g, text_static_b} != BLACK_RGB) begin
            {r, g, b} = {text_static_r, text_static_g, text_static_b};
        end else if ({box_dynamic_r, box_dynamic_g, box_dynamic_b} != BLACK_RGB) begin
            {r, g, b} = {box_dynamic_r, box_dynamic_g, box_dynamic_b};
        end else begin
            {r, g, b} = {box_static_r, box_static_g, box_static_b};
        end
    end

endmodule
