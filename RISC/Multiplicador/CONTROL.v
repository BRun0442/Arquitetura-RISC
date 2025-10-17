module CONTROL (
	input Clk, K, St, M, rst,
	output reg Idle, Done, Load, Sh, Ad
);

	reg [1:0] stage;
	
	parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
	
	// Output depends only on the state
	always @ (posedge Clk, posedge rst) begin// na maquina de miley tem ver e blue aqui
	//zerar os sinais
		if (rst)
			stage <= S0;
		else
		case (stage)
			S0: 
				if  (St) begin 
					stage <= S1;
				end

			S1:
					stage <= S2;
				
			S2: 
				if (K) stage <= S3; else stage <= S1;
			S3:
				stage <= S0;
			default 
				stage <= S0;
		endcase
	end

	// Determine the next state
	always @ (*) begin// reset asincrono pois esta na lista de sensibilidade 
			case (stage)
				S0: begin
					Idle <= 1'b1;
					Done <= 1'b0;
					Sh   <= 1'b0;
					Ad   <= 1'b0;
					Load <= 1'b0;
					if (St) Load <= 1'b1;
				end
				S1: begin
					Idle <= 1'b0;
					Done <= 1'b0;
					Sh   <= 1'b0;
					Load <= 1'b0;
					if (M) Ad <= 1'b1; else Ad <= 1'b0;
				end
				S2: begin
					Idle <= 1'b0;
					Done <= 1'b0;
					Sh   <= 1'b1;
					Ad   <= 1'b0;
					Load <= 1'b0;
				end
				S3: begin
					Idle <= 1'b0;
					Done <= 1'b1;
					Sh   <= 1'b0;
					Ad   <= 1'b0;
					Load <= 1'b0;
				end
			endcase
	
	end
endmodule
