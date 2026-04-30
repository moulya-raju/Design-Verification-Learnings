module seq_top ;
    edge_detection  spec( );
    edge_detection_netlist  impl( );
endmodule

config seq_config_cfg1;
    design work.seq_top;
    default liblist work SPEC IMPL DW01 DW02 DW03 DW04 DW05 DW06 DWARE GTECH;
    instance seq_top.spec liblist SPEC DW01 DW02 DW03 DW04 DW05 DW06 DWARE GTECH;
    instance seq_top.impl liblist IMPL DW01 DW02 DW03 DW04 DW05 DW06 DWARE GTECH;
endconfig

