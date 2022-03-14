module DATAPATH(
    input clk,
    input reset,
    //
    input [3:0] D_CMPOp, 
    input D_EXTOp, 
    input [2:0] D_NPCOp, 
    input [2:0] D_SetWordOp,
    //
    input [3:0] E_ALUControl, 
    input E_ALUDataSrc, 
    input E_CalcResultSrc,
    //
	input M_MemWrite, 
    input [2:0] M_MemDataType, 
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
    output M_DM_RegAddrSel,
    output [31:0] D_instr, 
    output [31:0] E_instr, 
    output [31:0] M_instr, 
    output [31:0] W_instr,
    output E_branch,
    output M_branch,
    output W_branch);
	
     wire D_branch, D_cleardb;
	 wire [31:0] F_instr, F_PC;
	 wire [31:0] D_PC, D_npc, D_PCp8, D_GRF_rs, D_GRF_rt, D_imm32, D_SetWordResult, FWD_D_GRF_rs, FWD_D_GRF_rt;
	 wire [31:0] E_ALUResult, E_PC, E_GRF_rs, E_GRF_rt, E_SetWordResult, E_imm32, E_ALUData, FWD_E_GRF_rs, FWD_E_GRF_rt, E_CalcResult;
	 wire [31:0] M_DMRD, M_PC, M_GRF_rt, M_CalcResult, FWD_M_GRF_rt;
	 wire [31:0] W_CalcResult, W_DMRD, W_PC, W_RegData;
	 
    // F
   
    
    F_IFU ifu(.clk(clk), .reset(reset), .F_IFUen(!stall), .D_npc(D_npc), .F_instr(F_instr), .F_PC(F_PC));
	 
    // D
   

	D_REG d_reg(.clk(clk), 
                .reset(reset|D_cleardb), 
                .D_REGen(!stall), 
                .F_PC(F_PC), 
                .F_instr(F_instr), 
                // output
                .D_PC(D_PC), 
                .D_PCp8(D_PCp8), 
                .D_instr(D_instr));

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
                // output
                .D_npc(D_npc));

    D_CMP d_cmp(.A(FWD_D_GRF_rs), 
                .B(FWD_D_GRF_rt), 
                .D_CMPOp(D_CMPOp), 
                .stall(stall),
                // output
                .D_cleardb(D_cleardb),
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
                // output
                .E_ALUResult(E_ALUResult));

    E_REG e_reg(.clk(clk), 
                .reset(reset|stall), 
                .D_PC(D_PC), 
                .D_instr(D_instr), 
                .FWD_D_GRF_rs(FWD_D_GRF_rs), 
                .FWD_D_GRF_rt(FWD_D_GRF_rt), 
                .D_imm32(D_imm32), 
                .D_SetWordResult(D_SetWordResult),
                .D_branch(D_branch),
                // output
                .E_PC(E_PC),
                .E_instr(E_instr),
                .E_GRF_rs(E_GRF_rs),
                .E_GRF_rt(E_GRF_rt),
                .E_SetWordResult(E_SetWordResult),
                .E_imm32(E_imm32),
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

    MUX_d32s1 mux_E_CalcResult(.d0(E_SetWordResult), 
                               .d1(E_ALUResult), 
                               .sel(E_CalcResultSrc), 
                               // output
                               .result(E_CalcResult));
    
    
    // M
    

    M_DM m_dm(.clk(clk), 
              .reset(reset), 
              .A(M_CalcResult), 
              .M_MemData(FWD_M_GRF_rt), 
              .M_MemDataType(M_MemDataType), 
				  .M_MemWrite(M_MemWrite),
              .M_PC(M_PC), 
              // output
              .M_DM_RegAddrSel(M_DM_RegAddrSel),
              .M_RD(M_DMRD));

    M_REG m_reg(.clk(clk), 
                .reset(reset),
                .E_PC(E_PC),
                .E_instr(E_instr),
                .FWD_E_GRF_rt(FWD_E_GRF_rt),
                .E_CalcResult(E_CalcResult),
                .E_branch(E_branch),
                // output
                .M_PC(M_PC),
                .M_instr(M_instr),
                .M_GRF_rt(M_GRF_rt),
                .M_CalcResult(M_CalcResult),
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
                .reset(reset),
                .M_PC(M_PC),
                .M_instr(M_instr),
                .M_CalcResult(M_CalcResult),
                .M_DMRD(M_DMRD),
                .M_branch(M_branch),
                // output
                .W_PC(W_PC),
                .W_instr(W_instr),
                .W_CalcResult(W_CalcResult),
                .W_DMRD(W_DMRD),
                .W_branch(W_branch));

    MUX_d32s2 mux_W_RegData(.d0(W_CalcResult), 
                            .d1(W_DMRD), 
                            .d2(32'hx), 
                            .d3(32'hx), 
                            .sel(W_RegDataSrc), 
                            // output
                            .result(W_RegData));
    
endmodule 