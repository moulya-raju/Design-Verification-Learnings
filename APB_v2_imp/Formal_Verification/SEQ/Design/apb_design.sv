module apb_ram #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int MEM_DEPTH  = 32
)(
  input  logic                  pclk,
  input  logic                  presetn,

  input  logic                  psel,
  input  logic                  penable,
  input  logic                  pwrite,
  input  logic [ADDR_WIDTH-1:0] paddr,
  input  logic [DATA_WIDTH-1:0] pwdata,

  output logic [DATA_WIDTH-1:0] prdata,
  output logic                  pready,
  output logic                  pslverr
);

  //============================================================
  // MEMORY
  //============================================================
  logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

  //============================================================
  // APB INTERNAL DECODE
  //============================================================
  logic apb_access;
  logic valid_addr;

  assign apb_access = psel && penable;
  assign valid_addr = (paddr < MEM_DEPTH);

  // No wait-state slave
  assign pready = 1'b1;

  //============================================================
  // APB READ/WRITE/ERROR LOGIC
  //============================================================
  integer i;

  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      prdata  <= 32'b0;
      pslverr <= 1'b0;

      for (i = 0; i < MEM_DEPTH; i = i + 1)
        mem[i] <= '0;
    end
    else begin
      // Default: no error
      pslverr <= 1'b0;

      // ACCESS phase only
      if (apb_access) begin

        if (valid_addr) begin
          pslverr <= 1'b0;

          if (pwrite) begin
            mem[paddr] <= pwdata;
          end
          else begin
            prdata <= mem[paddr];
          end
          
        end
        
        
        else begin
          pslverr <= 1'b1;
        end

      end
    end
  end

endmodule
