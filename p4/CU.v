`include "opcode.v"
module CU(
    input [5:0] opcode,
    input [5:0] func,
    output reg [1:0] RegDataSrc,
    output reg MemWrite,
    output reg [2:0] MemDataSrc,
    output reg [2:0] NPCOp,
    output reg EXTOp,
    output reg [3:0] ALUControl,
    output reg ALUDataSrc,
    output reg [1:0] RegAddrSrc,
    output reg RegWrite,
	output reg [2:0] MemDataType);

    // RegDataSrc
    parameter ALUtoReg = 2'b00, MemtoReg = 2'b01, PCp4toReg = 2'b10;
    // RegAddrSrc
    parameter rt_addr = 2'b00, rd_addr = 2'b01, ra_addr = 2'b10;
    // MemDataSrc
    parameter RD2toMem = 3'b000;
    // NPCOp
    parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100;
    // EXTOp
    parameter SIGN_EXT = 1'b0, ZERO_EXT = 1'b1;
    // ALUControl
    parameter AND_ALU = 4'b0000, OR_ALU = 4'b0001, ADDU_ALU = 4'b0010, SLL_ALU = 4'b0011, AND_N_ALU = 4'b0100;   
    parameter OR_N_ALU = 4'b0101, SUBU_ALU = 4'b0110, SLT_ALU = 4'b0111, LUI_ALU = 4'b1000;
    // ALUDataSrc
    parameter RD2toALU = 1'b0, EXTtoALU = 1'b1;
    // MemDataType
    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010;


    always @(*) begin
        case (opcode)
            `LW_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = MemtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `LH_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = MemtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = HALF_TYPE;
            end
            `SW_OP : begin
                RegWrite = 1'b0;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b1;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `SH_OP : begin
                RegWrite = 1'b0;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b1;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = HALF_TYPE;
            end
            `BEQ_OP : begin
                RegWrite = 1'b0;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = BRANCH_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = SUBU_ALU;
                ALUDataSrc = RD2toALU;
                MemDataType = WORD_TYPE;
            end
            `ADDI_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `J_OP : begin
                RegWrite = 1'b0;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = J_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `ORI_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = ZERO_EXT;
                ALUControl = OR_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `LUI_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = ALUtoReg;
                RegAddrSrc = rt_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = PCp4_NPC;
                EXTOp = ZERO_EXT;
                ALUControl = LUI_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `JAL_OP : begin
                RegWrite = 1'b1;
                RegDataSrc = PCp4toReg;
                RegAddrSrc = ra_addr;
                MemWrite = 1'b0;
                MemDataSrc = RD2toMem;
                NPCOp = J_NPC;
                EXTOp = SIGN_EXT;
                ALUControl = ADDU_ALU;
                ALUDataSrc = EXTtoALU;
                MemDataType = WORD_TYPE;
            end
            `R_OP : begin
                RegAddrSrc = rd_addr;
                RegWrite = 1'b1;
                MemDataSrc = RD2toMem;
                MemWrite = 1'b0;
                EXTOp = SIGN_EXT;
                ALUDataSrc = RD2toALU;
                MemDataType = WORD_TYPE;
                case (func)
                    `AND_FUNC : begin
                        ALUControl = AND_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
                    `OR_FUNC : begin
                        ALUControl = OR_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
                    `SLT_FUNC : begin
                        ALUControl = SLT_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
                    `ADDU_FUNC : begin
                        ALUControl = ADDU_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
                    `SUBU_FUNC : begin
                        ALUControl = SUBU_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
                    `JALR_FUNC : begin            
                        ALUControl = ADDU_ALU;
                        NPCOp = JR_NPC;
                        RegDataSrc = PCp4toReg;
                    end
                    `JR_FUNC : begin                                
								ALUControl = ADDU_ALU;
                        NPCOp = JR_NPC;
                        RegDataSrc = ALUtoReg;
                    end
					`SLL_FUNC : begin
                        ALUControl = SLL_ALU;
                        NPCOp = PCp4_NPC;
                        RegDataSrc = ALUtoReg;
                    end
						  
                    

                    default: begin
								ALUControl = 4'bxxxx;
                        NPCOp = 3'bxxx;
                        RegDataSrc = 3'bxxx;
							end
								
                endcase
            end
            default: begin
                RegDataSrc = 2'bxx;
                MemWrite = 1'bx;
                NPCOp = 3'bxxx;
                EXTOp = 1'bx;
                ALUControl = 4'bxxxx;
                ALUDataSrc = 1'bx;
                RegAddrSrc = 2'bxx;
                RegWrite = 1'bx;
                MemDataSrc = 1'bx;
                MemDataType = 3'bxxx;
            end
        endcase
    end


endmodule 