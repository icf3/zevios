/* simz.v testbench interrupt3
   2019.4.19    Ver0.0
   Naoki Hirayama
*/
`timescale 1ns/1ps
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif


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
    genvar j;

    wire [4:0] opcode;
    assign opcode[4] = ICf3z.CZctl.IR[29].FF;
    assign opcode[3] = ICf3z.CZctl.IR[28].FF;
    assign opcode[2] = ICf3z.CZctl.IR[27].FF;
    assign opcode[1] = ICf3z.CZctl.IR[26].FF;
    assign opcode[0] = ICf3z.CZctl.IR[25].FF;

    wire [`PC_WIDTH-1:0] pc;

    for( j=0 ; j< `PC_WIDTH ; j=j+1 ) begin
        assign pc[j] = ICf3z.CZctl.PC[j].FF;
    end

    initial begin
        CLK = 1;
        xRESET_P = 1;
        xINPORT_P = 8'h5e;
        xINT0_P = 0;
        xINT1_P = 0;
        # 20
        xRESET_P = 0;
        ICf3z.CZctl.CF.FF = 0;
        ICf3z.CZctl.ZF.FF = 0;
        ICf3z.CZabcd.A = 0;
        xINT0_P = 1;
        # 40
        for(i=0 ; i<10000000 ; i=i+1 ) begin
            xINT0_P = (i>100) ? 1'b0 : 1'b1;
            # 10
            if(opcode == 5'h1f) begin
                $display("%h %h %h %h",ICf3z.CZabcd.A,ICf3z.CZabcd.B,ICf3z.CZabcd.C,ICf3z.CZabcd.D);
                $display("result:%h",ICf3z.CZabcd.D);
                $finish;
            end
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
