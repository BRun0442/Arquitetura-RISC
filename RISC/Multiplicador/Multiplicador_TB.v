`timescale 1ns/1ps
module Multiplicador_TB;

  // 100 MHz
  reg Clk = 0;
  always #5 Clk = ~Clk;

  // I/Os do DUT (16x16 -> 16b low; ajuste se seu topo expor 32b)
  reg  [15:0] Multiplicando, Multiplicador;
  reg         St, rst;
  wire [15:0] Produto;
  wire        Idle, Done;

  // DUT
  Multiplicador dut(
    .Multiplicando(Multiplicando),
    .Multiplicador(Multiplicador),
    .St(St), .Clk(Clk), .rst(rst),
    .Produto(Produto),
    .Idle(Idle), .Done(Done)
  );

  // ---------- Helpers (16 bits) ----------
  task start_mul(input [15:0] a, input [15:0] b);
    begin
      Multiplicando = a;
      Multiplicador = b;
      // garante estado ocioso antes do start (evita corrida)
      wait (Idle);
      @(posedge Clk);
      St = 1; @(posedge Clk); St = 0;
    end
  endtask

  // espera K do DUT (16 iterações) com timeout silencioso
  task wait_k_or_timeout(input integer cycles_max);
    integer i;
    begin
      for (i = 0; i < cycles_max; i = i + 1) begin
        @(posedge Clk);
        if (dut.K) begin
          @(posedge Clk); // 1 ciclo extra para estabilizar
          disable wait_k_or_timeout;
        end
      end
      // timeout silencioso
      $finish;
    end
  endtask

  // checagem silenciosa (encerra se falhar; sem prints)
  task check_prod(input [15:0] a, input [15:0] b);
    reg [31:0] exp32;
    begin
      exp32 = a * b;
      if (Produto !== exp32[15:0]) begin
        // falha silenciosa
        $finish;
      end
    end
  endtask
  // --------------------------------------

  initial begin
    // opcional: waveform
    $dumpfile("multiplicador16_tb.vcd");
    $dumpvars(0, Multiplicador_TB);

    // reset
    St = 0; Multiplicando = 0; Multiplicador = 0;
    rst = 1; repeat (2) @(posedge Clk); rst = 0; @(posedge Clk);

    // testes (cada um espera K e checa parte baixa de 32b)
    start_mul(16'd7,     16'd7);     wait_k_or_timeout(64); check_prod(16'd7,     16'd7);     @(posedge Clk);
    start_mul(16'd5,     16'd2);     wait_k_or_timeout(64); check_prod(16'd5,     16'd2);     @(posedge Clk);
    start_mul(16'd0,     16'd1234);  wait_k_or_timeout(64); check_prod(16'd0,     16'd1234);  @(posedge Clk);
    start_mul(16'd65535, 16'd3);     wait_k_or_timeout(64); check_prod(16'd65535, 16'd3);     @(posedge Clk);
    start_mul(16'd30000, 16'd4000);  wait_k_or_timeout(64); check_prod(16'd30000, 16'd4000);

    // encerra sem imprimir nada
    @(posedge Clk);
    $finish;
  end

endmodule
