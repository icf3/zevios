top: icarus

# icarus verilog
icarus: czreg.v
	iverilog -DSPM_WIDTH=8 -o czreg czreg.v

# Xilinx Vivado
xsim: czreg.v
	xvlog -d SPM_WIDTH=8 -d USE_XILINX_RAM_STYLE czreg.v
	xelab czreg -s simsim --debug wave

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str czreg
