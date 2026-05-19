// text_display.sv

module text_display #(
    parameter MAX_CHARS = 42  // Set this when you instantiate! Maximum 80 to fit on a 640 pixel screen with 8x8 font
) (
    input logic [9:0] x, y,
    input logic [9:0] start_x, start_y,  //start coordinates
    input logic       enable_display,
    input logic [(MAX_CHARS*8)-1:0] text_string,
    input  logic [7:0] font_row,
    output logic [10:0] font_rom_addr,
    output logic pixel_on,
    output logic in_box
);

  logic [9:0] rel_x, rel_y;
  logic [6:0] char_index;
  logic [2:0] px, py;
  logic [7:0] current_ascii;
  logic       in_text_area;

  // 1. Math & Bounding Box
  always_comb begin
    rel_x = x - start_x;
    rel_y = y - start_y;

    in_text_area =  (x >= start_x && x < start_x + (MAX_CHARS * 8)) &&
                    (y >= start_y && y < start_y + 8);

    in_box = in_text_area;
  end

  // 2. Indexing
  always_comb begin
    char_index = rel_x[9:3];
    px         = rel_x[2:0];
    py         = rel_y[2:0];
  end

  // 3. Extract ASCII
  always_comb begin
    if (char_index < MAX_CHARS) begin
      // Converts left-to-right screen 'char_index' to right-to-left packed array indexing.
      // Verilog stores the first character at the highest bit position.
      // '+: 8' starts at the calculated base bit and grabs an 8-bit ASCII character upward.
      // Example (MAX_CHARS=42, char_index=0): (42-1-0)*8 = bit 328. Grabs bits [335:328].
      current_ascii = text_string[((MAX_CHARS - 1 - char_index) * 8) +: 8];
    end else begin
      current_ascii = 8'd32;  // Space
    end
  end

  // 4. ROM Addressing 
  always_comb begin
    if (current_ascii >= 8'd32 && current_ascii <= 8'd90) begin
      font_rom_addr = {current_ascii, py};
    end else begin
      font_rom_addr = 11'd32; // If an invalid character is sent, default to Address 32 (Space) don't need py since space is blank.
    end
  end

  // 5. Output the Pixel 
  always_comb begin
    if (in_text_area && enable_display) begin
      // Since MSB is on the left, we use 7 - px (reads from the right)
      pixel_on = font_row[3'd7 - px];
    end else begin
      pixel_on = 1'b0;
    end
  end

endmodule
