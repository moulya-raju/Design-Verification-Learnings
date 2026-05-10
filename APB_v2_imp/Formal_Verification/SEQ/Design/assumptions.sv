bind apb_ram apb_assumptions u_apb_assume (.pclk(pclk));

assume property (@(posedge pclk)
  !(psel && penable && !pwrite)
);
