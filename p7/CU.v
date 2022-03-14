`include "constant.v"
module CU(
    input [31:0] instr,
    input branch,
    input [4:0] DM_RegAddr,
    input [1:0] stage,
    output conditionStore,
    // D
    output [3:0] CMPOp,
    output EXTOp,
    output [2:0] NPCOp,
    output [2:0] SetWordOp,
    output multdiv_INSTR,
    output [4:0] ExcCode,
    // E
    output [4:0] ALUControl,
    output ALUDataSrc,
    output start,
    output [3:0] MULTDIVControl,
    output [1:0] CalcResultSrc,
    // M
    output MemWrite,
	output [2:0] MemDataType,
    output EXLClr,
    output CP0Write,
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
    parameter CalctoReg = 2'b00, MemtoReg = 2'b01, CP0toReg = 2'b10;
    // RegAddrSrc
    parameter rt_addr = 2'b00, rd_addr = 2'b01, ra_addr = 2'b10;
    // MemDataSrc
    parameter RD2toMem = 3'b000;
    // NPCOp
    parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100, EPC_NPC = 3'b101;
    // EXTOp
    parameter SIGN_EXT = 1'b0, ZERO_EXT = 1'b1;
    // CMPOp
    parameter EQ_CMP = 4'd0, OPPOSITE_CMP = 4'd1, NEQ_CMP = 4'd2, LEZ_CMP = 4'd3;
    parameter GTZ_CMP = 4'd4, LTZ_CMP = 4'd5, GEZ_CMP = 4'd6;
    // SetWordOp
    parameter LUI_SET = 3'b000, PCp8_SET = 3'b001;
    // ALUControl
    parameter ADD_ALU = 5'd0, ADDU_ALU = 5'd1, SUB_ALU = 5'd2, SUBU_ALU = 5'd3;
    parameter SLL_ALU = 5'd4, SRL_ALU = 5'd5, SRA_ALU = 5'd6, SLLV_ALU = 5'd7;
    parameter SRLV_ALU = 5'd8, SRAV_ALU = 5'd9, AND_ALU = 5'd10, OR_ALU = 5'd11;
    parameter XOR_ALU = 5'd12, NOR_ALU = 5'd13, SLT_ALU = 5'd14, SLTU_ALU = 5'd15;
    parameter LOAD_ALU = 5'd16, STORE_ALU = 5'd17;
    // ALUDataSrc
    parameter RD2toALU = 1'b0, EXTtoALU = 1'b1;
    // MULTDIVControl
    parameter MULT_MULTDIV = 4'b0000, MULTU_MULTDIV = 4'b0001, DIV_MULTDIV = 4'b0010, DIVU_MULTDIV = 4'b0011;
    parameter MTHI_MULTDIV = 4'b0100, MTLO_MULTDIV = 4'b0101;
    // CalcResultSrc
    parameter SetWordtoCalc = 2'b00, ALUtoCalc = 2'b01, HItoCalc = 2'b10, LOtoCalc = 2'b11;
    // MemDataType
    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010, UHALF_TYPE = 3'b011, UBYTE_TYPE = 3'b100, NONE_TYPE = 3'b111;
    // Stage
    parameter D_Stage = 2'b00, E_Stage = 2'b01, M_Stage = 2'b10, W_Stage = 2'b11, Non_Stage = 2'b11;
    // ExcCode
    parameter AdEL_EXC = 5'd4, AdES_EXC = 5'd5, RI_EXC = 5'd10, Ov_EXC = 5'd12;

    wire [5:0] opcode, func;

    wire lb_i, lbu_i, lh_i, lhu_i, lw_i, sb_i, sh_i, sw_i;
    wire addi_i, addiu_i, andi_i, ori_i, xori_i, lui_i, sltiu_i, sltu_i;
    wire beq_i, bne_i, blez_i, bgtz_i, bltz_i, bgez_i;
    wire j_i, jal_i, jalr_i, jr_i;
	wire bonall_i, mtc0_i, mfc0_i, eret_i;

    wire add_i, addu_i, sub_i, subu_i;
    wire mult_i, multu_i, div_i, divu_i, mfhi_i, mflo_i, mthi_i, mtlo_i;
    wire sll_i, srl_i, sra_i, sllv_i, srlv_i, srav_i;
    wire and_i, or_i, xor_i, nor_i, slt_i, slti_i, instrRecognized;
    
    wire ALU_urr_INSTR, ALU_uri_INSTR, ALU_sri_INSTR, SETWORD_INSTR;
    wire store_INSTR, load_INSTR, BRANCH_rs_INSTR, BRANCH_rsrt_INSTR;

    // instr distribute
    assign opcode = instr[31:26];
    assign func = instr[5:0];

    assign A1 = instr[25:21];
    assign A2 = instr[20:16];
    assign A3 = (RegAddrSrc == rt_addr) ? instr[20:16] :
                (RegAddrSrc == rd_addr) ? instr[15:11] :
                (RegAddrSrc == ra_addr) ? 5'b11111 : 5'b0;

    // instr recognize

    assign lb_i = (opcode == `LB_OP);
    assign lbu_i = (opcode == `LBU_OP);
    assign lh_i = (opcode == `LH_OP);
    assign lhu_i = (opcode == `LHU_OP);
    assign lw_i = (opcode == `LW_OP);
    assign sb_i = (opcode == `SB_OP);
    assign sh_i = (opcode == `SH_OP);
    assign sw_i = (opcode == `SW_OP);
    assign addi_i = (opcode == `ADDI_OP);
    assign addiu_i = (opcode == `ADDIU_OP);
    assign andi_i = (opcode == `ANDI_OP);
    assign ori_i = (opcode == `ORI_OP);
    assign xori_i = (opcode == `XORI_OP);
    assign lui_i = (opcode == `LUI_OP);
    assign slti_i = (opcode == `SLTI_OP);
    assign sltiu_i = (opcode == `SLTIU_OP);
    assign beq_i = (opcode == `BEQ_OP);
    assign bne_i = (opcode == `BNE_OP);
    assign blez_i = (opcode == `BLEZ_OP);
    assign bgtz_i = (opcode == `BGTZ_OP);
    assign bltz_i = (opcode == `BLTZ_OP) & (A2 == `BLTZ_RT);
    assign bgez_i = (opcode == `BGEZ_OP) & (A2 == `BGEZ_RT);
    assign j_i = (opcode == `J_OP);
    assign jal_i = (opcode == `JAL_OP);

    assign add_i = (opcode == `R_OP) && (func == `ADD_FUNC);
    assign addu_i = (opcode == `R_OP) && (func == `ADDU_FUNC);
    assign sub_i = (opcode == `R_OP) && (func == `SUB_FUNC);
    assign subu_i = (opcode == `R_OP) && (func == `SUBU_FUNC);
    assign mult_i = (opcode == `R_OP) && (func == `MULT_FUNC);
    assign multu_i = (opcode == `R_OP) && (func == `MULTU_FUNC);
    assign div_i = (opcode == `R_OP) && (func == `DIV_FUNC);
    assign divu_i = (opcode == `R_OP) && (func == `DIVU_FUNC);
    assign mfhi_i = (opcode == `R_OP) && (func == `MFHI_FUNC);
    assign mflo_i = (opcode == `R_OP) && (func == `MFLO_FUNC);
    assign mthi_i = (opcode == `R_OP) && (func == `MTHI_FUNC);
    assign mtlo_i = (opcode == `R_OP) && (func == `MTLO_FUNC);
    assign sll_i = (opcode == `R_OP) && (func == `SLL_FUNC);
    assign srl_i = (opcode == `R_OP) && (func == `SRL_FUNC);
    assign sra_i = (opcode == `R_OP) && (func == `SRA_FUNC);
    assign sllv_i = (opcode == `R_OP) && (func == `SLLV_FUNC);
    assign srlv_i = (opcode == `R_OP) && (func == `SRLV_FUNC);
    assign srav_i = (opcode == `R_OP) && (func == `SRAV_FUNC);
    assign and_i = (opcode == `R_OP) && (func == `AND_FUNC);
    assign or_i = (opcode == `R_OP) && (func == `OR_FUNC);
    assign xor_i = (opcode == `R_OP) && (func == `XOR_FUNC);
    assign nor_i = (opcode == `R_OP) && (func == `NOR_FUNC);
    assign slt_i = (opcode == `R_OP) && (func == `SLT_FUNC);
    assign sltu_i = (opcode == `R_OP) && (func == `SLTU_FUNC);
    assign jalr_i = (opcode == `R_OP) && (func == `JALR_FUNC);
    assign jr_i = (opcode == `R_OP) && (func == `JR_FUNC);
    assign nop_i = (instr == 32'h0);
	assign bonall_i = 1'b0;
    assign mtc0_i = (opcode == `MTC0_OP) && (A1 == `MTC0_RS);
    assign mfc0_i = (opcode == `MFC0_OP) && (A1 == `MFC0_RS);
    assign eret_i = (opcode == `ERET_OP) && (func == `ERET_FUNC);

    assign ALU_urr_INSTR = add_i|addu_i|sub_i|subu_i|sll_i|srl_i|sra_i|sllv_i|srl_i|sra_i|sllv_i|srlv_i|srav_i|and_i|or_i|xor_i|nor_i|slt_i|sltu_i;
    assign ALU_uri_INSTR = ori_i|andi_i|xori_i;
    assign ALU_sri_INSTR = addi_i|addiu_i|slti_i|sltiu_i;
    assign multdiv_INSTR = mult_i|multu_i|div_i|divu_i|mthi_i|mtlo_i|mfhi_i|mflo_i;


    assign conditionStore = 1'b0;

    assign BRANCH_rsrt_INSTR = beq_i|bne_i;
    assign BRANCH_rs_INSTR = blez_i|bgtz_i|bltz_i|bgez_i;
    assign SETWORD_INSTR = lui_i;

    assign load_INSTR = lw_i|lh_i|lb_i|lhu_i|lbu_i;
    assign store_INSTR = sw_i|sh_i|sb_i;

    assign instrRecognized = (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|multdiv_INSTR|BRANCH_rsrt_INSTR|
                              BRANCH_rs_INSTR|SETWORD_INSTR|load_INSTR|store_INSTR|nop_i|j_i|jal_i|jalr_i|jr_i|mtc0_i|mfc0_i|eret_i);

    assign ExcCode = instrRecognized ? 5'h0 : RI_EXC;
    // control signal
    assign RegWrite = (load_INSTR|ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|jal_i|jalr_i|bonall_i|mfhi_i|mflo_i|mfc0_i);

    assign RegDataSrc = (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|jal_i|jalr_i|bonall_i|mfhi_i|mflo_i) ? CalctoReg :
                        (load_INSTR) ? MemtoReg :
                        (mfc0_i) ? CP0toReg : 2'bxx;

    assign RegAddrSrc = (load_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|mfc0_i) ? rt_addr :
                        (ALU_urr_INSTR|jalr_i|mfhi_i|mflo_i|mtc0_i) ? rd_addr : // set mtc0_A3 = rd
                        (jal_i|bonall_i) ? ra_addr : 2'bxx;

    assign EXLClr = eret_i;
    assign CP0Write = mtc0_i;

    assign MemWrite = (store_INSTR);

    assign MemDataType = (lw_i|sw_i) ? WORD_TYPE :
                         (lh_i|sh_i) ? HALF_TYPE :
                         (lb_i|sb_i) ? BYTE_TYPE :
                         (lhu_i) ? UHALF_TYPE :
                         (lbu_i) ? UBYTE_TYPE : NONE_TYPE;

    assign NPCOp = (load_INSTR|store_INSTR|ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|SETWORD_INSTR|nop_i|multdiv_INSTR|mfc0_i|mtc0_i) ? PCp4_NPC :
                   (BRANCH_rs_INSTR|BRANCH_rsrt_INSTR|bonall_i) ? BRANCH_NPC :
                   (j_i|jal_i) ? J_NPC :
                   (jr_i|jalr_i) ? JR_NPC :
                   (eret_i) ? EPC_NPC : 3'bxxx;
 

    assign EXTOp = (ALU_uri_INSTR) ? ZERO_EXT : SIGN_EXT;
	 
	assign CMPOp = (beq_i) ? EQ_CMP :
                   (bonall_i) ? OPPOSITE_CMP : 
                   (bne_i) ? NEQ_CMP :
                   (blez_i) ? LEZ_CMP :
                   (bgtz_i) ? GTZ_CMP :
                   (bltz_i) ? LTZ_CMP :
                   (bgez_i) ? GEZ_CMP : 4'hx;

    
    assign SetWordOp = (lui_i) ? LUI_SET : 
                       (jal_i|jalr_i|bonall_i) ? PCp8_SET : 3'bxxx;
							  
	
    
    assign ALUControl = (add_i|addi_i) ? ADD_ALU :
                        (addu_i|addiu_i) ? ADDU_ALU :
                        (load_INSTR) ? LOAD_ALU :
                        (store_INSTR) ? STORE_ALU :
                        (sub_i) ? SUB_ALU :
                        (subu_i) ? SUBU_ALU :
                        (sll_i) ? SLL_ALU :
                        (srl_i) ? SRL_ALU :
                        (sra_i) ? SRA_ALU :
                        (sllv_i) ? SLLV_ALU :
                        (srlv_i) ? SRLV_ALU :
                        (srav_i) ? SRAV_ALU :
                        (and_i|andi_i) ? AND_ALU :
                        (or_i|ori_i) ? OR_ALU :
                        (xor_i|xori_i) ? XOR_ALU :
                        (nor_i) ? NOR_ALU :
                        (slt_i|slti_i) ? SLT_ALU :
                        (sltu_i|sltiu_i) ? SLTU_ALU : 5'h1f;
                        
    
    assign ALUDataSrc = (load_INSTR|store_INSTR|ALU_sri_INSTR|ALU_uri_INSTR) ? EXTtoALU :
                        (ALU_urr_INSTR) ? RD2toALU  : 1'bx;

    assign start = (mult_i|multu_i|div_i|divu_i);

    assign MULTDIVControl = (mult_i) ? MULT_MULTDIV :
                           (multu_i) ? MULTU_MULTDIV :
                           (div_i) ? DIV_MULTDIV :
                           (divu_i) ? DIVU_MULTDIV :
                           (mthi_i) ? MTHI_MULTDIV :
                           (mtlo_i) ? MTLO_MULTDIV : 4'hx;
    
    assign CalcResultSrc = (SETWORD_INSTR|jal_i|jalr_i|bonall_i) ? SetWordtoCalc : 
                           (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|load_INSTR|store_INSTR) ? ALUtoCalc :
                           (mfhi_i) ? HItoCalc :
                           (mflo_i) ? LOtoCalc : 2'hx;

    // T lw_i, sw_i, lui_i, ori_i, R_i, beq_i, j_i, jal_i, jalr_i, jr_i, addu_i, subu_i;
    
    assign GRF_rs_useStage = (BRANCH_rs_INSTR|BRANCH_rsrt_INSTR|jalr_i|jr_i|bonall_i) ? D_Stage : 
                             (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|load_INSTR|store_INSTR|mult_i|multu_i|div_i|divu_i|mthi_i|mtlo_i) ? E_Stage :
                             (1'b0) ? M_Stage :
                             (1'b0) ? W_Stage : 
                             (j_i|jal_i|SETWORD_INSTR|mfhi_i|mflo_i|mfc0_i|mtc0_i|eret_i) ? Non_Stage : 2'bxx;
    
    
    assign GRF_rt_useStage = (BRANCH_rsrt_INSTR|bonall_i) ? D_Stage : 
                             (ALU_urr_INSTR|mult_i|multu_i|div_i|divu_i) ? E_Stage :
                             (store_INSTR|mtc0_i) ? M_Stage :
                             (1'b0) ? W_Stage :
                             (load_INSTR|BRANCH_rs_INSTR|ALU_sri_INSTR|ALU_uri_INSTR|SETWORD_INSTR|jal_i|jalr_i|j_i|jr_i|mthi_i|mtlo_i|mfhi_i|mflo_i|mfc0_i|eret_i) ? Non_Stage : 2'bxx;

    assign GRF_WD_newStage = RegWrite ? ((1'b0) ? D_Stage : 
                             (SETWORD_INSTR|jalr_i|jal_i|bonall_i) ? E_Stage :
                             (ALU_urr_INSTR|ALU_uri_INSTR|ALU_sri_INSTR|mfhi_i|mflo_i) ? M_Stage :
                             (load_INSTR|mfc0_i) ? W_Stage : 2'bxx) : 2'b00;


endmodule 