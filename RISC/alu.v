module alu(A, B, sel, out, zeroFlag);
    input [31:0] A, B;
    input [1:0] sel;
    output reg [31:0] out;
    output zeroFlag;

    assign zeroFlag = (out == 32'b0) ? 1 : 0;  // Define zeroFlag como 1 se out é zero, caso contrário, 0.
		// 1 = out	-> 	0 
		// 0 = out 	-> 	1 

    always @(*)
    begin
        case(sel)
            2'b00: out <= A + B; 	// b00: somar
            2'b01: out <= A - B;		// b01: subtrair
            2'b10: out <= A & B;		// b10: AND
            2'b11: out <= A | B;		// b11: OR
        endcase
    end
 
endmodule