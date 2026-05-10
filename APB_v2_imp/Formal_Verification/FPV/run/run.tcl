#============================================================
# VC Formal FPV TCL Script for APB RAM
#============================================================

set_fml_appmode FPV

set design apb_ram

read_file -top $design -format sverilog -sva -vcs {
  /u/moulya/LEARNINGS/APB_v2_imp/RTL/apb_design.sv
  +define+FORMAL
}

create_clock pclk -period 100
create_reset presetn -sense low

sim_run -stable
sim_save_reset

check_fv

report_fv -lis#============================================================
# VC Formal FPV TCL Script for APB RAM
#============================================================

set_fml_appmode FPV

set design apb_ram

read_file -top $design -format sverilog -sva -vcs {
  /u/moulya/LEARNINGS/APB_v2_imp/RTL/apb_design.sv
  +define+FORMAL
}

create_clock pclk -period 100
create_reset presetn -sense low

sim_run -stable
sim_save_reset

check_fv

report_fv -list
