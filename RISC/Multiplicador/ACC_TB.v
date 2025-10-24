`timescale 1ns/1ps

module Multiplicador_TB32;

  // Entradas do DUT
  reg  [31:0] Multiplicando;
  reg  [31:0] Multiplicador;
  reg         St, Clk, rst;

  // Saídas do DUT
  wire [31:0] Produto;  // assume produto truncado a 32 bits no seu módulo
  wire        Idle, Done;

  // Clock 100 MHz (10 ns)
  initial Clk = 1'b0;
  always  #5 Clk = ~Clk;

  // DUT
  Multiplicador dut (
    .Multiplicando(Multiplicando),
    .Multiplicador(Multiplicador),
    .St(St),
    .Clk(Clk),
    .rst(rst),
    .Produto(Produto),
    .Idle(Idle),
    .Done(Done)
  );

  // Tarefa: inicia uma multiplicação com pulso de 1 ciclo em St e espera o Done
  task start_mul(input [31:0] a, input [31:0] b);
    begin
      // aguarda ocioso (se o controle usar Idle)
      @(posedge Clk);
      while (!Idle) @(posedge Clk);

      Multiplicando = a;
      Multiplicador = b;

      // pulso de start por 1 ciclo
      St = 1'b1; @(posedge Clk);
      St = 1'b0;

      // espera concluir
      while (!Done) @(posedge Clk);
      @(posedge Clk); // 1 ciclo extra pra estabilizar nas ondas
    end
  endtask

  initial begin
    // Inicialização
    St = 1'b0;
    Multiplicando = 32'd0;
    Multiplicador = 32'd0;

    // Reset
    rst = 1'b1; repeat (3) @(posedge Clk);
    rst = 1'b0; @(posedge Clk);

    // Teste 1: 0x0000_00A5 * 0x0000_0014  (165 * 20)
    start_mul(32'h0000_00A5, 32'h0000_0014);

    // Teste 2: 0x1234_5678 * 0x0000_0002
    start_mul(32'h1234_5678, 32'h0000_0002);

    // (Opcional) Teste 3: números "grandes"
    start_mul(32'hFFFF_FFFF, 32'h0000_00FF);

    // pausa para inspeção de ondas
    repeat (10) @(posedge Clk);
    $stop; // deixa a simulação pausada para ver as ondas
  end

endmodule
