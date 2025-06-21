vlib work
vdel -all
vlib work

# Compile RTL and Testbench
vlog  router_dut.sv
vlog  testbench.sv
vlog  top_if.sv
# Simulate the top-level testbench module
vsim work.top


#add wave -r *

# Run simulation
run -all

