module E_REG(
    input clk,
    input reset,
    input stall,
    input IntReq,
    input [31:0] D_PC,
    input [31:0] D_instr,
    input [31:0] FWD_D_GRF_rs, 
    input [31:0] FWD_D_GRF_rt,
    input [31:0] D_imm32,
    input [31:0] D_SetWordResult,
    input [4:0] D_ExcCode,
    input [4:0] D_CU_ExcCode,
    input D_isdb,
    input D_branch,
    output reg [31:0] E_PC,
    output reg [31:0] E_instr, 
    output reg [31:0] E_GRF_rs,  
    output reg [31:0] E_GRF_rt, 
    output reg [31:0] E_SetWordResult,
    output reg [31:0] E_imm32,
    output reg [4:0] E_ExcCode,
    output reg E_isdb,
    output reg E_branch);

    always @(posedge clk) begin
        if (reset|stall|IntReq) begin
            E_PC <= stall ? D_PC :(IntReq ? 32'h00004180 : 32'h0);
            E_instr <= 32'h0;
            E_GRF_rs <= 32'h0;
            E_GRF_rt <= 32'h0;
            E_SetWordResult <= 32'h0;
            E_imm32 <= 32'h0;
            E_ExcCode <= 5'h0;
            E_branch <= 1'b0;
            E_isdb <= stall ? D_isdb : 1'b0;
        end
        else begin
            E_PC <= D_PC;
            E_instr <= (D_CU_ExcCode == 0) ? D_instr : 32'h0;
            E_GRF_rs <= FWD_D_GRF_rs;
            E_GRF_rt <= FWD_D_GRF_rt;
            E_SetWordResult <= D_SetWordResult;
            E_imm32 <= D_imm32;
            E_ExcCode <= (D_CU_ExcCode == 0) ? D_ExcCode : D_CU_ExcCode;
            E_branch <= D_branch;
            E_isdb <= D_isdb;
        end
    end

endmodule