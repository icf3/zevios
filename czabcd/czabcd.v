// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* czabcd.v
   2019.04.18   Ver0.1 */

`timescale 1ns/1ps
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif

module czabcd(
    input CLK,
    input [`PC_WIDTH-1:0] xIRA_P,    // CTL
    input [`PC_WIDTH-1:0] xSMEMDO_P, // SMEM
    input xMOV_P,           // CTL
    input [7:0] xREGDO_P,   // REG
    input xCMPSUB_P,        // CTL
    input xASEL_P,          // CTL
    input [7:0] xN_P,       // CTL	        
    input [1:0] xADDLSEL_P, // CTL
    input xCF_P,            // CTL
    input xCFBIT_P,         // CTL
    input xONE_P,           // CTL
    input xZF_P,            // CTL
    input [3:0] xBCSEL_P,   // CTL
    input xMUL_P,           // CTL
    input xCYCF_P,          // CTL
    input xOUTPUTK_P,       // CTL
    input xDSELREG_P,       // CTL
    input xDSEL_P,          // CTL
    input [1:0] xADDRSEL_P, // CTL
    input xNOT_P,           // CTL
    input [1:0] xLALUOP_P,  // CTL
    input xINPUT_P,         // CTL
    input [7:0] xINPORT_P,  // GAIBU
    output [7:0] xREGDI_P,  // REG
    output xAMSB_P,         // CTL
    output xCY_P,           // CTL
    output [`PC_WIDTH-1:0] xREGAB_P, // GAIBU
    output [7:0] xPORTID_P, // GAIBU
    output xZFIN_P,         // CTL
    output [7:0] xADDR_P,   // CTL
    output xCZERO_P,        // CTL
    output [7:0] xOUTPORT_P); // GAIBU

    genvar i;

    reg [7:0] A, B, C, D;

    wire [7:0] diva,ans;
    wire b_ce,b_ans,b_lsh,b_rsh,b_reg;
    wire c_ce,c_ans,c_lsh,c_rsh,c_reg;
    wire cin;
    wire [7:0] b_rsh_data, b_lsh_data;
    wire [7:0] c_rsh_data, c_lsh_data;
    wire [7:0] addl0, addl1, addr, add0, add1;
    wire [7:0] input_z0, input_z1, input_z2, input_z3, input_z4, lalu;
    wire czeromul;

    /* diva */
    assign diva[0] = B[7];
    for( i=1 ; i<8 ; i=i+1 ) begin
        assign diva[i] = A[i-1];
    end

    /* b_rsh_data */
    for( i=0 ; i<7 ; i=i+1 ) begin
        assign b_rsh_data[i] = ans[i+1];
    end
    assign b_rsh_data[7] = xCY_P;

    /* b_lsh_data */
    assign b_lsh_data[0] = C[7];
    for( i=1 ; i<8 ; i=i+1 ) begin
        assign b_lsh_data[i] = B[i-1];
    end

    /* c_rsh_data */
    for( i=0 ; i<7 ; i=i+1 ) begin
        assign c_rsh_data[i] = C[i+1];
    end
    assign c_rsh_data[7] = ans[0];

    /* c_lsh_data */
    assign c_lsh_data[0] = xCYCF_P;
    for( i=1 ; i<8 ; i=i+1 ) begin
        assign c_lsh_data[i] = C[i-1];
    end

    assign b_ans = (~xBCSEL_P[3]) & xBCSEL_P[2];
    assign b_lsh = (xBCSEL_P[3] & (~xBCSEL_P[2])) & (~(xBCSEL_P[1]&xBCSEL_P[0]));
    assign b_rsh = (xBCSEL_P[3] & xBCSEL_P[2]) & ((~xBCSEL_P[1])|xBCSEL_P[0]);
    assign b_reg = (xBCSEL_P[3] & (~xBCSEL_P[2])) & (xBCSEL_P[1] & xBCSEL_P[0]);
    assign b_ce  = b_ans | b_lsh | b_rsh | b_reg;

    assign c_ans = (~xBCSEL_P[1]) & xBCSEL_P[0];
    assign c_lsh = (~(xBCSEL_P[3] & xBCSEL_P[2])) & (xBCSEL_P[1]&(~xBCSEL_P[0]));
    assign c_rsh = ((~xBCSEL_P[3]) | xBCSEL_P[2]) & (xBCSEL_P[1]&xBCSEL_P[0]);
    assign c_reg = (xBCSEL_P[3] & xBCSEL_P[2]) & (xBCSEL_P[1] & (~xBCSEL_P[0]));
    assign c_ce  = c_ans | c_lsh | c_rsh | c_reg;

    always @(posedge CLK) begin
        A <= xASEL_P ? (xCMPSUB_P ? diva : ans) : A;

        B <= b_rsh ? b_rsh_data :
             b_ans ? ans :
             b_lsh ? b_lsh_data :
             b_reg ? xREGDO_P : B;
             
        C <= c_rsh ? c_rsh_data :
             c_ans ? ans :
             c_lsh ? c_lsh_data :
             c_reg ? xREGDO_P : C;

        D <= xDSEL_P ? (xDSELREG_P ? xREGDO_P : ans) : D;
    end

    assign xREGDI_P = (xMOV_P) ? xREGDO_P : A;

    assign xAMSB_P = A[7];

    assign addl0 = (xADDLSEL_P==2'b00) ? 8'd0 :
                   (xADDLSEL_P==2'b01) ? A :
                   (xADDLSEL_P==2'b10) ? diva : xN_P;

    assign czeromul = C[0] | (~xMUL_P);

    assign addl1 = czeromul ? addl0 : 8'd0;


    assign addr = (xADDRSEL_P==2'b00) ? 8'd0 :
                  (xADDRSEL_P==2'b01) ? B :
                  (xADDRSEL_P==2'b10) ? C : D;

    assign xADDR_P = xNOT_P ? (~addr) : addr;

    assign cin = (xCF_P & xCFBIT_P) | xONE_P;

    assign {xCY_P , add0} = addl1 + xADDR_P + cin;

    assign input_z0 = (xINPUT_P && xN_P[2:0]==0) ? xINPORT_P : 0;
    assign input_z1 = (xINPUT_P && xN_P[2:0]==1) ? xSMEMDO_P[7:0] : 0;
    assign input_z2 = (xINPUT_P && xN_P[2:0]==2) ? xSMEMDO_P[`PC_WIDTH-1:8] : 0;
    assign input_z3 = (xINPUT_P && xN_P[2:0]==3) ? xIRA_P[7:0] : 0;
    assign input_z4 = (xINPUT_P && xN_P[2:0]==4) ? xIRA_P[`PC_WIDTH-1:8] : 0;

    assign lalu = (xLALUOP_P==2'b00) ? 8'd0 :
                  (xLALUOP_P==2'b01) ? (addl1 & xADDR_P) :
                  (xLALUOP_P==2'b10) ? (addl1 ^ xADDR_P) : (addl1 | xADDR_P);

    assign   add1 = (xLALUOP_P[0] | xLALUOP_P[1] | xINPUT_P) ? 0 : add0;

    assign ans = add1 | input_z0 | input_z1 | input_z2 | input_z3 | input_z4 | lalu;

    assign xOUTPORT_P[3:0] = xOUTPUTK_P ? xN_P[3:0] : D[3:0];
    assign xOUTPORT_P[7:4] = xOUTPUTK_P ? 0 : D[7:4];

    assign xREGAB_P[7:0] = A;
    for( i=8 ; i< `PC_WIDTH ; i=i+1 ) begin
        assign xREGAB_P[i] = B[i-8];
    end

    assign xPORTID_P = B;

    assign xZFIN_P = (~|lalu) & ((~xCFBIT_P)|xZF_P);

    assign xCZERO_P = C[0];

endmodule // czabcd
