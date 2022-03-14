module mips(
    input clk,
    input reset);

    wire MemWrite, EXTOp, ALUDataSrc,RegWrite;
    wire [1:0] RegDataSrc, RegAddrSrc;
    wire [2:0] MemDataSrc, NPCOp, MemDataType;
    wire [3:0] ALUControl;
    wire [5:0] opcode, func;
    wire [31:0] instr, PC;
	 wire [255:0] asm;

    assign opcode = instr[31:26];
    assign func = instr[5:0];
    
    DATAPATH datapath( .clk(clk), 
                        .reset(reset), 
                        .RegDataSrc(RegDataSrc), 
                        .MemWrite(MemWrite), 
                        .MemDataSrc(MemDataSrc), 
                        .NPCOp(NPCOp), 
                        .EXTOp(EXTOp), 
                        .ALUControl(ALUControl), 
                        .ALUDataSrc(ALUDataSrc), 
                        .RegAddrSrc(RegAddrSrc), 
                        .RegWrite(RegWrite), 
                        .MemDataType(MemDataType),
						.PC(PC),
                        .instr(instr));

    CU cu(.opcode(opcode),
        .func(func),
        .RegDataSrc(RegDataSrc),
        .MemWrite(MemWrite),
        .MemDataSrc(MemDataSrc),
        .NPCOp(NPCOp),
        .EXTOp(EXTOp),
        .ALUControl(ALUControl),
        .ALUDataSrc(ALUDataSrc),
        .RegAddrSrc(RegAddrSrc),
        .RegWrite(RegWrite),
        .MemDataType(MemDataType));

endmodule 