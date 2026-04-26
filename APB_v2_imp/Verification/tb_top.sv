`timescale 1ns/1ps
import uvm_pkg::*;          
`include "uvm_macros.svh"

`include "interface.sv"

import apb_pkg::*;

//==============================================================
// TOP
//==============================================================
module tb_top;

  bit pclk = 0;
  always #5 pclk = ~pclk;

  apb_if vif(pclk);

  apb_ram dut(
    .presetn(vif.presetn),
    .pclk(pclk),
    .psel(vif.psel),
    .penable(vif.penable),
    .pwrite(vif.pwrite),
    .paddr(vif.paddr),
    .pwdata(vif.pwdata),
    .prdata(vif.prdata),
    .pready(vif.pready),
    .pslverr(vif.pslverr)
  );

  initial begin
    vif.presetn = 0;
    vif.psel = 0;
    vif.penable = 0;
    vif.pwrite = 0;
    vif.paddr = 0;
    vif.pwdata = 0;

    repeat(2) @(posedge pclk);
    vif.presetn = 1;
  end

  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"*","vif",vif);
    run_test("apb_test");
  end

endmodule
