module ADDRDecoding(WE, inputResult, iAddress, iWE, CS);
	input WE;
	input [31:0] inputResult;
	output reg [31:0] iAddress;
	output reg iWE, CS;
	
	reg [31:0] superior;
	reg [31:0] inferior;
	
	initial begin
			inferior = 32'h00000780;
			superior = 32'h00000B7F; //VALOR A SER DEFINIDO!!!!!!!!!!!!
			CS = 1; //DAR UMA OLHADA NO VALOR INICIAL!!! 
			iWE = 0;
			iAddress = 0;
	end
	
	always @ (*) begin
		if(inputResult >= inferior && inputResult <= superior) begin
			iWE = WE;
			CS = 1;
			iAddress = inputResult - inferior;
		end 
		else begin
			CS = 0; //Nao importa muito os valores nesse else!! Mas eh importante o iWE estar como ZERO!!!
			iWE = 0;
			iAddress = 0;
		end
	end
endmodule
