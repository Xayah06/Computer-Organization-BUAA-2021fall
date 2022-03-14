module D_REG(
    input clk,
    input reset,
    input D_REGen,
    input [31:0] F_PC,
    input [31:0] F_instr,
    output reg [31:0] D_PC,
    output [31:0] D_PCp8,
    output reg [31:0] D_instr);

	assign D_PCp8 = D_PC + 32'h8;

    always @(posedge clk) begin
        if (reset) begin
            D_PC <= 32'h0;
            D_instr <= 32'h0;
        end
        else begin
            if (D_REGen) begin
                D_PC <= F_PC;
                D_instr <= F_instr;
            end
            else begin
                D_PC <= D_PC;
                D_instr <= D_instr;
            end
            
        end
    end

endmodule