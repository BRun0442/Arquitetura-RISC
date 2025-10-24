`timescale 1ns/1ps
module Multiplicador_TB;
  reg  [3:0] Multiplicando, Multiplicador;
  reg        St, Clk, rst;
  wire [7:0] Produto;
  wire       Idle, Done;

  // DUT
  Multiplicador dut(
    .Multiplicando(Multiplicando),
    .Multiplicador(Multiplicador),
    .St(St), .Clk(Clk), .rst(rst),
    .Produto(Produto),
    .Idle(Idle), .Done(Done)
  );

  // clock
  initial Clk = 0;
  always  #5 Clk = ~Clk;

  // helpers
  task start_mul(input [3:0] a, input [3:0] b);
    begin
      Multiplicando = a;
      Multiplicador = b;
      St = 1; @(posedge Clk); St = 0;
    end
  endtask

  task wait_done_or_timeout(input integer cycles_max);
    integer i;
    begin
      for (i=0; i<cycles_max; i=i+1) begin
        @(posedge Clk);
        if (Done) disable wait_done_or_timeout;
      end
      if (!Done) begin
        $display("[%0t] TIMEOUT (Done nao chegou)", $time);
        $fatal;
      end
    end
  endtask

  task check_prod(input [3:0] a, input [3:0] b);
    reg [7:0] exp;
    begin
      exp = a * b;
      if (Produto !== exp) begin
        $display("[%0t] FAIL  %0d x %0d  got=%0d exp=%0d", $time, a, b, Produto, exp);
        $fatal;
      end else begin
        $display("[%0t] PASS  %0d x %0d  = %0d", $time, a, b, Produto);
      end
    end
  endtask

  initial begin
    // opcional: ondas
    $dumpfile("multiplicador_tb.vcd");
    $dumpvars(0, Multiplicador_TB);

    // reset
    St = 0; Multiplicando = 0; Multiplicador = 0;
    rst = 1; @(posedge Clk); rst = 0; @(posedge Clk);

    // casos pedidos e alguns extras
    start_mul(4'd7,  4'd7);  wait_done_or_timeout(64); check_prod(4'd7,  4'd7);  @(posedge Clk);
    start_mul(4'd5,  4'd2);  wait_done_or_timeout(64); check_prod(4'd5,  4'd2);  @(posedge Clk);
    start_mul(4'd11, 4'd13); wait_done_or_timeout(64); check_prod(4'd11, 4'd13); @(posedge Clk);
    start_mul(4'd0,  4'd9);  wait_done_or_timeout(64); check_prod(4'd0,  4'd9);  @(posedge Clk);
    start_mul(4'd15, 4'd15); wait_done_or_timeout(64); check_prod(4'd15, 4'd15);

    $display("Todos os testes passaram.");
    $finish;
  end
endmodule