// vga_wrapper.sv DE1-SoC

module vga_wrapper (
    input  logic       CLOCK_50,
    input  logic       sw_reset,
    output logic       VGA_CLK,
    output logic       VGA_HS,
    output logic       VGA_VS,
    output logic       VGA_SYNC_N,
    output logic       VGA_BLANK_N,
    output logic [7:0] VGA_R,
    output logic [7:0] VGA_G,
    output logic [7:0] VGA_B, //add , here
    // Memory Sweeper signals
    input  logic [15:0] vga_read_data,  // Data returning from RAM
    output logic [7:0]  vga_addr,       // Address requested from RAM
    // Debug
    input  logic        debug_on
);

    // Internal wire to carry the true internal 25MHz clock
    logic clk_25;

    vga vga_inst (
        // Inputs
        .clk(CLOCK_50),
        .reset(sw_reset),
        // Outputs
        .vgaclk(clk_25),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .sync_b(VGA_SYNC_N),
        .blank_b(VGA_BLANK_N),
        .r(VGA_R), .g(VGA_G), .b(VGA_B),
        // Memory Sweeper signals
	    .vga_read_data(vga_read_data),  // Data returning from RAM
	    .vga_addr(vga_addr),             // Address requested from RAM
        // Debug
        .debug_on(debug_on)
    );

    // Invert the clock as it leaves the chip toward the video DAC.
    assign VGA_CLK = ~clk_25;

endmodule
