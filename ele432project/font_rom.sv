// font_rom.sv

module font_rom #(
    parameter ADDR_OFFSET = 8'd32
)(
    input  logic [10:0] font_addr,   // Made for the character number we have
    output logic [7:0] font_data_out
);

    // Initialize character ROM
    logic [7:0] font_rom [511:0];

    // Read characters from file
    initial $readmemb("char8x8_mem.txt", font_rom);

    // Output character
    always_comb begin
        font_data_out = font_rom[{font_addr[8:3] - ADDR_OFFSET, font_addr[2:0]}];
    end

endmodule