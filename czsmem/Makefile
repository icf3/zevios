top: icarus

# icarus verilog
icarus: czsmem.v
	iverilog -DPC_WIDTH=10 -o czsmem czsmem.v

# Xilinx Vivado
xsim: czsmem.v
	xvlog -d PC_WIDTH=10 czsmem.v
	xelab czsmem -s simsim --debug wave

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str czsmem
