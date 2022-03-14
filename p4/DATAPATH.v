module DATAPATH(
    input clk,
    input reset,
    input [1:0] RegDataSrc,
    input MemWrite,
    input [2:0] MemDataSrc,
    input [2:0] NPCOp,
    input EXTOp,
    input [3:0] ALUControl,
    input ALUDataSrc,
    input [1:0] RegAddrSrc,
    input RegWrite,
	input [2:0] MemDataType,
    output [31:0] PC,
	 output [31:0] instr);

    wire branch;
    wire [4:0] rs, rt, rd, shamt, RegAddr;
    wire [15:0] imm_16;
    wire [31:0] ALUResult, PCp4, RegData, RD1, RD2, MemRD, MemData, extended_imm, ALUData;
	 
	 
    assign rs = instr[25:21];
    assign rt = instr[20:16];
    assign rd = instr[15:11];
	 assign imm_16 = instr[15:0];
    assign shamt = instr[10:6];
	 

    IFU ifu(.clk(clk), .reset(reset), .branch(branch), .NPCOp(NPCOp), .ALUResult(ALUResult), .instr(instr), .PCp4(PCp4), .PC(PC));
    GRF grf(.clk(clk), .reset(reset), .RegWrite(RegWrite), .A1(rs), .A2(rt), .A3(RegAddr), .RegData(RegData), .PC(PC), .RD1(RD1), .RD2(RD2));
    EXT ext(.imm(imm_16), .EXTOp(EXTOp), .extended_imm(extended_imm));
    MUX_d5s2 mux_RegAddr(.d0(rt), .d1(rd), .d2(5'b11111), .d3(5'b0), .sel(RegAddrSrc), .result(RegAddr));
    MUX_d32s1 mux_ALUData(.d0(RD2), .d1(extended_imm), .sel(ALUDataSrc), .result(ALUData));
    ALU alu(.A(RD1), .B(ALUData), .shamt(shamt), .ALUControl(ALUControl), .sign(branch), .ALUResult(ALUResult));
    MUX_d32s3 mux_MemData(.d0(RD2), .d1(32'hxxxx_xxxx), .d2(32'hxxxx_xxxx), .d3(32'hxxxx_xxxx), .d4(32'hxxxx_xxxx), .d5(32'hxxxx_xxxx), .d6(32'hxxxx_xxxx), .d7(32'hxxxx_xxxx), .sel(MemDataSrc), .result(MemData));
    DM dm(.A(ALUResult), .MemData(MemData), .clk(clk), .MemWrite(MemWrite), .reset(reset), .PC(PC), .RD(MemRD), .MemDataType(MemDataType));
    MUX_d32s2 mux_RegData(.d0(ALUResult), .d1(MemRD), .d2(PCp4), .d3(32'hxxxx_xxxx), .sel(RegDataSrc), .result(RegData));
    
endmodule 