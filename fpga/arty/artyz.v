/* artyz.v
   2019.4.9   Ver0.0
   Naoki Hirayama
*/

`timescale 1ns/1ps

module artyz(
    input CLK,
    input xRESET_N,
    input [9:0] SW,
    output [7:0] LED_A,  // OUTPORT
    output [7:0] LED_B,  // PORTID
    output [3:0] IOZ);

    wire xRESET_P = ~xRESET_N;

    icf3z ICf3z(
        .CLK(CLK),
        .xINPORT_P(SW[9:2]),
        .xRESET_P(xRESET_P),
        .xINT0_P(SW[0]),
        .xINT1_P(SW[1]),
        .xPORTID_P(LED_B),
        .xOUTPORT_P(LED_A),
        .xWSTROBE_P(IOZ[0]),
        .xWSTROBEK_P(IOZ[1]),
        .xIOSTROBE_P(IOZ[2]),
	.xRSTROBE_P(IOZ[3]));

endmodule
