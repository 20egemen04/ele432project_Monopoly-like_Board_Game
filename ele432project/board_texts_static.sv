// board_texts_static.sv

module board_texts_static #(
    parameter BLACK_RGB = 24'h000000,
    parameter BLACK_TEXT_RGB = 24'h010101, // Slightly off-black to prevent text from being completely invisible when overlapping with box borders
    parameter WHITE_TEXT_RGB = 24'hFFFFFF,
    parameter PROJECT_NAME_RGB = 24'h9F0000
)(
    input logic [9:0] x, y,
    output logic [7:0] r, g, b
);

    // Internal signals and Font Data
    logic [10:0] master_rom_addr;
    logic [7:0] master_rom_data;

    logic [10:0] text_addr [102:0];
    logic text_pix [102:0];
    logic text_box [102:0];

    always_comb begin
        // Only give the ROM address to the module that the VGA beam is currently inside
        master_rom_addr = 9'd0; // Default value (covers the 'else' case)
        
        // Loop from highest index down to 0
        // text_box[0] will "win" because it's the last assignment made
        for (int i = 102; i >= 0; i--) begin
            if (text_box[i]) begin
                master_rom_addr = text_addr[i];
            end
        end
    end

    font_rom fontROM_static(
        .font_addr(master_rom_addr),
        .font_data_out(master_rom_data)
    );



    // Text for the board tiles
    text_display #(.MAX_CHARS(1'd1)) tile_0_text_0
    (
        .x(x), .y(y),
        .start_x(10'd443), .start_y(10'd435), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("0"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[0]), 
        .pixel_on(text_pix[0]), .in_box(text_box[0])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_0_text_1
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("START"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[1]), 
        .pixel_on(text_pix[1]), .in_box(text_box[1])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_0_text_2
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd451), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("$2000"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[2]), 
        .pixel_on(text_pix[2]), .in_box(text_box[2])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_1_text_0
    (
        .x(x), .y(y),
        .start_x(10'd386), .start_y(10'd435), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("1"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[3]), 
        .pixel_on(text_pix[3]), .in_box(text_box[3])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_1_text_1
    (
        .x(x), .y(y),
        .start_x(10'd382), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E1"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[4]), 
        .pixel_on(text_pix[4]), .in_box(text_box[4])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_2_text_0
    (
        .x(x), .y(y),
        .start_x(10'd336), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("2"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[5]), 
        .pixel_on(text_pix[5]), .in_box(text_box[5])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_2_text_1
    (
        .x(x), .y(y),
        .start_x(10'd332), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E2"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[6]), 
        .pixel_on(text_pix[6]), .in_box(text_box[6])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_3_text_0
    (
        .x(x), .y(y),
        .start_x(10'd286), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("3"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[7]), 
        .pixel_on(text_pix[7]), .in_box(text_box[7])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_3_text_1
    (
        .x(x), .y(y),
        .start_x(10'd282), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E3"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[8]), 
        .pixel_on(text_pix[8]), .in_box(text_box[8])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_4_text_0
    (
        .x(x), .y(y),
        .start_x(10'd236), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("4"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[9]), 
        .pixel_on(text_pix[9]), .in_box(text_box[9])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_4_text_1
    (
        .x(x), .y(y),
        .start_x(10'd216), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CHANCE"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[10]), 
        .pixel_on(text_pix[10]), .in_box(text_box[10])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_5_text_0
    (
        .x(x), .y(y),
        .start_x(10'd186), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("5"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[11]), 
        .pixel_on(text_pix[11]), .in_box(text_box[11])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_5_text_1
    (
        .x(x), .y(y),
        .start_x(10'd182), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E4"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[12]), 
        .pixel_on(text_pix[12]), .in_box(text_box[12])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_6_text_0
    (
        .x(x), .y(y),
        .start_x(10'd136), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("6"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[13]), 
        .pixel_on(text_pix[13]), .in_box(text_box[13])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_6_text_1
    (
        .x(x), .y(y),
        .start_x(10'd132), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[14]), 
        .pixel_on(text_pix[14]), .in_box(text_box[14])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_7_text_0
    (
        .x(x), .y(y),
        .start_x(10'd86), .start_y(10'd435),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("7"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[15]), 
        .pixel_on(text_pix[15]), .in_box(text_box[15])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_7_text_1
    (
        .x(x), .y(y),
        .start_x(10'd82), .start_y(10'd443), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E6"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[16]), 
        .pixel_on(text_pix[16]), .in_box(text_box[16])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_8_text_0
    (
        .x(x), .y(y),
        .start_x(10'd36), .start_y(10'd424), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("8"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[17]), 
        .pixel_on(text_pix[17]), .in_box(text_box[17])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_8_text_1
    (
        .x(x), .y(y),
        .start_x(10'd16), .start_y(10'd432),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("MAKEUP"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[18]), 
        .pixel_on(text_pix[18]), .in_box(text_box[18])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_8_text_2
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd440),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("EXAM"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[19]), 
        .pixel_on(text_pix[19]), .in_box(text_box[19])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_8_text_3
    (
        .x(x), .y(y),
        .start_x(10'd16), .start_y(10'd468),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("FINALS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[20]), 
        .pixel_on(text_pix[20]), .in_box(text_box[20])
    );

    text_display #(.MAX_CHARS(1'd1)) tile_9_text_0
    (
        .x(x), .y(y),
        .start_x(10'd28), .start_y(10'd378), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("9"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[21]), 
        .pixel_on(text_pix[21]), .in_box(text_box[21])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_9_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd386), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CNTRL"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[22]), 
        .pixel_on(text_pix[22]), .in_box(text_box[22])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_9_text_2
    (
        .x(x), .y(y),
        .start_x(10'd20), .start_y(10'd394), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[23]), 
        .pixel_on(text_pix[23]), .in_box(text_box[23])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_10_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd328), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("10"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[24]), 
        .pixel_on(text_pix[24]), .in_box(text_box[24])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_10_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd336), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("POWER"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[25]), 
        .pixel_on(text_pix[25]), .in_box(text_box[25])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_10_text_2
    (
        .x(x), .y(y),
        .start_x(10'd20), .start_y(10'd344), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[26]), 
        .pixel_on(text_pix[26]), .in_box(text_box[26])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_11_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd278), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("11"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[27]), 
        .pixel_on(text_pix[27]), .in_box(text_box[27])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_11_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd286), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("MICRO"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[28]), 
        .pixel_on(text_pix[28]), .in_box(text_box[28])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_11_text_2
    (
        .x(x), .y(y),
        .start_x(10'd20), .start_y(10'd294), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[29]), 
        .pixel_on(text_pix[29]), .in_box(text_box[29])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_12_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd228), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("12"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[30]), 
        .pixel_on(text_pix[30]), .in_box(text_box[30])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_12_text_1
    (
        .x(x), .y(y),
        .start_x(10'd20), .start_y(10'd236), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("BUS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[31]), 
        .pixel_on(text_pix[31]), .in_box(text_box[31])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_12_text_2
    (
        .x(x), .y(y),
        .start_x(10'd16), .start_y(10'd244), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("STOP"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[32]), 
        .pixel_on(text_pix[32]), .in_box(text_box[32])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_13_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd178), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("13"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[33]), 
        .pixel_on(text_pix[33]), .in_box(text_box[33])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_13_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd186), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CMPTR"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[34]), 
        .pixel_on(text_pix[34]), .in_box(text_box[34])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_13_text_2
    (
        .x(x), .y(y),
        .start_x(10'd16), .start_y(10'd194), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("ROOM"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[35]), 
        .pixel_on(text_pix[35]), .in_box(text_box[35])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_14_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd128), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("14"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[36]), 
        .pixel_on(text_pix[36]), .in_box(text_box[36])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_14_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd136), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("STUDY"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[37]), 
        .pixel_on(text_pix[37]), .in_box(text_box[37])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_14_text_2
    (
        .x(x), .y(y),
        .start_x(10'd16), .start_y(10'd144), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("ROOM"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[38]), 
        .pixel_on(text_pix[38]), .in_box(text_box[38])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_15_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd78), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("15"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[39]), 
        .pixel_on(text_pix[39]), .in_box(text_box[39])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_15_text_1
    (
        .x(x), .y(y),
        .start_x(10'd12), .start_y(10'd86), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("PRJCT"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[40]), 
        .pixel_on(text_pix[40]), .in_box(text_box[40])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_15_text_2
    (
        .x(x), .y(y),
        .start_x(10'd20), .start_y(10'd94), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[41]), 
        .pixel_on(text_pix[41]), .in_box(text_box[41])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_16_text_0
    (
        .x(x), .y(y),
        .start_x(10'd24), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("16"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[42]), 
        .pixel_on(text_pix[42]), .in_box(text_box[42])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_16_text_1
    (
        .x(x), .y(y),
        .start_x(10'd8), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SILENT"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[43]), 
        .pixel_on(text_pix[43]), .in_box(text_box[43])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_16_text_2
    (
        .x(x), .y(y),
        .start_x(10'd8), .start_y(10'd36), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("GARDEN"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[44]), 
        .pixel_on(text_pix[44]), .in_box(text_box[44])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_17_text_0
    (
        .x(x), .y(y),
        .start_x(10'd82), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("17"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[45]), 
        .pixel_on(text_pix[45]), .in_box(text_box[45])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_17_text_1
    (
        .x(x), .y(y),
        .start_x(10'd82), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E7"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[46]), 
        .pixel_on(text_pix[46]), .in_box(text_box[46])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_18_text_0
    (
        .x(x), .y(y),
        .start_x(10'd132), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("18"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[47]), 
        .pixel_on(text_pix[47]), .in_box(text_box[47])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_18_text_1
    (
        .x(x), .y(y),
        .start_x(10'd132), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E8"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[48]), 
        .pixel_on(text_pix[48]), .in_box(text_box[48])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_19_text_0
    (
        .x(x), .y(y),
        .start_x(10'd182), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("19"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[49]), 
        .pixel_on(text_pix[49]), .in_box(text_box[49])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_19_text_1
    (
        .x(x), .y(y),
        .start_x(10'd182), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("E9"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[50]), 
        .pixel_on(text_pix[50]), .in_box(text_box[50])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_20_text_0
    (
        .x(x), .y(y),
        .start_x(10'd232), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("20"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[51]), 
        .pixel_on(text_pix[51]), .in_box(text_box[51])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_20_text_1
    (
        .x(x), .y(y),
        .start_x(10'd216), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CHANCE"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[52]), 
        .pixel_on(text_pix[52]), .in_box(text_box[52])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_21_text_0
    (
        .x(x), .y(y),
        .start_x(10'd282), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("21"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[53]), 
        .pixel_on(text_pix[53]), .in_box(text_box[53])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_21_text_1
    (
        .x(x), .y(y),
        .start_x(10'd266), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("ELECTR"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[54]), 
        .pixel_on(text_pix[54]), .in_box(text_box[54])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_21_text_2
    (
        .x(x), .y(y),
        .start_x(10'd278), .start_y(10'd36),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[55]), 
        .pixel_on(text_pix[55]), .in_box(text_box[55])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_22_text_0
    (
        .x(x), .y(y),
        .start_x(10'd332), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("22"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[56]), 
        .pixel_on(text_pix[56]), .in_box(text_box[56])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_22_text_1
    (
        .x(x), .y(y),
        .start_x(10'd316), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SIMLAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[57]), 
        .pixel_on(text_pix[57]), .in_box(text_box[57])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_23_text_0
    (
        .x(x), .y(y),
        .start_x(10'd382), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("23"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[58]), 
        .pixel_on(text_pix[58]), .in_box(text_box[58])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_23_text_1
    (
        .x(x), .y(y),
        .start_x(10'd366), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("MACHIN"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[59]), 
        .pixel_on(text_pix[59]), .in_box(text_box[59])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_23_text_2
    (
        .x(x), .y(y),
        .start_x(10'd378), .start_y(10'd36), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LAB"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[60]), 
        .pixel_on(text_pix[60]), .in_box(text_box[60])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_24_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd20), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("24"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[61]), 
        .pixel_on(text_pix[61]), .in_box(text_box[61])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_24_text_1
    (
        .x(x), .y(y),
        .start_x(10'd423), .start_y(10'd28), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("FAILED"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[62]), 
        .pixel_on(text_pix[62]), .in_box(text_box[62])
    );

    text_display #(.MAX_CHARS(3'd6)) tile_24_text_2
    (
        .x(x), .y(y),
        .start_x(10'd423), .start_y(10'd36), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("FINALS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[63]), 
        .pixel_on(text_pix[63]), .in_box(text_box[63])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_25_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd78), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("25"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[64]), 
        .pixel_on(text_pix[64]), .in_box(text_box[64])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_25_text_1
    (
        .x(x), .y(y),
        .start_x(10'd435), .start_y(10'd86),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("EEE"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[65]), 
        .pixel_on(text_pix[65]), .in_box(text_box[65])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_25_text_2
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd94),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("GRASS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[66]), 
        .pixel_on(text_pix[66]), .in_box(text_box[66])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_26_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd128), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("26"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[67]), 
        .pixel_on(text_pix[67]), .in_box(text_box[67])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_26_text_1
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd136), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("LIBR."),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[68]), 
        .pixel_on(text_pix[68]), .in_box(text_box[68])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_27_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd178), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("27"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[69]), 
        .pixel_on(text_pix[69]), .in_box(text_box[69])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_27_text_1
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd186), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("STAD."),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[70]), 
        .pixel_on(text_pix[70]), .in_box(text_box[70])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_28_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd228), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("28"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[71]), 
        .pixel_on(text_pix[71]), .in_box(text_box[71])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_28_text_1
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd236), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("METRO"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[72]), 
        .pixel_on(text_pix[72]), .in_box(text_box[72])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_28_text_2
    (
        .x(x), .y(y),
        .start_x(10'd431), .start_y(10'd244), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("STOP"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[73]), 
        .pixel_on(text_pix[73]), .in_box(text_box[73])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_29_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd278), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("29"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[74]), 
        .pixel_on(text_pix[74]), .in_box(text_box[74])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_29_text_1
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd286), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CAFE-"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[75]), 
        .pixel_on(text_pix[75]), .in_box(text_box[75])
    );

    text_display #(.MAX_CHARS(3'd5)) tile_29_text_2
    (
        .x(x), .y(y),
        .start_x(10'd427), .start_y(10'd294), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("TERIA"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[76]), 
        .pixel_on(text_pix[76]), .in_box(text_box[76])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_30_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd328), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("30"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[77]), 
        .pixel_on(text_pix[77]), .in_box(text_box[77])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_30_text_1
    (
        .x(x), .y(y),
        .start_x(10'd431), .start_y(10'd336), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CITY"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[78]), 
        .pixel_on(text_pix[78]), .in_box(text_box[78])
    );

    text_display #(.MAX_CHARS(3'd4)) tile_30_text_2
    (
        .x(x), .y(y),
        .start_x(10'd431), .start_y(10'd344), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("MALL"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[79]), 
        .pixel_on(text_pix[79]), .in_box(text_box[79])
    );

    text_display #(.MAX_CHARS(2'd2)) tile_31_text_0
    (
        .x(x), .y(y),
        .start_x(10'd439), .start_y(10'd378), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("31"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[80]), 
        .pixel_on(text_pix[80]), .in_box(text_box[80])
    );

    text_display #(.MAX_CHARS(2'd3)) tile_31_text_1
    (
        .x(x), .y(y),
        .start_x(10'd435), .start_y(10'd386),
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("BAM"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[81]), 
        .pixel_on(text_pix[81]), .in_box(text_box[81])
    );



    // Player info box
    text_display #(.MAX_CHARS(5'd17)) player_info_line_names
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd13), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("PLAYER     MONEY "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[82]), 
        .pixel_on(text_pix[82]), .in_box(text_box[82])
    );



    // Input info text
    text_display #(.MAX_CHARS(5'd10)) input_info_line_0
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd216), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("INPUT INFO"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[83]), 
        .pixel_on(text_pix[83]), .in_box(text_box[83])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_1
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd224), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("-----------------"),
        .font_row(master_rom_data),
        .font_rom_addr(text_addr[84]), 
        .pixel_on(text_pix[84]), .in_box(text_box[84])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_2
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd240), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("KEY0  : CONFIRM  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[85]), 
        .pixel_on(text_pix[85]), .in_box(text_box[85])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_3
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd248), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("KEY1  : DENY     "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[86]), 
        .pixel_on(text_pix[86]), .in_box(text_box[86])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_4
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd256), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("KEY2  : ROLL DICE"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[87]), 
        .pixel_on(text_pix[87]), .in_box(text_box[87])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_5
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd264), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("KEY3  : -EMPTY-  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[88]), 
        .pixel_on(text_pix[88]), .in_box(text_box[88])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_6
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd272), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SW0   : RESET    "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[89]), 
        .pixel_on(text_pix[89]), .in_box(text_box[89])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_7
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd280), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SW1   : -EMPTY-  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[90]), 
        .pixel_on(text_pix[90]), .in_box(text_box[90])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_8
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd288), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SW3-2 : #PLAYER  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[91]), 
        .pixel_on(text_pix[91]), .in_box(text_box[91])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_9
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd296), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SW8-4 : #DEBUG   "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[92]), 
        .pixel_on(text_pix[92]), .in_box(text_box[92])
    );

    text_display #(.MAX_CHARS(5'd17)) input_info_line_10
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd304), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("SW9   : DEBUG    "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[93]), 
        .pixel_on(text_pix[93]), .in_box(text_box[93])
    );



    // Credits
    text_display #(.MAX_CHARS(5'd7)) credits_line_0
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd408), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("CREDITS"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[94]), 
        .pixel_on(text_pix[94]), .in_box(text_box[94])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_1
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd416), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("-----------------"),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[95]), 
        .pixel_on(text_pix[95]), .in_box(text_box[95])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_2
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd432), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("; EGEMEN CELIK   "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[96]), 
        .pixel_on(text_pix[96]), .in_box(text_box[96])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_3
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd440), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("; HAKAN TORE     "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[97]), 
        .pixel_on(text_pix[97]), .in_box(text_box[97])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_4
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd448), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("; ALPEREN SALMAN "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[98]), 
        .pixel_on(text_pix[98]), .in_box(text_box[98])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_5
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd456), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("; M. ENES BICAK  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[99]), 
        .pixel_on(text_pix[99]), .in_box(text_box[99])
    );

    text_display #(.MAX_CHARS(5'd17)) credits_line_6
    (
        .x(x), .y(y),
        .start_x(10'd492), .start_y(10'd464), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("; EMRE K. KAYMAK "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[100]), 
        .pixel_on(text_pix[100]), .in_box(text_box[100])
    );
    


    // Project name
    text_display #(.MAX_CHARS(6'd42)) project_name_line_0
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd230), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("  ELE432 ADVANCED DIGITAL DESIGN PROJECT  "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[101]), 
        .pixel_on(text_pix[101]), .in_box(text_box[101])
    );

    text_display #(.MAX_CHARS(6'd42)) project_name_line_1
    (
        .x(x), .y(y),
        .start_x(10'd72), .start_y(10'd242), 
        .enable_display(1'b1),  // Always ON for the static board
        .text_string("        HUEE : OWNER OF THE CAMPUS        "),
        .font_row(master_rom_data), 
        .font_rom_addr(text_addr[102]), 
        .pixel_on(text_pix[102]), .in_box(text_box[102])
    );



    // Final color output
    always_comb begin
        // Simple priority: if text is on, show white text. Otherwise, show black (transparent).
        if (text_pix[0] || text_pix[1] || text_pix[2]
            || text_pix[9] || text_pix[10] 
            || text_pix[17] || text_pix[18] || text_pix[19] 
            || text_pix[30] || text_pix[31] || text_pix[32]
            || text_pix[42] || text_pix[43] || text_pix[44]
            || text_pix[51] || text_pix[52]
            || text_pix[61] || text_pix[62] || text_pix[63]
            || text_pix[71] || text_pix[72] || text_pix[73]
            || text_pix[82]) begin
            {r, g, b} = WHITE_TEXT_RGB;
        end else if (text_pix[101] || text_pix[102]) begin
            {r, g, b} = PROJECT_NAME_RGB;
        end else if (text_pix) begin
            {r, g, b} = BLACK_TEXT_RGB;
        end else begin
            {r, g, b} = BLACK_RGB;
        end
    end

endmodule