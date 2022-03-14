module W_REG(
    input clk,
    input reset,
    input [31:0] M_PC,
    input [31:0] M_instr,
    input [31:0] M_CalcResult,
    input [31:0] M_DMRD,
    input M_branch,
    output reg [31:0] W_PC,
    output reg [31:0] W_instr, 
    output reg [31:0] W_CalcResult,  
    output reg [31:0] W_DMRD,
    output reg W_branch);

    always @(posedge clk) begin
        if (reset) begin
            W_PC <= 32'h0;
            W_instr <= 32'h0;
            W_CalcResult <= 32'h0;
            W_DMRD <= 32'h0;
            W_branch <= 1'b0;
        end
        else begin
            W_PC <= M_PC;
            W_instr <= M_instr;
            W_CalcResult <= M_CalcResult;
            W_DMRD <= M_DMRD;
            W_branch <= M_branch;
        end
    end

endmodule