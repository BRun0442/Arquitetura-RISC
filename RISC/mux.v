module mux (
    input wire [31:0] A,       // reg 0
    input wire [31:0] B,       // reg 1
    input wire sel,            // seleção
    output wire [31:0] out     // Saída
);

    assign out = (sel) ? A : B;

endmodule