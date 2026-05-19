// monopoly_rng_core.sv

module monopoly_rng_core (
    input logic clk,
    input logic rst_n,

    // ALPEREN İLE İLETİŞİM
    input  logic       req_dice,  // "Bana bir zar ver" isteği
    input  logic       req_card,  // "Bana bir kart ver" isteği
    output logic [4:0] data_out,  // Ortak çıkış yolu (Zar veya 1-21 arası Kart)
    output logic       ready,     // "Veri hazır" sinyali

    // MPU6050 SENSÖRÜNDEN GELEN İVME VERİLERİ
    input logic [15:0] accel_x,
    input logic [15:0] accel_y,
    input logic [15:0] accel_z
);

  // ---------------------------------------------------
  // 1. SÜREKLİ ÇALIŞAN LFSR'LER (Serbest Dönen TRNG)
  // ---------------------------------------------------
  wire noise_dice = accel_x[0] ^ accel_y[1];
  wire noise_card = accel_y[0] ^ accel_z[1];

  logic [7:0] lfsr_dice;  // Zar için 8-bit yeterli (Dağılımı 255/6 = 42.5 gayet iyi)
  logic [15:0] lfsr_card;  // Kart için 16-bit yüksek çözünürlüklü LFSR

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr_dice <= 8'hA5;
      lfsr_card <= 16'h6B3C;
    end else begin
      // Zar LFSR'si (8-bit polinom)
      lfsr_dice <= {
        lfsr_dice[6:0], lfsr_dice[7] ^ lfsr_dice[5] ^ lfsr_dice[4] ^ lfsr_dice[3] ^ noise_dice
      };

      // Kart LFSR'si (16-bit polinom: x^16 + x^14 + x^13 + x^11 + 1)
      lfsr_card <= {
        lfsr_card[14:0], lfsr_card[15] ^ lfsr_card[13] ^ lfsr_card[12] ^ lfsr_card[10] ^ noise_card
      };
    end
  end

  // ---------------------------------------------------
  // 2. MATEMATİK VE EL SIKIŞMA (Handshake FSM)
  // ---------------------------------------------------
  // Zar Formülü: 8-bit x 8-bit = Maks 16-bit sonuç
  wire [15:0] mult_dice = lfsr_dice * 8'd6;

  // Kart Formülü: 16-bit x 8-bit = Maks 24-bit sonuç (65535 * 21 = 1,376,235)
  wire [23:0] mult_card = lfsr_card * 8'd21;

  typedef enum logic [1:0] {
    IDLE,
    WAIT_FOR_ACK
  } state_t;
  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ready <= 1'b0;
      data_out <= 5'd0;
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          ready <= 1'b0;

          if (req_dice) begin
            // 8-bit kaydırma (bölü 256)
            data_out <= 5'(mult_dice[15:8] + 5'd1);  // 1-6 arası zar
            ready <= 1'b1;
            state <= WAIT_FOR_ACK;
          end else if (req_card) begin
            // 16-bit kaydırma (bölü 65536) -> En üst 8 biti alıyoruz
            // 1.376.235 sayısı Hex olarak 24'h14FFFF'tir. 
            // En üst 8 biti [23:16] bize 20 değerini (Hex 14) verir. +1 ekleyince 21 olur.
            data_out <= 5'(mult_card[23:16] + 5'd1);  // 1-21 arası kart
            ready <= 1'b1;
            state <= WAIT_FOR_ACK;
          end
        end

        WAIT_FOR_ACK: begin
          if (!req_dice && !req_card) begin
            ready <= 1'b0;
            state <= IDLE;
          end
        end
      endcase
    end
  end

endmodule
