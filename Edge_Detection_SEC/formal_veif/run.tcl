# ============================================================
# VC Formal Sequential Equivalence Checking Script
# ============================================================

set_fml_appmode SEQ

# ------------------------------------------------------------
# Read Standard Cell Library
# ------------------------------------------------------------
read_file ../RTL/osu05_stdcells.v

# ------------------------------------------------------------
# Read RTL (spec) and GLS (impl)
# ------------------------------------------------------------
analyze -format sverilog -library spec ../RTL/edge_detector.sv
analyze -format sverilog -library impl ../RTL/edge_detection_gls.sv

# ------------------------------------------------------------
# Elaborate Designs
# ------------------------------------------------------------
elaborate_seq -spectop edge_detection -impltop edge_detection_netlist

# ------------------------------------------------------------
# Map by name
# ------------------------------------------------------------
map_by_name

# ------------------------------------------------------------
# Clock and Reset
# ------------------------------------------------------------
create_clock -period 100 spec.clk
create_reset spec.rst -sense high

# ------------------------------------------------------------
# Run reset simulation
# ------------------------------------------------------------
sim_run -stable
sim_save_reset



#mapping unintialized registors using SEQ config

seq_config -map_uninit -map_x zero

# ------------------------------------------------------------
# Run Formal Check
# ------------------------------------------------------------
check_fv
