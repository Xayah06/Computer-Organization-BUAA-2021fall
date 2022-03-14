
module DATAPATH(
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    //
    input [3:0] D_CMPOp, 
    input D_EXTOp, 
    input [2:0] D_NPCOp, 
    input [2:0] D_SetWordOp,
    input [4:0] D_CU_ExcCode,
    //
    input E_start,
    input [3:0] E_MULTDIVControl,
    input [4:0] E_ALUControl, 
    input E_ALUDataSrc, 
    input [1:0] E_CalcResultSrc,
    input [2:0] E_MemDataType,
    input E_MemWrite,
    //
	input M_MemWrite, 
    input [2:0] M_MemDataType, 
    input M_EXLClr,
    input M_CP0Write,
    input [5:0] HWInt,
    //
    input W_RegWrite, 
    input [4:0] W_A3,
    input [1:0] W_RegDataSrc, 
    //
	input stall,
    input [1:0] D_GRF_rs_ForwardSrc, 
    input [1:0] D_GRF_rt_ForwardSrc, 
    input [1:0] E_GRF_rs_ForwardSrc, 
    input [1:0] E_GRF_rt_ForwardSrc, 
    input [1:0] M_GRF_rt_ForwardSrc,
    //
    output [4:0] M_DM_RegAddr,
    output [4:0] W_DM_RegAddr,
    output E_busy,
    output [31:0] D_instr, 
    output [31:0] E_instr, 
    output [31:0] M_instr, 
    output [31:0] W_instr,
    output E_branch,
    output M_branch,
    output W_branch,
    output [31:0] M_PC,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,
    output [31:0] m_inst_addr,
    output responseInt,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr);
	
    wire D_branch, D_cleardb, F_isdb, D_isdb, E_isdb, M_isdb, IntReq;
	wire [31:0] F_instr, F_PC;
	wire [31:0] D_PC, D_npc, D_PCp8, D_GRF_rs, D_GRF_rt, D_imm32, D_SetWordResult, FWD_D_GRF_rs, FWD_D_GRF_rt;
	wire [31:0] E_ALUResult, E_PC, E_GRF_rs, E_GRF_rt, E_SetWordResult, E_imm32, E_ALUData, FWD_E_GRF_rs, FWD_E_GRF_rt, E_CalcResult, E_HI, E_LO;
	wire [31:0] M_DMRD, M_GRF_rt, M_CalcResult, FWD_M_GRF_rt, M_CP0_Dout, fixed_EPC;
	wire [31:0] W_CalcResult, W_DMRD, W_PC, W_RegData, W_CP0_Dout;
    wire [4:0] F_ExcCode, D_ExcCode, E_ExcCode, E_ALU_ExcCode, M_ExcCode, CP0_ExcCode;
	 
    assign i_inst_addr = F_PC;
    assign m_data_addr = M_CalcResult;
    assign m_inst_addr = M_PC;
    assign w_grf_we = W_RegWrite;
    assign w_grf_addr = W_A3;
    assign w_grf_wdata = W_RegData;
    assign w_inst_addr = W_PC;

    assign F_instr = i_inst_rdata;
    


    


    // F
   
    
    F_IFU ifu(.clk(clk), 
              .reset(reset), 
              .F_IFUen((!stall)|IntReq), // when stall, pc can jump to exc
              .D_npc(D_npc), 
              .F_PC(F_PC),
              .F_ExcCode(F_ExcCode));
	 
    // D
   

	D_REG d_reg(.clk(clk), 
                .reset(reset), 
                .IntReq(IntReq),
                .D_REGen(!stall), 
                .F_PC(F_PC), 
                .F_instr(F_instr),  
                .D_npc(D_npc),
                .D_cleardb(D_cleardb),
                .F_isdb(F_isdb),
                .F_ExcCode(F_ExcCode),
                // output
                .D_PC(D_PC), 
                .D_PCp8(D_PCp8), 
                .D_instr(D_instr), 
                .D_isdb(D_isdb),
                .D_ExcCode(D_ExcCode));

    D_GRF d_grf(.clk(clk), 
                .reset(reset), 
                .W_RegWrite(W_RegWrite), 
                .D_A1(D_instr[25:21]), 
                .D_A2(D_instr[20:16]), 
                .W_A3(W_A3), 
                .W_RegData(W_RegData), 
                .W_PC(W_PC),
                // output 
                .D_RD1(D_GRF_rs), 
                .D_RD2(D_GRF_rt));

    D_EXT d_ext(.D_imm16(D_instr[15:0]), 
                .D_EXTOp(D_EXTOp), 
                // output
                .D_imm32(D_imm32));

    D_SETWORD d_serword(.D_imm16(D_instr[15:0]), 
                        .SetWordOp(D_SetWordOp), 
                        .D_PCp8(D_PCp8), 
                        //output
                        .D_SetWordResult(D_SetWordResult));

    D_NPC d_npc(.D_PC(D_PC), 
                .F_PC(F_PC), 
                .D_instr(D_instr), 
                .D_NPCOp(D_NPCOp),
                .FWD_D_GRF_rs(FWD_D_GRF_rs), 
                .D_branch(D_branch), 
                .fixed_EPC(fixed_EPC),
                .stall(stall),
                .IntReq(IntReq),
                // output
                .D_cleardb(D_cleardb),
                .F_isdb(F_isdb),
                .D_npc(D_npc));

    D_CMP d_cmp(.A(FWD_D_GRF_rs), 
                .B(FWD_D_GRF_rt), 
                .D_CMPOp(D_CMPOp), 
                // output
                .D_branch(D_branch));

    MUX_d32s2 mux_FWD_D_GRF_rs(.d0(D_GRF_rs), 
                               .d1(M_CalcResult), 
                               .d2(E_SetWordResult), 
                               .d3(32'hx), 
                               .sel(D_GRF_rs_ForwardSrc), 
                               // output
                               .result(FWD_D_GRF_rs));


    MUX_d32s2 mux_FWD_D_GRF_rt(.d0(D_GRF_rt), 
                               .d1(M_CalcResult), 
                               .d2(E_SetWordResult), 
                               .d3(32'hx), 
                               .sel(D_GRF_rt_ForwardSrc), 
                               // output 
                               .result(FWD_D_GRF_rt));

   
    
    // E
    

    E_ALU e_alu(.A(FWD_E_GRF_rs), 
                .B(E_ALUData), 
                .E_shamt(E_instr[10:6]), 
                .E_ALUControl(E_ALUControl), 
                .E_MemWrite(E_MemWrite),
                .E_MemDataType(E_MemDataType), 
                // output
                .E_ALUResult(E_ALUResult),
                .E_ALU_ExcCode(E_ALU_ExcCode));

    E_MULTDIV e_multdiv(.A(FWD_E_GRF_rs), 
                        .B(FWD_E_GRF_rt), 
                        .clk(clk),
                        .reset(reset),
                        .IntReq(IntReq),
                        .start(E_start),
                        .MULTDIVControl(E_MULTDIVControl),
                        .busy(E_busy),
                        .HI(E_HI),
                        .LO(E_LO));

    E_REG e_reg(.clk(clk), 
                .reset(reset),
                .stall(stall),
                .IntReq(IntReq),
                .D_PC(D_PC), 
                .D_instr(D_instr), 
                .FWD_D_GRF_rs(FWD_D_GRF_rs), 
                .FWD_D_GRF_rt(FWD_D_GRF_rt), 
                .D_imm32(D_imm32), 
                .D_SetWordResult(D_SetWordResult),
                .D_ExcCode(D_ExcCode),
                .D_CU_ExcCode(D_CU_ExcCode),
                .D_isdb(D_isdb),
                .D_branch(D_branch),
                // output
                .E_PC(E_PC),
                .E_instr(E_instr),
                .E_GRF_rs(E_GRF_rs),
                .E_GRF_rt(E_GRF_rt),
                .E_SetWordResult(E_SetWordResult),
                .E_imm32(E_imm32),
                .E_ExcCode(E_ExcCode),
                .E_isdb(E_isdb),
                .E_branch(E_branch));
                
    MUX_d32s1 mux_E_ALUData(.d0(FWD_E_GRF_rt), 
                            .d1(E_imm32), 
                            .sel(E_ALUDataSrc), 
                            // output
                            .result(E_ALUData));

    

    MUX_d32s2 mux_FWD_E_GRF_rs(.d0(E_GRF_rs), 
                               .d1(W_RegData), 
                               .d2(M_CalcResult), 
                               .d3(32'hx), 
                               .sel(E_GRF_rs_ForwardSrc), 
                               // output
                               .result(FWD_E_GRF_rs));

    MUX_d32s2 mux_FWD_E_GRF_rt(.d0(E_GRF_rt), 
                               .d1(W_RegData), 
                               .d2(M_CalcResult), 
                               .d3(32'hx), 
                               .sel(E_GRF_rt_ForwardSrc), 
                               // output
                               .result(FWD_E_GRF_rt));

    MUX_d32s2 mux_E_CalcResult(.d0(E_SetWordResult), 
                               .d1(E_ALUResult), 
                               .d2(E_HI),
                               .d3(E_LO),
                               .sel(E_CalcResultSrc), 
                               // output
                               .result(E_CalcResult));
    
    
    // M
    

    M_DM m_dm(.A(M_CalcResult), 
              .M_MemData(FWD_M_GRF_rt), 
              .M_MemDataType(M_MemDataType), 
              .m_data_rdata(m_data_rdata),
              .M_MemWrite(M_MemWrite),
              .IntReq(IntReq),
              .M_PC(M_PC),
              .M_instr(M_instr),
              .M_ExcCode(M_ExcCode),
              .FWD_M_GRF_rt(FWD_M_GRF_rt),
              // output
              .m_data_wdata(m_data_wdata),
              .M_DM_RegAddr(M_DM_RegAddr),
              .m_data_byteen(m_data_byteen),
              .CP0_ExcCode(CP0_ExcCode),
              .M_DMRD(M_DMRD));
    
    CP0 cp0(.clk(clk),
            .reset(reset),
            .A1(M_instr[15:11]),
            .A2(M_instr[15:11]),
            .Din(FWD_M_GRF_rt),
            .M_PC(M_PC),
            .CP0_ExcCode(CP0_ExcCode),
            .HWInt(HWInt), 
            .M_CP0Write(M_CP0Write),
            .M_EXLClr(M_EXLClr),
            .M_isdb(M_isdb),
            .IntReq(IntReq),
            .fixed_EPC(fixed_EPC),
            .DOut(M_CP0_Dout),
            .responseInt(responseInt)); 

    M_REG m_reg(.clk(clk), 
                .reset(reset),
                .IntReq(IntReq),
                .E_PC(E_PC),
                .E_instr(E_instr),
                .FWD_E_GRF_rt(FWD_E_GRF_rt),
                .E_CalcResult(E_CalcResult),
                .E_ExcCode(E_ExcCode),
                .E_ALU_ExcCode(E_ALU_ExcCode),
                .E_branch(E_branch),
                .E_isdb(E_isdb),
                // output
                .M_PC(M_PC),
                .M_instr(M_instr),
                .M_GRF_rt(M_GRF_rt),
                .M_CalcResult(M_CalcResult),
                .M_ExcCode(M_ExcCode),
                .M_isdb(M_isdb),
                .M_branch(M_branch));

    MUX_d32s2 mux_FWD_M_GRF_rt(.d0(M_GRF_rt), 
                               .d1(W_RegData),
                               .d2(32'hx),
                               .d3(32'hx),
                               .sel(M_GRF_rt_ForwardSrc),
                               // output
                               .result(FWD_M_GRF_rt));


    // W
    

    W_REG w_reg(.clk(clk),
                .reset(reset|IntReq),
                .M_PC(M_PC),
                .M_instr(M_instr),
                .M_CalcResult(M_CalcResult),
                .M_DMRD(M_DMRD),
                .M_DM_RegAddr(M_DM_RegAddr),
                .M_CP0_Dout(M_CP0_Dout),
                .M_branch(M_branch),
                // output
                .W_PC(W_PC),
                .W_instr(W_instr),
                .W_DM_RegAddr(W_DM_RegAddr),
                .W_CalcResult(W_CalcResult),
                .W_DMRD(W_DMRD),
                .W_CP0_Dout(W_CP0_Dout),
                .W_branch(W_branch));

    MUX_d32s2 mux_W_RegData(.d0(W_CalcResult), 
                            .d1(W_DMRD), 
                            .d2(W_CP0_Dout), 
                            .d3(32'hx), 
                            .sel(W_RegDataSrc), 
                            // output
                            .result(W_RegData));
    
endmodule 