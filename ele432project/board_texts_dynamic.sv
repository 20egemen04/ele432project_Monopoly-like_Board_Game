// board_texts_dynamic.sv

module board_texts_dynamic #(
    parameter MAX_CHARS = 42,  // Set this when you instantiate! Maximum 80 to fit on a 640 pixel screen with 8x8 font
    parameter BLACK_RGB = 24'h000000,
    parameter BLACK_TEXT_RGB = 24'h010101, // Slightly off-black to prevent text from being completely invisible when overlapping with box borders
    parameter WHITE_TEXT_RGB = 24'hFFFFFF,
    parameter P1_TEXT_RGB = 24'hFF0000,
    parameter P2_TEXT_RGB = 24'h00FF00,
    parameter P3_TEXT_RGB = 24'h3F3FFF,
    parameter P4_TEXT_RGB = 24'hFFFF00,
    parameter DEBUG_RGB = 24'h9F0000
)(
    input  logic [9:0]  x, y,
    input  logic        clk,
    input  logic [3:0]  pawn_selected,          // whether this pawn is currently selected
    input  logic [3:0]  pawn_in_makeup,         // whether this pawn is in the makeup area
    input  logic [3:0]  pawn_enabled,           // which pawns are enabled (for text coloring)
    input  logic [19:0] pawn_tile,              // 5-bit tile number (0-31)    
    input  logic [4:0]  card_id,                // Which card to read (1 to 21)
    input  logic [31:0] player_money,           // 32-bit vector of player money 8 bits each
    input  logic [15:0] active_price,           // 16-bit vector of active price
    input  logic [7:0]  current_vga_cmd,        // 8-bit vector of current VGA command
    input  logic        debug_on,               // Debug mode
    output logic [7:0]  r, g, b
);

    // Generate enable_display_chance signal
    logic enable_display_chance;
    always_comb begin
        // Default value
        enable_display_chance = 1'b0;
        // enable chance text when one of the pawns is on the chance tile
        for (int i = 0; i < 4; i++) begin
            if (pawn_selected[i] && ((pawn_tile[(i * 5) +: 5] == 5'd4) || (pawn_tile[(i * 5) +: 5] == 5'd20))) begin
                enable_display_chance = 1'b1;
            end
        end
    end

    // Internal signals and Font Data
    // Yes, I am aware it is a duplicate.
    logic [10:0] master_rom_addr;
    logic [7:0] master_rom_data;

    logic [10:0] text_addr [15:0];
    logic text_pix [15:0];
    logic text_box [15:0];

    always_comb begin
        // Only give the ROM address to the module that the VGA beam is currently inside
        master_rom_addr = 9'd0; // Default value (covers the 'else' case)
        
        // Loop from highest index down to 0
        // text_box[0] will "win" because it's the last assignment made
        for (int i = 13; i >= 0; i--) begin
            if (text_box[i]) begin
                master_rom_addr = text_addr[i];
            end
        end
    end

    font_rom fontROM_dynamic(
        .font_addr(master_rom_addr),
        .font_data_out(master_rom_data)
    );

    // Internal signals for chance card
    logic [((MAX_CHARS * 8) - 1):0] chance_string_line_0, chance_string_line_1, chance_string_line_2, chance_string_line_3;

    // Get text from ROM
    chance_card_text_rom_string text_rom_string(
        .clk(clk),
        .card_id(card_id),
        .text_string_line_0(chance_string_line_0),
        .text_string_line_1(chance_string_line_1),
        .text_string_line_2(chance_string_line_2),
        .text_string_line_3(chance_string_line_3)
    );

    // Render Chance Card texts
    text_display #(.MAX_CHARS(4'd13)) chance_line_0
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd120), 
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string(" CHANCE CARD "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[0]), 
        .pixel_on(text_pix[0]), .in_box(text_box[0])
    );

    text_display #(.MAX_CHARS(4'd13)) chance_line_1
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd128), 
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string("-------------"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[1]), 
        .pixel_on(text_pix[1]), .in_box(text_box[1])
    );

    text_display chance_line_2
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd136),
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string(chance_string_line_0),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[2]), 
        .pixel_on(text_pix[2]), .in_box(text_box[2])
    );

    text_display chance_line_3
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd144),
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string(chance_string_line_1),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[3]), 
        .pixel_on(text_pix[3]), .in_box(text_box[3])
    );

    text_display chance_line_4
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd152),
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string(chance_string_line_2),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[4]), 
        .pixel_on(text_pix[4]), .in_box(text_box[4])
    );

    text_display chance_line_5
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd160),
        .enable_display(enable_display_chance),  // Only on when the chance card is active
        .text_string(chance_string_line_3),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[5]), 
        .pixel_on(text_pix[5]), .in_box(text_box[5])
    );
    


    // Internal signals for player info (start at least (489, 9) but here use (492, 13) for static start and (492, 21) for dynamic start)
    logic [135:0] player_info_string_line [3:0];

    // Prepare text strings and enable signals 
    always_comb begin
        // Defaults
        for (int i = 0; i < 4; i++) begin
            player_info_string_line[i] = 40'd0;
        end
        
        for (int i = 0; i < 4; i++) begin
            if (pawn_enabled[i]) begin
                if (pawn_selected[i])   player_info_string_line[i][135:128] = ";";
                else                    player_info_string_line[i][135:128] = " ";
                player_info_string_line[i][127:112] = " P";
                player_info_string_line[i][111:104] = 8'(i + 49);
                player_info_string_line[i][103:48]  = "   :  $";                
                player_info_string_line[i][47:40]   = 8'((player_money[(i * 8) +: 8] / 100) + 8'd48);
                player_info_string_line[i][39:32]   = 8'(((player_money[(i * 8) +: 8] % 100) / 10) + 8'd48);
                player_info_string_line[i][31:24]   = 8'((player_money[(i * 8) +: 8] % 10) + 8'd48);
                player_info_string_line[i][23:0]    = "00 ";
            end
        end

    end

    // Render Player Info texts
    text_display #(.MAX_CHARS(5'd17)) player_info_line_0
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd21), 
        .enable_display(pawn_enabled[0]),  // Only on when player is active
        .text_string(player_info_string_line[0]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[6]), 
        .pixel_on(text_pix[6]), .in_box(text_box[6])
    );

    text_display #(.MAX_CHARS(5'd17)) player_info_line_1
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd29), 
        .enable_display(pawn_enabled[1]),  // Only on when player is active
        .text_string(player_info_string_line[1]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[7]), 
        .pixel_on(text_pix[7]), .in_box(text_box[7])
    );

    text_display #(.MAX_CHARS(5'd17)) player_info_line_2
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd37), 
        .enable_display(pawn_enabled[2]),  // Only on when player is active
        .text_string(player_info_string_line[2]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[8]), 
        .pixel_on(text_pix[8]), .in_box(text_box[8])
    );

    text_display #(.MAX_CHARS(5'd17)) player_info_line_3
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd45), 
        .enable_display(pawn_enabled[3]),  // Only on when player is active
        .text_string(player_info_string_line[3]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[9]), 
        .pixel_on(text_pix[9]), .in_box(text_box[9])
    );
    


    // CMDs to display data
    localparam CMD_NONE = 8'h00;
    localparam CMD_PROMPT_BUY = 8'h04;
    localparam CMD_PROMPT_VEND = 8'h05;
    localparam CMD_GAME_OVER = 8'h06;
    localparam CMD_PROMPT_RENT = 8'h08;
    localparam CMD_ACK_WAIT = 8'h09;

    logic show_buy_prompt;
    logic show_vend_prompt;
    logic show_rent_prompt;
    logic show_game_over;
    logic show_ack_wait;  //  Kart/Ceza bekleme ekrani 

    logic show_in_makeup;

    logic show_cmd_prompt;

    // Other internal cmd display signals
    logic [335:0] cmd_display_string_line [2:0]; 

    // Prepare signals
    always_comb begin
        // Enable signals
        show_buy_prompt  = (current_vga_cmd == CMD_PROMPT_BUY);
        show_vend_prompt = (current_vga_cmd == CMD_PROMPT_VEND);
        show_rent_prompt = (current_vga_cmd == CMD_PROMPT_RENT);
        show_game_over   = (current_vga_cmd == CMD_GAME_OVER);
        show_ack_wait    = (current_vga_cmd == CMD_ACK_WAIT);

        for (int i = 0; i < 4; i = i + 1) begin
            if (pawn_selected[i] && pawn_in_makeup[i]) begin
                show_in_makeup = 1'b1;
            end else show_in_makeup = 1'b0;
        end

        show_cmd_prompt = show_buy_prompt || show_vend_prompt || show_rent_prompt || show_game_over || show_ack_wait;

        // Text signals
        // Default
        cmd_display_string_line = '{default : {42{8'h20}}};

        // PAY
        if (show_buy_prompt || show_vend_prompt || show_rent_prompt) begin
            // line 0 and line 2
            if (show_buy_prompt) begin
                // line 0
                cmd_display_string_line[0][335:72] = "DO YOU WANT TO BUY THIS PROPERTY?";
                cmd_display_string_line[0][71:0] = {9{8'h20}};
                // line 2
                cmd_display_string_line[2][335:136] = "KEY0 : BUY    KEY1 : DENY";
                cmd_display_string_line[2][135:0] = {17{8'h20}};
            end else if (show_vend_prompt) begin
                // line 0
                cmd_display_string_line[0][335:56] = "DO YOU WANT TO BUY VENDING MACHINE?";
                cmd_display_string_line[0][55:0] = {7{8'h20}};
                // line 2
                cmd_display_string_line[2][335:136] = "KEY0 : BUY    KEY1 : DENY";
                cmd_display_string_line[2][135:0] = {17{8'h20}};
            end else if (show_rent_prompt) begin
                // line 0
                cmd_display_string_line[0][335:16] = "YOU NEED TO PAY MONEY TO ANOTHER PLAYER.";
                cmd_display_string_line[0][15:0] = {2{8'h20}};
                // line 2
                cmd_display_string_line[2][335:256] = "KEY0 : PAY";
                cmd_display_string_line[2][255:0] = {32{8'h20}};
            end

            // line 1
            cmd_display_string_line[1][335:208] = "ACTIVE PRICE : $";
            cmd_display_string_line[1][207:200] = 8'((active_price / 100) + 8'd48);
            cmd_display_string_line[1][199:192] = 8'(((active_price % 100) / 10) + 8'd48);
            cmd_display_string_line[1][191:184] = 8'((active_price % 10) + 8'd48);
            cmd_display_string_line[1][183:168] = "00";
            cmd_display_string_line[1][167:0] = {21{8'h20}};
        end 
        // GAME OVER
        else if (show_game_over) begin
            // line 0
            cmd_display_string_line[0][335:208] = {16{8'h20}};
            cmd_display_string_line[0][207:128] = "GAME OVER!";
            cmd_display_string_line[0][127:0] = {16{8'h20}};
            // line 1
            cmd_display_string_line[1][335:256] = {10{8'h20}};
            cmd_display_string_line[1][255:80] = "; CONGRATULATIONS!!! ;";
            cmd_display_string_line[1][79:0] = {10{8'h20}};
            // line 2
            cmd_display_string_line[1][335:248] = {11{8'h20}};
            cmd_display_string_line[2][247:88] = "RESET GAME WITH SW0.";
            cmd_display_string_line[1][87:0] = {11{8'h20}};
        end 
        // ACK when there is a chance card or waiting in jail (MAKEUP)
        else if (show_ack_wait) begin
            if (enable_display_chance) begin
                // line 0
                cmd_display_string_line[0][335:120] = "YOU ARE ON THE CHANCE TILE.";
                cmd_display_string_line[0][119:0] = {15{8'h20}};
                // line 1
                cmd_display_string_line[2][335:0] = {42{8'h20}};
                // line 2
                cmd_display_string_line[2][335:128] = "PRESS KEY 0 TO CONTINUE...";
                cmd_display_string_line[2][127:0] = {16{8'h20}};
            end else begin
                if (show_in_makeup) begin
                    // line 0
                    cmd_display_string_line[0][335:104] = "YOU ARE TAKING A MAKEUP EXAM.";
                    cmd_display_string_line[0][103:0] = {13{8'h20}};
                end else begin
                    // line 0
                    cmd_display_string_line[0][335:0] = {42{8'h20}};
                end
                // line 1
                cmd_display_string_line[2][335:0] = {42{8'h20}};
                // line 2
                cmd_display_string_line[2][335:128] = "PRESS KEY 0 TO CONTINUE...";
                cmd_display_string_line[2][127:0] = {16{8'h20}};
            end
        end 
    end

    // Render CMDs
    text_display cmd_prompt_line_0
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd320),
        .enable_display(show_cmd_prompt),
        .text_string(cmd_display_string_line[0]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[10]), 
        .pixel_on(text_pix[10]), .in_box(text_box[10])
    );

    text_display cmd_prompt_line_1
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd328),
        .enable_display(show_cmd_prompt),
        .text_string(cmd_display_string_line[1]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[11]), 
        .pixel_on(text_pix[11]), .in_box(text_box[11])
    );

    text_display cmd_prompt_line_2
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd344),
        .enable_display(show_cmd_prompt),
        .text_string(cmd_display_string_line[2]),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[12]), 
        .pixel_on(text_pix[12]), .in_box(text_box[12])
    );



    // Debug
    text_display #(.MAX_CHARS(1'd1)) debug_icon
    (
        .x(x), .y(y),
        .start_x(10'd628), .start_y(10'd304), 
        .enable_display(debug_on),  // SW9
        .text_string(";"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[13]), 
        .pixel_on(text_pix[13]), .in_box(text_box[13])
    );



    // Final RGB
    always_comb begin
        if (text_pix[13])           {r, g, b} = DEBUG_RGB;
        else if (text_pix[0] || text_pix[1] || text_pix[2] || text_pix[3] || text_pix[4] || text_pix[5]
            || text_pix[10] || text_pix[11] || text_pix[12]) begin
            {r, g, b} = WHITE_TEXT_RGB;
        end else if (text_pix[6])   {r, g, b} = P1_TEXT_RGB;
        else if (text_pix[7])       {r, g, b} = P2_TEXT_RGB;
        else if (text_pix[8])       {r, g, b} = P3_TEXT_RGB;
        else if (text_pix[9])       {r, g, b} = P4_TEXT_RGB;
        else {r, g, b} = BLACK_RGB;
    end

endmodule