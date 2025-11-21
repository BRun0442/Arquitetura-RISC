module control (
	input [31:0] in,
	output [24:0] out,
	output [31:0] jmpAddress, //obs
	output jmpFlag //obs
);

	//Grupo = 8 
	reg [5:0] operation_code, logic_operation;
	reg [4:0] rs, rt, rd;
	
	reg [1:0] ALU_sel;
	reg mul_start, mux_immediate_regB, mux2_ALU;
	reg WR_mem, CS_WB_2, WR_regfile;
	reg [31:0] jmpAddress_reg; //No PDF esta 26 bits mas deve aumentar para 32b 
	reg jmpFlag_reg, branchFlag;

	assign out = {
		rs,
		rt,
		rd,
		WR_regfile,	// Write/Read do register file. Escrita = 1, leitura = 0
		mux_immediate_regB, // REG B = 0 ou Immediate = 1
		ALU_sel,
		mul_start,
		mux2_ALU,
		WR_mem,
		CS_WB_2,
		branchFlag,
		jmpFlag_reg
	};
	
	assign jmpAddress = jmpAddress_reg; //Obs
	assign jmpFlag = jmpFlag_reg; //Obs
	
	always @(in)
	begin
		operation_code = in[31:26];
		rs = in[25:21];
		rt = in[20:16];
		//logic_operation = in[15:0];
		
		case(operation_code)
			//Load Word
			6'd40:
				begin
					ALU_sel = 2'b00; //soma
					rd = rt; //
					WR_regfile = 1; //Escrita nos registradores
					WR_mem = 0; //Leitura da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 0; //Pega conteudo vindo das memorias ext ou int
					jmpFlag_reg = 0;
					branchFlag = 0;
				end
			
			//Store Word 
			6'd41:
				begin
					ALU_sel = 2'b00; //soma
					rd = rs; //
					WR_regfile = 0; //Leitura nos registradores
					WR_mem = 1; //Escrita da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 0; //Pega conteudo vindo das memorias ext ou int
					jmpFlag_reg = 0;
					branchFlag = 0;
				end
				
			//Branch on Not Equal
			6'd42:
				begin
					ALU_sel = 2'b01; //subtracao
					rd = 5'd0; //Indiferente no 
					WR_regfile = 0; //Leitura nos registradores
					WR_mem = 0; //Escrita da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 0; //Pega conteudo vindo das memorias ext ou int
					jmpFlag_reg = 0;
					branchFlag = 1;
				end
				
			//Add Immediate
			6'd43:
				begin
					ALU_sel = 2'b00; //soma
					rd = rt;
					WR_regfile = 1; //Escrita nos registradores
					WR_mem = 0; //Escrita da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 1; //Pega conteudo vindo do reg D
					jmpFlag_reg = 0;
					branchFlag = 0;
				end
				
			//Or Immediate
			6'd44:
				begin
					ALU_sel = 2'b11; //or
					rd = rt;
					WR_regfile = 1; //Escrita nos registradores
					WR_mem = 0; //Escrita da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 1; //Pega conteudo vindo do reg D
					jmpFlag_reg = 0;
					branchFlag = 0;
				end
				
			//Jump
			6'd2:
				begin
					ALU_sel = 2'b00; //JMP
					rd = 5'd0;
					WR_regfile = 0; //Escrita nos registradores
					WR_mem = 0; //Escrita da memoria
					mux_immediate_regB = 1; //Imediato
					mux2_ALU = 1; //ALU
					mul_start = 0; //Sem multiplicacao
					CS_WB_2 = 1; //Pega conteudo vindo do reg D
					jmpFlag_reg = 1;
					branchFlag = 0;
					
					jmpAddress_reg = {6'd0, in[25:0]}; // Verificar essa parte
				end
				
				
				
			default:
				begin
					logic_operation = in[15:0];
					rd = in[15:11];
					
					case(logic_operation)
						//Add
						6'd32:
							begin
								ALU_sel = 2'b00;
								WR_regfile = 1;
								rd = rd; //
								WR_mem = 0;
								mux_immediate_regB = 0;
								mux2_ALU = 1;
								mul_start = 0;
								CS_WB_2 = 1;
								jmpFlag_reg = 0;
								branchFlag = 0;
							end
							
						//Subtract
						6'd34:
							begin
								ALU_sel = 2'b01;
								WR_regfile = 1;
								rd = rd; //
								WR_mem = 0;
								mux_immediate_regB = 0;
								mux2_ALU = 1;
								mul_start = 0;
								CS_WB_2 = 1; //Observacao
								jmpFlag_reg = 0;
								branchFlag = 0;
							end
							
						//Multiplication
						6'd50:
							begin
								ALU_sel = 2'b00; //indiferente
								WR_regfile = 1;
								rd = rd; //
								WR_mem = 0;
								mux_immediate_regB = 0; //indiferente
								mux2_ALU = 0;
								mul_start = 1;
								CS_WB_2 = 1; //Observacao
								jmpFlag_reg = 0;
								branchFlag = 0;
							end
							
						//And
						6'd36:
							begin
								ALU_sel = 2'b10;
								rd = rd;
								WR_regfile = 1;
								WR_mem = 0;
								mux_immediate_regB = 0;
								mux2_ALU = 1;
								mul_start = 0;
								CS_WB_2 = 1;
								jmpFlag_reg = 0;
								branchFlag = 0;
							end
							
						//Or
						6'd37:
							begin
								ALU_sel = 2'b11;
								rd = rd;
								WR_regfile = 1;
								WR_mem = 0;
								mux_immediate_regB = 0;
								mux2_ALU = 1;
								mul_start = 0;
								CS_WB_2 = 1;
								jmpFlag_reg = 0;
								branchFlag = 0;
							end
				endcase
			end
		endcase
	end
endmodule
