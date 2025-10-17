module Multiplicador(
    input  [3:0] Multiplicando,
    input  [3:0] Multiplicador,
    input        St, Clk, rst,
    output [7:0] Produto,
    output       Idle, Done
);
    // Controle
    wire Load, Sh, Ad, K, M;

    // Barramentos internos
    wire [4:0] Soma;        // {cout,sum[3:0]} do Adder
    wire [8:0] Resultado;   // {COUT, A[3:0], B[3:0]} do ACC
	 wire [3:0] OperandoB;
	 

    // Decodificações
    assign M        = Resultado[0];      // LSB de B
    assign OperandoB  = Resultado[7:4];
	 
    // Soma: Multiplicando + A
    Adder adder (
        .OperandoA(Multiplicando),
        .OperandoB(OperandoB),
        .Soma(Soma)                     // Soma[4]=cout, Soma[3:0]=sum
    );
	 
    ACC acc(
        .Load(Load),
        .Sh(Sh),
        .Ad(Ad),
        .Clk(Clk),
        .rst(rst),
        .Entradas({Soma,Multiplicador}),
        .Saidas(Resultado)
    );

    CONTROL control(
        .Clk(Clk),
        .K(K),
        .St(St),
        .M(M),
        .rst(rst),
        .Idle(Idle),
        .Done(Done),
        .Load(Load),
        .Sh(Sh),
        .Ad(Ad)
    );

    Counter counter(
        .Load(Load),
        .Clk(Clk),
        .rst(rst),
        .K(K)
    );
	 
	 assign Produto = Resultado[7:0];
	 
endmodule
