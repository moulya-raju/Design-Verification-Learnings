# ============================================================
# VC Formal Sequential Equivalence Checking Script
# ============================================================

set_fml_appmode SEQ

# ------------------------------------------------------------
# Read Standard Cell Library
# ------------------------------------------------------------
read_file ../Design/osu05_stdcells.v

# ------------------------------------------------------------
# Read RTL (spec) and GLS (impl)
# ------------------------------------------------------------
analyze -format sverilog -library spec ../Design/apb_design.sv
analyze -format sverilog -library impl ../Design/apb_ram_gls.sv
analyze -format sverilog -library spec ../Design/assumptions.sv

# ------------------------------------------------------------
# Elaborate Designs
# ------------------------------------------------------------
elaborate_seq -spectop apb_ram -impltop apb_ram

# ------------------------------------------------------------
# Map by name
# ------------------------------------------------------------
map_by_name

# ------------------------------------------------------------
# Clock and Reset
# ------------------------------------------------------------
create_clock -period 100 spec.pclk
create_reset spec.presetn -sense low

# ------------------------------------------------------------
# Run reset simulation
# ------------------------------------------------------------
sim_run -stable
sim_save_reset

# ------------------------------------------------------------
# Handle Uninitialized Registers
# ------------------------------------------------------------
seq_config -map_uninit -map_x zero

# ------------------------------------------------------------
# Prevent read-before-write (FIXED)
# ------------------------------------------------------------
add_assumption -name apb_no_illegal_read \
  "!(spec.psel && spec.penable && !spec.pwrite)"

# ------------------------------------------------------------
# Run Formal Check
# ------------------------------------------------------------
check_fv
