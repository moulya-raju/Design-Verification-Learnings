//==============================================================
// TEST FILE
// Contains all tests for APB UVM Testbench
//==============================================================

//==============================================================
// BASE TEST - all other tests extend this
//==============================================================
class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)

  apb_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  // Common pass/fail report at end of every test
  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    svr = uvm_report_server::get_server();
    if(svr.get_severity_count(UVM_ERROR) == 0)
      `uvm_info("TEST_STATUS", "*** TEST PASSED ***", UVM_LOW)
    else
      `uvm_error("TEST_STATUS", "*** TEST FAILED ***")
  endfunction

endclass

//==============================================================
// ORIGINAL TEST - kept exactly as is
//==============================================================
class apb_test extends apb_base_test;
  `uvm_component_utils(apb_test)

  apb_seq seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("APB_TEST", "Starting Main Coverage Test", UVM_LOW)
    seq = apb_seq::type_id::create("seq");
    seq.start(env.agt.seqr);
    #200;
    phase.drop_objection(this);
  endtask

endclass

//==============================================================
// WRITE TEST - writes to every address
//==============================================================
class apb_write_test extends apb_base_test;
  `uvm_component_utils(apb_write_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_seq seq;
    phase.raise_objection(this);
    `uvm_info("WRITE_TEST", "Starting Write Test", UVM_LOW)
    seq = apb_write_seq::type_id::create("seq");
    seq.start(env.agt.seqr);
    #200;
    phase.drop_objection(this);
  endtask

endclass

//==============================================================
// READ TEST - writes first then reads back all addresses
//==============================================================
class apb_read_test extends apb_base_test;
  `uvm_component_utils(apb_read_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_seq wseq;
    apb_read_seq  rseq;
    phase.raise_objection(this);
    `uvm_info("READ_TEST", "Starting Read Test", UVM_LOW)

    // Write first so reads have valid data
    wseq = apb_write_seq::type_id::create("wseq");
    wseq.start(env.agt.seqr);

    // Then read back all addresses
    rseq = apb_read_seq::type_id::create("rseq");
    rseq.start(env.agt.seqr);

    #200;
    phase.drop_objection(this);
  endtask

endclass

//==============================================================
// ERROR TEST - out of bounds addresses, checks pslverr
//==============================================================
class apb_error_test extends apb_base_test;
  `uvm_component_utils(apb_error_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_error_seq seq;
    phase.raise_objection(this);
    `uvm_info("ERROR_TEST", "Starting Error Test", UVM_LOW)
    seq = apb_error_seq::type_id::create("seq");
    seq.start(env.agt.seqr);
    #200;
    phase.drop_objection(this);
  endtask

endclass

//==============================================================
// STRESS TEST - 50000 random transactions
//==============================================================
class apb_stress_test extends apb_base_test;
  `uvm_component_utils(apb_stress_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_stress_seq seq;
    phase.raise_objection(this);
    `uvm_info("STRESS_TEST", "Starting Stress Test", UVM_LOW)
    seq = apb_stress_seq::type_id::create("seq");
    seq.start(env.agt.seqr);
    #200;
    phase.drop_objection(this);
  endtask

endclass
