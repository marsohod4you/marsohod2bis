
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

reg [31:0]counter;
always @(posedge CLK100MHZ)
	if( KEY0 )
		counter <= counter+1;

assign LED = counter[25:23];

endmodule
