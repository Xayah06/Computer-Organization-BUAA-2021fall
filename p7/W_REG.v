module W_REG(
    input clk,
    input reset,
    input [31:0] M_PC,
    input [31:0] M_instr,
    input [31:0] M_CalcResult,
    input [31:0] M_DMRD,
    input [4:0] M_DM_RegAddr,
    input [31:0] M_CP0_Dout,
    input M_branch,
    output reg [31:0] W_PC,
    output reg [31:0] W_instr, 
    output reg [31:0] W_CalcResult,  
    output reg [31:0] W_DMRD,
    output reg [4:0] W_DM_RegAddr,
    output reg [31:0] W_CP0_Dout,
    output reg W_branch);

    always @(posedge clk) begin
        if (reset) begin
            W_PC <= 32'h0;
            W_instr <= 32'h0;
            W_CalcResult <= 32'h0;
            W_DMRD <= 32'h0;
            W_branch <= 1'b0;
            W_DM_RegAddr <= 4'h0;
            W_CP0_Dout <= 32'h0;
        end
        else begin
            W_PC <= M_PC;
            W_instr <= M_instr;
            W_CalcResult <= M_CalcResult;
            W_DMRD <= M_DMRD;
            W_branch <= M_branch;
            W_DM_RegAddr <= M_DM_RegAddr;
            // if (M_PC == 32'h00004184 & M_CP0_Dout == 32'h80000010) begin
            //     W_CP0_Dout <= 32'h00000028;
            // end
            // else W_CP0_Dout <= M_CP0_Dout;
            W_CP0_Dout <= M_CP0_Dout;
        
        end
    end

endmodule