module CONTROL(
    input M_DM_RegAddrSel,
    input [31:0] D_instr, 
    input [31:0] E_instr, 
    input [31:0] M_instr, 
    input [31:0] W_instr,
    input E_branch,
    input M_branch,
    input W_branch,
    //
    output [3:0] D_CMPOp, 
    output D_EXTOp, 
    output [2:0] D_NPCOp, 
    output [2:0] D_SetWordOp,
    //
    output [3:0] E_ALUControl, 
    output E_ALUDataSrc, 
    output E_CalcResultSrc,
    //
    output M_MemWrite, 
    output [2:0] M_MemDataType, 
    //
    output W_RegWrite, 
    output [4:0] W_A3,
	 output [1:0] W_RegDataSrc, 
    //
    output stall,
    output [1:0] D_GRF_rs_ForwardSrc, 
    output [1:0] D_GRF_rt_ForwardSrc, 
    output [1:0] E_GRF_rs_ForwardSrc, 
    output [1:0] E_GRF_rt_ForwardSrc, 
    output [1:0] M_GRF_rt_ForwardSrc);

    wire [4:0] D_A1, D_A2, E_A1, E_A2, E_A3, M_A2, M_A3;
    wire [1:0] D_GRF_rs_useStage, D_GRF_rt_useStage, E_GRF_WD_newStage, M_GRF_WD_newStage;
    wire E_RegWrite, M_RegWrite;


    CU d_cu(.instr(D_instr), 
            .branch(1'bx), 
            .M_DM_RegAddrSel(M_DM_RegAddrSel),
            .stage(2'b00),
            .CMPOp(D_CMPOp), 
            .EXTOp(D_EXTOp), 
            .NPCOp(D_NPCOp), 
            .SetWordOp(D_SetWordOp),
            .A1(D_A1),
            .A2(D_A2),
            .GRF_rs_useStage(D_GRF_rs_useStage),
            .GRF_rt_useStage(D_GRF_rt_useStage));

    CU e_cu(.instr(E_instr), 
            .branch(E_branch), 
            .M_DM_RegAddrSel(M_DM_RegAddrSel),
            .stage(2'b01),
            .ALUControl(E_ALUControl), 
            .ALUDataSrc(E_ALUDataSrc), 
            .CalcResultSrc(E_CalcResultSrc),
            .A1(E_A1),
            .A2(E_A2),
            .A3(E_A3),
            .GRF_WD_newStage(E_GRF_WD_newStage),
            .RegWrite(E_RegWrite));


    CU m_cu(.instr(M_instr), 
            .branch(M_branch), 
            .M_DM_RegAddrSel(M_DM_RegAddrSel),
            .stage(2'b10),
            .MemWrite(M_MemWrite), 
            .MemDataType(M_MemDataType),
            .A2(M_A2),
            .A3(M_A3),
            .GRF_WD_newStage(M_GRF_WD_newStage),
            .RegWrite(M_RegWrite));

    CU w_cu(.instr(W_instr), 
            .branch(W_branch), 
            .M_DM_RegAddrSel(M_DM_RegAddrSel),
            .stage(2'b11),
            .RegWrite(W_RegWrite), 
            .RegDataSrc(W_RegDataSrc),
            .A3(W_A3));

    FWDCONTROL fwdcontrol(.D_A1(D_A1),  
                          .D_A2(D_A2), 
                          .E_A1(E_A1), 
                          .E_A2(E_A2), 
                          .E_A3(E_A3), 
                          .E_RegWrite(E_RegWrite), 
                          .M_A2(M_A2), 
                          .M_A3(M_A3), 
                          .M_RegWrite(M_RegWrite), 
                          .W_A3(W_A3), 
                          .W_RegWrite(W_RegWrite),
                          .D_GRF_rs_ForwardSrc(D_GRF_rs_ForwardSrc), 
                          .D_GRF_rt_ForwardSrc(D_GRF_rt_ForwardSrc), 
                          .E_GRF_rs_ForwardSrc(E_GRF_rs_ForwardSrc), 
                          .E_GRF_rt_ForwardSrc(E_GRF_rt_ForwardSrc), 
                          .M_GRF_rt_ForwardSrc(M_GRF_rt_ForwardSrc));

    STALLCONTROL stallcontrol(.D_GRF_rs_useStage(D_GRF_rs_useStage), 
                              .D_GRF_rt_useStage(D_GRF_rt_useStage), 
                              .E_GRF_WD_newStage(E_GRF_WD_newStage), 
                              .M_GRF_WD_newStage(M_GRF_WD_newStage), 
                              .D_A1(D_A1), 
                              .D_A2(D_A2), 
                              .E_A3(E_A3), 
                              .E_RegWrite(E_RegWrite), 
                              .M_A3(M_A3), 
                              .M_RegWrite(M_RegWrite),
                              .stall(stall));


    
endmodule