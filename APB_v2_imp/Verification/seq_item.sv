//==============================================================
// TRANSACTION
//==============================================================
class apb_txn extends uvm_sequence_item;
  rand bit        write;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
        bit [31:0] rdata;

  `uvm_object_utils(apb_txn)

  function new(string name="apb_txn");
    super.new(name);
  endfunction

  

  //------------------------------------------------------------
  // CONSTRAINT 1: Weighted read/write distribution
  // 70% writes, 30% reads - realistic memory traffic
  //------------------------------------------------------------
  constraint rw_dist_c {
    write dist {1 := 70, 0 := 30};
  }

  
  //------------------------------------------------------------
  // CONSTRAINT 2: Corner data values weighted
  // Give higher probability to corner values for better coverage
  //------------------------------------------------------------
  constraint corner_data_c {
    wdata dist {
      32'h0000_0000 := 5,   // all zeros
      32'hFFFF_FFFF := 5,   // all ones
      32'hAAAA_AAAA := 5,   // alternating 1010
      32'h5555_5555 := 5,   // alternating 0101
      32'hDEAD_BEEF := 5,   // common debug pattern
      [32'h0000_0001 : 32'hFFFFFFFE] := 75  // random values
    };
  }

  //------------------------------------------------------------
  // CONSTRAINT 3: Boundary addresses weighted
  // Give higher probability to boundary addresses
  //------------------------------------------------------------
  constraint boundary_addr_c {
    addr dist {
      0              := 10,  // first address
      31             := 10,  // last address
      [1:30]         := 80   // middle addresses
    };
  }

endclass
