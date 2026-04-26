//==============================================================
// DRIVER
//==============================================================
class apb_driver extends uvm_driver #(apb_txn);
  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Driver: virtual interface not set")
  endfunction

  task run_phase(uvm_phase phase);
    apb_txn tr;

    forever begin
      seq_item_port.get_next_item(tr);
      drive(tr);
      seq_item_port.item_done();
    end
  endtask

  task drive(apb_txn tr);
    @(posedge vif.pclk);

    vif.psel   <= 1;
    vif.pwrite <= tr.write;
    vif.paddr  <= tr.addr;
    vif.pwdata <= tr.wdata;
    vif.penable<= 0;			//SETUP

    @(posedge vif.pclk);
    vif.penable <= 1;			//ACCESS

    @(posedge vif.pclk);
    vif.psel    <= 0;
    vif.penable <= 0;		//BACK to IDLE
  endtask
endclass




