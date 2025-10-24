module ADDRDecoding_Prog(iAddressInst, CS_P, ADDR_Prog);
	input [31:0] ADDR_Prog;
	output reg CS_P;
	output reg [31:0] iAddressInst;
	
	reg [31:0] superior;
	reg [31:0] inferior;
	
	initial begin
			inferior = 32'h00000410;
			superior = 32'h0000080F;
			CS_P = 1;
			iAddressInst = 0;
	end
	
	always @ (*) begin
		if(ADDR_Prog >= inferior && ADDR_Prog <= superior) begin
			CS_P = 1;
			iAddressInst = ADDR_Prog - inferior;
		end 
		else begin
			CS_P = 0;
		end
	end
endmodule
