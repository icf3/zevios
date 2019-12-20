// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* czreg.v
   2019.4.8   Ver0.0 */

`timescale 1ns/1ps
//`define USE_XILINX_RAM_STYLE
`ifndef SPM_WIDTH
    `define SPM_WIDTH 8
`endif


module czreg(CLK, xREGRA_P, xREGWA_P, xREGWE_P, xREGDI_P, xREGDO_P);

    input CLK;
    input [`SPM_WIDTH-1:0] xREGRA_P;
    input [`SPM_WIDTH-1:0] xREGWA_P;
    input xREGWE_P;
    input [7:0] xREGDI_P;
    output [7:0] xREGDO_P;

    reg [7:0] DO;

`ifdef USE_XILINX_RAM_STYLE
    (* ram_style = "distributed" *)
`endif
    reg [7:0] ram [2**`SPM_WIDTH-1:0];

    always @(posedge CLK) begin
	DO <= ram [xREGRA_P];
        ram [xREGWA_P] <= xREGWE_P ? xREGDI_P : ram [xREGWA_P];
    end

    assign xREGDO_P = DO;

endmodule
