module apb_ram (
  input               pclk,
  input               presetn,
  input               psel,
  input               penable,
  input               pwrite,
  input        [31:0] paddr,
  input        [31:0] pwdata,
  output reg   [31:0] prdata,
  output              pready,
  output reg          pslverr
);

  // Memory Array: 32 entries of 32-bit data
  reg [31:0] mem [0:31];

  // State Encoding based on your block diagram
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
  } state_t;

  state_t state;

  // PREADY = 1 ensures a standard 2-cycle transfer (Setup + Access)
  assign pready = 1'b1;

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      state   <= IDLE;
      prdata  <= 32'h0;
      pslverr <= 1'b0;
    end else begin
      case (state)

        // 1. IDLE State: Wait for PSEL from Master
        IDLE: begin
          pslverr <= 1'b0;
          if (psel && !penable) begin
            state <= SETUP;
          end
        end

        // 2. SETUP State: Data preparation
        SETUP: begin
          state <= ACCESS;
          
          // Check if address is within array bounds (0 to 31)
          if (paddr < 32) begin
            pslverr <= 1'b0;
            if (!pwrite) begin
              prdata <= mem[paddr]; // Direct indexing
            end
          end else begin
            pslverr <= 1'b1; // Error if address is out of bounds
          end
        end

        // 3. ACCESS State: Finalize transfer and check for next transfer
        ACCESS: begin
          // Perform the write only if address is valid
          if (pwrite && (paddr < 32)) begin
            mem[paddr] <= pwdata; 
          end

          // Determine Next State based on diagram arrows:
          if (psel && !penable) begin
            // "Transfer" -> Back to SETUP for back-to-back operation
            state <= SETUP;
            
            // Re-evaluate read/error for the next address immediately
            if (paddr < 32) begin
              pslverr <= 1'b0;
              if (!pwrite) prdata <= mem[paddr];
            end else begin
              pslverr <= 1'b1;
            end
          end else begin
            // "No transfer" -> Return to IDLE
            state <= IDLE;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
