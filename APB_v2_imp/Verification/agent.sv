//==============================================================
// AGENT
//==============================================================
class apb_agent extends uvm_component;
  `uvm_component_utils(apb_agent)

  apb_driver drv;
  uvm_sequencer #(apb_txn) seqr;
  apb_monitor mon;

  virtual apb_if vif;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Agent vif not set")

    drv  = apb_driver::type_id::create("drv",this);
    seqr = uvm_sequencer#(apb_txn)::type_id::create("seqr",this);
    mon  = apb_monitor::type_id::create("mon",this);

    uvm_config_db#(virtual apb_if)::set(this,"drv","vif",vif);
    uvm_config_db#(virtual apb_if)::set(this,"mon","vif",vif);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
