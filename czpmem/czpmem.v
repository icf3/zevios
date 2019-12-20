// Copyright (c) 2019 Naoki Hirayama
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* czpmem.v
   2019.4.15   Ver0.0 */

`timescale 1ns/1ps
/* FPGA case , comment out USE_XPM and USE_XPM_xxbit */
//`define USE_XPM
`ifndef PC_WIDTH
    `define PC_WIDTH 10
`endif
/***************************************/
/* Xilinx XPM                          */
/***************************************/
//`define USE_XPM_10bit
//`define USE_XPM_11bit
//`define USE_XPM_12bit
//`define USE_XPM_13bit
//`define USE_XPM_14bit
//`define USE_XPM_15bit
//`define USE_XPM_16bit

`ifdef USE_XPM_10bit
    `define XPM_MEMORY_SIZE 32768
`endif
`ifdef USE_XPM_11bit
    `define XPM_MEMORY_SIZE 65536
`endif
`ifdef USE_XPM_12bit
    `define XPM_MEMORY_SIZE 131072
`endif
`ifdef USE_XPM_13bit
    `define XPM_MEMORY_SIZE 262144
`endif
`ifdef USE_XPM_14bit
    `define XPM_MEMORY_SIZE 524288
`endif
`ifdef USE_XPM_15bit
    `define XPM_MEMORY_SIZE 1048576
`endif
`ifdef USE_XPM_16bit
    `define XPM_MEMORY_SIZE 2097152
`endif
/***************************************/


`ifndef USE_XPM
module rom_style (clk, en, addrA, dout);
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 16;

    input       clk;
    input       en;
    input [ADDR_WIDTH-1:0] addrA;
    output reg [DATA_WIDTH-1:0] dout;

    (* rom_style = "block" *)
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    initial $readmemh("pmem.bin", rom);

    always @(posedge clk) begin
        if (en)
          dout <= rom[addrA];
    end
endmodule // rom_style
`endif


module czpmem(CLK, xPC_P, xIR_P);
    input CLK;
    input [`PC_WIDTH-1:0] xPC_P;
    output [31:0] xIR_P;

    wire [31:0] dout;

`ifndef USE_XPM

    rom_style #(
        .ADDR_WIDTH(`PC_WIDTH),
        .DATA_WIDTH(32)
    ) program_rom (
        .clk(CLK),
        .en(1'b1),
        .addrA(xPC_P),
        .dout(dout)
    );

`else

    xpm_memory_sprom # (
        .ADDR_WIDTH_A(`PC_WIDTH),             // DECIMAL
        .AUTO_SLEEP_TIME(0),           // DECIMAL
	.ECC_MODE("no_ecc"),           // String
	.MEMORY_INIT_FILE("pmem.mem"), // String
	.MEMORY_INIT_PARAM("0"),       // String
	.MEMORY_OPTIMIZATION("true"),  // String
	.MEMORY_PRIMITIVE("auto"),     // String
	.MEMORY_SIZE(`XPM_MEMORY_SIZE), // DECIMAL
	.MESSAGE_CONTROL(0),           // DECIMAL
	.READ_DATA_WIDTH_A(32),        // DECIMAL
	.READ_LATENCY_A(1),            // DECIMAL
	.READ_RESET_VALUE_A("0"),      // String
	.USE_MEM_INIT(1),              // DECIMAL
	.WAKEUP_TIME("disable_sleep")  // String
    ) xpm_memory_sprom_inst (
        .dbiterra(),                   // 1-bit output: Leave open.
        .douta(dout),                  // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
        .sbiterra(),                   // 1-bit output: Leave open.
        .addra(xPC_P),                 // ADDR_WIDTH_A-bit input: Address for port A read operations.
        .clka(CLK),                    // 1-bit input: Clock signal for port A.
        .ena(1'b1),                    // 1-bit input: Memory enable signal for port A. Must be high on clock
                                       // cycles when read operations are initiated. Pipelined internally.
       .injectdbiterra(1'b0),          // 1-bit input: Do not change from the provided value.
       .injectsbiterra(1'b0),          // 1-bit input: Do not change from the provided value.
       .regcea(1'b0),                  // 1-bit input: Do not change from the provided value.
       .rsta(1'b0),                    // 1-bit input: Reset signal for the final port A output register stage.
                                       // Synchronously resets output port douta to the value specified by
			               // parameter READ_RESET_VALUE_A.
       .sleep(1'b0)                    // 1-bit input: sleep signal to enable the dynamic power saving feature.
    );

`endif

    assign xIR_P = dout;

endmodule
