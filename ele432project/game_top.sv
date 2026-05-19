// game_top.sv

module game_top (
    // ==========================================
    // STANDARD BOARD INPUTS
    // ==========================================
    input  logic       CLOCK_50,
    input  logic [3:0] KEY,          // KEY[0]: Confirm, KEY[1]: Deny, KEY[2]: Dice
    input  logic [9:0] SW,           // SW[0]: Master Reset, SW[3:2] Player numbers, SW[8:4]: Numbers, SW[9]: Debug
    // I2C / ACCELEROMETER PINS
    inout  wire  [1:0] GPIO_0,       // GPIO_0[1] is SDA, GPIO_0[0] is SCL
	 
    // VGA DISPLAY OUTPUTS
    output logic       VGA_CLK,
    output logic       VGA_HS,
    output logic       VGA_VS,
    output logic       VGA_SYNC_N,
    output logic       VGA_BLANK_N,
    output logic [7:0] VGA_R,
    output logic [7:0] VGA_G,
    output logic [7:0] VGA_B,
    // 7-SEGMENT DISPLAY OUTPUTS (Red LEDs)
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

  // ==========================================
  // INTERNAL WIRING & ROUTING
  // ==========================================
  logic clk;
  assign clk = CLOCK_50;

  // --- RESET LOGIC ---
  logic sw_reset;
  assign sw_reset = SW[0];  // SW0 is the absolute master of the system

  // ENGINEERING TRICK: Other modules expect an active-low (0) reset. 
  // Since SW0 is active-high (1), we invert it to send 0 when the switch is up!
  logic sys_rst_n;
  assign sys_rst_n = ~SW[0];

  // --- PHYSICAL BUTTON ROUTING ---
  // Keys are active-low physically, so we invert them here to make them active-high
  logic btn_confirm, btn_deny, btn_vending, btn_dice_raw;
  assign btn_confirm  = ~KEY[0];
  assign btn_deny     = ~KEY[1];
  assign btn_vending  = ~KEY[0];  // Deny and Vending share the same button
  assign btn_dice_raw = ~KEY[2];

  // --- SWITCH ROUTING ---
  logic [6:0] sw_num;
  logic       sw_debug;
  assign sw_num   = SW[8:2];  // Shifted to [8:2] so it doesn't overlap with SW[0] reset
  assign sw_debug = SW[9];

  // --- INTERNAL COMMUNICATION WIRES ---
  logic db_confirm, db_deny, db_vending, db_dice_button;

  logic rng_req_dice, rng_req_card, rng_ready;
  logic [4:0] rng_out;

  logic [7:0] mem_addr;
  logic [15:0] mem_write_data, mem_read_data;
  logic mem_we, mem_req, mem_ack;

  logic [ 7:0] vga_addr;
  logic [15:0] vga_read_data;

  logic [7:0] w_addr, w_data_write, w_data_read;
  logic [15:0] w_sub_addr;
  logic w_sub_len, w_req_trans, w_valid_out, w_busy;
  logic [23:0] w_byte_len;
  logic [15:0] accel_x, accel_y, accel_z;
  logic shake_pulse;

  // =================================================================
  // 1. BUTTON DEBOUNCER
  // =================================================================
  button_debouncer #(
      .DEBOUNCE_LIMIT(20'd10)
  ) U_BUTTON_ARRAY (
      .clk(clk),
      .rst_n(sys_rst_n),  // When SW0 is high, buttons freeze
      .btn_in({btn_dice_raw, btn_vending, btn_deny, btn_confirm}),
      .btn_out({db_dice_button, db_vending, db_deny, db_confirm})
  );

  // =================================================================
  // 2. ACCELEROMETER & SHAKE DETECTOR (I2C)
  // =================================================================
  i2c_master master_inst (
      .i_clk(clk),
      .reset_n(sys_rst_n),
      .i_addr_w_rw(w_addr),
      .i_sub_addr(w_sub_addr),
      .i_sub_len(w_sub_len),
      .i_byte_len(w_byte_len),
      .i_data_write(w_data_write),
      .req_trans(w_req_trans),
      .data_out(w_data_read),
      .valid_out(w_valid_out),
      .busy(w_busy),
      .scl_o(GPIO_0[0]),
      .sda_o(GPIO_0[1]),
      .req_data_chunk(),
      .nack()
  );

  mpu6050_controller mpu_ctrl_inst (
      .clk(clk),
      .rst_n(sys_rst_n),
      .i2c_addr_w_rw(w_addr),
      .i2c_sub_addr(w_sub_addr),
      .i2c_sub_len(w_sub_len),
      .i2c_byte_len(w_byte_len),
      .i2c_data_write(w_data_write),
      .i2c_req_trans(w_req_trans),
      .i2c_data_out(w_data_read),
      .i2c_valid_out(w_valid_out),
      .i2c_busy(w_busy),
      .accel_x(accel_x),
      .accel_y(accel_y),
      .accel_z(accel_z),
      .data_ready()
  );

  shake_detector U_SHAKE (
      .clk(clk),
      .rst_n(sys_rst_n),
      .accel_x(accel_x),
      .accel_y(accel_y),
      .accel_z(accel_z),
      .shake_pulse(shake_pulse)
  );

  // MAGIC MERGE: You can roll the dice by pressing the button OR shaking the board!
  logic game_dice_trigger;
  assign game_dice_trigger = db_dice_button | shake_pulse;

  // =================================================================
  // 3. HARDWARE RNG (Using Accelerometer Noise)
  // =================================================================
  monopoly_rng_core U_RNG (
      .clk(clk),
      .rst_n(sys_rst_n),  // When SW0 is high, RNG history is cleared
      .req_dice(rng_req_dice),
      .req_card(rng_req_card),
      .accel_x(accel_x),
      .accel_y(accel_y),
      .accel_z(accel_z),
      .data_out(rng_out),
      .ready(rng_ready)
  );

  // =================================================================
  // 4. MAIN GAME STATE MACHINE (FSM)
  // =================================================================
  // Wires to retrieve the current dice and cards directly from the FSM
  logic [3:0] current_dice_1, current_dice_2;
  logic [4:0] current_card;

  main_game_fsm U_FSM (
      .clk(clk),
      .sw_reset(sw_reset),  // The FSM explicitly takes the active-high SW0 reset
      .db_confirm(db_confirm),
      .db_deny(db_deny),
      .db_vending(db_vending),
      .db_dice(game_dice_trigger),
      .sw_num(sw_num),
      .sw_debug(sw_debug),

      .rng_req_dice(rng_req_dice),
      .rng_req_card(rng_req_card),
      .rng_out(rng_out),
      .rng_ready(rng_ready),

      .mem_addr(mem_addr),
      .mem_write_data(mem_write_data),
      .mem_we(mem_we),
      .mem_req(mem_req),
      .mem_ack(mem_ack),
      .mem_read_data(mem_read_data),

      // Outputting values directly for the 7-segment displays
      .out_dice_1(current_dice_1),
      .out_dice_2(current_dice_2),
      .out_card  (current_card)
  );

  // =================================================================
  // 5. DUAL-PORT MEMORY CONTROLLER
  // =================================================================
  memory_controller U_MEM (
      .clk(clk),
      .rst_n(sys_rst_n),  // When SW0 is high, memory interface resets
      // PORT A: Game Logic (FSM)
      .mem_addr(mem_addr),
      .mem_write_data(mem_write_data),
      .mem_we(mem_we),
      .mem_req(mem_req),
      .mem_ack(mem_ack),
      .mem_read_data(mem_read_data),
      // PORT B: Screen Reader (VGA Sweeper)
      .vga_addr(vga_addr),
      .vga_read_data(vga_read_data)
  );

  // =================================================================
  // 6. VGA DISPLAY DRIVER       
  // =================================================================
  vga_wrapper VGA_DISPLAY (
      .CLOCK_50(CLOCK_50),
      .sw_reset(sw_reset),  // VGA module expects an active-high reset
      .VGA_CLK(VGA_CLK),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_SYNC_N(VGA_SYNC_N),
      .VGA_BLANK_N(VGA_BLANK_N),
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),

      .vga_addr(vga_addr),
      .vga_read_data(vga_read_data),

      .debug_on(SW[9])
  );

  // =================================================================
  // 7. 7-SEGMENT DISPLAYS (Physical Red Numbers)
  // =================================================================
  // Splitting the drawn card into tens and ones digits

  logic [4:0] card_tens, card_ones;
  always_comb begin
    if (current_card >= 5'd20) begin
      card_tens = 5'd2;
      card_ones = current_card - 5'd20;
    end else if (current_card >= 5'd10) begin
      card_tens = 5'd1;
      card_ones = current_card - 5'd10;
    end else begin
      card_tens = 5'h1F;  // If less than 10, turn off the tens digit display
      card_ones = current_card;
    end
  end

  hex_decoder hex_dice1 (
      .bin_in ({1'b0, current_dice_1}),
      .hex_out(HEX0)
  );
  hex_decoder hex_dice2 (
      .bin_in ({1'b0, current_dice_2}),
      .hex_out(HEX1)
  );
  hex_decoder hex_card1 (
      .bin_in (card_ones),
      .hex_out(HEX2)
  );  // Ones digit
  hex_decoder hex_card2 (
      .bin_in (card_tens),
      .hex_out(HEX3)
  );  // Tens digit

endmodule
