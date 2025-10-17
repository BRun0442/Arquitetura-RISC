`timescale 1ns/1ps

module CONTROL_TB;

  // Entradas
  reg Clk, K, St, M, rst;
  // Saídas
  wire Idle, Done, Load, Sh, Ad;

  // DUT
  CONTROL dut (
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

  // Clock 10 ns
  initial Clk = 1'b0;
  always #5 Clk = ~Clk;

  // Helper para checagens rápidas
  task check_outputs(
    input expIdle, expDone, expLoad, expSh, expAd,
    input [127:0] msg
  );
    begin
      #1; // dar tempo para a lógica combinacional
      if (Idle!==expIdle || Done!==expDone || Load!==expLoad || Sh!==expSh || Ad!==expAd) begin
        $error("[%0t] %s  Got: Idle=%0b Done=%0b Load=%0b Sh=%0b Ad=%0b",
               $time, msg, Idle, Done, Load, Sh, Ad);
      end else begin
        $display("[%0t] OK  %s", $time, msg);
      end
    end
  endtask

  // Monitor opcional
  initial begin
    $display("  t  | rst St M K | Idle Done Load Sh Ad");
    $monitor("%4t |  %b   %b %b %b |   %b     %b    %b   %b  %b",
             $time, rst, St, M, K, Idle, Done, Load, Sh, Ad);
  end

  initial begin
    // Init
    rst = 1; St = 0; M = 0; K = 0;
    @(negedge Clk); rst = 0;

    // S0 (Idle) sem start
    check_outputs(1,0,0,0,0, "S0/Idle sem start");

    // Enquanto em S0, aplicar St=1 deve gerar Load=1 (pulso)
    St = 1;
    check_outputs(1,0,1,0,0, "S0 com St=1 -> Load=1 (pulso)");

    // Próxima borda: S1
    @(posedge Clk);
    // Em S1: Ad = M. Vamos testar M=1.
    M = 1;
    check_outputs(0,0,0,0,1, "S1 com M=1 -> Ad=1");

    // Próxima borda: S2
    @(posedge Clk);
    // Em S2: Sh=1; K decide próximo estado
    K = 0;
    check_outputs(0,0,0,1,0, "S2 com K=0 -> Sh=1, voltará para S1");

    // Próxima borda: volta para S1
    @(posedge Clk);
    // Em S1: testar M=0 agora
    M = 0;
    check_outputs(0,0,0,0,0, "S1 com M=0 -> Ad=0");

    // Próxima borda: S2 novamente
    @(posedge Clk);
    // Em S2: colocar K=1 antes da próxima borda para ir a S3
    K = 1;
    check_outputs(0,0,0,1,0, "S2 com K=1 -> na próxima borda vai para S3");

    // Próxima borda: S3 (Done)
    @(posedge Clk);
    check_outputs(0,1,0,0,0, "S3 -> Done=1");

    // Zerar St para permitir retorno a S0; K não importa mais
    St = 0; K = 0;

    // Próxima borda: S0
    @(posedge Clk);
    check_outputs(1,0,0,0,0, "Retornou a S0/Idle");

    // Novo ciclo rápido só para ver Load de novo
    St = 1;
    check_outputs(1,0,1,0,0, "S0 com St=1 (novo pulso Load)");
    @(posedge Clk); // vai a S1
    St = 0;         // baixa start

    // Encerrar
    #10 $display("Testbench CONTROL finalizado com sucesso.");
    #10 $finish;
  end

  // Watchdog (segurança)
  initial begin : watchdog
    #1000;
    $fatal(1, "Timeout na TB do CONTROL.");
  end

endmodule
