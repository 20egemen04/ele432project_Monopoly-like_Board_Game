// board_boxes_dynamic.sv

module board_boxes_dynamic #(
    parameter BLACK_RGB = 24'h000000,
    parameter TILE_P1_RGB = 24'hFF9F9F,
    parameter TILE_P2_RGB = 24'h9FFF9F,
    parameter TILE_P3_RGB = 24'h9F9FFF,
    parameter TILE_P4_RGB = 24'hFFFF87,
    parameter TILE_BORDER_RGB = 24'h010101,
    parameter VENDING_RGB = 24'hFF00FF,
    parameter VENDING_BORDER_RGB = 24'h010101,

    parameter TILE_WIDTH = 10'd50,
    parameter VENDING_WIDTH = 10'd16,
    parameter VENDING_HEIGHT = 10'd13,

    parameter TILE_0_8_TOP = 10'd415,
    parameter TILE_0_8_BOT = 10'd480,
    parameter TILE_8_16_LEFT = 10'd0,
    parameter TILE_8_16_RIGHT = 10'd65,
    parameter TILE_16_24_TOP = 10'd0,
    parameter TILE_16_24_BOT = 10'd65,
    parameter TILE_24_32_LEFT = 10'd415,
    parameter TILE_24_32_RIGHT = 10'd480,

    parameter TILE_1_AND_23_LEFT = 10'd365,
    parameter TILE_2_AND_22_LEFT = 10'd315,
    parameter TILE_3_AND_21_LEFT = 10'd265,
    parameter TILE_4_AND_20_LEFT = 10'd215,
    parameter TILE_5_AND_19_LEFT = 10'd165,
    parameter TILE_6_AND_18_LEFT = 10'd115,
    parameter TILE_7_AND_17_LEFT = 10'd65,
    parameter TILE_9_AND_31_TOP = 10'd365,
    parameter TILE_10_AND_30_TOP = 10'd315,
    parameter TILE_11_AND_29_TOP = 10'd265,
    parameter TILE_12_AND_28_TOP = 10'd215,
    parameter TILE_13_AND_27_TOP = 10'd165,
    parameter TILE_14_AND_26_TOP = 10'd115,
    parameter TILE_15_AND_25_TOP = 10'd65,

    parameter VENDING_0_8_TOP = 10'd415,
    parameter VENDING_8_16_LEFT = 10'd52,
    parameter VENDING_16_24_TOP = 10'd52,
    parameter VENDING_24_32_LEFT = 10'd415,

    parameter DICE_0_LEFT = 10'd506,
    parameter DICE_0_TOP = 10'd65,
    parameter DICE_1_LEFT = 10'd564,
    parameter DICE_1_TOP = 10'd65
) (
    input  logic [9:0]  x, y,
    input  logic [3:0]  pawn_enabled,           // which pawns are enabled (for tile coloring)
    input  logic [19:0] pawn_tile,              // 5-bit tile number (0-31)
    input  logic [3:0]  pawn_selected,          // whether this pawn is currently selected
    input  logic [3:0]  pawn_in_makeup,         // whether this pawn is in the makeup area
    input  logic [2:0]  tile_ownership [31:0],  // bit-2 is enable signal, bits 0-1 are player IDs
    input  logic [5:0]  dice_info,              // info for one dice 3 bits
    input  logic [1:0]  vending_machine [31:0], // number of vending machines (0-3) on a tile
    output logic [7:0]  r, g, b
);

    // Internal signals for pawn drawing
    logic [23:0] pawn_1_rgb, pawn_2_rgb, pawn_3_rgb, pawn_4_rgb;

    // Draw pawns
    draw_pawn draw_pawn_1 (
        .x(x), .y(y),
        .pawn_id(2'b00), // Pawn 1
        .pawn_enabled(pawn_enabled[0]), // Pawn 1 enabled
        .pawn_tile(pawn_tile[4:0]), // Pawn 1s tile
        .pawn_selected(pawn_selected[0]), // Pawn 1 selected
        .pawn_in_makeup(pawn_in_makeup[0]), // Pawn 1 in makeup
        .pawn_sprite_mode(1'b1), // Enable sprite if in makeup for testing
        .r(pawn_1_rgb[23:16]), .g(pawn_1_rgb[15:8]), .b(pawn_1_rgb[7:0])
    );

    draw_pawn draw_pawn_2 (
        .x(x), .y(y),
        .pawn_id(2'b01), // Pawn 2
        .pawn_enabled(pawn_enabled[1]), // Pawn 2 enabled
        .pawn_tile(pawn_tile[9:5]), // Pawn 2s tile
        .pawn_selected(pawn_selected[1]), // Pawn 2 selected
        .pawn_in_makeup(pawn_in_makeup[1]), // Pawn 2 in makeup
        .pawn_sprite_mode(1'b1), // Enable sprite if in makeup for testing
        .r(pawn_2_rgb[23:16]), .g(pawn_2_rgb[15:8]), .b(pawn_2_rgb[7:0])
    );

    draw_pawn draw_pawn_3 (
        .x(x), .y(y),
        .pawn_id(2'b10), // Pawn 3
        .pawn_enabled(pawn_enabled[2]), // Pawn 3 enabled
        .pawn_tile(pawn_tile[14:10]), // Pawn 3s tile
        .pawn_selected(pawn_selected[2]), // Pawn 3 selected
        .pawn_in_makeup(pawn_in_makeup[2]), // Pawn 3 in makeup
        .pawn_sprite_mode(1'b1), // Enable sprite if in makeup for testing
        .r(pawn_3_rgb[23:16]), .g(pawn_3_rgb[15:8]), .b(pawn_3_rgb[7:0])
    );

    draw_pawn draw_pawn_4( //sprite mode off for testing
        .x(x), .y(y),
        .pawn_id(2'b11), // Pawn 4
        .pawn_enabled(pawn_enabled[3]), // Pawn 4 enabled
        .pawn_tile(pawn_tile[19:15]), // Pawn 4s tile
        .pawn_selected(pawn_selected[3]), // Pawn 4 selected
        .pawn_in_makeup(pawn_in_makeup[3]), // Pawn 4 in makeup
        .pawn_sprite_mode(1'b1), // Enable sprite if in makeup for testing
        .r(pawn_4_rgb[23:16]), .g(pawn_4_rgb[15:8]), .b(pawn_4_rgb[7:0])
    );



    // Internal signals for tile ownership drawing
    logic [31:0] in_tile, on_tile_border;
    logic [23:0] tile_rgb;

    // Fix the pin floating
    always_comb begin
        in_tile[0] = 1'b0;
        in_tile[4] = 1'b0;
        in_tile[8] = 1'b0;
        in_tile[12] = 1'b0;
        in_tile[16] = 1'b0;
        in_tile[20] = 1'b0;
        in_tile[24] = 1'b0;
        in_tile[28] = 1'b0;
        on_tile_border[0] = 1'b0;
        on_tile_border[4] = 1'b0;
        on_tile_border[8] = 1'b0;
        on_tile_border[12] = 1'b0;
        on_tile_border[16] = 1'b0;
        on_tile_border[20] = 1'b0;
        on_tile_border[24] = 1'b0;
        on_tile_border[28] = 1'b0;
    end

    // Draw tile ownerships
    rectgen tile_1 (
        .x(x), .y(y),
        .left(TILE_1_AND_23_LEFT), .top(TILE_0_8_TOP), .right(TILE_1_AND_23_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[1]), .onborder(on_tile_border[1])
    );

    rectgen tile_2 (
        .x(x), .y(y),
        .left(TILE_2_AND_22_LEFT), .top(TILE_0_8_TOP), .right(TILE_2_AND_22_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[2]), .onborder(on_tile_border[2])
    );

    rectgen tile_3 (
        .x(x), .y(y),
        .left(TILE_3_AND_21_LEFT), .top(TILE_0_8_TOP), .right(TILE_3_AND_21_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[3]), .onborder(on_tile_border[3])
    );

    rectgen tile_5 (
        .x(x), .y(y),
        .left(TILE_5_AND_19_LEFT), .top(TILE_0_8_TOP), .right(TILE_5_AND_19_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[5]), .onborder(on_tile_border[5])
    );
  
    rectgen tile_6 (
        .x(x), .y(y),
        .left(TILE_6_AND_18_LEFT), .top(TILE_0_8_TOP), .right(TILE_6_AND_18_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[6]), .onborder(on_tile_border[6])
    );
  
    rectgen tile_7 (
        .x(x), .y(y),
        .left(TILE_7_AND_17_LEFT), .top(TILE_0_8_TOP), .right(TILE_7_AND_17_LEFT + TILE_WIDTH), .bot(TILE_0_8_BOT),
        .inrect(in_tile[7]), .onborder(on_tile_border[7])
    );

    rectgen tile_9 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_9_AND_31_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_9_AND_31_TOP + TILE_WIDTH),
        .inrect(in_tile[9]), .onborder(on_tile_border[9])
    );

    rectgen tile_10 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_10_AND_30_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_10_AND_30_TOP + TILE_WIDTH),
        .inrect(in_tile[10]), .onborder(on_tile_border[10])
    );

    rectgen tile_11 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_11_AND_29_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_11_AND_29_TOP + TILE_WIDTH),
        .inrect(in_tile[11]), .onborder(on_tile_border[11])
    );

    rectgen tile_13 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_13_AND_27_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_13_AND_27_TOP + TILE_WIDTH),
        .inrect(in_tile[13]), .onborder(on_tile_border[13])
    );
  
    rectgen tile_14 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_14_AND_26_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_14_AND_26_TOP + TILE_WIDTH),
        .inrect(in_tile[14]), .onborder(on_tile_border[14])
    );
  
    rectgen tile_15 (
        .x(x), .y(y),
        .left(TILE_8_16_LEFT), .top(TILE_15_AND_25_TOP), .right(TILE_8_16_RIGHT), .bot(TILE_15_AND_25_TOP + TILE_WIDTH),
        .inrect(in_tile[15]), .onborder(on_tile_border[15])
    );

    rectgen tile_17 (
        .x(x), .y(y),
        .left(TILE_7_AND_17_LEFT), .top(TILE_16_24_TOP), .right(TILE_7_AND_17_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[17]), .onborder(on_tile_border[17])
    );

    rectgen tile_18 (
        .x(x), .y(y),
        .left(TILE_6_AND_18_LEFT), .top(TILE_16_24_TOP), .right(TILE_6_AND_18_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[18]), .onborder(on_tile_border[18])
    );

    rectgen tile_19 (
        .x(x), .y(y),
        .left(TILE_5_AND_19_LEFT), .top(TILE_16_24_TOP), .right(TILE_5_AND_19_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[19]), .onborder(on_tile_border[19])
    );

    rectgen tile_21 (
        .x(x), .y(y),
        .left(TILE_3_AND_21_LEFT), .top(TILE_16_24_TOP), .right(TILE_3_AND_21_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[21]), .onborder(on_tile_border[21])
    );

    rectgen tile_22 (
        .x(x), .y(y),
        .left(TILE_2_AND_22_LEFT), .top(TILE_16_24_TOP), .right(TILE_2_AND_22_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[22]), .onborder(on_tile_border[22])
    );

    rectgen tile_23 (
        .x(x), .y(y),
        .left(TILE_1_AND_23_LEFT), .top(TILE_16_24_TOP), .right(TILE_1_AND_23_LEFT + TILE_WIDTH), .bot(TILE_16_24_BOT),
        .inrect(in_tile[23]), .onborder(on_tile_border[23])
    );

    rectgen tile_25 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_15_AND_25_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_15_AND_25_TOP + TILE_WIDTH),
        .inrect(in_tile[25]), .onborder(on_tile_border[25])
    );

    rectgen tile_26 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_14_AND_26_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_14_AND_26_TOP + TILE_WIDTH),
        .inrect(in_tile[26]), .onborder(on_tile_border[26])
    );

    rectgen tile_27 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_13_AND_27_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_13_AND_27_TOP + TILE_WIDTH),
        .inrect(in_tile[27]), .onborder(on_tile_border[27])
    );

    rectgen tile_29 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_11_AND_29_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_11_AND_29_TOP + TILE_WIDTH),
        .inrect(in_tile[29]), .onborder(on_tile_border[29])
    );

    rectgen tile_30 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_10_AND_30_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_10_AND_30_TOP + TILE_WIDTH),
        .inrect(in_tile[30]), .onborder(on_tile_border[30])
    );

    rectgen tile_31 (
        .x(x), .y(y),
        .left(TILE_24_32_LEFT), .top(TILE_9_AND_31_TOP), .right(TILE_24_32_RIGHT), .bot(TILE_9_AND_31_TOP + TILE_WIDTH),
        .inrect(in_tile[31]), .onborder(on_tile_border[31])
    );



    // Internal Signals for dice. Add as an input { input logic [5:0] dice_info, }
	logic [23:0] dice_0_rgb, dice_1_rgb;

    // Draw dice
	draw_dice draw_dice_0 (
		.x(x), .y(y),
		.dice_x(DICE_0_LEFT), .dice_y(DICE_0_TOP),
		.dice_info(dice_info[5:3]),
		.r(dice_0_rgb[23:16]), .g(dice_0_rgb[15:8]), .b(dice_0_rgb[7:0])
	);
	
	draw_dice draw_dice_1 (
		.x(x), .y(y),
		.dice_x(DICE_1_LEFT), .dice_y(DICE_1_TOP),
		.dice_info(dice_info[2:0]),
		.r(dice_1_rgb[23:16]), .g(dice_1_rgb[15:8]), .b(dice_1_rgb[7:0])
	);



    // Internal Signals for Vending Machines
    logic [31:0] in_vending, on_vending_border;
    logic [23:0] vending_rgb;

    // Fix the pin floating
    always_comb begin
        in_vending[0] = 1'b0;
        in_vending[4] = 1'b0;
        in_vending[8] = 1'b0;
        in_vending[12] = 1'b0;
        in_vending[16] = 1'b0;
        in_vending[20] = 1'b0;
        in_vending[24] = 1'b0;
        in_vending[28] = 1'b0;
        on_vending_border[0] = 1'b0;
        on_vending_border[4] = 1'b0;
        on_vending_border[8] = 1'b0;
        on_vending_border[12] = 1'b0;
        on_vending_border[16] = 1'b0;
        on_vending_border[20] = 1'b0;
        on_vending_border[24] = 1'b0;
        on_vending_border[28] = 1'b0;
    end

    // Draw vending machines
    rectgen vending_1 (
        .x(x), .y(y),
        .left(TILE_1_AND_23_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_1_AND_23_LEFT + 10'(vending_machine[1] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[1]), .onborder(on_vending_border[1])
    );

    rectgen vending_2 (
        .x(x), .y(y),
        .left(TILE_2_AND_22_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_2_AND_22_LEFT + 10'(vending_machine[2] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[2]), .onborder(on_vending_border[2])
    );

    rectgen vending_3 (
        .x(x), .y(y),
        .left(TILE_3_AND_21_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_3_AND_21_LEFT + 10'(vending_machine[3] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[3]), .onborder(on_vending_border[3])
    );

    rectgen vending_5 (
        .x(x), .y(y),
        .left(TILE_5_AND_19_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_5_AND_19_LEFT + 10'(vending_machine[5] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[5]), .onborder(on_vending_border[5])
    );
    
    rectgen vending_6 (
        .x(x), .y(y),
        .left(TILE_6_AND_18_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_6_AND_18_LEFT + 10'(vending_machine[6] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[6]), .onborder(on_vending_border[6])
    );

    rectgen vending_7 (
        .x(x), .y(y),
        .left(TILE_7_AND_17_LEFT + 10'd1), .top(VENDING_0_8_TOP),
        .right(TILE_7_AND_17_LEFT + 10'(vending_machine[7] * VENDING_WIDTH) + 10'd1), .bot(VENDING_0_8_TOP + VENDING_HEIGHT),
        .inrect(in_vending[7]), .onborder(on_vending_border[7])
    );

    rectgen vending_9 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_9_AND_31_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_9_AND_31_TOP + 10'(vending_machine[9] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[9]), .onborder(on_vending_border[9])
    );

    rectgen vending_10 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_10_AND_30_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_10_AND_30_TOP + 10'(vending_machine[10] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[10]), .onborder(on_vending_border[10])
    );

    rectgen vending_11 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_11_AND_29_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_11_AND_29_TOP + 10'(vending_machine[11] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[11]), .onborder(on_vending_border[11])
    );

    rectgen vending_13 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_13_AND_27_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_13_AND_27_TOP + 10'(vending_machine[13] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[13]), .onborder(on_vending_border[13])
    );

    rectgen vending_14 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_14_AND_26_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_14_AND_26_TOP + 10'(vending_machine[14] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[14]), .onborder(on_vending_border[14])
    );

    rectgen vending_15 (
        .x(x), .y(y),
        .left(VENDING_8_16_LEFT), .top(TILE_15_AND_25_TOP + 10'd1),
        .right(VENDING_8_16_LEFT + VENDING_HEIGHT), .bot(TILE_15_AND_25_TOP + 10'(vending_machine[15] * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[15]), .onborder(on_vending_border[15])
    );

    rectgen vending_17 (
        .x(x), .y(y),
        .left(TILE_7_AND_17_LEFT + 10'((10'd3 - vending_machine[17]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_7_AND_17_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[17]), .onborder(on_vending_border[17])
    );

    rectgen vending_18 (
        .x(x), .y(y),
        .left(TILE_6_AND_18_LEFT + 10'((10'd3 - vending_machine[18]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_6_AND_18_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[18]), .onborder(on_vending_border[18])
    );

    rectgen vending_19 (
        .x(x), .y(y),
        .left(TILE_5_AND_19_LEFT + 10'((10'd3 - vending_machine[19]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_5_AND_19_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[19]), .onborder(on_vending_border[19])
    );

    rectgen vending_21 (
        .x(x), .y(y),
        .left(TILE_3_AND_21_LEFT + 10'((10'd3 - vending_machine[21]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_3_AND_21_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[21]), .onborder(on_vending_border[21])
    );

    rectgen vending_22 (
        .x(x), .y(y),
        .left(TILE_2_AND_22_LEFT + 10'((10'd3 - vending_machine[22]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_2_AND_22_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[22]), .onborder(on_vending_border[22])
    );

    rectgen vending_23 (
        .x(x), .y(y),
        .left(TILE_1_AND_23_LEFT + 10'((10'd3 - vending_machine[23]) * VENDING_WIDTH) + 10'd1), .top(VENDING_16_24_TOP),
        .right(TILE_1_AND_23_LEFT + 10'(10'd3 * VENDING_WIDTH) + 10'd1), .bot(VENDING_16_24_TOP + VENDING_HEIGHT),
        .inrect(in_vending[23]), .onborder(on_vending_border[23])
    );

    rectgen vending_25 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_15_AND_25_TOP + 10'((10'd3 - vending_machine[25]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_15_AND_25_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[25]), .onborder(on_vending_border[25])
    );

    rectgen vending_26 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_14_AND_26_TOP + 10'((10'd3 - vending_machine[26]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_14_AND_26_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[26]), .onborder(on_vending_border[26])
    );

    rectgen vending_27 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_13_AND_27_TOP + 10'((10'd3 - vending_machine[27]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_13_AND_27_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[27]), .onborder(on_vending_border[27])
    );

    rectgen vending_29 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_11_AND_29_TOP + 10'((10'd3 - vending_machine[29]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_11_AND_29_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[29]), .onborder(on_vending_border[29])
    );

    rectgen vending_30 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_10_AND_30_TOP + 10'((10'd3 - vending_machine[30]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_10_AND_30_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[30]), .onborder(on_vending_border[30])
    );

    rectgen vending_31 (
        .x(x), .y(y),
        .left(VENDING_24_32_LEFT), .top(TILE_9_AND_31_TOP + 10'((10'd3 - vending_machine[31]) * VENDING_WIDTH) + 10'd1),
        .right(VENDING_24_32_LEFT + VENDING_HEIGHT), .bot(TILE_9_AND_31_TOP + 10'(10'd3 * VENDING_WIDTH) + 10'd1),
        .inrect(in_vending[31]), .onborder(on_vending_border[31])
    );



    // Final pixel color logic for dynamic boxes
    always_comb begin
        // Default to black for transparency later
        {r, g, b} = BLACK_RGB;
        tile_rgb = BLACK_RGB;
        vending_rgb = BLACK_RGB;

        // Tile ownership
        for (int i = 31; i >= 0; i--) begin
            // If there is at least 1 vending machine, assign the colors
            if (vending_machine[i] && in_vending[i]) begin
                if (on_vending_border[i]) begin
                    vending_rgb = VENDING_BORDER_RGB;
                end else begin
                    vending_rgb = VENDING_RGB;
                end
            end
            // tile_ownership[i][2] is the enable bit
            else if (tile_ownership[i][2] && in_tile[i]) begin
                if (on_tile_border[i]) begin
                    tile_rgb = TILE_BORDER_RGB;
                end else begin
                    case (tile_ownership[i][1:0])
                        2'b00: tile_rgb = TILE_P1_RGB;
                        2'b01: tile_rgb = TILE_P2_RGB;
                        2'b10: tile_rgb = TILE_P3_RGB;
                        2'b11: tile_rgb = TILE_P4_RGB;
                    endcase
                end
            end
        end

        // Pawns
        if (pawn_1_rgb != BLACK_RGB) {r, g, b} = pawn_1_rgb;
        else if (pawn_2_rgb != BLACK_RGB) {r, g, b} = pawn_2_rgb;
        else if (pawn_3_rgb != BLACK_RGB) {r, g, b} = pawn_3_rgb;
        else if (pawn_4_rgb != BLACK_RGB) {r, g, b} = pawn_4_rgb;
        else if (dice_0_rgb != BLACK_RGB) {r, g, b} = dice_0_rgb;
        else if (dice_1_rgb != BLACK_RGB) {r, g, b} = dice_1_rgb;
        else if (vending_rgb != BLACK_RGB) {r, g, b} = vending_rgb;
        else if (tile_rgb != BLACK_RGB) {r, g, b} = tile_rgb;       // keep at bottom

    end

endmodule