module registerfile (
    input Clk, WE, resetControl,
    input [4:0] rs, rt, rd, // rs = registro A, rt = registro B, rd = registro de destino
    input [31:0] in,
    output reg [31:0] outA, outB
);    
    reg [31:0] register [31:0]; // Banco de registradores
    integer i;

    // Inicialização dos registradores zerando os valores
    initial begin
        for (i = 0; i < 32; i = i + 1) 
            register[i] <= 32'h0;
    end

    always @(posedge Clk) begin
        // Resetar as saídas se `resetControl` estiver ativo
        if (resetControl) begin
            outA <= 32'h0;
            outB <= 32'h0;
        end else begin
            // Leitura
            if (rs == 0) 
                outA <= 32'h0; // Registrador $0 é sempre 0
            else 
                outA <= register[rs];

            if (rt == 0) 
                outB <= 32'h0; // Registrador $0 é sempre 0
            else 
                outB <= register[rt];
				//So escreve no registro de destino se WE estiver ligado
				if (WE && rd != 0) 
                register[rd] <= in; // Evitar escrever no registrador $0
        end
    end
	 
endmodule
