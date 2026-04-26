# ============================================================
# QuestaSim Run Script - APB UVM Project
# Usage:
#   vsim -do run.do        (GUI mode - with waveforms)
#   vsim -c -do run.do     (batch mode - no waveforms)
# ============================================================

# Step 1: Clean previous work library
if {[file exists work]} {
    vdel -lib work -all
}

# Step 2: Create fresh work library
vlib work
vmap work work

# Step 3: Compile RTL
vlog -sv ../RTL/apb_design.sv

# Step 4: Compile Interface (must be before package)
vlog -sv interface.sv

# Step 5: Compile Package (contains all TB classes)
vlog -sv package.sv

# Step 6: Compile Top (last always)
vlog -sv tb_top.sv

# Step 7: Simulate
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random

# Step 8: Add waveforms
add wave -divider "CLOCK AND RESET"
add wave -color cyan       sim:/tb_top/pclk
add wave -color red        sim:/tb_top/vif/presetn

add wave -divider "APB CONTROL SIGNALS"
add wave -color yellow     sim:/tb_top/vif/psel
add wave -color yellow     sim:/tb_top/vif/penable
add wave -color yellow     sim:/tb_top/vif/pwrite

add wave -divider "APB ADDRESS AND DATA"
add wave -color white -hex sim:/tb_top/vif/paddr
add wave -color white -hex sim:/tb_top/vif/pwdata
add wave -color white -hex sim:/tb_top/vif/prdata

add wave -divider "APB RESPONSE SIGNALS"
add wave -color green      sim:/tb_top/vif/pready
add wave -color red        sim:/tb_top/vif/pslverr

add wave -divider "DUT FSM STATE"
add wave -color orange     sim:/tb_top/dut/state

# Step 9: Configure waveform window
wave zoom full

# Step 10: Run simulation
run -all

# Step 11: Zoom to fit all waves after simulation
wave zoom full
