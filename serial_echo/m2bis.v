
module m2bis(
	input wire	CLK100MHZ, 	//board 100MHz crystal
	input wire	KEY0,		//board button with weak pull-up resistor, normally logical ONE
	output wire	[2:0]LED,	//board LEDs
	
	//FTDI serial port signals
	input wire	FTDI_BD0,	//from FTDI, RxD
	output wire FTDI_BD1,	//to FTDI, TxD
	input wire	FTDI_BD2, 	//from FTDI, RTS
	output wire FTDI_BD3, 	//to FTDI, CTS
	
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
	
	//serial flash interface
	output wire DCLK,
	output wire NCSO,
	output wire ASDO,
	input wire	DATA0
);

wire w_clk;
wire w_locked;

//use instance of PLL, which generates 12MHz
my_pll my_pll_instance(
	.inclk0( CLK100MHZ ),
	.c0( w_clk ),
	.locked( w_locked )
	);

wire [7:0]rx_byte;
wire w_rbyte_ready;
serial my_serial_inst(
	.reset( ~w_locked ),
	.clk100( w_clk ),
	.rx( FTDI_BD0 ),
	.rx_byte( rx_byte ),
	.rbyte_ready( w_rbyte_ready )
	);

//registered delay of w_rbyte_ready impulse 
reg [1:0]r_rbyte_ready;
always @( posedge w_clk )
	r_rbyte_ready <= { r_rbyte_ready[0], w_rbyte_ready };

//fix received serial byte into register
reg [7:0]r_rx_byte;
always @( posedge w_clk )
	if( w_rbyte_ready )
		r_rx_byte <= rx_byte;

//modify received byte +1 and fix into register
reg [7:0]r_rx_byte_1;
always @( posedge w_clk )
	if( r_rbyte_ready[0] )
		r_rx_byte_1 <= r_rx_byte+1'b1;

//serial send modified byte back to host (echo)
tx_serial my_tx_serial_inst(
	.reset( ~w_locked ),
	.clk100( w_clk ),
	.sbyte( r_rx_byte_1 ),
	.send( r_rbyte_ready[1] ),
	.tx( FTDI_BD1 ),
	.busy() 
	);


reg [2:0]recv_char_counter;
always @( posedge w_clk )
	if( w_rbyte_ready )
		recv_char_counter <= recv_char_counter + 1;

assign LED = recv_char_counter;

endmodule
