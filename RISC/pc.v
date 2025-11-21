module pc(
    input CLK, RST, zeroFlag, jmpFlag, branchFlag,
    input [31:0] branchOffset, jmpAddress,
    output reg [31:0] addr,
    output reg resetControl //
);

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            addr <= 32'd1040; // end inicial
            resetControl <= 0;
        end
        else if (jmpFlag) begin
            addr <= jmpAddress + 32'd1040; // Jump para endereço imediato
            resetControl <= 0;
        end
        else if (branchFlag && !zeroFlag) begin
            addr <= addr + $signed(branchOffset) + 4; // Offset sinalizado
            resetControl <= 1; // Reset ativado
        end
        else begin
            addr <= addr + 4; // Incremento padrão
            resetControl <= 0;
        end
    end
endmodule
