module risc ();
	input CLK, RST,
	input dataBus_Read, Prog_BUS_READ,
	output [31:0] ADDR, dataBus_Write, ADDRProgout, 
	output CS, WE, CS_P
);

    (*keep=1*)wire [31:0] dataOut_InstMem;
    (*keep=1*)wire mul_CLK, system_CLK;
	 (*keep=1*)wire [31:0] ADDR_prog;
    (*keep=1*)wire resetControl;
	 (*keep=1*)wire [31:0] dataOut_Imm;
	 (*keep=1*)wire [24:0] CTRL0, CTRL1, CTRL2;
	 (*keep=1*)wire [25:0] CTRL3;
	 (*keep=1*)wire [31:0] wireA, wireB;
	 (*keep=1*)wire [31:0] writeBack, regA, regB;
    (*keep=1*)wire [31:0] dataOut_ALU, dataOut_Mul, ADDR_mux_out, regD_out,mux1_ALU_out;
	 (*keep=1*)wire [31:0] ADDR_mux_out;//dataOut_M1, dataOut_M2, dataOut_M3;
	 (*keep=1*)wire [31:0] local_addr;//endereço corrigido da memoria
	 (*keep=1*)wire zeroFlag;
	 (*keep=1*)wire [31:0] iAddressInst;
	 
	 
//    (*keep=1*)wire [31:0] dataOut_RF1, dataOut_RF2;   
//    (*keep=1*)wire dataOut_M;


	 
	 (*keep=1*)wire CS_WB;
    assign CS_WB = CTRL3[25];
	 
//====================Instruction Fetch===============================
	 
	InstMem Intruction_Memory(
		.address(iAddressInst),
		.clock(system_CLK),
		.q(dataOut_InstMem)
	);
	
	mux ADDRProg_Mux(
		.sel(CS_P),
		.A(Prog_BUS_READ),
		.B(dataOut_InstMem),
		.out(ADDRProg_Mux_out)
	);
	wire [31:0] ADDRProg_Mux_out;
	
	ADDRDecoding_Prog ADDR_Decoding_Prog(
		.ADDR_Prog(ADDR_prog),
		.iAddressInst(iAddressInst),
		.CS_P(CS_P)
	 );	
	
	PC pc(
		.CLK(system_CLK),
		.RST(RST),
		.zeroFlag(zeroFlag),
		.jmpFlag(CTRL0[0]),
		.branchFlag(CTRL1[1]),
		.jmpAddress(jmpAddress),
		.branchOffset(branchOffset),
		.addr(ADDR_prog),
		.resetControl(resetControl)
	);
	
	wire [31:0] branchOffset;
	assign branchOffset = dataOut_Imm;
   	

//====================Instruction Decode===============================

	registerfile Register_File(
		.Clk(system_CLK),
		.WE(CTRL3[9]),
		.rs(CTRL0[24:20]),
		.rt(CTRL0[19:15]),
		.rd(CTRL3[14:10]),
		.in(writeBack),
		.outA(wireA),
		.outB(wireB),
		.resetControl(resetControl)
	);

	register A(
		.CLK(system_CLK),
		.RST(RST),
		.in(wireA),
		.out(wireAout)
	);
	wire [31:0] wireAout;
		
	register B(
		.CLK(system_CLK),
		.RST(RST),
		.in(wireB),
		.out(wireBout)
	);
	wire [31:0] wireBout;
	
	
	control Control(
		.in(ADDRProg_Mux_out),
		.jmpAddress(jmpAddress),
		.out(CTRL0)
	);
	wire [31:0] jmpAddress;
	
	
	
	extend Extend(
		.instInput(ADDRProg_Mux_out),
		.valueOutput(dataOut_Extend)
	);
	
	wire [31:0] dataOut_Extend;

	register IMM(
		.CLK(system_CLK),
		.RST(resetControl),
		.in(dataOut_Extend),
		.out(dataOut_Imm)
	);

	register CTRL1 (
		.CLK(system_CLK),
		.RST(resetControl),
		.in(CTRL0[24:0]),
		.out(CTRL1[24:0])
	);
	
//=========================Execute===============================	



	Multiplicador multiplicador(
		.Clk(mul_CLK),
		.St(CTRL1[5]),
		.Multiplicador(wireAout[15:0]),
		.Multiplicando(wireBout[15:0]),
		.Produto(dataOut_Mul),
		.rst(RST)
	);


	mux mux1_ALU (
		.sel(ctrl1[8]),
		.A(wireBout),
		.B(dataOut_Imm),
		.out(mux1_ALU_out)
	);
	wire[31:0] mux1_ALU_out;

	
	alu ALU(
		.sel(ctrl1[7:6]),
		.A(wireAout),
		.B(mux1_ALU_out),
		.out(dataOut_ALU),
		.zeroFlag(zeroFlag)
	);


	mux mux2_ALU(
		.sel(CTRL1[4]),
		.A(dataOut_Mul),
		.B(dataOut_ALU),
		.out(mux2_ALU_out)
	);
	

//=========================Memory===============================	


	ADDRDecoding ADDR_Decoding (
		.WE(ctrl1[3]),
		.iWE(iWE),
		.iAddress(local_addr),//endereço corrigido da memoria
		.inputResult(mux2_ALU_out),
		.CS(CS)
	);
	
	wire iWE;
	wire [31:0] local_addr;
	
	datamemory ADDR (
		.clock(system_CLK), 
		.wren(iWE),  
		.address(local_addr),
		.data(wireBout),
		.q(dout)
	);
	


	//=========================Write Back===============================	
	
	(*keep=1*)wire [31:0] dout;
	
	mux ADDR_mux(
		.sel(CS_WB),
		.A(dout), // dout
		.B(Data_BUS_READ), // dataBus_Read
		.out(ADDR_mux_out)
	);
	
	
	mux regD_mux(
		.sel(CTRL3[2]),	
		.A(regD_out), // dataOut_D2
		.B(ADDR_mux_out), // dataOut_M3
		.out(writeBack)
	);
	
	register D(
		.CLK(system_CLK),
		.RST(RST),
		.in(mux2_ALU_out),
		.out(regD_out)
	);
	
	
   register #(26) CTRL3 (
        .CLK(system_CLK),
        .RST(RST),
        .in({CS,CTRL3[24:0]}),
        .out(CTRL3)
    );
	 
	 PLL pll (
		.inclk0 (CLK),
		.c0 (mul_CLK),
		.c1 (system_CLK)
	);
	
	
	assign ADDR = mux2_ALU_out;
	assign WE = CTRL1[3];
	assign ADDR_Prog = ADDR_prog - 32'd2064;//obs
	assign iAddress = mux2_ALU_out - 32'd2944;//obs
	assign dataBus_Write = WireB;
	
	
	
endmodule