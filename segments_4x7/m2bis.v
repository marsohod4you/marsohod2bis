
module m2bis(
	input wire	CLK100MHZ, 	//board 100MHz crystal
	input wire	KEY0,		//board button with weak pull-up resistor, normally logical ONE
	output wire	[2:0]LED,	//board LEDs
	
	//below are signals unused in project but 
	//they exist on marsohod2bis board
	
	//VGA interface
	output wire [4:0]VGA_RED,
	output wire [5:0]VGA_GREEN,
	output wire [4:0]VGA_BLUE,
	output wire VGA_HSYNC,
	output wire VGA_VSYNC,
	
	//ADC1175 interface
	input wire	[7:0]ADC_D,
	output wire ADC_CLK,
	
	//Shield I/O interface
	inout wire	[15:0]IO,
	
	//SDRAM (MT48LC4M16A2-75) interface
	output wire	SDRAM_CLK,
	inout wire	[15:0]SDRAM_DQ,
	output wire [11:0]SDRAM_A,
	output wire SDRAM_LDQM,
	output wire SDRAM_UDQM,
	output wire SDRAM_BA0,
	output wire SDRAM_BA1,
	output wire SDRAM_RAS,
	output wire SDRAM_CAS,
	output wire SDRAM_WE,
	
	//FTDI serial port signals
	input wire	FTDI_BD0,	//from FTDI, RxD
	output wire FTDI_BD1,	//to FTDI, TxD
	input wire	FTDI_BD2, 	//from FTDI, RTS
	output wire FTDI_BD3, 	//to FTDI, CTS
	
	//serial flash interface
	output wire DCLK,
	output wire NCSO,
	output wire ASDO,
	input wire	DATA0
);

reg [47:0]counter;
always @(posedge CLK100MHZ)
	if( KEY0 )
		counter <= counter+1;

assign LED = counter[25:23];

wire [3:0]s0_digit_sel;
wire [7:0]s0_out;
seg4x7 seg4x7_instance(
	.clk( CLK100MHZ ),
	.in( counter[36:20] ),
	.digit_sel( s0_digit_sel ),
	.out( s0_out )
);

wire [35*8-1:0]alphabet = "....ABCDEFGHIJKLMNOPQRSTUVWXYZ.....";
wire [19*8-1:0]message  = "....HELLO WORLD....";

reg [31:0]show_string;
always @( posedge CLK100MHZ )
	if( ~IO[ 8] )
		show_string <= 32'h31313131; //"1111"
	else
	if( ~IO[ 9] )
		show_string <= 32'h32323232; //"2222"
	else
	if( ~IO[10] )
		show_string <= (alphabet >> (31 - counter[29:25])*8 );
	else
		show_string <= (message >> (15-counter[28:25])*8 );

wire [3:0]s1_digit_sel;
wire [7:0]s1_out;
seg4x7_assii seg4x7_ascii_instance(
	.clk( CLK100MHZ ),
	.in( show_string ),
	.digit_sel( s1_digit_sel ),
	.out( s1_out )
);

wire four_keys; assign four_keys = ~IO[8] | ~IO[9] | ~IO[10] | ~IO[11];

reg [3:0]s_digit_sel;
reg [7:0]s_out;
always @(posedge CLK100MHZ )
	begin
		s_digit_sel <= four_keys ? s1_digit_sel : s0_digit_sel;
		s_out <= four_keys ? s1_out : s0_out;
	end
	
assign { IO[15],IO[13],IO[12],IO[14] } = s_digit_sel;
assign IO[7:0]  = s_out;

endmodule
