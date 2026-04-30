lappend search_path u/moulya/FV/Edge_Detection/RTL
set target_library osu05_stdcells.db
set link_library [concat "*" $target_library]
link
read_file -format sverilog /u/moulya/FV/Edge_Detection/RTL/edge_detector.sv
current_design edge_detection
compile
report_area
report_cell
report_power

write -format Verilog -hierarchy -output edge_detection.netlist
link
