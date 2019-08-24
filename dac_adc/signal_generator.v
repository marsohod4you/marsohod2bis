
module signal_generator(
	input wire clk,
	input wire [2:0]selector,
	output wire [7:0]signal
);

reg [5:0]addr;
always @(posedge clk)
	addr <= addr + 1;

wire [7:0]s_meandr;
rom #(.MIF_FILE("./python/meandr.mif")) rom_inst1(
	.address( addr ),
	.clock( clk ),
	.q(s_meandr)
);

wire [7:0]s_saw1;
rom #(.MIF_FILE("./python/saw1.mif")) rom_inst2(
	.address( addr ),
	.clock( clk ),
	.q(s_saw1)
);

wire [7:0]s_saw3;
rom #(.MIF_FILE("./python/saw3.mif")) rom_inst3(
	.address( addr ),
	.clock( clk ),
	.q(s_saw3)
);

wire [7:0]s_sin;
rom #(.MIF_FILE("./python/sin.mif")) rom_inst4(
	.address( addr ),
	.clock( clk ),
	.q(s_sin)
);

reg [7:0]s_out;
always @( posedge clk )
	case( selector[1:0] )
		0: s_out <= s_meandr;
		1: s_out <= s_saw1;
		2: s_out <= s_saw3;
		3: s_out <= s_sin;
	endcase

assign signal = s_out;

endmodule
