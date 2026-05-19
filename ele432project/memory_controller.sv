// memory_controller.sv

/* =========================================================================
   MODULE: memory_controller
   ARCHITECTURE: Dual-Port Memory Mapped I/O Bridge
   FIX: Removed the '!mem_req' wait condition in the DONE state.
   The memory controller now supports Back-to-Back (Pipelined) writes!
========================================================================= */

module memory_controller (
    input logic clk,
    input logic rst_n, 

    // PORT A: Interface from the Main Game Controller
    input  logic [ 7:0] mem_addr,        
    input  logic [15:0] mem_write_data,  
    input  logic        mem_we,          
    input  logic        mem_req,         
    output logic        mem_ack,         
    output logic [15:0] mem_read_data,   

    // PORT B: Interface to the VGA Sweeper
    input  logic [ 7:0] vga_addr,        
    output logic [15:0] vga_read_data   
);

  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    READ  = 2'b01,
    WRITE = 2'b10,
    DONE  = 2'b11
  } state_t;

  state_t current_state, next_state;

  logic [15:0] memory_array [0:255];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) current_state <= IDLE;
    else        current_state <= next_state;
  end

  // =======================================================
  // KOMBİNASYONEL DURUM GEÇİŞİ (KİLİTLENMELER KALDIRILDI)
  // =======================================================
  always_comb begin
    next_state = current_state;
    case (current_state)
      IDLE: begin
        if (mem_req) begin
          if (mem_we) next_state = WRITE;
          else        next_state = READ;
        end
      end
      READ:  next_state = DONE;
      WRITE: next_state = DONE;
      DONE:  next_state = IDLE; // <-- SİHİRLİ DÜZELTME BURASI! (Artık mem_req'in 0 olmasını beklemeden direkt IDLE'a dönüyor!)
      default: next_state = IDLE;
    endcase
  end

  // =======================================================
  // 1-CYCLE PULSE ONAY SİNYALİ (FSM'İ KANDIRMAYAN ACK)
  // =======================================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_ack       <= 1'b0;
      mem_read_data <= 16'd0;
    end else begin
      mem_ack <= 1'b0; // Varsayılan: Hep 0 kal, sadece iş bitince 1 ol.

      case (current_state)
        READ: begin
          mem_read_data <= memory_array[mem_addr];
          mem_ack       <= 1'b1;  // Bir sonraki clock (DONE) için 1 yap
        end
        WRITE: begin
          memory_array[mem_addr] <= mem_write_data;
          mem_ack                <= 1'b1;  // Bir sonraki clock (DONE) için 1 yap
        end
        DONE: begin
          mem_ack <= 1'b0;  // Bir sonraki clock (IDLE) için hemen 0 yap! FSM takılmasın.
        end
      endcase
    end
  end

  // PORT B: VGA
  assign vga_read_data = memory_array[vga_addr];

endmodule