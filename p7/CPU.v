
module CPU (
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    input [5:0] HWInt,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3:0] m_data_byteen,
    output [31:0] m_inst_addr,
    output [31:0] macroscopic_pc,
    output responseInt,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr);

    wire M_MemWrite, D_EXTOp, E_ALUDataSrc, E_MemWrite, W_RegWrite, D_eret_i;
    wire E_start, E_branch, E_busy, M_branch, W_branch, stall;
    wire [1:0] W_RegDataSrc, D_GRF_rs_ForwardSrc, D_GRF_rt_ForwardSrc;
    wire [1:0] E_CalcResultSrc, E_GRF_rs_ForwardSrc, E_GRF_rt_ForwardSrc, M_GRF_rt_ForwardSrc;
    wire [2:0] D_NPCOp, M_MemDataType, E_MemDataType, D_SetWordOp;
    wire [3:0] D_CMPOp, E_MULTDIVControl;
	wire [4:0] E_ALUControl, W_A3, M_DM_RegAddr, W_DM_RegAddr, D_CU_ExcCode;
    wire [31:0] D_instr, E_instr, M_instr, W_instr;

    
    DATAPATH datapath(.clk(clk),
                        .reset(reset),
                        .i_inst_rdata(i_inst_rdata),
                        .m_data_rdata(m_data_rdata),
                        
                        .D_CMPOp(D_CMPOp),
                        .D_NPCOp(D_NPCOp),
						.D_EXTOp(D_EXTOp),
                        .D_SetWordOp(D_SetWordOp),
                        .D_CU_ExcCode(D_CU_ExcCode),

                        .E_start(E_start),
                        .E_MULTDIVControl(E_MULTDIVControl),
                        .E_ALUControl(E_ALUControl),
                        .E_ALUDataSrc(E_ALUDataSrc),
                        .E_CalcResultSrc(E_CalcResultSrc),
                        .E_MemDataType(E_MemDataType),
                        .E_MemWrite(E_MemWrite),

                        .M_MemWrite(M_MemWrite),
                        .M_MemDataType(M_MemDataType),
                        .M_EXLClr(M_EXLClr),
                        .M_CP0Write(M_CP0Write),
                        .HWInt(HWInt),

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
                        .M_DM_RegAddr(M_DM_RegAddr),
                        .W_DM_RegAddr(W_DM_RegAddr),
                        .E_busy(E_busy),
                        .D_instr(D_instr),
                        .E_instr(E_instr),
                        .M_instr(M_instr),
                        .W_instr(W_instr),
                        .E_branch(E_branch),
                        .M_branch(M_branch),
                        .W_branch(W_branch),
                        .M_PC(macroscopic_pc),
                        .i_inst_addr(i_inst_addr),
                        .m_data_addr(m_data_addr),
                        .m_data_wdata(m_data_wdata),
                        .m_data_byteen(m_data_byteen),
                        .m_inst_addr(m_inst_addr),
                        .responseInt(responseInt),
                        .w_grf_we(w_grf_we),
                        .w_grf_addr(w_grf_addr),
                        .w_grf_wdata(w_grf_wdata),
                        .w_inst_addr(w_inst_addr));

    CONTROL control(.M_DM_RegAddr(M_DM_RegAddr),
                    .W_DM_RegAddr(W_DM_RegAddr),
          .E_busy(E_busy),
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
          .D_CU_ExcCode(D_CU_ExcCode),

          .E_start(E_start),
          .E_MULTDIVControl(E_MULTDIVControl),
          .E_ALUControl(E_ALUControl),
          .E_ALUDataSrc(E_ALUDataSrc),
          .E_CalcResultSrc(E_CalcResultSrc),
          .E_MemDataType(E_MemDataType),
          .E_MemWrite(E_MemWrite),
          

          .M_MemWrite(M_MemWrite),
          .M_MemDataType(M_MemDataType),
          .M_EXLClr(M_EXLClr),
          .M_CP0Write(M_CP0Write),

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