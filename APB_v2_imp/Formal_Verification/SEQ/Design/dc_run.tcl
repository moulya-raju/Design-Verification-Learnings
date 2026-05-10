lappend search_path u/moulya/FV_S2_DC_SYN/EQ/Design
set target_library osu05_stdcells.db
set link_library [concat "*" $target_library]
link
read_file -format sverilog /u/moulya/LEARNINGS/APB_v2_imp/Formal_Verification/Design/apb_design.sv
current_design apb_ram
compile
report_area
report_cell
report_power

write -format Verilog -hierarchy -output apb_ram_gls.netlist
link
