top: xsim

# icarus verilog
icarus: czabcd.v
	iverilog -o czabcd czabcd.v

# Xilinx Vivado
xsim: czabcd.v
	xvlog czabcd.v
	xelab czabcd -s simsim --debug wave

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str czabcd

