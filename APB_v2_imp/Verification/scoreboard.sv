//==============================================================
// SCOREBOARD (VALIDATION HAPPENS HERE)
//==============================================================
class apb_scoreboard extends uvm_component;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_txn, apb_scoreboard) imp;

  bit [31:0] model_mem [32];

  function new(string name, uvm_component parent);
    super.new(name,parent);
    imp = new("imp",this);
  endfunction

  function void write(apb_txn tr);

    if(tr.write) begin
      model_mem[tr.addr] = tr.wdata;
      `uvm_info("WRITE",
                $sformatf("WRITE=%0d ADDR=%0d DATA=%0h written to memory",
                          tr.write,tr.addr, tr.wdata), UVM_LOW)
      
    end
    else begin
      if(model_mem[tr.addr] !== tr.rdata)
        `uvm_error("READ MISMATCH",
                   $sformatf("Write=%0d ADDR=%0d EXP=%0h GOT=%0h",tr.write,
          tr.addr, model_mem[tr.addr], tr.rdata))
      else
        `uvm_info("READ MATCH",
                  $sformatf("Write=%0d ADDR=%0d EXP=%0h GOT=%0h OK",
                            tr.write,tr.addr,model_mem[tr.addr], tr.rdata), UVM_LOW)
    end
  endfunction
endclass
