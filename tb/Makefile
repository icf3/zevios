#
# icf3z test bench
#
icarus: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=8 -o simz simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

icarus_spm16: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=16 -o simz simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

icarus_int: simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=8 -o simz simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

icarus_int_spm16: simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=16 -o simz simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

xsim: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=8  simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab simz  -s simsim --debug wave

xsim_spm16: simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=16  simz.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab simz  -s simsim --debug wave

xsim_int: simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=8  simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab simz  -s simsim --debug wave

xsim_int_spm16: simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=16  simz_int.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab simz  -s simsim --debug wave

interrupt3: simz_interrupt3.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	iverilog -DPC_WIDTH=10 -DSPM_WIDTH=8 -o simz simz_interrupt3.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v

xsim_interrupt3: simz_interrupt3.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v pmem.bin
	xvlog -d PC_WIDTH=10 -d SPM_WIDTH=8  simz_interrupt3.v icf3z.v czctl.v czabcd.v czpmem.v czsmem.v czreg.v 
	xelab simz  -s simsim -L unisims_ver -L unimacro_ver --debug wave

copy:
	cp ../icf3z/icf3z.v ../czctl/czctl.v ../czabcd/czabcd.v ../czpmem/czpmem.v ../czsmem/czsmem.v ../czreg/czreg.v .

clean:
	rm -rf xsim.dir dat.add .Xil .cache *.vcd *.wdb *.jou *.log *.pb *.inc a.out wave.vcd vivado_pid*.str simz
	rm -rf czctl.v czabcd.v czpmem.v czsmem.v czreg.v icf3z.v pmem.bin



