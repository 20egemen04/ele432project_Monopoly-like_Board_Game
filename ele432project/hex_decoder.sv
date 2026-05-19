// hex_decoder.sv

module hex_decoder (
    input  logic [4:0] bin_in,  // 0'dan 9'a kadar rakamlar (5'h1F ise ekranı kapatır)
    output logic [6:0] hex_out  // Active-Low çıkış
);
  always_comb begin
    case (bin_in)
      5'd0: hex_out = 7'b1000000;  // '0'
      5'd1: hex_out = 7'b1111001;  // '1'
      5'd2: hex_out = 7'b0100100;  // '2'
      5'd3: hex_out = 7'b0110000;  // '3'
      5'd4: hex_out = 7'b0011001;  // '4'
      5'd5: hex_out = 7'b0010010;  // '5'
      5'd6: hex_out = 7'b0000010;  // '6'
      5'd7: hex_out = 7'b1111000;  // '7'
      5'd8: hex_out = 7'b0000000;  // '8'
      5'd9: hex_out = 7'b0010000;  // '9'
      default: hex_out = 7'b1111111;  // Ekran kapalı (Blank)
    endcase
  end
endmodule
