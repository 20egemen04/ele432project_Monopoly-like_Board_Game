// shake_detector.sv

module shake_detector (
    input  logic clk,
    input  logic rst_n,
    input  logic [15:0] accel_x, // I2C modülünden gelen ham X ivmesi
    input  logic [15:0] accel_y, // I2C modülünden gelen ham Y ivmesi
    input  logic [15:0] accel_z, // I2C modülünden gelen ham Z ivmesi
    output logic shake_pulse     // Zar atma sinyali!
);

  // MPU6050 değerleri 2'ye tümleyen (2's complement) formatındadır.
  // Biz sadece büyüklükle (mutlak değer) ilgileniyoruz.
  wire [15:0] abs_x = accel_x[15] ? (~accel_x + 1'b1) : accel_x;
  wire [15:0] abs_y = accel_y[15] ? (~accel_y + 1'b1) : accel_y;
  wire [15:0] abs_z = accel_z[15] ? (~accel_z + 1'b1) : accel_z;

  // Sallama Eşiği (Bu değeri deneyerek bulmalısınız, 16-bitlik aralıkta bir değer)
  //OLD.. localparam THRESHOLD = 16'd15000; 

  // 1g = ~16384. Gerçek bir sallama (yaklaşık 1.5g - 2g) hissetmesi için eşiği yükselttik.
  localparam THRESHOLD = 16'd28000;

  logic is_shaking;

  // Herhangi bir eksende ivme eşiği geçerse sallanıyor demektir
  assign is_shaking = (abs_x > THRESHOLD) || (abs_y > THRESHOLD) || (abs_z > THRESHOLD);

  // Daha önceki buton modülümüzde yazdığımız Edge Detector mantığının aynısı!
  // Sallama bittiği an (is_shaking 1'den 0'a düştüğünde) tek bir pulse üretelim.
  logic shaking_delayed;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shaking_delayed <= 1'b0;
    end else begin
      shaking_delayed <= is_shaking;
    end
  end

  // Düşen kenar yakalayıcı: Sallama durduğu an zar sonucunu sabitle.
  assign shake_pulse = ~is_shaking & shaking_delayed;

endmodule
