module extend(instInput, valueOutput);
	input	[31:0] instInput;
	output reg [31:0] valueOutput;
	
	always @ (*) begin
		if(instInput[15])
			valueOutput <= {16'hFFFF, instInput[15:0]};
		else 
			valueOutput <= {16'h0000, instInput[15:0]};
	end
endmodule
