// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* czctl.v
   2019.04.20   Ver0.2
   2019.12.19   Ver0.3 */

`timescale 1ns/1ps
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif
`ifndef SPM_WIDTH
    `define SPM_WIDTH 8
`endif

`define COMP_BIT    31
`define COPR_BIT    30
`define MUL_BIT      8
`define CF_BIT       9

`define OP_IX        1
`define OP_B         2
`define OP_BCF       3
`define OP_BZF       4
`define OP_BC        5
`define OP_CALL      6
`define OP_RETURN    8
`define OP_JRETURN   9
`define OP_LOOP     12
`define OP_WAIT     13
`define OP_DREG     14


`define OP_ADD      16 /* FIX */
`define OP_MOV      20
`define OP_REGBANK  21
`define OP_ENABLE   22
`define OP_DISABLE  23
`define OP_RETURNI  24
`define OP_POPSP    25
`define OP_IOSTROBE 26
`define OP_OUTPUTK  27

module FFstd(
    output Q,
    input C,
    input D);

    reg FF;
    always @(posedge C) FF <= D;
    assign Q = FF;

endmodule // FFstd

module FFrst(
    output Q,
    input C,
    input D,
    input R);

    reg FF;
    always @(posedge C) FF <= R ? 0 : D;
    assign Q = FF;
endmodule // FFrst

module FFce(
    output Q,
    input C,
    input D,
    input CE);

    reg FF;
    always @(posedge C) FF <= CE ? D : FF;
    assign Q = FF;
endmodule // FFce

