// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* czsmem.v
   2019.4.8   Ver0.0 */

`timescale 1ns/1ps
//`define USE_XILINX_RAM_STYLE
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif
`ifndef STACK_WIDTH
    `define STACK_WIDTH 4
`endif

module czsmem(CLK, xSMEMA_P, xSMEMWE_P, xSMEMDI_P, xSMEMDO_P);

    input CLK;
    input [`STACK_WIDTH-1:0] xSMEMA_P;
    input xSMEMWE_P;
    input [`PC_WIDTH-1:0] xSMEMDI_P;
    output [`PC_WIDTH-1:0] xSMEMDO_P;

    reg [`PC_WIDTH-1:0] DO;

`ifdef USE_XILINX_RAM_STYLE
    (* ram_style = "distributed" *)
`endif
    reg [`PC_WIDTH-1:0] ram [2**`STACK_WIDTH-1:0];

    always @(posedge CLK) begin
	DO <= ram [xSMEMA_P];
        ram [xSMEMA_P] <= xSMEMWE_P ? xSMEMDI_P : ram [xSMEMA_P];
    end

    assign xSMEMDO_P = DO;

endmodule


