/* simz.v
   2019.4.18    Ver0.0
   Naoki Hirayama
*/
`timescale 1ns/1ps

//`define INT0_ON
//`define INT1_ON
//`define INT1_CONST_1
//`define IMODE_ENABLE

module simz(
    output [7:0] xPORTID_P,
    output [7:0] xOUTPORT_P,
    output xWSTROBE_P,
    output xWSTROBEK_P,
    output xIOSTROBE_P,
    output xRSTROBE_P);

    reg CLK;
    reg xRESET_P;
    reg [7:0] xINPORT_P;
    reg xINT0_P;
    reg xINT1_P;

    integer i;

    wire [4:0] opcode;
    assign opcode[4] = ICf3z.CZctl.IR[29].FF;
    assign opcode[3] = ICf3z.CZctl.IR[28].FF;
    assign opcode[2] = ICf3z.CZctl.IR[27].FF;
    assign opcode[1] = ICf3z.CZctl.IR[26].FF;
    assign opcode[0] = ICf3z.CZctl.IR[25].FF;

    initial begin
        CLK = 1;
        xRESET_P = 1;
        xINPORT_P = 8'h5e;
        xINT0_P = 0;
`ifdef INT1_CONST_1
        xINT1_P = 1;
`else
        xINT1_P = 0;
`endif
        # 20
        xRESET_P = 0;
        ICf3z.CZctl.CF.FF = 0;
        ICf3z.CZctl.ZF.FF = 0;
        ICf3z.CZabcd.A = 0;
        # 40
`ifdef IMODE_ENABLE
        ICf3z.CZctl.IMODE.FF = 1;
`endif

        for(i=0 ; i<10000000 ; i=i+1 ) begin
            # 5
            if(opcode == 5'h1f) begin
                $display("%h %h %h %h",ICf3z.CZabcd.A,ICf3z.CZabcd.B,ICf3z.CZabcd.C,ICf3z.CZabcd.D);
                $display("result:%h",ICf3z.CZabcd.D);
                for(i=256 ; i<=65504 ; i=i+32) begin
                    $display("%h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                        ICf3z.CZreg.ram[i],
                        ICf3z.CZreg.ram[i+1],
                        ICf3z.CZreg.ram[i+2],
                        ICf3z.CZreg.ram[i+3],
                        ICf3z.CZreg.ram[i+4],
                        ICf3z.CZreg.ram[i+5],
                        ICf3z.CZreg.ram[i+6],
                        ICf3z.CZreg.ram[i+7],
                        ICf3z.CZreg.ram[i+8],
                        ICf3z.CZreg.ram[i+9],
                        ICf3z.CZreg.ram[i+10],
                        ICf3z.CZreg.ram[i+11],
                        ICf3z.CZreg.ram[i+12],
                        ICf3z.CZreg.ram[i+13],
                        ICf3z.CZreg.ram[i+14],
                        ICf3z.CZreg.ram[i+15],
                        ICf3z.CZreg.ram[i+16],
                        ICf3z.CZreg.ram[i+17],
                        ICf3z.CZreg.ram[i+18],
                        ICf3z.CZreg.ram[i+19],
                        ICf3z.CZreg.ram[i+20],
                        ICf3z.CZreg.ram[i+21],
                        ICf3z.CZreg.ram[i+22],
                        ICf3z.CZreg.ram[i+23],
                        ICf3z.CZreg.ram[i+24],
                        ICf3z.CZreg.ram[i+25],
                        ICf3z.CZreg.ram[i+26],
                        ICf3z.CZreg.ram[i+27],
                        ICf3z.CZreg.ram[i+28],
                        ICf3z.CZreg.ram[i+29],
                        ICf3z.CZreg.ram[i+30],
                        ICf3z.CZreg.ram[i+31]);
                end

                $finish;
            end
`ifdef INT0_ON
            xINT0_P = (i==100 || i==101 || i==102) ? 1'b1 : 1'b0;
            if(i==100) $display("*** INT0 ON ***\n");
`endif
`ifdef INT1_ON
            xINT1_P = (i==200 || i==201 || i==202) ? 1'b1 : 1'b0;
            if(i==200) $display("*** INT1 ON ***\n");
`endif
        end
        $display("TIME OVER");
        $finish;
    end

    always # 5 CLK <= ~CLK;

    icf3z ICf3z(
        .CLK(CLK),
        .xINPORT_P(xINPORT_P),
        .xRESET_P(xRESET_P),
        .xINT0_P(xINT0_P),
        .xINT1_P(xINT1_P),
        .xPORTID_P(xPORTID_P),
        .xOUTPORT_P(xOUTPORT_P),
        .xWSTROBE_P(xWSTROBE_P),
        .xWSTROBEK_P(xWSTROBEK_P),
        .xIOSTROBE_P(xIOSTROBE_P),
	.xRSTROBE_P(xRSTROBE_P));

/*
    initial begin
       $dumpfile("waves.vcd");
       $dumpvars(0,ICf3z);
    end
*/
   
endmodule
