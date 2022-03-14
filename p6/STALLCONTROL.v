module STALLCONTROL(
    input [1:0] D_GRF_rs_useStage, 
    input [1:0] D_GRF_rt_useStage, 
    input [1:0] E_GRF_WD_newStage, 
    input [1:0] M_GRF_WD_newStage, 
    input E_conditionStore,
    input M_conditionStore,
	input [4:0] D_A1, 
    input [4:0] D_A2, 
    input D_multdiv_INSTR,
    input [4:0] E_A3, 
    input E_busy,
    input E_start,
    input E_RegWrite, 
    input [4:0] M_A3, 
    input M_RegWrite,
	output stall);

    parameter D_Stage = 2'b00, E_Stage = 2'b01, M_Stage = 2'b10, W_Stage = 2'b11, Non_Stage = 2'b11;

    wire stall_E_rs, stall_M_rs, stall_E_rt, stall_M_rt, stall_busy;
    reg [1:0] D_GRF_rs_Tuse, D_GRF_rt_Tuse, E_GRF_WD_Tnew, M_GRF_WD_Tnew;
	 
    assign stall = stall_E_rs | stall_M_rs | stall_E_rt | stall_M_rt | stall_busy;
    assign stall_E_rs = ((D_GRF_rs_Tuse < E_GRF_WD_Tnew) & E_RegWrite & (E_conditionStore ? 1'b0 :(D_A1 === E_A3)) & (D_A1 !== 5'h0));
    assign stall_M_rs = ((D_GRF_rs_Tuse < M_GRF_WD_Tnew) & M_RegWrite & (M_conditionStore ? 1'b0 :(D_A1 === M_A3)) & (D_A1 !== 5'h0));
    assign stall_E_rt = ((D_GRF_rt_Tuse < E_GRF_WD_Tnew) & E_RegWrite & (E_conditionStore ? 1'b0 :(D_A2 === E_A3)) & (D_A2 !== 5'h0));
    assign stall_M_rt = ((D_GRF_rt_Tuse < M_GRF_WD_Tnew) & M_RegWrite & (M_conditionStore ? 1'b0 :(D_A2 === M_A3)) & (D_A2 !== 5'h0));
    assign stall_busy = D_multdiv_INSTR & (E_busy | E_start);
    

    always @(*) begin
       case (D_GRF_rs_useStage)
           D_Stage: D_GRF_rs_Tuse = 0;
           E_Stage: D_GRF_rs_Tuse = 1;
           M_Stage: D_GRF_rs_Tuse = 2;
           default: D_GRF_rs_Tuse = 3;
       endcase 
    end

    always @(*) begin
       case (D_GRF_rt_useStage)
           D_Stage: D_GRF_rt_Tuse = 0;
           E_Stage: D_GRF_rt_Tuse = 1;
           M_Stage: D_GRF_rt_Tuse = 2;
           default: D_GRF_rt_Tuse = 3;
       endcase 
    end

    always @(*) begin
       case (E_GRF_WD_newStage)
           D_Stage: E_GRF_WD_Tnew = 0;
           E_Stage: E_GRF_WD_Tnew = 0;
           M_Stage: E_GRF_WD_Tnew = 1;
           W_Stage: E_GRF_WD_Tnew = 2;
       endcase 
    end

    always @(*) begin
       case (M_GRF_WD_newStage)
           D_Stage: M_GRF_WD_Tnew = 0;
           E_Stage: M_GRF_WD_Tnew = 0;
           M_Stage: M_GRF_WD_Tnew = 0;
           W_Stage: M_GRF_WD_Tnew = 1;
       endcase 
    end

    
endmodule