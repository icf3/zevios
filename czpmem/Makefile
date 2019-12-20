top: xsim

# icarus verilog
icarus: czpmem.v
	iverilog -DPC_WIDTH=10 -o czpmem czpmem.v

# Xilinx Vivado
xsim: czpmem.v
	xvlog -d PC_WIDTH=10 czpmem.v
	xelab czpmem -s simsim --debug wave

# Xilinx Vivado
xpm: czpmem.v
	xvlog -d PC_WIDTH=10 -d USE_XPM czpmem.v
	xelab czpmem -s simsim -L xpm --debug wave

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str czpmem
