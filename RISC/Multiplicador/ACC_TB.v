`timescale 1ns/1ps

module ACC_TB;
  // Estímulos
  reg Load, Sh, Ad, Clk, rst;
  reg [8:0] Entradas;

  // Saída observada
  wire [8:0] Saidas;

  // DUT
  ACC dut (
    .Load(Load),
    .Sh(Sh),
    .Ad(Ad),
    .Clk(Clk),
    .rst(rst),
    .Entradas(Entradas),
    .Saidas(Saidas)
  );

  // Relógio de 10 ns
  always #5 Clk = ~Clk;

  // Monitoração
  initial begin
    $display(" t  rst L Ad Sh | Entradas   | Saidas");
    $monitor("%3t  %b   %b  %b  %b | %9b | %9b",
              $time, rst, Load, Ad, Sh, Entradas, Saidas);
  end

  // Estímulos sequenciais
  initial begin
    // Init
    Clk = 1'b0;
    Load = 0; Sh = 0; Ad = 0; rst = 1'b1;
    Entradas = 9'b0;
    #12 rst = 1'b0;     // libera reset em borda de clk

    // 1) LOAD: carrega nibble baixo e zera alto (como o módulo pretende)
    Entradas = 9'b1_1010_1101; // [8]=1, [7:4]=1010, [3:0]=1101
    @(negedge Clk); Load = 1;
    @(negedge Clk); Load = 0;

    // 2) AD: copia [7:4] de Entradas para Saidas[7:4]
    Entradas[7:4] = 4'b0111;
    @(negedge Clk); Ad = 1;
    @(negedge Clk); Ad = 0;

    // 3) SH: desloca à direita (Saidas[7:0] <= Saidas[8:1])
    repeat (2) begin
      @(negedge Clk); Sh = 1;
      @(negedge Clk); Sh = 0;
    end

    // 4) Nova carga e sequência AD+SH
    Entradas = 9'b0_1111_0001;
    @(negedge Clk); Load = 1;
    @(negedge Clk); Load = 0;

    Entradas[7:4] = 4'b1010;
    @(negedge Clk); Ad = 1;
    @(negedge Clk); Ad = 0;

    repeat (3) begin
      @(negedge Clk); Sh = 1;
      @(negedge Clk); Sh = 0;
    end

    // 5) Prioridade: sinais simultâneos (Load deve ganhar do Ad e do Sh)
    Entradas = 9'b0_0011_0101;
    @(negedge Clk) begin Load = 1; Ad = 1; Sh = 1; end
    @(negedge Clk) begin Load = 0; Ad = 0; Sh = 0; end

    // 6) Reset durante operação
    @(negedge Clk); rst = 1;
    @(negedge Clk); rst = 0;

    #20 $finish;
  end
endmodule
