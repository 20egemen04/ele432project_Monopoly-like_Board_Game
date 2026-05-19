// chance_card_engine.sv

module chance_card_engine (
    input  logic [4:0] card_id,
    output logic [7:0] bank_money,
    output logic       bank_sign,
    output logic [7:0] all_players_money,
    output logic       all_players_sign,
    output logic [7:0] next_player_money,
    output logic       move_en,
    output logic [4:0] move_to_tile,
    output logic [2:0] move_back_val,
    output logic       to_makeup_exam
);

  localparam TILE_START = 5'd0;
  localparam TILE_BUS_STOP = 5'd12;
  localparam TILE_METRO = 5'd28;
  localparam TILE_SILENCE = 5'd16;
  localparam TILE_STUDY = 5'd14;
  localparam TILE_CAFETERIA = 5'd29;

  always_comb begin
    bank_money        = 8'd0;
    bank_sign         = 1'b1;
    all_players_money = 8'd0;
    all_players_sign  = 1'b1;
    next_player_money = 8'd0;
    move_to_tile      = 5'd0;
    move_en           = 1'b0;
    move_back_val     = 3'd0;
    to_makeup_exam    = 1'b0;

    case (card_id)
      5'd1: begin
        move_to_tile = TILE_START;
        move_en = 1'b1;
      end
      5'd2: begin
        move_back_val = 3'd3;
      end
      5'd3: begin
        bank_money = 8'd10;
        bank_sign  = 1'b0;
      end
      5'd4: begin
        move_to_tile = TILE_SILENCE;
        move_en = 1'b1;
      end
      5'd5: begin
        move_to_tile = TILE_STUDY;
        move_en = 1'b1;
      end
      5'd6: begin
        all_players_money = 8'd5;
        all_players_sign  = 1'b0;
      end
      5'd7, 5'd8: begin
        to_makeup_exam = 1'b1;
      end
      5'd9: begin
        bank_money = 8'd5;
        bank_sign  = 1'b0;
      end
      5'd10: begin
        bank_money = 8'd10;
        bank_sign  = 1'b1;
      end
      5'd11: begin
        bank_money = 8'd15;
        bank_sign  = 1'b1;
      end
      5'd12: begin
        all_players_money = 8'd5;
        all_players_sign  = 1'b1;
      end
      5'd13: begin
        all_players_money = 8'd4;
        all_players_sign  = 1'b1;
      end
      5'd14: begin
        bank_money = 8'd5;
        bank_sign  = 1'b0;
      end
      5'd15: begin
        move_to_tile = TILE_METRO;
        move_en = 1'b1;
      end
      5'd16: begin
        move_to_tile = TILE_CAFETERIA;
        move_en = 1'b1;
      end
      5'd17: begin
        bank_money = 8'd1;
        bank_sign  = 1'b0;
      end
      5'd18: begin
        next_player_money = 8'd5;
        move_to_tile = TILE_BUS_STOP;
        move_en = 1'b1;
        // Duct tape solution
        bank_money = 8'd0;
        bank_sign  = 1'b1;
      end
      5'd19: begin
        all_players_money = 8'd3;
        all_players_sign = 1'b0;
        bank_money = 8'd10;
        bank_sign = 1'b0;
      end
      5'd20: begin
        move_to_tile = TILE_BUS_STOP;
        move_en = 1'b1;
      end
      5'd21: begin
        move_to_tile = TILE_METRO;
        move_en = 1'b1;
      end
      default: begin
      end
    endcase
  end
endmodule
