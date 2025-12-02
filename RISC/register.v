module register #(parameter DATA_WIDTH=32) (
	input [DATA_WIDTH-1:0] in, 
	input CLK, RST,
	output reg[DATA_WIDTH-1:0] out 
);

	always @(posedge CLK, posedge RST)
		if(RST)
			out <= 0;
		else
			out <= in;

endmodule