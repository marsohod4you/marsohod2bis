
module m2bis(
	input wire	CLK100MHZ, 	//board 100MHz crystal
	input wire	KEY0,		//board button with weak pull-up resistor, normally logical ONE
	output wire	[2:0]LED,	//board LEDs
	
	//FTDI serial port signals
	input wire	FTDI_BD0,	//from FTDI, RxD
	output wire FTDI_BD1,	//to FTDI, TxD
	input wire	FTDI_BD2, 	//from FTDI, RTS
	output wire FTDI_BD3, 	//to FTDI, CTS
	
	//ADC1175 interface
	input wire	[7:0]ADC_D,
	output wire ADC_CLK,

	//VGA interface
	output wire [5:0]VGA_GREEN,
	
	//below are signals unused in project but 
	//they exist on marsohod2bis board
	
	//VGA interface
	output wire [4:0]VGA_RED,
	output wire [4:0]VGA_BLUE,
	output wire VGA_HSYNC,
	output wire VGA_VSYNC,
	
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

//want internal frequency 12MHz, used for serial port
wire clk12Mhz;
wire clk64Mhz;

//use instance of PLL, which generates 12MHz
my_pll my_pll_instance(
	.inclk0( CLK100MHZ ),
	.c0( clk12Mhz ),
	.c1( clk64Mhz ),
	.locked()
	);

//catch board key press
reg [1:0]prev_key_state;
always @(posedge clk12Mhz)
	prev_key_state <= { prev_key_state[0], KEY0 };

reg key_press_event;
always @( posedge clk12Mhz )
	key_press_event <= (prev_key_state== 2'b10);
	
reg [2:0]key_press_counter;
always @( posedge clk12Mhz )
	if( key_press_event )
		key_press_counter <= key_press_counter + 1;

assign LED = key_press_counter;

wire [7:0]s;
signal_generator sgen(
	.clk( clk64Mhz ),
	.selector( key_press_counter ),
	.signal( s )
);

//connect generated signal to GREEN VGA DAC
assign VGA_GREEN = s[7:2];

//connect ADC clock for external ADC
assign ADC_CLK = clk12Mhz;

//catch ADC data
reg [7:0]adc_data;
always @( posedge clk12Mhz )
	adc_data <= ADC_D;

reg [7:0]cnt;
reg send;
always @( posedge clk12Mhz )
begin
	if( cnt==11 )
		cnt <= 0;
	else
		cnt <= cnt+1;
	send <= cnt==11;
end

//use instance of serial port transmitter
serial_tx serial_tx_instance(
  .clk12( clk12Mhz ),
  .sbyte( adc_data ),
  .sbyte_rdy( send ),
  .tx( FTDI_BD1 ),
  .end_of_send( end_of_send ),
  .ack()
);


endmodule
