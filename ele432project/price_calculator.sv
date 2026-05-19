// price_calculator.sv

module price_calculator (
    input  logic [4:0] tile_id,
    output logic [7:0] buy_price,
    output logic [7:0] vending_price,
    output logic [7:0] rent_0,
    output logic [7:0] rent_1,
    output logic [7:0] rent_2,
    output logic [7:0] rent_3,
    output logic       is_property
);

  assign is_property = (tile_id[1:0] != 2'b00);

  logic [3:0] n;

  always_comb begin
    n = {1'b0, tile_id[4:2]} + 4'd1;

    buy_price = (n * 8'd2) + 8'd1;
    vending_price = ((n + 8'd1) / 8'd2) * 8'd4;

    rent_0 = n + 8'd1;
    rent_1 = (n * 8'd3) + 8'd3;
    rent_2 = (n * 8'd5) + 8'd5;
    rent_3 = (n * 8'd6) + 8'd6;
  end

endmodule