module FFrst_s(
    output Q,
    input C,
    input D,
    input R,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= R ? 0 : RI ? FFsave : D;
        FFsave <= R ? 0 : INT ? D : FFsave;
    end
    assign Q = FF;
endmodule // FFrst_s

module FFstd_s(
    output Q,
    input C,
    input D,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= RI ? FFsave : D;
        FFsave <= INT ? D : FFsave;
    end
    assign Q = FF;
endmodule // FFstd_s

module FFce_s(
    output Q,
    input C,
    input D,
    input CE,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= RI ? FFsave : CE ? D : FF;
        FFsave <= INT ? (CE ? D : FF) : FFsave;
    end
    assign Q = FF;
endmodule // FFce_s

module FFcerst_s(
    output Q,
    input C,
    input D,
    input CE,
    input R,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= R ? 0 : RI ? FFsave : CE ? D : FF;
        FFsave <= R ? 0 : INT ? (CE ? D : FF ) : FFsave;
    end
    assign Q = FF;
endmodule // FFcerst_s

module FFrst_sz(
    output Q,
    input C,
    input D,
    input R,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= R ? 0 : RI ? FFsave : INT ? 0 : D;
        FFsave <= R ? 0 : INT ? D : FFsave;
    end
    assign Q = FF;
endmodule // FFrst_sz

module FFrst_sz2(
    output Q,
    input C,
    input D,
    input R,
    input INT,
    input RI);

    reg FF, FFsave;
    always @(posedge C) begin
        FF <= R ? 0 : RI ? FFsave : INT ? 0 : D;
        FFsave <= R ? 0 : INT ? D : FFsave;
    end
    assign Q = RI ? FFsave : FF;
endmodule // FFrst_sz2

module czctl(
    input CLK,
    input xAMSB_P,                 // ABCD
    input [`PC_WIDTH-1:0] xREGAB_P,  // ABCD
    input [`PC_WIDTH-1:0] xSMEMDO_P, // SMEM
    input xCY_P,                   // ABCD
    input xRESET_P,                // GAIBU
    input xZFIN_P,                 // ABCD
    input xCZERO_P,                // ABCD
    input [31:0] xIR_P,            // PMEM
    input [7:0] xADDR_P,           // ABCD
    input [7:0] xREGDO_P,          // REG
    input xINT0_P,                 // GAIBU
    input xINT1_P,                 // GAIBU
    output xCYCF_P,                // ABCD
    output xCMPSUB_P,              // ABCD
    output [`PC_WIDTH-1:0] xIRA_P, // ABCD
    output [`PC_WIDTH-1:0] xSMEMDI_P, // SMEM
    output [`PC_WIDTH-1:0] xPC_P,  // PMEM
    output xWSTROBE_P,             // GAIBU
    output xOUTPUTK_P,             // ABCD
    output xWSTROBEK_P,            // GAIBU
    output xIOSTROBE_P,            // GAIBU
    output [3:0] xSMEMA_P,         // SMEM
    output xCF_P,                  // ABCD
    output xZF_P,                  // ABCD
    output xINPUT_P,               // ABCD
    output xRSTROBE_P,             // GAIBU
    output xSMEMWE_P,              // SMEM
    output xMOV_P,                 // ABCD
    output [1:0] xLALUOP_P,        // ABCD
    output [`SPM_WIDTH-1:0] xREGRA_P, // REG
    output [`SPM_WIDTH-1:0] xREGWA_P, // REG
    output xREGWE_P,               // REG
    output xASEL_P,                // ABCD
    output [3:0] xBCSEL_P,         // ABCD
    output xDSEL_P,                // ABCD
    output xDSELREG_P,             // ABCD
    output xMUL_P,                 // ABCD
    output xNOT_P,                 // ABCD
    output [1:0] xADDRSEL_P,       // ABCD
    output [1:0] xADDLSEL_P,       // ABCD
    output xCFBIT_P,               // ABCD
    output xONE_P,                 // ABCD
    output [7:0] xN_P);            // ABCD

    genvar i;

    function three_or_more; 
        input [3:0] x;
        three_or_more = ~(~(x[3]|x[2]) & ~(x[1]&x[0]));
    endfunction // Q

    wire cmd_INT, wait_w0, wait_w1, wait_w2, loop_l;
    wire cmd_RETURNI;

    /* SP */ wire [3:0] SPout, SPin;
    FFrst SP[3:0] (.Q(SPout),.C(CLK),.D(SPin),.R(xRESET_P));

    /* INT */ wire INTout, INTin;
    FFrst INT(.Q(INTout),.C(CLK),.D(INTin),.R(xRESET_P));

    /* INTD */ wire INTDout, INTDin;
    FFrst INTD(.Q(INTDout),.C(CLK),.D(INTDin),.R(xRESET_P));

    /* INTDD */ wire INTDDout, INTDDin;
    FFstd INTDD(.Q(INTDDout),.C(CLK),.D(INTDDin));

    /* IMODE */ wire IMODEout, IMODEin;
    FFrst_sz2 IMODE(.Q(IMODEout),.C(CLK),.D(IMODEin),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* PC */ wire [`PC_WIDTH-1:0] PCout, PCin;
    FFcerst_s PC[`PC_WIDTH-1:0] (.Q(PCout),.C(CLK),.D(PCin),.CE(wait_w1),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* CF,ZF */ wire CFout, CFin, ZFout, ZFin;
    FFstd_s CF(.Q(CFout),.C(CLK),.D(CFin),.INT(cmd_INT),.RI(cmd_RETURNI));
    FFstd_s ZF(.Q(ZFout),.C(CLK),.D(ZFin),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* I */ wire [3:0] Iout, Iin;
    FFstd_s I[3:0] (.Q(Iout),.C(CLK),.D(Iin),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* IR */ wire [31:0] IRout, IRin;
    FFcerst_s IR[31:0] (.Q(IRout),.C(CLK),.D(IRin),.CE(wait_w0),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* CO */ wire [7:0] COout, COin, COce;
    FFce_s CO[7:0] (.Q(COout),.C(CLK),.D(COin),.CE(COce),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* HL */ wire HLout, HLin;
    FFrst_sz HL(.Q(HLout),.C(CLK),.D(HLin),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* RETD */ wire RETDout, RETDin;
    FFrst_s RETD(.Q(RETDout),.C(CLK),.D(RETDin),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* BANK */ wire BANKout, BANKin;
    FFrst_s BANK(.Q(BANKout),.C(CLK),.D(BANKin),.R(xRESET_P),.INT(cmd_INT),.RI(cmd_RETURNI));

    /* IRA */ wire [`PC_WIDTH-1:0] IRAout, IRAin, IRAce;
    FFce IRA[`PC_WIDTH-1:0] (.Q(IRAout),.C(CLK),.D(IRAin),.CE(IRAce));

    /* REGRA */ wire [`SPM_WIDTH-1:0] REGRAout, REGRAin;
    wire REGRAce;
    FFce REGRA[`SPM_WIDTH-1:0] (.Q(REGRAout),.C(CLK),.D(REGRAin),.CE(REGRAce));

    /* INT0 */ wire INT0out, INT0in;
    FFstd INT0(.Q(INT0out),.C(CLK),.D(INT0in));

    /* INT1 */ wire INT1out, INT1in;
    FFstd INT1(.Q(INT1out),.C(CLK),.D(INT1in));

/* OP code ------------------------------------------------------ */
    wire COMP_bit;
    assign COMP_bit = INTDDout ? 0 : IRout[`COMP_BIT];

    wire [22:0] IRQ;
    assign IRQ[0] = IRout[8];
    assign IRQ[1] = IRout[9];
    assign IRQ[2] = IRout[10];
    assign IRQ[3] = IRout[11];
    assign IRQ[4] = IRout[12];
    assign IRQ[5] = IRout[13];
    assign IRQ[6] = IRout[14];
    assign IRQ[7] = IRout[15];
    assign IRQ[8] = IRout[16];
    assign IRQ[9] = IRout[17];
    assign IRQ[10] = COMP_bit ? 0 : INTDDout ? 0 : IRout[18];
    assign IRQ[11] = COMP_bit ? 0 : INTDDout ? 0 : IRout[19];
    assign IRQ[12] = COMP_bit ? 0 : INTDDout ? 0 : IRout[20];
    assign IRQ[13] = COMP_bit ? 0 : INTDDout ? 0 : IRout[21];
    assign IRQ[14] = COMP_bit ? 0 : INTDDout ? 0 : IRout[22];
    assign IRQ[15] = COMP_bit ? 0 : INTDDout ? 0 : IRout[23];
    assign IRQ[16] = COMP_bit ? 0 : INTDDout ? 0 : IRout[24];
    assign IRQ[17] = COMP_bit ? 0 : INTDDout ? 0 : IRout[25];
    assign IRQ[18] = COMP_bit ? 0 : INTDDout ? 0 : IRout[26];
    assign IRQ[19] = COMP_bit ? 0 : INTDDout ? 0 : IRout[27];
    assign IRQ[20] = COMP_bit ? 0 : INTDDout ? 0 : IRout[28];
    assign IRQ[21] = COMP_bit ? 0 : INTDDout ? 0 : IRout[29];
    assign IRQ[22] = IRout[30];
    
    wire COPR_bit;
    assign COPR_bit = IRQ[`COPR_BIT-8];

    wire [4:0] opcode;
    assign opcode = IRQ[21:17];

    wire op_IX;
    assign op_IX = opcode==`OP_IX ? 1 : 0;

    wire op_B;
    assign op_B = opcode==`OP_B ? 1 : 0;

    wire op_BCF;
    assign op_BCF = opcode==`OP_BCF ? 1 : 0;

    wire op_BZF;
    assign op_BZF = opcode==`OP_BZF ? 1 : 0;

    wire op_BC;
    assign op_BC = opcode==`OP_BC ? 1 : 0;

    wire op_CALL;
    assign op_CALL = opcode==`OP_CALL ? 1 : 0;

    wire op_RETURN;
    assign op_RETURN = opcode==`OP_RETURN ? 1 : 0;

    wire op_JRETURN;
    assign op_JRETURN = opcode==`OP_JRETURN ? 1 : 0;

    wire op_LOOP;
    assign op_LOOP = opcode==`OP_LOOP ? 1 : 0;

    wire op_WAIT;
    assign op_WAIT = opcode==`OP_WAIT ? 1 : 0;

    wire op_DREG;
    assign op_DREG = opcode==`OP_DREG ? 1 : 0;

    wire op_ADD;
    assign op_ADD = opcode==`OP_ADD ? 1 : 0;

    /* AND XOR OR */
    assign xLALUOP_P = opcode[4]&(~opcode[3])&(~opcode[2]) ? opcode[1:0] : 2'b00;

    assign xMOV_P = opcode==`OP_MOV ? 1 : 0;

    wire op_REGBANK;
    assign op_REGBANK = opcode==`OP_REGBANK ? 1 : 0;

    wire op_ENABLE;
    assign op_ENABLE = opcode==`OP_ENABLE ? 1 : 0;

    wire op_DISABLE;
    assign op_DISABLE = opcode==`OP_DISABLE ? 1 : 0;

    wire op_RETURNI;
    assign op_RETURNI = opcode==`OP_RETURNI ? 1 : 0;

    wire op_POPSP;
    assign op_POPSP = opcode==`OP_POPSP ? 1 : 0;

    assign xIOSTROBE_P = opcode==`OP_IOSTROBE ? 1 : 0;

    assign xOUTPUTK_P = opcode==`OP_OUTPUTK ? 1 : 0;
    assign xWSTROBEK_P = xOUTPUTK_P;

    assign xINPUT_P = opcode[4]&opcode[3]&opcode[2]&(~opcode[1]) ? 1 : 0;
    assign xRSTROBE_P = xINPUT_P;

    /* OUTPUT */
    assign xWSTROBE_P = opcode[4]&opcode[3]&opcode[2]&(~opcode[0]) ? 1 : 0;

/* -------------------------------------------------------------- */    

    wire [`PC_WIDTH-1:0] sig_PC;

    assign wait_w0 = ~(op_WAIT & |Iout);
    assign wait_w1 = ~(op_WAIT & three_or_more(Iout));
    assign wait_w2 = op_WAIT & (Iout==2 ? 1 : 0);
    assign loop_l  = op_LOOP & |Iout;

    wire sig_DIVA, MUL_bit;

    assign MUL_bit = IRQ[`MUL_BIT-8];

    assign sig_DIVA = xADDLSEL_P[1]&(~xADDLSEL_P[0]);
    assign xCYCF_P = xCY_P | (sig_DIVA ? xAMSB_P : CFout);
    assign xCMPSUB_P = ~(xCYCF_P & ~MUL_bit) & sig_DIVA;

    assign xIRA_P = IRAout;
    
    wire sig_JUMP; // Indirect JUMP

    assign PCin = sig_JUMP ? xREGAB_P :
                  wait_w2 ? sig_PC-1 : 
                  loop_l ? xSMEMDI_P : sig_PC+1;

    assign IRAin = sig_PC;
    for( i=0 ; i< `PC_WIDTH ; i=i+1 ) begin
        assign IRAce[i] = cmd_INT ? 1 : 0;
    end

    wire sel_PC1, sel_PC2;

    assign sel_PC1 = (COMP_bit & HLout) | (op_CALL & COPR_bit);
    assign sel_PC2 = COMP_bit & (~HLout);
    assign xSMEMDI_P = sel_PC1 ? PCout-1 : 
                       sel_PC2 ? PCout-2 :
                       loop_l  ? (PCout - IRout[7:0]) : PCout;

    wire op_jump_and_call, op_return, op_call;

    assign op_call = opcode[4:0]==5'b00110 ? 1 :
                     opcode[4:0]==5'b00111 && (COPR_bit^ZFout)==0 ? 1 : 0;

    assign op_jump_and_call = 
             opcode[4:0]==5'b00010 ? 1 :
             opcode[4:0]==5'b00011 && (COPR_bit^CFout)==0 ? 1 :
             opcode[4:0]==5'b00100 && (COPR_bit^ZFout)==0 ? 1 :
             opcode[4:0]==5'b00101 && (COPR_bit^xCZERO_P)==0 ? 1 : op_call;

    assign op_return = opcode[4:2]==3'b010 ? (~opcode[1] | ~(opcode[0]^ZFout)) : 0;

    assign sig_PC = cmd_RETURNI ? IRAout :
                    COMP_bit ? (IRout[30:24]<<3)|`PC_WIDTH'd4 :
                    op_jump_and_call ? IRout[`PC_WIDTH-1:0] :
                    op_return ? xSMEMDO_P : PCout;

    assign INT0in = xINT0_P;
    assign INT1in = xINT1_P;

    assign cmd_RETURNI = op_RETURNI & (~INT0out);

    assign xPC_P = (cmd_INT & INT0out) ? `PC_WIDTH'd2 :
                   (cmd_INT & INT1out) ? `PC_WIDTH'd3 :
                   (op_RETURNI & INT0out) ? `PC_WIDTH'd2 : sig_PC;

    assign sig_JUMP = op_jump_and_call ? (IRout[`PC_WIDTH-1:0] ==`PC_WIDTH'd1 ? 1 : 0) : 0;

    assign SPin = op_return ? SPout+1 : op_POPSP ? SPout+1 : (op_call|COMP_bit) ? SPout-1 : SPout;

    assign xSMEMA_P = SPin;

    assign CFin = op_ADD ? xCY_P: CFout;
    assign xCF_P = CFout;

    assign ZFin = xLALUOP_P ? xZFIN_P: ZFout;
    assign xZF_P = ZFout;

    assign RETDin = op_return;

    assign IRin[31:16] = COMP_bit || op_JRETURN || (op_CALL | op_B)&COPR_bit ? {14'd0 , xIR_P[17:16]} :
                  (HLout & RETDout) ? xIR_P[15:0] : xIR_P[31:16];
    assign IRin[15:8] = xIR_P[15:8];
    assign IRin[7:4] = COMP_bit ? IRout[7:4]  : xIR_P[7:4];
    assign IRin[3:0] = xIR_P[3:0];

    wire [24:0] IRV;
    assign IRV = COPR_bit ? {IRQ[16:0] , COout } : {IRQ[16:0] , IRout[7:0] };

    assign Iin = op_IX ? IRV[7:4] : (op_LOOP || op_WAIT) ? Iout-1 : Iout;

    assign COin = IRout[23:16];
    assign COce = COMP_bit ? 8'b11111111 : 8'b00000000;

    assign HLin = op_POPSP ? 0 : HLout ^ COMP_bit;

    assign xSMEMWE_P = op_call | COMP_bit;

    assign BANKin = (op_REGBANK & ~IRV[4]) ? 0 :
                    (op_REGBANK &  IRV[4]) ? 1 : BANKout;


    assign xREGRA_P = cmd_RETURNI ? REGRAout : REGRAin;

    assign REGRAce = cmd_INT;

    generate
    if( `SPM_WIDTH > 8 ) begin
    assign REGRAin[7:0] = IRV[17:16]==2'b00 ? {3'd0, BANKout , IRV[7:4]} :
                          IRV[17:16]==2'b01 ? IRV[7:0] : xADDR_P;
    assign REGRAin[`SPM_WIDTH-1:8] = IRV[17:16]==2'b11 ? xREGDO_P[`SPM_WIDTH-9:0] : 0;
    assign xREGWA_P[7:0] = IRV[17:16]==2'b00 ? {3'd0, BANKout , IRV[3:0]} :
                           IRV[17:16]==2'b01 ? IRV[7:0] : xADDR_P;
    assign xREGWA_P[`SPM_WIDTH-1:8] = IRV[17:16]==2'b11 ? xREGDO_P[`SPM_WIDTH-9:0] : 0;
    end
    else 
    begin
    assign REGRAin[4:0] = IRV[17:16]==2'b00 ? {BANKout , IRV[7:4]} :
                          IRV[17:16]==2'b01 ? IRV[4:0] : xADDR_P;
    assign REGRAin[`SPM_WIDTH-1:5] = IRV[17:16]==2'b00 ? 0 :
                                     IRV[17:16]==2'b01 ? IRV[`SPM_WIDTH-1:5] : xADDR_P[`SPM_WIDTH-1:5];
    assign xREGWA_P[4:0] = IRV[17:16]==2'b00 ? {BANKout , IRV[3:0]} :
                           IRV[17:16]==2'b01 ? IRV[4:0] : xADDR_P;
    assign xREGWA_P[`SPM_WIDTH-1:5] = IRV[17:16]==2'b00 ? 0 :
                                      IRV[17:16]==2'b01 ? IRV[`SPM_WIDTH-1:5] : xADDR_P[`SPM_WIDTH-1:5];
    end
    endgenerate

    assign INTin = (xINT0_P | xINT1_P) & IMODEout;
    assign INTDin = INTout;

    assign IMODEin = (op_ENABLE | IMODEout) & ~op_DISABLE;

    assign cmd_INT = INTDin & ~INTDout;

    assign INTDDin = cmd_INT;

    assign xREGWE_P = IRV[18];
    assign xASEL_P = IRV[24];
    assign xBCSEL_P = IRV[23:20];
    assign xDSEL_P = IRV[19];
    assign xDSELREG_P = op_DREG;
    assign xONE_P = IRV[15];
    assign xNOT_P = IRV[14];
    assign xADDRSEL_P = IRV[13:12];
    assign xADDLSEL_P = IRV[11:10];
    assign xCFBIT_P = IRV[9];
    assign xMUL_P = IRV[8];
    assign xN_P = IRV[7:0];

endmodule // czctl
