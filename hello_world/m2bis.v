
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

//want internal frequency 12MHz, used for serial port
wire clk12Mhz;

//use instance of PLL, which generates 12MHz
my_pll my_pll_instance(
	.inclk0( CLK100MHZ ),
	.c0( clk12Mhz ),
	.locked()
	);


reg [8*14-1:0] message = "* !dlroW olleH";

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

wire end_of_send;
wire send;
reg [15:0]message_bit_index;
wire [7:0]send_char;
assign send_char = message >> message_bit_index;

//use instance of serial port transmitter
serial_tx serial_tx_instance(
  .clk12( clk12Mhz ),
  .sbyte( send_char ),
  .sbyte_rdy( send ),
  .tx( FTDI_BD1 ),
  .end_of_send( end_of_send ),
  .ack()
);

localparam STATE_WAIT_KEY_PRESS = 0;
localparam STATE_SEND_CHAR = 1;
localparam STATE_WAIT_CHAR_SENT = 2;

reg [3:0]state = STATE_WAIT_KEY_PRESS;

always @( posedge clk12Mhz )
begin
	case( state )
	STATE_WAIT_KEY_PRESS:
		begin
			if( key_press_event ) state <= STATE_SEND_CHAR;
		end
	STATE_SEND_CHAR:
		begin
			state <= STATE_WAIT_CHAR_SENT;
		end
	STATE_WAIT_CHAR_SENT:
		begin
			if( end_of_send ) 
				state <= ((send_char==8'h2A) ? STATE_WAIT_KEY_PRESS : STATE_SEND_CHAR);
		end
	endcase
end

assign send = (state == STATE_SEND_CHAR);

always @( posedge clk12Mhz )
	if( state==STATE_WAIT_KEY_PRESS )
		message_bit_index <= 0;
	else
	if( state==STATE_SEND_CHAR )
		message_bit_index <= message_bit_index+8;

endmodule
