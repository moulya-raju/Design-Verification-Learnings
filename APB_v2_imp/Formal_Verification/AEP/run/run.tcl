set_fml_appmode AEP

set_fml_var fml_aep_unique_name true
read_file -top apb_ram -format sverilog -aep all -vcs {/u/moulya/LEARNINGS/APB_v2_imp/RTL/apb_design.sv}

create_clock pclk -period 100
create_reset presetn -period low

sim_run -stable
sim_save_reset
