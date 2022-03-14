`include "constant.v"
module CU(
    input [31:0] instr,
    input branch,
    input M_DM_RegAddrSel,
    input [1:0] stage,
    // D
    output [3:0] CMPOp,
    output EXTOp,
    output [2:0] NPCOp,
    output [2:0] SetWordOp,
    // E
    output [3:0] ALUControl,
    output ALUDataSrc,
    output CalcResultSrc,
    // M
    output MemWrite,
	output [2:0] MemDataType,
    // W
    output RegWrite,
    output [1:0] RegAddrSrc,
    output [1:0] RegDataSrc,
    // Forward
    output [4:0] A1,
    output [4:0] A2,
    output [4:0] A3,
    // Stall
    output [1:0] GRF_rs_useStage,
    output [1:0] GRF_rt_useStage,
    output [1:0] GRF_WD_newStage);

    // RegDataSrc
    parameter CalctoReg = 2'b00, MemtoReg = 2'b01;
    // RegAddrSrc
    parameter rt_addr = 2'b00, rd_addr = 2'b01, ra_addr = 2'b10;
    // MemDataSrc
    parameter RD2toMem = 3'b000;
    // NPCOp
    parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100;
    // EXTOp
    parameter SIGN_EXT = 1'b0, ZERO_EXT = 1'b1;
    // CMPOp
    parameter EQ_CMP = 4'b0000, OPPOSITE_CMP = 4'b0001;
    // SetWordOp
    parameter LUI_SET = 3'b000, PCp8_SET = 3'b001;
    // ALUControl
    parameter AND_ALU = 4'b0000, OR_ALU = 4'b0001, ADDU_ALU = 4'b0010, SLL_ALU = 4'b0011, AND_N_ALU = 4'b0100;   
    parameter OR_N_ALU = 4'b0101, SUBU_ALU = 4'b0110, SLT_ALU = 4'b0111, LUI_ALU = 4'b1000;
    // ALUDataSrc
    parameter RD2toALU = 1'b0, EXTtoALU = 1'b1;
    // CalcResultSrc
    parameter SetWordtoCalc = 1'b0, ALUtoCalc = 1'b1;
    // MemDataType
    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010, UHALF_TYPE = 3'b011, UBYTE_TYPE = 3'b100;
    // Stage
    parameter D_Stage = 2'b00, E_Stage = 2'b01, M_Stage = 2'b10, W_Stage = 2'b11, Non_Stage = 2'b11;

    wire [5:0] opcode, func;

    wire lw_i, sw_i, lui_i, ori_i, R_i, beq_i, j_i, jal_i, jalr_i, jr_i, addu_i, subu_i, bonall_i;
    wire lh_i, lb_i, sh_i, sb_i, lhu_i, lbu_i;
    wire ALU_urr_INSTR, ALU_uri_INSTR, ALU_sri_INSTR, SETWORD_INSTR;
    wire store_INSTR, load_INSTR, BRANCH_INSTR;

    // instr distribute
    assign opcode = instr[31:26];
    assign func = instr[5:0];
    assign A1 = instr[25:21];
    assign A2 = instr[20:16];
    assign A3 = (RegAddrSrc == rt_addr) ? instr[20:16] :
                (RegAddrSrc == rd_addr) ? instr[15:11] :
                (RegAddrSrc == ra_addr) ? 5'b11111 : 5'bxxxxx;

    // instr recognize
    assign lw_i = (opcode == `LW_OP);
    assign sw_i = (opcode == `SW_OP);
    assign lui_i = (opcode == `LUI_OP);
    assign ori_i = (opcode == `ORI_OP);
    assign beq_i = (opcode == `BEQ_OP);
    assign j_i = (opcode == `J_OP);
    assign jal_i = (opcode == `JAL_OP);
    assign addu_i = (opcode == `R_OP) && (func == `ADDU_FUNC);
    assign subu_i = (opcode == `R_OP) && (func == `SUBU_FUNC);
    assign jalr_i = (opcode == `R_OP) && (func == `JALR_FUNC);
    assign jr_i = (opcode == `R_OP) && (func == `JR_FUNC);
    assign nop_i = (instr == 32'h0);
    assign bonall_i = (opcode == `BONALL_OP);
    assign lh_i = (opcode == `LH_OP);
    assign lb_i = (opcode == `LB_OP);
    assign sh_i = (opcode == `SH_OP);
    assign sb_i = (opcode == `SB_OP);
    assign lhu_i = (opcode == `LHU_OP);
    assign lbu_i = (opcode == `LBU_OP);


    assign ALU_urr_INSTR = addu_i | subu_i;
    assign ALU_uri_INSTR = ori_i;
    assign ALU_sri_INSTR = 1'b0;

    assign BRANCH_INSTR = beq_i;
    assign SETWORD_INSTR = lui_i;

    assign load_INSTR = lw_i|lh_i|lb_i|lhu_i|lbu_i;
    assign store_INSTR = sw_i|sh_i|sb_i;


    // control signal
    assign RegWrite = (load_INSTR|ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|jal_i|jalr_i|bonall_i);

    assign RegDataSrc = (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|jal_i|jalr_i|bonall_i) ? CalctoReg :
                        (load_INSTR) ? MemtoReg : 2'bxx;

    assign RegAddrSrc = (load_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR) ? rt_addr :
                        (ALU_urr_INSTR|jalr_i) ? rd_addr :
                        (jal_i|bonall_i) ? ra_addr : 2'bxx;

    assign MemWrite = (store_INSTR);

    assign MemDataType = (lw_i|sw_i) ? WORD_TYPE :
                         (lh_i|sh_i) ? HALF_TYPE :
                         (lb_i|sb_i) ? BYTE_TYPE :
                         (lhu_i) ? UHALF_TYPE :
                         (lbu_i) ? UBYTE_TYPE : 3'bxxx;

    assign NPCOp = (load_INSTR|store_INSTR|ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|nop_i) ? PCp4_NPC :
                   (BRANCH_INSTR|bonall_i) ? BRANCH_NPC :
                   (j_i|jal_i) ? J_NPC :
                   (jr_i|jalr_i) ? JR_NPC : 3'bxxx;

    assign EXTOp = (ALU_uri_INSTR) ? ZERO_EXT : SIGN_EXT;
	 
	assign CMPOp = (beq_i) ? EQ_CMP :
                   (bonall_i) ? OPPOSITE_CMP : 4'bxxxx;

    
    assign SetWordOp = (lui_i) ? LUI_SET : 
                       (jal_i|jalr_i|bonall_i) ? PCp8_SET : 3'bxxx;
							  
	
    
    assign ALUControl = (ori_i) ? OR_ALU :
                        (load_INSTR|store_INSTR|addu_i) ? ADDU_ALU :
                        (subu_i) ? SUBU_ALU :  4'bxxxx;
    
    assign ALUDataSrc = (load_INSTR|store_INSTR|ALU_sri_INSTR|ALU_uri_INSTR) ? EXTtoALU :
                        (ALU_urr_INSTR) ? RD2toALU  : 1'bx;
    
    assign CalcResultSrc = (SETWORD_INSTR|jal_i|jalr_i|bonall_i) ? SetWordtoCalc : ALUtoCalc;

    // T lw_i, sw_i, lui_i, ori_i, R_i, beq_i, j_i, jal_i, jalr_i, jr_i, addu_i, subu_i;
    
    assign GRF_rs_useStage = (BRANCH_INSTR|jalr_i|jr_i|bonall_i) ? D_Stage : 
                             (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|load_INSTR|store_INSTR) ? E_Stage :
                             (1'b0) ? M_Stage :
                             (1'b0) ? W_Stage : 
                             (j_i|jal_i|SETWORD_INSTR) ? Non_Stage : 2'bxx;
    
    
    assign GRF_rt_useStage = (BRANCH_INSTR|bonall_i) ? D_Stage : 
                             (ALU_urr_INSTR) ? E_Stage :
                             (store_INSTR) ? M_Stage :
                             (1'b0) ? W_Stage :
                             (load_INSTR|ALU_sri_INSTR|ALU_uri_INSTR|SETWORD_INSTR|jal_i|jalr_i|j_i|jr_i) ? Non_Stage : 2'bxx;

    assign GRF_WD_newStage = RegWrite ? ((1'b0) ? D_Stage : 
                             (SETWORD_INSTR|jalr_i|jal_i|bonall_i) ? E_Stage :
                             (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR) ? M_Stage :
                             (load_INSTR) ? W_Stage : 2'bxx) : 2'b00;


endmodule 