module mips(
    input clk,
    input reset);

    wire M_MemWrite, D_EXTOp, E_ALUDataSrc, E_CalcResultSrc, W_RegWrite, E_branch, M_branch, W_branch, stall, M_DM_RegAddrSel;
    wire [1:0] W_RegDataSrc, D_GRF_rs_ForwardSrc, D_GRF_rt_ForwardSrc, E_GRF_rs_ForwardSrc, E_GRF_rt_ForwardSrc, M_GRF_rt_ForwardSrc;
    wire [2:0] D_NPCOp, M_MemDataType, D_SetWordOp;
    wire [3:0] E_ALUControl, D_CMPOp;
	 wire [4:0] W_A3;
    wire [31:0] D_instr, E_instr, M_instr, W_instr;

    
    DATAPATH datapath(.clk(clk),
                        .reset(reset),
                        .D_CMPOp(D_CMPOp),
                        .D_NPCOp(D_NPCOp),
								.D_EXTOp(D_EXTOp),
                        .D_SetWordOp(D_SetWordOp),
                        .E_ALUControl(E_ALUControl),
                        .E_ALUDataSrc(E_ALUDataSrc),
                        .E_CalcResultSrc(E_CalcResultSrc),
                        .M_MemWrite(M_MemWrite),
                        .M_MemDataType(M_MemDataType),
                        .W_RegWrite(W_RegWrite),
                        .W_A3(W_A3),
                        .W_RegDataSrc(W_RegDataSrc),
                        .stall(stall),
                        .D_GRF_rs_ForwardSrc(D_GRF_rs_ForwardSrc),
                        .D_GRF_rt_ForwardSrc(D_GRF_rt_ForwardSrc),
                        .E_GRF_rs_ForwardSrc(E_GRF_rs_ForwardSrc),
                        .E_GRF_rt_ForwardSrc(E_GRF_rt_ForwardSrc),
                        .M_GRF_rt_ForwardSrc(M_GRF_rt_ForwardSrc),
                        // output
                        .M_DM_RegAddrSel(M_DM_RegAddrSel),
                        .D_instr(D_instr),
                        .E_instr(E_instr),
                        .M_instr(M_instr),
                        .W_instr(W_instr),
                        .E_branch(E_branch),
                        .M_branch(M_branch),
                        .W_branch(W_branch));

    CONTROL control(.M_DM_RegAddrSel(M_DM_RegAddrSel),
          .D_instr(D_instr),
          .E_instr(E_instr),
          .M_instr(M_instr),
          .W_instr(W_instr),
          .E_branch(E_branch),
          .M_branch(M_branch),
          .W_branch(W_branch),
          // output
          .D_CMPOp(D_CMPOp),
          .D_NPCOp(D_NPCOp),
			 .D_EXTOp(D_EXTOp),
          .D_SetWordOp(D_SetWordOp),
          .E_ALUControl(E_ALUControl),
          .E_ALUDataSrc(E_ALUDataSrc),
          .E_CalcResultSrc(E_CalcResultSrc),
          .M_MemWrite(M_MemWrite),
          .M_MemDataType(M_MemDataType),
          .W_RegWrite(W_RegWrite),
          .W_A3(W_A3),
          .W_RegDataSrc(W_RegDataSrc),
          .stall(stall),
          .D_GRF_rs_ForwardSrc(D_GRF_rs_ForwardSrc),
          .D_GRF_rt_ForwardSrc(D_GRF_rt_ForwardSrc),
          .E_GRF_rs_ForwardSrc(E_GRF_rs_ForwardSrc),
          .E_GRF_rt_ForwardSrc(E_GRF_rt_ForwardSrc),
          .M_GRF_rt_ForwardSrc(M_GRF_rt_ForwardSrc));

endmodule 