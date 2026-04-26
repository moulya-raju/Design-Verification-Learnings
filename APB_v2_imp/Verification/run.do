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

# Step 8: Run
run -all

quit -sim
