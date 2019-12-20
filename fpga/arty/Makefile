xsim: artyz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=8  -d USE_XPM -d USE_XPM_10bit artyz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab artyz -s simsim -L xpm -L unisims_ver -L unimacro_ver --debug wave

copy:
	cp ../../icf3z/icf3z.v ../../czctl/czctl.v ../../czabcd/czabcd.v ../../czpmem/czpmem.v ../../czsmem/czsmem.v ../../czreg/czreg.v .

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str
	rm -rf czctl.v czabcd.v czpmem.v czsmem.v czreg.v icf3z.v

