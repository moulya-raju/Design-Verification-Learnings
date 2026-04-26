# ============================================================
# Regression Script - APB UVM Project
# Runs all tests sequentially and reports pass/fail
# Usage: do regression.do
# ============================================================

# ============================================================
# STEP 1: Clean previous work library (compile once for all tests)
# ============================================================
if {[file exists work]} {
    vdel -lib work -all
}

# ============================================================
# STEP 2: Create fresh work library
# ============================================================
vlib work
vmap work work

# ============================================================
# STEP 3: Compile all files (compile ONCE, run multiple tests)
# ============================================================
echo "===== Compiling RTL ====="
vlog -sv ../RTL/apb_design.sv

echo "===== Compiling Interface ====="
vlog -sv interface.sv

echo "===== Compiling Package ====="
vlog -sv package.sv

echo "===== Compiling Top ====="
vlog -sv tb_top.sv

# ============================================================
# STEP 4: Run all tests
# ============================================================

# --- TEST 2: Read Test ---
echo "===== Running apb_read_test ====="
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_read_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random
run -all
quit -sim
echo "===== Done apb_read_test ====="


# --- TEST 1: Main Coverage Test ---
echo "===== Running apb_test ====="
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random
run -all
quit -sim
echo "===== Done apb_test ====="



# --- TEST 3: Write Test ---
echo "===== Running apb_write_test ====="
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_write_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random
run -all
quit -sim
echo "===== Done apb_write_test ====="


# --- TEST 4: Error Test ---
echo "===== Running apb_error_test ====="
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_error_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random
run -all
quit -sim

# --- TEST 5: Stress Test ---
echo "===== Running apb_stress_test ====="
vsim -t 1ns \
     -voptargs="+acc" \
     work.tb_top \
     +UVM_TESTNAME=apb_stress_test \
     +UVM_VERBOSITY=UVM_LOW \
     -sv_seed random
run -all
quit -sim
echo "===== Done apb_stress_test ====="

echo "===== Regression Complete ====="
