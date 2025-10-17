module ACC (
	input Load, Sh, Ad, Clk, rst,
	input [32:0] Entradas,
	output reg [32:0] Saidas
);

	//Aqui entra a implementação do ckt
	always @ (posedge Clk, posedge rst) begin
		if (rst) begin
			Saidas   <= 33'd0;
		end
		else if (Load) begin
			Saidas[15:0] <= Entradas[15:0];
			Saidas[32:16] <= 17'd0;
		end
		else if(Ad) begin
			Saidas[32:16] <= Entradas[32:16];
			Saidas[15:0] <= Saidas[15:0];
		end
		else if (Sh) begin
			Saidas <= Saidas >> 1;
		end
		
	end

endmodule
