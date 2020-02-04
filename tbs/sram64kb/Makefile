#
# icf3z test bench
#
top: icarus

# icarus verilog
icarus: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=16 -o simz simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

# Xilinx vivado
xsim: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=16  simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	xelab simz -s simsim --debug wave

copy:
	cp ../../icf3z/icf3z.v ../../czctl/czctl.v ../../czabcd/czabcd.v ../../czpmem/czpmem.v ../../czsmem/czsmem.v ../../czreg/czreg.v .

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str simz
	rm -rf czctl.v czabcd.v czpmem.v czsmem.v czreg.v icf3z.v


