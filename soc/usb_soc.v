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
module usb_soc (
	input  wire clk48m,
	input  wire rst,

	//Slave iface from cpu
	input [17:0] addr,
	input [31:0] din,
	input wen, ren,
	output [31:0] dout,
	output ready,

	// IRQ
	output wire irq,

	// SOF indication
	output wire sof,

	// Interface
	inout  wire pad_dp,
	inout  wire pad_dn,
	output reg  pad_pu
);

wire [31:0] memrx_data;
wire memtx_we;
wire memrx_re;
wire [15:0] creg_data;
wire creg_cyc, creg_we, creg_ack;
wire sel_creg, sel_rxmem, sel_txmem, sel_invalid;

usb #(
	.TARGET("ECP5"),
	.EPDW(32), //mem bus width
	.EVT_DEPTH(4)
) usb_inst  (
	.pad_dp(pad_dp),
	.pad_dn(pad_dn),
	.pad_pu(pad_pu),

	.ep_tx_addr_0(addr[17:2]),
	.ep_tx_data_0(din),
	.ep_tx_we_0(sel_txmem && wen),
	.ep_rx_addr_0(addr[17:2]),
	.ep_rx_data_1(memrx_data),
	.ep_rx_re_0(sel_rxmem && ren),
	
	.ep_clk(clk48m),
	
	.bus_addr(addr[17:2]),
	.bus_din(din[15:0]),
	.bus_dout(creg_data),
	.bus_cyc(creg_cyc),
	.bus_we(wen),
	.bus_ack(creg_ack),
	
	.irq(irq),
	.sof(sof),
	.clk(clk48m),
	.rst(rst)
);

//Note: RAM is 2KByte, but we reserve 64KiB for the different regions, totalling 
//at (rounded) 256K for the entire memory space.

assign sel_creg = (addr[17:16] == 'h0);
assign sel_rxmem = (addr[17:16] == 'h1);
assign sel_txmem = (addr[17:16] == 'h2);
assign sel_invalid = (addr[17:16] == 'h3);
wire sel_any_immed;
assign sel_any_immed = sel_rxmem | sel_txmem | sel_invalid;

assign creg_cyc = sel_creg & (wen || ren);

assign dout = sel_creg ? creg_data : (sel_rxmem ? memrx_data : 'hDEADBEEF);

reg ready_n;

always @(posedge clk48m) begin
	if (rst) begin
		ready_n <= 0;
	end else begin
		ready_n <= sel_any_immed & (ren|wen);
	end
end

assign ready = (ready_n || creg_ack) & (wen || ren);

endmodule
