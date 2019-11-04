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

//Semi-random trng (ish) generator. It's based on two lfsrs clocked by the main clock and the internal
//clock of the ecp5, respectively. While it should have a somewhat good random output, don't try to
//rely too much on it for crypto stuff... It's mainly chosen above a pure lfsr because it gives a 
//different set of random-ish numbers on every bootup.

//Note: You probably don't want to read from this more often than once every 32 clock cycles.

module rng (
		input clk1,
		input clk2, //assumed to be slower than clk - >= 2x slower.
		input rst,
		output reg [31:0] rngno
	);

	wire [31:0] rngnuma;
	wire [31:0] rngnumb;

	lfsr64b #(
		.INITIAL_VAL(64'hAAAAAAAAAAAAAAAA)
	) prnga (
		.clk(clk1),
		.rst(rst),
		.prngout(rngnuma)
	);
	
	//Reset is synchronous with clk1. Domain-cross-thingy to clk2, so we know for sure it lasts long enough
	//there as well.
	reg [1:0] reset_slow_ct;
	reg [1:0] old_clk2;
	always @(posedge clk1) begin
		if (rst) begin
			reset_slow_ct <= 3;
		end else if (old_clk2[0] == 1 && old_clk2[1] == 0 && reset_slow_ct != 0) begin
			reset_slow_ct <= reset_slow_ct - 1;
		end
		old_clk2[1] <= old_clk2[0];
		old_clk2[0] <= clk2;
	end
	
	reg reset_clk2;
	always @(posedge clk2) begin
		reset_clk2 <= (reset_slow_ct != 0);
	end
	
	lfsr64b #(
		.INITIAL_VAL(64'hBBBBBBBBBBBBBBBB)
	) prngb (
		.clk(clk2),
		.rst(reset_clk2),
		.prngout(rngnumb)
	);
	
	//Do clock domain crossing back and
	reg [31:0] rngnumb_cross[0:1];
	always @(posedge clk1) begin
		rngnumb_cross[1] <= rngnumb_cross[0];
		rngnumb_cross[0] <= rngnumb;
		rngno <= rngnumb_cross[1] ^ rngnuma;
	end

endmodule

module lfsr64b #(
		parameter [63:0] INITIAL_VAL = 64'hFFFFFFFFFFFFFFFF
	) (
		input clk,
		input rst,
		output [31:0] prngout
	);
	
	reg [63:0] prngdata;
	assign prngout = prngdata[31:0];

	wire feedback;
	assign feedback = ~(prngdata[63] ^ prngdata[62] ^ prngdata[60] ^ prngdata[59]);

	always @(posedge clk) begin
		if (rst) begin
			prngdata <= INITIAL_VAL;
		end else begin
			prngdata <= {prngdata[62:0],feedback};
		end
	end
endmodule

