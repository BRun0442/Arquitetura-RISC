`timescale 1ns/1ps
module alu_TB();
  reg  [31:0] A, B;
  reg  [1:0]  sel;
  wire [31:0] out;
  wire        zeroFlag;

  // Sua ALU
  alu DUT(.A(A), .B(B), .sel(sel), .out(out), .zeroFlag(zeroFlag));

  initial begin
    // 1) BEQ típico: A == B -> SUB dá 0 -> zeroFlag = 1
    A=32'd5; B=32'd5; sel=2'b01; #1;
    
    // 2) BNE típico: A != B -> SUB != 0 -> zeroFlag = 0
    A=32'd7; B=32'd5; sel=2'b01; #1;
    
    // 3) AND sem bits em comum -> resultado 0 -> zeroFlag = 1
    A=32'hF0F0_0F0F; B=32'h0F0F_F0F0; sel=2'b10; #1;
    
    // 4) OR com resultado != 0 -> zeroFlag = 0
    A=32'h0000_0000; B=32'h0000_0001; sel=2'b11; #1;
    

    $finish;
  end
endmodule
