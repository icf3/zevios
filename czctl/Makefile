top: icarus

# icarus verilog
icarus: czctl.v
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=8 -o czctl czctl.v

icarus12: czctl.v
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=12 -o czctl czctl.v

icarus16: czctl.v
	iverilog -DPC_WIDTH=12 -DSPM_WIDTH=16 -o czctl czctl.v

# Xilinx Vivado
xsim: czctl.v
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=8 czctl.v
	xelab czctl -s simsim --debug wave

xsim12: czctl.v
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=12 czctl.v
	xelab czctl -s simsim --debug wave

xsim16: czctl.v
	xvlog -d PC_WIDTH=12 -d SPM_WIDTH=16 czctl.v
	xelab czctl -s simsim --debug wave

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str czctl
