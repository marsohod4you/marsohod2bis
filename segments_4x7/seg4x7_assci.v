module seg4x7_assci(
	input		wire	clk,			// 100MHZ
	input		wire	[31:0] in,
	output	reg	[3:0] digit_sel,
	output	reg	[7:0] out
);

reg     [19:0] cnt;
always @ (posedge clk)
	cnt <= cnt +1'b1;

wire [1:0]digit_idx; assign digit_idx = cnt[19:18];
always @ (posedge clk)
	digit_sel <= 4'b0001 << digit_idx;

wire [7:0]a;
assign a = 	digit_sel[0] ? in[7:0] : 
				digit_sel[1] ? in[15:8] : 
				digit_sel[2] ? in[23:16]: in[31:24];

//bit number..
//   +--6--+
//   |     |
//   5     7
//   |     |
//   +--3--+
//   |     |
//   0     4
//   |     |
//   +--2--+ (1)

always @ (posedge clk)
	case(a)
		//	bAfCgD.e  
		8'h20:out <= 8'b11111111;//space
		8'h2E:out <= 8'b11111101;//.
		8'h30:out <= 8'b00001010;//0
		8'h31:out <= 8'b01101111;//1
		8'h32:out <= 8'b00110010;//2
		8'h33:out <= 8'b00100011;//3
		8'h34:out <= 8'b01000111;//4
		8'h35:out <= 8'b10000011;//5
		8'h36:out <= 8'b10000010;//6
		8'h37:out <= 8'b00101111;//7
		8'h38:out <= 8'b00000010;//8
		8'h39:out <= 8'b00000011;//9
		
		8'h41:out <= 8'b00000110;//A
		8'h42:out <= 8'b11000010;//B
		8'h43:out <= 8'b10011010;//C
		8'h44:out <= 8'b01100010;//D
		8'h45:out <= 8'b10010010;//E
		8'h46:out <= 8'b10010110;//F
		8'h47:out <= 8'b10001010;//G
		8'h48:out <= 8'b01000110;//H
		
		8'h49:out <= 8'b11011110;//I
		8'h4A:out <= 8'b01101011;//J
		8'h4B:out <= 8'b11110111;//K -
		8'h4C:out <= 8'b11011010;//L
		8'h4D:out <= 8'b11110111;//M -
		8'h4E:out <= 8'b11100110;//N
		8'h4F:out <= 8'b11100010;//O
		8'h50:out <= 8'b00010110;//P
		8'h51:out <= 8'b00000111;//Q
		8'h52:out <= 8'b11110110;//R
		8'h53:out <= 8'b10000011;//S
		8'h54:out <= 8'b11010010;//T
		8'h55:out <= 8'b11101010;//U
		8'h56:out <= 8'b11110111;//V
		8'h57:out <= 8'b01011011;//W
		8'h58:out <= 8'b11110111;//X
		8'h59:out <= 8'b01000011;//Y
		8'h5A:out <= 8'b10110011;//Z
	default:
		out <= 8'b11110111; // - 
	endcase

endmodule
