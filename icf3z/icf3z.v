// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* icf3z.v
   2019.04.23   Ver0.1 */

`timescale 1ns/1ps
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif
`ifndef SPM_WIDTH
    `define SPM_WIDTH 8
`endif
`ifndef STACK_WIDTH
    `define STACK_WIDTH 4
`endif

module icf3z(
    input CLK,
    input [7:0] xINPORT_P,
    input xRESET_P,
    input xINT0_P,
    input xINT1_P,
    output [7:0] xPORTID_P,
    output [7:0] xOUTPORT_P,
    output xWSTROBE_P,
    output xWSTROBEK_P,
    output xIOSTROBE_P,
    output xRSTROBE_P);

    wire xAMSB_P;
    wire [`PC_WIDTH-1:0] xREGAB_P;
    wire [`PC_WIDTH-1:0] xIRA_P;
    wire [`PC_WIDTH-1:0] xSMEMDO_P;
    wire xCY_P;
    wire xZFIN_P;
    wire xCZERO_P;
    wire [31:0] xIR_P;
    wire [7:0] xADDR_P;

    wire xMOV_P;
    wire [7:0] xREGDO_P;
    wire xCMPSUB_P;
    wire xASEL_P;
    wire [7:0] xN_P;
    wire [1:0] xADDLSEL_P;
    wire xCF_P;
    wire xCFBIT_P;
    wire xONE_P;
    wire xZF_P;
    wire [3:0] xBCSEL_P;
    wire xMUL_P;
    wire xCYCF_P;
    wire xOUTPUTK_P;
    wire xDSELREG_P;
    wire xDSEL_P;
    wire [1:0] xADDRSEL_P;
    wire xNOT_P;
    wire [1:0] xLALUOP_P;
    wire xINPUT_P;

    wire [`PC_WIDTH-1:0] xPC_P;
    wire [`STACK_WIDTH-1:0] xSMEMA_P;
    wire xSMEMWE_P;
    wire [`PC_WIDTH-1:0] xSMEMDI_P;
    wire [`SPM_WIDTH-1:0] xREGRA_P;
    wire [`SPM_WIDTH-1:0] xREGWA_P;
    wire xREGWE_P;
    wire [7:0] xREGDI_P;

    czctl CZctl(
        .CLK(CLK),
        .xAMSB_P(xAMSB_P),
        .xREGAB_P(xREGAB_P),
        .xSMEMDO_P(xSMEMDO_P),
        .xCY_P(xCY_P),
        .xRESET_P(xRESET_P),
        .xZFIN_P(xZFIN_P),
        .xCZERO_P(xCZERO_P),
        .xIR_P(xIR_P),
        .xADDR_P(xADDR_P),
        .xREGDO_P(xREGDO_P),
        .xINT0_P(xINT0_P),
        .xINT1_P(xINT1_P),
        .xCYCF_P(xCYCF_P),
        .xCMPSUB_P(xCMPSUB_P),
        .xIRA_P(xIRA_P),
        .xSMEMDI_P(xSMEMDI_P),
        .xPC_P(xPC_P),
        .xWSTROBE_P(xWSTROBE_P),
        .xOUTPUTK_P(xOUTPUTK_P),
        .xWSTROBEK_P(xWSTROBEK_P),
        .xIOSTROBE_P(xIOSTROBE_P),
        .xSMEMA_P(xSMEMA_P),
        .xCF_P(xCF_P),
        .xZF_P(xZF_P),
        .xINPUT_P(xINPUT_P),
        .xRSTROBE_P(xRSTROBE_P),
        .xSMEMWE_P(xSMEMWE_P),
        .xMOV_P(xMOV_P),
        .xLALUOP_P(xLALUOP_P),
        .xREGRA_P(xREGRA_P),
        .xREGWA_P(xREGWA_P),
        .xREGWE_P(xREGWE_P),
        .xASEL_P(xASEL_P),
        .xBCSEL_P(xBCSEL_P),
        .xDSEL_P(xDSEL_P),
        .xDSELREG_P(xDSELREG_P),
        .xMUL_P(xMUL_P),
        .xNOT_P(xNOT_P),
        .xADDRSEL_P(xADDRSEL_P),
        .xADDLSEL_P(xADDLSEL_P),
        .xCFBIT_P(xCFBIT_P),
        .xONE_P(xONE_P),
	.xN_P(xN_P));

    czabcd CZabcd(
        .CLK(CLK),
        .xIRA_P(xIRA_P),
        .xSMEMDO_P(xSMEMDO_P),
        .xMOV_P(xMOV_P),
        .xREGDO_P(xREGDO_P),
        .xCMPSUB_P(xCMPSUB_P),
        .xASEL_P(xASEL_P),
        .xN_P(xN_P),
        .xADDLSEL_P(xADDLSEL_P),
        .xCF_P(xCF_P),
        .xCFBIT_P(xCFBIT_P),
        .xONE_P(xONE_P),
        .xZF_P(xZF_P),
        .xBCSEL_P(xBCSEL_P),
        .xMUL_P(xMUL_P),
        .xCYCF_P(xCYCF_P),
        .xOUTPUTK_P(xOUTPUTK_P),
        .xDSELREG_P(xDSELREG_P),
        .xDSEL_P(xDSEL_P),
        .xADDRSEL_P(xADDRSEL_P),
        .xNOT_P(xNOT_P),
        .xLALUOP_P(xLALUOP_P),
        .xINPUT_P(xINPUT_P),
        .xINPORT_P(xINPORT_P),
        .xREGDI_P(xREGDI_P),
        .xAMSB_P(xAMSB_P),
        .xCY_P(xCY_P),
        .xREGAB_P(xREGAB_P),
        .xPORTID_P(xPORTID_P),
        .xZFIN_P(xZFIN_P),
        .xADDR_P(xADDR_P),
        .xCZERO_P(xCZERO_P),
        .xOUTPORT_P(xOUTPORT_P));

    czpmem CZpmem(
        .CLK(CLK),
        .xPC_P(xPC_P),
        .xIR_P(xIR_P));

    czsmem CZsmem(
        .CLK(CLK),
        .xSMEMA_P(xSMEMA_P),
        .xSMEMWE_P(xSMEMWE_P),
        .xSMEMDI_P(xSMEMDI_P),
        .xSMEMDO_P(xSMEMDO_P));

    czreg CZreg(
        .CLK(CLK),
        .xREGRA_P(xREGRA_P),
        .xREGWA_P(xREGWA_P),
        .xREGWE_P(xREGWE_P),
        .xREGDI_P(xREGDI_P),
        .xREGDO_P(xREGDO_P));

endmodule // icf3z
