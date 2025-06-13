vlib work
vdel -all
vlib work

# Compile RTL and Testbench
vlog -sv router_dut.sv
vlog -sv testbench.sv

# Simulate the top-level testbench module
vsim -voptargs=+acc testbench

# Optionally add all signals to wave window
add wave -r *

# Run simulation
run -all
