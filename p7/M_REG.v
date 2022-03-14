module M_REG(
    input clk,
    input reset,
    input IntReq,
    input [31:0] E_PC,
    input [31:0] E_instr,
    input [31:0] FWD_E_GRF_rt,
    input [31:0] E_CalcResult,
    input [4:0] E_ExcCode,
    input [4:0] E_ALU_ExcCode,
    input E_isdb,
    input E_branch,
    output reg [31:0] M_PC,
    output reg [31:0] M_instr, 
    output reg [31:0] M_GRF_rt,  
    output reg [31:0] M_CalcResult,
    output reg [4:0] M_ExcCode,
    output reg M_isdb,
    output reg M_branch);

    always @(posedge clk) begin
        if (reset|IntReq) begin
            M_PC <= IntReq ? 32'h00004180 : 32'h0;
            M_instr <= 32'h0;
            M_GRF_rt <= 32'h0;
            M_CalcResult <= 32'h0;
            M_ExcCode <= 5'h0;
            M_branch <= 1'b0;
            M_isdb <= 1'b0;
        end
        else begin
            M_PC <= E_PC;
            M_instr <= E_instr;
            M_GRF_rt <= FWD_E_GRF_rt;
            M_CalcResult <= E_CalcResult;
            M_ExcCode <= (E_ALU_ExcCode == 0 ) ? E_ExcCode : E_ALU_ExcCode;
            M_branch <= E_branch;
            M_isdb <= E_isdb;
		end
    end

endmodule