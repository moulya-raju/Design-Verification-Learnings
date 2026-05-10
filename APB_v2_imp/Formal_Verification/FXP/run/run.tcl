#============================================================
# VC Formal FXP TCL Script for APB RAM
#============================================================

set_fml_appmode FXP

# Unique property names for FXP/AEP
set_fml_var fml_aep_unique_name true

# Enable automatic root-cause analysis
set_fml_var fxp_compute_rootcause_auto true

# Read RTL and generate automatic endpoint properties
read_file -top apb_ram -format sverilog -sva -vcs  {/u/moulya/LEARNINGS/APB_v2_imp/RTL/apb_design.sv}

# Create actual RTL clock and reset
create_clock pclk -period 100
create_reset presetn -sense low

# Run reset simulation and save initialized state
sim_run -stable
sim_save_reset

# Generate FXP checks
fxp_generate

# Optional: run all generated properties
# check_fv
