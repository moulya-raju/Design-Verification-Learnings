//==============================================================
// SEQUENCE FILE
// Contains all sequences for APB UVM Testbench
//==============================================================

//==============================================================
// BASE SEQUENCE - all other sequences extend this
//==============================================================
class apb_base_seq extends uvm_sequence #(apb_txn);
  `uvm_object_utils(apb_base_seq)

  function new(string name="apb_base_seq");
    super.new(name);
  endfunction

  // Helper task to send a write transaction
  task send_write(bit [31:0] addr, bit [31:0] wdata);
    apb_txn tr;
    tr = apb_txn::type_id::create("tr");
    start_item(tr);
    tr.write = 1;
    tr.addr  = addr;
    tr.wdata = wdata;
    finish_item(tr);
  endtask

  // Helper task to send a read transaction
  task send_read(bit [31:0] addr);
    apb_txn tr;
    tr = apb_txn::type_id::create("tr");
    start_item(tr);
    tr.write = 0;
    tr.addr  = addr;
    finish_item(tr);
  endtask

endclass

//==============================================================
// WRITE SEQUENCE - writes to every address once
//==============================================================
class apb_write_seq extends apb_base_seq;
  `uvm_object_utils(apb_write_seq)

  function new(string name="apb_write_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("WRITE_SEQ", "Writing to all 32 addresses", UVM_LOW)
    for(int i = 0; i < 32; i++) begin
      send_write(i, $urandom);
    end
  endtask

endclass

//==============================================================
// READ SEQUENCE - reads from every address once
//==============================================================
class apb_read_seq extends apb_base_seq;
  `uvm_object_utils(apb_read_seq)

  function new(string name="apb_read_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("READ_SEQ", "Reading from all 32 addresses", UVM_LOW)
    for(int i = 0; i < 32; i++) begin
      send_read(i);
    end
  endtask

endclass

//==============================================================
// ERROR SEQUENCE - sends out of bounds addresses
// Covers: pslverr=1 path, paddr>=32 branch
//==============================================================
class apb_error_seq extends apb_base_seq;
  `uvm_object_utils(apb_error_seq)

  function new(string name="apb_error_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("ERROR_SEQ", "Sending out of bounds addresses", UVM_LOW)

    // Out of bounds writes
    repeat(10) begin
      send_write($urandom_range(32, 255), $urandom);
    end

    // Out of bounds reads
    repeat(10) begin
      send_read($urandom_range(32, 255));
    end

  endtask

endclass

//==============================================================
// STRESS SEQUENCE - 50000 random transactions
// Covers: all address ranges, read/write mix
//==============================================================
class apb_stress_seq extends apb_base_seq;
  `uvm_object_utils(apb_stress_seq)

  function new(string name="apb_stress_seq");
    super.new(name);
  endfunction

  task body();
    apb_txn tr;
    `uvm_info("STRESS_SEQ", "Starting 50000 random transactions", UVM_LOW)

    repeat(50000) begin
      tr = apb_txn::type_id::create("tr");
      start_item(tr);
      tr.write = $urandom_range(0,1);
      tr.addr  = $urandom_range(0,31);
      tr.wdata = $urandom;
      finish_item(tr);
    end

  endtask

endclass

//==============================================================
// MAIN SEQUENCE - coverage focused
// Covers: random, write_after_read, corner values, transitions
//==============================================================
class apb_seq extends apb_base_seq;
  `uvm_object_utils(apb_seq)

  bit [31:0] corner_addrs[$] = '{0, 5, 10, 15, 20, 25, 31};

  function new(string name="apb_seq");
    super.new(name);
  endfunction

  task body();
    // ----------------------------------------------------------
    // SCENARIO 1: RANDOM READ/WRITE
    // Covers: all address ranges, read/write mix, toggle bins
    // ----------------------------------------------------------
    `uvm_info("APB_SEQ", "Scenario 1: Random Read/Write", UVM_LOW)
    repeat(10000) begin
      apb_txn tr;
      tr = apb_txn::type_id::create("tr");
      start_item(tr);
      tr.write = $urandom_range(0,1);
      tr.addr  = $urandom_range(0,31);
      tr.wdata = $urandom;
      finish_item(tr);
    end

    // ----------------------------------------------------------
    // SCENARIO 2: WRITE AFTER READ
    // Covers: write_after_read transition bin
    // ----------------------------------------------------------
    `uvm_info("APB_SEQ", "Scenario 2: Write After Read", UVM_LOW)
    repeat(10) begin
      send_read($urandom_range(0,31));
      send_write($urandom_range(0,31), $urandom);
    end

    // ----------------------------------------------------------
    // SCENARIO 3: CORNER DATA VALUES
    // Covers: all_ones, alternating_a, alternating_5 bins
    // ----------------------------------------------------------
    `uvm_info("APB_SEQ", "Scenario 3: Corner Data Values", UVM_LOW)
    foreach(corner_addrs[i]) begin

      // all_ones: write, read, write_after_read, read_after_write
      send_write(corner_addrs[i], 32'hFFFF_FFFF);
      send_read(corner_addrs[i]);
      send_read(corner_addrs[i]);
      send_write(corner_addrs[i], 32'hFFFF_FFFF);
      send_write(corner_addrs[i], 32'hFFFF_FFFF);
      send_read(corner_addrs[i]);

      // alternating_a: write, read, back_to_back, read_after_write
      send_write(corner_addrs[i], 32'hAAAA_AAAA);
      send_read(corner_addrs[i]);
      send_write(corner_addrs[i], 32'hAAAA_AAAA);
      send_write(corner_addrs[i], 32'hAAAA_AAAA);
      send_write(corner_addrs[i], 32'hAAAA_AAAA);
      send_read(corner_addrs[i]);

      // alternating_5: write, read, back_to_back, read_after_write
      send_write(corner_addrs[i], 32'h5555_5555);
      send_read(corner_addrs[i]);
      send_write(corner_addrs[i], 32'h5555_5555);
      send_write(corner_addrs[i], 32'h5555_5555);
      send_write(corner_addrs[i], 32'h5555_5555);
      send_read(corner_addrs[i]);

      // Transition: min_to_max
      send_write(corner_addrs[i], 32'h0000_0000);
      send_write(corner_addrs[i], 32'hFFFF_FFFF);

      // Transition: max_to_min
      send_write(corner_addrs[i], 32'hFFFF_FFFF);
      send_write(corner_addrs[i], 32'h0000_0000);

      // Transition: zero_to_nonzero
      send_write(corner_addrs[i], 32'h0000_0000);
      send_write(corner_addrs[i], 32'hDEAD_BEEF);

    end

  endtask

endclass
