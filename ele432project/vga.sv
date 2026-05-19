// vga.sv

module vga (
    // Inputs
    input  logic       clk,             // 50 MHz clock
    input  logic       reset,
    // Outputs
    output logic       vgaclk,          // 25 MHz VGA clock 
    output logic       hsync,
    output logic       vsync,
    output logic       sync_b,
    output logic       blank_b,         // to monitor & DAC 
    output logic [7:0] r, g, b,
    // Memory Sweeper signals
	  input  logic [15:0] vga_read_data,  // Data returning from RAM
	  output logic [7:0]  vga_addr,       // Address requested from RAM
    // Debug
    input  logic        debug_on
);  // to video DAC 

  // Internal signals for coordinates
  logic [9:0] x, y;

  // Use a clock divider to create the 25 MHz VGA pixel clock <- old
  // 25 MHz clk period = 40 ns 
  // Screen is 800 clocks wide by 525 tall, but only 640 x 480 used for display 
  // HSync = 1/(40 ns * 800) = 31.25 kHz 
  // Vsync = 31.25 KHz / 525 = 59.52 Hz (~60 Hz refresh rate) 

  // use the altera ip pll clock to get 25.175 MHz clock
  logic pll_locked;

  vga_pll pll_inst (
      .refclk  (clk),        // Connects to your 50 MHz input 'clk'
      .rst     (reset),      // Connects to your 'reset' wire
      .outclk_0(vgaclk),     // Your clean 25.175 MHz pixel clock out to 'vgaclk'
      .locked  (pll_locked)  // High when clock is stable
  );

  // Create internal pipeline registers
  logic [7:0] r_reg, g_reg, b_reg;
  logic hsync_reg, vsync_reg, blank_b_reg, sync_b_reg;

  // Route your boardDisp and controller outputs to these internal registers first
  always_ff @(posedge vgaclk or posedge reset) begin
    if (reset) begin
      r       <= 8'd0;
      g       <= 8'd0;
      b       <= 8'd0;
      hsync   <= 1'b1;
      vsync   <= 1'b1;
      blank_b <= 1'b0;
      sync_b  <= 1'b0;
    end else if (!pll_locked) begin  // Keeps outputs safe until the clock stabilizes!
      r       <= 8'd0;
      g       <= 8'd0;
      b       <= 8'd0;
      hsync   <= 1'b1;
      vsync   <= 1'b1;
      blank_b <= 1'b0;
      sync_b  <= 1'b0;
    end else begin
      r       <= r_reg;
      g       <= g_reg;
      b       <= b_reg;
      hsync   <= hsync_reg;
      vsync   <= vsync_reg;
      blank_b <= blank_b_reg;
      sync_b  <= sync_b_reg;
    end
  end

  // generate monitor timing signals 
  vgaController vgaCont (
      .vgaclk(vgaclk),
      .reset(reset),
      .hsync(hsync_reg), .vsync(vsync_reg),
      .sync_b(sync_b_reg), .blank_b(blank_b_reg),
      .hcnt(x), .vcnt(y)
  );

  // Internal signals for game mechanics
  logic [31:0] player_money;
  logic [ 3:0] pawn_enabled;
  logic [19:0] pawn_tile;
  logic [ 3:0] pawn_selected;
  logic [ 3:0] pawn_in_makeup;
  logic [95:0] tile_ownership;
  logic [63:0] vending_machine;
  logic [ 2:0] tile_ownership_board [31:0];
  logic [ 1:0] vending_machine_board[31:0];
  logic [ 5:0] dice_info;
  logic [ 4:0] card_id;
  logic [ 7:0] active_price;
  logic [ 7:0] current_vga_cmd;

  always_comb begin
    for (int i = 0; i < 32; i = i + 1) begin
      tile_ownership_board[i]  = tile_ownership[i*3+:3];
      vending_machine_board[i] = vending_machine[i*2+:2];
    end
  end

  // Get game mechanics signals from memory sweeper
  vga_memory_sweeper sweeper_inst (
      // Inputs
      .clk            (clk),              // Runs on the fast 50 MHz clock!
      .reset          (reset),
      .vga_read_data  (vga_read_data),    // Receives data from RAM
      // Outputs
      .vga_addr       (vga_addr),         // Sends address out to RAM
      .player_money   (player_money),
      .pawn_enabled   (pawn_enabled),
      .pawn_tile      (pawn_tile),
      .pawn_selected  (pawn_selected),
      .pawn_in_makeup (pawn_in_makeup),
      .tile_ownership (tile_ownership),
      .vending_machine(vending_machine),
      .dice_info      (dice_info),
      .card_id        (card_id),
      .active_price   (active_price),
      .current_vga_cmd(current_vga_cmd)
  );


  // user-defined module to determine pixel color 
  board_display boardDisp (
      .clk(vgaclk),
      .x(x), .y(y),
      .pawn_enabled(pawn_enabled),
      .pawn_tile(pawn_tile),
      .pawn_selected(pawn_selected),
      .pawn_in_makeup(pawn_in_makeup),
      .tile_ownership(tile_ownership_board),
      .dice_info(dice_info),
      .vending_machine(vending_machine_board),
      .card_id(card_id),
      .player_money(player_money),
      .active_price(active_price),
      .current_vga_cmd(current_vga_cmd),
      .debug_on(debug_on),
      .r(r_reg), .g(g_reg), .b(b_reg)
  );
  
endmodule 



module vgaController #(parameter HBP     = 10'd48,   // horizontal back porch
                                 HACTIVE = 10'd640,  // number of pixels per line
                                 HFP     = 10'd16,   // horizontal front porch
                                 HSYN    = 10'd96,   // horizontal sync pulse = 60 to move electron gun back to left
                                 HMAX    = HBP + HACTIVE + HFP + HSYN, //48+640+16+96=800: number of horizontal pixels (i.e., clock cycles)
                                 VBP     = 10'd32,   // vertical back porch
                                 VACTIVE = 10'd480,  // number of lines
                                 VFP     = 10'd11,   // vertical front porch
                                 VSYN    = 10'd2,    // vertical sync pulse = 2 to move electron gun back to top
                                 VMAX    = VBP + VACTIVE + VFP  + VSYN) //32+480+11+2=525: number of vertical pixels (i.e., clock cycles)                      

     (input  logic vgaclk,
      input  logic reset,
      output logic hsync, vsync,
      output logic sync_b, blank_b, 
      output logic [9:0] hcnt, vcnt); 

      // counters for horizontal and vertical positions 
      always @(posedge vgaclk, posedge reset) begin
        if (reset) begin
          hcnt <= 0;
          vcnt <= 0;
        end else begin
          hcnt <= hcnt + 10'd1;
          if (hcnt == HMAX - 1) begin
            hcnt <= 0;
            vcnt <= vcnt + 10'd1;
            if (vcnt == VMAX - 1) vcnt <= 0;
          end
        end
      end
	  

      // compute sync signals (active low) 
      assign hsync  = ~( (hcnt >= (HACTIVE + HFP)) & (hcnt < (HACTIVE + HFP + HSYN)) ); 
      assign vsync  = ~( (vcnt >= (VACTIVE + VFP)) & (vcnt < (VACTIVE + VFP + VSYN)) ); 
      // Use this for older monitors: assign sync_b = hsync & vsync; 
      assign sync_b = 1'b0;  // this should be 0 for newer monitors

      // force outputs to black when not writing pixels
      // The following also works: assign blank_b = hsync & vsync; 
      assign blank_b = (hcnt < HACTIVE) & (vcnt < VACTIVE); 
endmodule
