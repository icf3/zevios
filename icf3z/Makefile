top: icarus

icarus: icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=16 -o icf3z icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v -T typ

xsim: icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=16 -d USE_XPM  -d USE_XPM_10bit icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	xelab icf3z -s simsim -L xpm -L unisims_ver -L unimacro_ver --debug wave

copy:
	cp ../czctl/czctl.v ../czabcd/czabcd.v ../czpmem/czpmem.v ../czsmem/czsmem.v ../czreg/czreg.v .

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str icf3z
	rm -rf czctl.v czabcd.v czpmem.v czsmem.v czreg.v

