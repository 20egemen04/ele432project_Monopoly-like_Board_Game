//draw_dice.sv

module draw_dice #(
    parameter BLACK_RGB = 24'h000000,
    parameter BLACK_DOT_RGB = 24'h010101,
    parameter RED_DOT_RGB = 24'hFF0000
) (
    input  logic [9:0] x, y,
    input  logic [9:0] dice_x, dice_y,  // top-left corner of the dice box
    input  logic [2:0] dice_info,  // info for one dice 3 bits
    output logic [7:0] r, g, b
);

  // Internal signals
  logic [6:0] in_dot;
  logic [9:0] rel_x, rel_y;
  logic col_L, col_C, col_R;
  logic row_T, row_M, row_B;

  always_comb begin
    rel_x = x - dice_x;
    rel_y = y - dice_y;
  end

  // Dot boundaries
  always_comb begin
    // Columns (4 pixels wide each, exactly spaced)
    col_L = (rel_x >= 10'd9 && rel_x < 10'd13);
    col_C = (rel_x >= 10'd23 && rel_x < 10'd27);
    col_R = (rel_x >= 10'd37 && rel_x < 10'd41);

    // Rows (4 pixels tall each, exactly spaced)
    row_T = (rel_y >= 10'd9 && rel_y < 10'd13);
    row_M = (rel_y >= 10'd23 && rel_y < 10'd27);
    row_B = (rel_y >= 10'd37 && rel_y < 10'd41);
  end

  // Dot locations
  always_comb begin
    in_dot[0] = col_C && row_M;  // Center dot

    in_dot[1] = col_L && row_T;  // Top-Left
    in_dot[2] = col_L && row_M;  // Mid-Left
    in_dot[3] = col_L && row_B;  // Bot-Left

    in_dot[4] = col_R && row_T;  // Top-Right
    in_dot[5] = col_R && row_M;  // Mid-Right
    in_dot[6] = col_R && row_B;  // Bot-Right
  end

  // Color output 
  always_comb begin
    //	initial default: transparent
    {r, g, b} = BLACK_RGB;

    case (dice_info)
      3'd1: if (in_dot[0]) {r, g, b} = RED_DOT_RGB;

      3'd2: if (in_dot[1] || in_dot[6]) {r, g, b} = BLACK_DOT_RGB;

      3'd3: if (in_dot[0] || in_dot[1] || in_dot[6]) {r, g, b} = BLACK_DOT_RGB;

      3'd4: if (in_dot[1] || in_dot[3] || in_dot[4] || in_dot[6]) {r, g, b} = BLACK_DOT_RGB;

      3'd5:
      if (in_dot[0] || in_dot[1] || in_dot[3] || in_dot[4] || in_dot[6]) {r, g, b} = BLACK_DOT_RGB;

      3'd6:
      if (in_dot[1] || in_dot[2] || in_dot[3] || in_dot[4] || in_dot[5] || in_dot[6])
        {r, g, b} = BLACK_DOT_RGB;

	  3'd7:
	  if (in_dot[0] || in_dot[1] || in_dot[2] || in_dot[3] || in_dot[4] || in_dot[5] || in_dot[6])
		{r, g, b} = RED_DOT_RGB;

      default: {r, g, b} = BLACK_RGB;  //default
    endcase

  end

endmodule
