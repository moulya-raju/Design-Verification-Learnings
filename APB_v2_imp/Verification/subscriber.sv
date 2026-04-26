///============================================================
//COVERAGE
//=============================================================
class apb_coverage extends uvm_subscriber #(apb_txn);
  `uvm_component_utils(apb_coverage)
  apb_txn tr;
  real coverage_score; // To store the percentage
  //==============================================================
  // COVERGROUP
  //==============================================================
  covergroup apb_cg;
    option.per_instance = 1; // Allows tracking coverage for this specific instance
    option.name = "APB_Functional_Coverage";
    // 1. ADDRESS COVERAGE
    cp_addr: coverpoint tr.addr {
      bins low_range    = { [0:10] };
      bins mid_range    = { [11:21] };
      bins high_range   = { [22:31] };
      illegal_bins out_of_bounds = { [32:$] };
      ignore_bins skip_13 = { 13 };
    }
    // 2. DIRECTION COVERAGE
    cp_write: coverpoint tr.write {
      bins read_write[] = {0, 1};
      bins write_after_read  = (0 => 1);
      bins read_after_write  = (1 => 0);
      bins back_to_back_wr   = (1 [* 2]);
    }
    // 3. DATA BUCKETS
    cp_wdata: coverpoint tr.wdata {
      bins data_buckets[4] = {[0:$]};
    }
    // 4. CROSS
    cross_addr_write: cross cp_addr, cp_write;

    // 5. INDIVIDUAL ADDRESS WALKING
    // Ensures every single memory location is accessed
    cp_addr_walk: coverpoint tr.addr {
      bins addr_walk[32] = { [0:31] };
    }

    // 6. WDATA CORNER CASES
    // Ensures critical data patterns are written
    cp_wdata_corners: coverpoint tr.wdata {
      bins all_zeros     = { 32'h0000_0000 };  // all bits 0
      bins all_ones      = { 32'hFFFF_FFFF };  // all bits 1
      bins alternating_a = { 32'hAAAA_AAAA };  // 1010...
      bins alternating_5 = { 32'h5555_5555 };  // 0101...
      bins all_others    = default;
    }

    // 7. ADDRESS BOUNDARY COVERAGE
    // Ensures first and last valid addresses are hit
    cp_addr_boundary: coverpoint tr.addr {
      bins first_addr = { 0  };   // first valid address
      bins last_addr  = { 31 };   // last valid address
      bins others     = default;
    }

    // 8. WRITE DATA TRANSITION
    // Covers interesting data transitions
    cp_wdata_transition: coverpoint tr.wdata {
      bins zero_to_nonzero = (32'h0 => [32'h1:32'hFFFF_FFFF]);
      bins nonzero_to_zero = ([32'h1:32'hFFFF_FFFF] => 32'h0);
      bins max_to_min      = (32'hFFFF_FFFF => 32'h0);
      bins min_to_max      = (32'h0 => 32'hFFFF_FFFF);
    }

    // 9. CROSS: ADDRESS BOUNDARY vs DIRECTION
    // Ensures reads and writes happen at boundary addresses
    cross_boundary_write: cross cp_addr_boundary, cp_write;

    
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_cg = new();
  endfunction
  
  // Sample coverage every time a transaction arrives
  virtual function void write(apb_txn t);
    this.tr = t;
    apb_cg.sample();
  endfunction

  //==============================================================
  // DISPLAY FUNCTIONS
  //==============================================================
  // Manual display function
  function void display_coverage();
    coverage_score = apb_cg.get_inst_coverage();
    `uvm_info("COV_REPORT", $sformatf("Current APB Coverage: %0.2f%%", coverage_score), UVM_LOW)
  endfunction

  // Standard UVM Report Phase (automatically called at end of simulation)
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    display_coverage();
    
    // Display if you hit 100%
    if (apb_cg.get_inst_coverage() >= 100.0) begin
      `uvm_info("COV_REPORT", "GOAL REACHED: 100% Functional Coverage!", UVM_LOW)
    end
  endfunction

endclass
