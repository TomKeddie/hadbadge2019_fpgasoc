//Combinatorial signed 18x18 multiplier.
/*
 * Copyright (C) 2019  Jeroen Domburg <jeroen@spritesmods.com>
 * All rights reserved.
 *
 * BSD 3-clause, see LICENSE.bsd
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module mul_18x18(
	input [17:0] a,
	input [17:0] b,
	output [35:0] dout
);

    wire en;
	assign en = 1;

    /* verilator lint_off PINMISSING */
    MULT18X18D  #(
//    .CLK3_DIV("ENABLED"),
//    .CLK2_DIV("ENABLED"),
//    .CLK1_DIV("ENABLED"),
//    .CLK0_DIV("ENABLED"),
    //.REG_INPUTC_CLK("NONE"),
    .SOURCEB_MODE("B_SHIFT"),
    .RESETMODE("SYNC"),
    // .REG_INPUTA_RST("RST0"),
    // .REG_INPUTA_CE("CE0"),
    // .REG_INPUTA_CLK("CLK0"),
    // .REG_INPUTB_RST("RST0"),
    // .REG_INPUTB_CE("CE0"),
    // .REG_INPUTB_CLK("CLK0"),
    // .REG_OUTPUT_CLK("CLK0"),
    // .REG_PIPELINE_RST("RST0"),
    // .REG_PIPELINE_CE("CE0"),
    // .REG_PIPELINE_CLK("CLK0"),
    .GSR("DISABLED"))
dsp_mult_0(
		 // Outputs
		 .SROA17			(),
		 .SROA16			(),
		 .SROA15			(),
		 .SROA14			(),
		 .SROA13			(),
		 .SROA12			(),
		 .SROA11			(),
		 .SROA10			(),
		 .SROA9			(),
		 .SROA8			(),
		 .SROA7			(),
		 .SROA6			(),
		 .SROA5			(),
		 .SROA4			(),
		 .SROA3			(),
		 .SROA2			(),
		 .SROA1			(),
		 .SROA0			(),
		 .SROB17			(),
		 .SROB16			(),
		 .SROB15			(),
		 .SROB14			(),
		 .SROB13			(),
		 .SROB12			(),
		 .SROB11			(),
		 .SROB10			(),
		 .SROB9			(),
		 .SROB8			(),
		 .SROB7			(),
		 .SROB6			(),
		 .SROB5			(),
		 .SROB4			(),
		 .SROB3			(),
		 .SROB2			(),
		 .SROB1			(),
	   .SROB0			(),
		 .ROA8			(),
		 .ROA7			(),
		 .ROA6			(),
		 .ROA5			(),
		 .ROA4			(),
		 .ROA3			(),
		 .ROA2			(),
		 .ROA1			(),
		 .ROA0			(),
		 .ROB8			(),
		 .ROB7			(),
		 .ROB6			(),
		 .ROB5			(),
		 .ROB4			(),
		 .ROB3			(),
		 .ROB2			(),
		 .ROB1			(),
		 .ROB0			(),
		 .ROC8			(),
		 .ROC7			(),
		 .ROC6			(),
		 .ROC5			(),
		 .ROC4			(),
		 .ROC3			(),
		 .ROC2			(),
		 .ROC1			(),
		 .ROC0			(),
		.P35(dout[35]), .P34(dout[34]), .P33(dout[33]), .P32(dout[32]),
		.P31(dout[31]), .P30(dout[30]), .P29(dout[29]), .P28(dout[28]), .P27(dout[27]), .P26(dout[26]), .P25(dout[25]), .P24(dout[24]),
		.P23(dout[23]), .P22(dout[22]), .P21(dout[21]), .P20(dout[20]), .P19(dout[19]), .P18(dout[18]), .P17(dout[17]), .P16(dout[16]),
		.P15(dout[15]), .P14(dout[14]), .P13(dout[13]), .P12(dout[12]), .P11(dout[11]), .P10(dout[10]), .P9(dout[9]), .P8(dout[8]),
		.P7(dout[7]), .P6(dout[6]), .P5(dout[5]), .P4(dout[4]), .P3(dout[3]), .P2(dout[2]), .P1(dout[1]), .P0(dout[0]),
		 .SIGNEDP		(),
		 // Inputs
		.A17(a[17]), .A16(a[16]),
		.A15(a[15]), .A14(a[14]), .A13(a[13]), .A12(a[12]), .A11(a[11]), .A10(a[10]), .A9(a[9]), .A8(a[8]),
		.A7(a[7]), .A6(a[6]), .A5(a[5]), .A4(a[4]), .A3(a[3]), .A2(a[2]), .A1(a[1]), .A0(a[0]),

		.B17(b[17]), .B16(b[16]),
		.B15(b[15]), .B14(b[14]), .B13(b[13]), .B12(b[12]), .B11(b[11]), .B10(b[10]), .B9(b[9]), .B8(b[8]),
		.B7(b[7]), .B6(b[6]), .B5(b[5]), .B4(b[4]), .B3(b[3]), .B2(b[2]), .B1(b[1]), .B0(b[0]),
		 .C17			(1'b0),
		 .C16			(1'b0),
		 .C15			(1'b0),
		 .C14			(1'b0),
		 .C13			(1'b0),
		 .C12			(1'b0),
		 .C11			(1'b0),
		 .C10			(1'b0),
		 .C9			(1'b0),
		 .C8			(1'b0),
		 .C7			(1'b0),
		 .C6			(1'b0),
		 .C5			(1'b0),
		 .C4			(1'b0),
		 .C3			(1'b0),
		 .C2			(1'b0),
		 .C1			(1'b0),
		 .C0			(1'b0),
		 .SIGNEDA		(1'B1),
		 .SIGNEDB		(1'B1),
		 .SOURCEA		(1'B0),
		 .SOURCEB		(1'B0),
		 .CE0			(en),
		 .CE1			(1'b1),
		 .CE2			(1'b1),
		 .CE3			(1'b1),
		 .CLK0			(1'b0),
		 .CLK1			(1'b0),
		 .CLK2			(1'b0),
		 .CLK3			(1'b0),
		 .RST0			(1'b0),
		 .RST1			(1'b0),
		 .RST2			(1'b0),
		 .RST3			(1'b0),
		 .SRIA17			(),
		 .SRIA16			(),
		 .SRIA15			(),
		 .SRIA14			(),
		 .SRIA13			(),
		 .SRIA12			(),
		 .SRIA11			(),
		 .SRIA10			(),
		 .SRIA9			(),
		 .SRIA8			(),
		 .SRIA7			(),
		 .SRIA6			(),
		 .SRIA5			(),
		 .SRIA4			(),
		 .SRIA3			(),
		 .SRIA2			(),
		 .SRIA1			(),
		 .SRIA0			(),
		 .SRIB17			(),
		 .SRIB16			(),
		 .SRIB15			(),
		 .SRIB14			(),
		 .SRIB13			(),
		 .SRIB12			(),
		 .SRIB11			(),
		 .SRIB10			(),
		 .SRIB9			(),
		 .SRIB8			(),
		 .SRIB7			(),
		 .SRIB6			(),
		 .SRIB5			(),
		 .SRIB4			(),
		 .SRIB3			(),
		 .SRIB2			(),
		 .SRIB1			(),
	   .SRIB0			());
endmodule
