module Counter (
	input Load, Clk, rst,
	output reg K
);

	reg [7:0]count;
	reg aux_Load = 1'b0;
	
	always @ (posedge Clk, posedge rst) begin
		
		if(rst)
		begin
			count     <= 8'd0;
			aux_Load  <= 1'b0;
			K         <= 1'b0;
		end 
		else if (Load) begin
			count     <= 8'd0;
			aux_Load  <= 1'b1;
			K         <= 1'b0;
		end
		else if({count == 8'd30} && aux_Load) begin
			count     <= 8'd0;
			aux_Load  <= 1'b0;
			K         <= 1'b1;		
		end 
		else if (aux_Load) begin
			count     <= count + 8'd1;
			K         <= 1'b0;
		end

	end
	
endmodule