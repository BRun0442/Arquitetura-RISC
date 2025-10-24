module extend(instInput, valueOutput, signalCtrl);
	input	[31:0] instInput;
	input signalCtrl;
	output reg [31:0] valueOutput;
	
	always @ (*) begin
		if(signalCtrl && instInput[15]) begin
			valueOutput <= {16'hFFFF, instInput[15:0]};
		end
		else begin
			valueOutput <= {16'h0000, instInput[15:0]};
		end
	end
endmodule
