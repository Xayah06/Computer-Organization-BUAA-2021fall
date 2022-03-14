module D_REG(
    input clk,
    input reset,
    input D_cleardb,
    input D_REGen,
    input IntReq,
    input [31:0] F_PC,
    input [31:0] F_instr,
    input [31:0] D_npc,
    input [4:0] F_ExcCode,
    input F_isdb,
    output reg [31:0] D_PC,
    output [31:0] D_PCp8,
    output reg [4:0] D_ExcCode,
    output reg [31:0] D_instr,
    output reg D_isdb);

	assign D_PCp8 = D_PC + 32'h8;

    always @(posedge clk) begin
        if (reset|D_cleardb|IntReq) begin
            D_PC <= D_cleardb ? D_npc : (IntReq : 32'h00004180 : 32'h0);
            D_instr <= 32'h0;
            D_ExcCode <= 5'h0;
            D_isdb <= 1'b0;
        end
        else begin
            if (D_REGen) begin
                // if (F_PC == 32'h00003684) D_PC <= D_instr;
				// else if (F_PC == 32'h0000368c | F_PC == 32'h00003688) D_PC <= D_PC + (F_isdb ? 4 : 0);
                // else D_PC <= F_PC;
				D_PC <= F_PC;
                D_instr <= (F_ExcCode == 5'h0) ? F_instr : 32'h0;
                D_ExcCode <= F_ExcCode;
                D_isdb <= F_isdb;
            end
            else begin
                D_PC <= D_PC;
                D_instr <= D_instr;
                D_ExcCode <= D_ExcCode;
                D_isdb <= D_isdb;
            end
            
        end
    end

endmodule