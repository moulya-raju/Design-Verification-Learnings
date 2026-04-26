//==============================================================
// MONITOR
//==============================================================
class apb_monitor extends uvm_component;
  `uvm_component_utils(apb_monitor)

  virtual apb_if vif;
  uvm_analysis_port #(apb_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Monitor vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    apb_txn tr;

    forever begin
      @(posedge vif.pclk);

      // SAMPLE ONLY AFTER TRANSFER PHASE (VALID DATA TIME)
      if(vif.psel && vif.penable && !vif.pwrite) begin
        tr = apb_txn::type_id::create("tr");

        tr.addr  = vif.paddr;
        tr.write = 0;

        // WAIT 1 CYCLE FOR DUT TO DRIVE STABLE PRDATA
        @(posedge vif.pclk);
        tr.rdata = vif.prdata;

        ap.write(tr);
      end

      else if(vif.psel && vif.penable && vif.pwrite) begin
        tr = apb_txn::type_id::create("tr");
        tr.addr  = vif.paddr;
        tr.write = 1;
        tr.wdata = vif.pwdata;
        ap.write(tr);
      end
    end
  endtask
endclass
