// button_debouncer.sv

module button_debouncer #(
    // Parameter for debounce time. 
    // At 50MHz, 1,000,000 cycles = 20ms. 
    // TIP: Lower this to ~10 during Questa simulation so you don't wait forever!
    parameter DEBOUNCE_LIMIT = 20'd1_000_000
) (
    input  logic       clk,
    input  logic       rst_n,   // Active-low reset
    input  logic [3:0] btn_in,  // Raw physical button inputs
    output logic [3:0] btn_out  // 1-clock-cycle pulse outputs for the FSM
);

  // 1. Two-stage synchronizer to prevent metastability
  logic [3:0] sync_0;
  logic [3:0] sync_1;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync_0 <= 4'b0000;
      sync_1 <= 4'b0000;
    end else begin
      sync_0 <= btn_in;
      sync_1 <= sync_0;
    end
  end

  // 2. Debounce Counter and State logic
  logic [19:0] counter;
  logic [ 3:0] stable_state;  // The debounced, steady state of the buttons
  logic [ 3:0] prev_state;  // Used for edge detection

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter      <= 20'd0;
      stable_state <= 4'b0000;
      prev_state   <= 4'b0000;
      btn_out      <= 4'b0000;
    end else begin
      // Edge detection logic (default to 0 every clock cycle)
      btn_out <= 4'b0000;
      prev_state <= stable_state;

      // If the synchronized input is different from our stable state, start counting
      if (sync_1 != stable_state) begin
        counter <= counter + 1'b1;

        // If it has been stable long enough, register the new state
        if (counter >= DEBOUNCE_LIMIT) begin
          stable_state <= sync_1;
          counter <= 20'd0;  // Reset counter
        end
      end else begin
        // If it glitches back, reset the counter
        counter <= 20'd0;
      end

      // 3. Generate a 1-cycle pulse ONLY on the rising edge of the stable state
      // (Assumes buttons are Active-High. If your board uses Active-Low, swap this logic)
      btn_out[0] <= stable_state[0] & ~prev_state[0];  // Confirm
      btn_out[1] <= stable_state[1] & ~prev_state[1];  // Deny
      btn_out[2] <= stable_state[2] & ~prev_state[2];  // Vending
      btn_out[3] <= stable_state[3] & ~prev_state[3];  // Dice
    end
  end

endmodule
