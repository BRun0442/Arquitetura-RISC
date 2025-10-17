`timescale 1ns/100ps

module Adder_TB();

	reg [3:0] OperandoA, OperandoB;
	wire [4:0] Soma;
	
	Adder DUT (
		.OperandoA(OperandoA),
		.OperandoB(OperandoB),
		.Soma(Soma)
	);
	
	initial begin
		 OperandoA = 4'd8; OperandoB = 4'd7;
		 #10;
		 
		 OperandoA = 4'd9; OperandoB = 4'd7;
		 #10;
		 
		 OperandoA = 4'd10; OperandoB = 4'd10;
		 #10;
		 
		 OperandoA = 4'd9; OperandoB = 4'd5;
		 #10;
		 
	end

endmodule