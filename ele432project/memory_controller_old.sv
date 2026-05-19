// memory_controller.sv

module memory_controller (
    input logic clk,
    input logic rst_n, // Active-low reset

    // PORT A: Interface from the Main Game Controller (UNCHANGED)
    input  logic [ 7:0] mem_addr,        // Which memory slot to look at (0-255)
    input  logic [15:0] mem_write_data,  // Data to save (if writing)
    input  logic        mem_we,          // Write Enable (1 = Write, 0 = Read)
    input  logic        mem_req,         // Signal to start the operation
    output logic        mem_ack,         // Signal that operation is done
    output logic [15:0] mem_read_data,   // Data retrieved (if reading)
    // ========================================================================

    // PORT B: Interface to the VGA Sweeper (NEW)
    input  logic [ 7:0] vga_addr,      // VGA asks for an address
    output logic [15:0] vga_read_data  // RAM spits out the data
    //=========================================================================
);

  // 1. Define FSM States using SystemVerilog 'enum'
  // This makes simulation debugging much easier because Questa will show 
  // the state names (IDLE, READ) instead of just numbers (00, 01).
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    READ  = 2'b01,
    WRITE = 2'b10,
    DONE  = 2'b11
  } state_t;

  state_t current_state, next_state;

  // 2. The Actual Memory Block
  // Quartus will automatically infer this as Block RAM (BRAM) inside the FPGA
  (* ram_init_file = "mif1.mif" *)
  logic [15:0] memory_array[0:255];

  // ==========================================
  // FSM BLOCK 1: State Register (Sequential)
  // ==========================================
  // always_ff guarantees this block creates flip-flops
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // ==========================================
  // FSM BLOCK 2: Next State Logic (Combinational)
  // ==========================================
  // always_comb automatically updates when any input changes
  always_comb begin
    // Default assignment prevents accidental latches
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (mem_req) begin
          if (mem_we) next_state = WRITE;
          else next_state = READ;
        end
      end

      READ: begin
        next_state = DONE;  // Reading from BRAM takes 1 clock cycle
      end

      WRITE: begin
        next_state = DONE;  // Writing to BRAM takes 1 clock cycle
      end

      DONE: begin
        if (!mem_req)  // Wait for the Main FSM to acknowledge and drop the request
          next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  // ==========================================
  // FSM BLOCK 3: Memory Operations (Sequential)
  // ==========================================
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_ack       <= 1'b0;
      mem_read_data <= 16'd0;
    end else begin
      // Default acknowledge state
      mem_ack <= 1'b0;

      case (current_state)
        READ: begin
          mem_read_data <= memory_array[mem_addr];
          mem_ack       <= 1'b1;  // Tell Main FSM data is ready
        end

        WRITE: begin
          memory_array[mem_addr] <= mem_write_data;
          mem_ack                <= 1'b1;  // Tell Main FSM write is done
        end

        DONE: begin
          mem_ack <= 1'b1;  // Hold the acknowledge high until the request drops
        end
      endcase
    end
  end

  // ==========================================
  // PORT B: The VGA Read Logic (NEW)
  // ==========================================
  // infers a hardware Dual-Port Block RAM

  always_ff @(posedge clk) begin
    vga_read_data <= memory_array[vga_addr];
  end

endmodule
