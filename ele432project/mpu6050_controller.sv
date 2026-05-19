// mpu6050_controller.sv

module mpu6050_controller #(
    parameter CLK_FREQ = 50_000_000  // 50 MHz DE1-SoC
) (
    input logic clk,
    input logic rst_n,

    // I2C Master'a Giden/Gelen Sinyaller
    output logic [ 7:0] i2c_addr_w_rw,
    output logic [15:0] i2c_sub_addr,
    output logic        i2c_sub_len,
    output logic [23:0] i2c_byte_len,
    output logic [ 7:0] i2c_data_write,
    output logic        i2c_req_trans,

    input logic [7:0] i2c_data_out,
    input logic       i2c_valid_out,
    input logic       i2c_busy,

    // Shake Detector'e Gidecek Olan Temiz Çıktılar
    output logic [15:0] accel_x,
    output logic [15:0] accel_y,
    output logic [15:0] accel_z,
    output logic        data_ready  // Verilerin güncellendiğini bildiren 1-cycle pulse
);

  // MPU6050 Sabitleri
  localparam MPU6050_ADDR_WRITE = 8'hD0;  // 0x68 << 1 + 0 (Yazma)
  localparam MPU6050_ADDR_READ = 8'hD1;  // 0x68 << 1 + 1 (Okuma)
  localparam REG_PWR_MGMT_1 = 16'h6B;
  localparam REG_ACCEL_XOUT_H = 16'h3B;

  // FSM Durumları
  typedef enum logic [2:0] {
    ST_INIT_REQ,   // Sensörü uyandırma komutunu hazırla
    ST_INIT_WAIT,  // Uyanma işleminin bitmesini bekle
    ST_READ_REQ,   // İvme verilerini okuma komutunu hazırla
    ST_READ_WAIT,  // 6 byte verinin gelmesini bekle ve topla
    ST_DELAY       // Okumalar arası bekleme (sensörü boğmamak için)
  } state_t;

  state_t state, next_state;

  // Gelen verileri toplamak için sayaç ve hafıza
  logic [2:0] byte_count;
  logic [7:0] recv_buffer[0:5];  // 6 adet 8-bitlik veri tutacak dizi

  // Gecikme sayacı (Yaklaşık 1 milisaniye bekleme için)
  localparam DELAY_CYCLES = CLK_FREQ / 1000;
  logic [15:0] delay_cnt;

  // Edge detector for busy signal (Busy 1'den 0'a düşünce işlem bitti demektir)
  logic busy_prev;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) busy_prev <= 1'b0;
    else busy_prev <= i2c_busy;
  end
  wire busy_falling = busy_prev & ~i2c_busy;

  // FSM ve Veri Toplama Bloğu
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= ST_INIT_REQ;
      i2c_req_trans <= 1'b0;
      byte_count <= 0;
      delay_cnt <= 0;
      data_ready <= 1'b0;
      accel_x <= 0;
      accel_y <= 0;
      accel_z <= 0;
    end else begin
      // Varsayılan değerler
      i2c_req_trans <= 1'b0;
      data_ready <= 1'b0;

      case (state)
        ST_INIT_REQ: begin
          // Uyandırma paketi hazırlığı
          i2c_addr_w_rw  <= MPU6050_ADDR_WRITE;
          i2c_sub_addr   <= REG_PWR_MGMT_1;
          i2c_sub_len    <= 1'b0;  // 8-bit adres
          i2c_byte_len   <= 24'd1;  // 1 byte yazacağız
          i2c_data_write <= 8'h00;  // Uyku modunu kapat

          i2c_req_trans  <= 1'b1;  // İletimi başlat
          state          <= ST_INIT_WAIT;
        end

        ST_INIT_WAIT: begin
          // İletim bittiğinde (busy düştüğünde) okuma isteğine geç
          if (busy_falling) begin
            state <= ST_READ_REQ;
          end
        end

        ST_READ_REQ: begin
          // 6 Byte İvme Verisi Okuma İsteği
          i2c_addr_w_rw <= MPU6050_ADDR_READ;
          i2c_sub_addr  <= REG_ACCEL_XOUT_H;
          i2c_sub_len   <= 1'b0;
          i2c_byte_len  <= 24'd6;  // X_H, X_L, Y_H, Y_L, Z_H, Z_L

          byte_count    <= 0;
          i2c_req_trans <= 1'b1;
          state         <= ST_READ_WAIT;
        end

        ST_READ_WAIT: begin
          // I2C Master 'valid_out' verdikçe verileri diziye kaydet
          if (i2c_valid_out) begin
            recv_buffer[byte_count] <= i2c_data_out;
            byte_count <= byte_count + 1'b1;
          end

          // İletim tamamen bittiğinde verileri birleştir
          if (busy_falling) begin
            // Sensör MSB First (Önce Yüksek Byte) gönderir
            accel_x <= {recv_buffer[0], recv_buffer[1]};
            accel_y <= {recv_buffer[2], recv_buffer[3]};
            accel_z <= {recv_buffer[4], recv_buffer[5]};

            data_ready <= 1'b1;  // Yeni veri hazır!
            state <= ST_DELAY;
          end
        end

        ST_DELAY: begin
          // Sürekli okuyup I2C hattını meşgul etmemek için 1ms bekle
          if (delay_cnt < DELAY_CYCLES) begin
            delay_cnt <= delay_cnt + 1'b1;
          end else begin
            delay_cnt <= 0;
            state <= ST_READ_REQ;  // Tekrar okuma isteği gönder
          end
        end

        default: state <= ST_INIT_REQ;
      endcase
    end
  end

endmodule
