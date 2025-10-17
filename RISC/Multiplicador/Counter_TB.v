module Counter_TB();
    reg Load, Clk, rst;
    wire K;
    
    Counter uut (
        .Load(Load),
        .Clk(Clk),
        .rst(rst),
        .K(K)
    );
 
    initial begin
        // Inicialização dos sinais
        Load = 0;
        Clk = 0;
        rst = 1; // Inicia com reset ativo
        
        // Desativa o reset após alguns ciclos de clock
        #10 rst = 0;
        
        // Teste 1: Ativar Load e observar K
        #10 Load = 1; // Ativa Load
        #10 Load = 0; // Desativa Load
        
        // Espera alguns ciclos para observar o comportamento
        #100;
        
        // Teste 2: Ativar Load novamente
        #10 Load = 1; // Ativa Load
        #10 Load = 0; // Desativa Load
        
        // Espera mais alguns ciclos
        #100;
        
        // Finaliza a simulação
        $stop;
    end 

    always #5 Clk = ~Clk;

endmodule