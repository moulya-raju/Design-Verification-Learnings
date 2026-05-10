#============================================================
# VC Formal FCA / COV TCL Script for APB RAM
#============================================================

set_fml_appmode COV

set design apb_ram

read_file -top $design -format sverilog -sva -vcs {
  /u/moulya/LEARNINGS/APB_v2_imp/RTL/apb_design.sv
} -cov all

create_clock pclk -period 100
create_reset presetn -sense low

sim_run -stable
sim_save_reset

# Run coverage analysis
check_fv


