module F_IFU(
    input clk,
    input reset,
    input F_IFUen,
    input [31:0] D_npc,
    output reg [31:0] F_PC,
    output [4:0] F_ExcCode);

    parameter IM_SIZE = 4096;
    parameter PC_base = 32'h0000_3000;
    parameter AdEL_EXC = 5'd4, AdES_EXC = 5'd5, RI_EXC = 5'd10, Ov_EXC = 5'd12;

    assign F_ExcCode = ((|F_PC[1:0]) | (F_PC < 32'h0000_3000) | (F_PC > 32'h0000_6ffc)) ? AdEL_EXC : 5'h0;

    reg [11:0] IM_addr;

	initial begin
        F_PC <= PC_base;
	end
	

    always @(posedge clk) begin // 同步复位
        if (reset) begin
            F_PC <= PC_base;
        end
        else begin
            if (F_IFUen) begin
                F_PC <= D_npc;
            end
            else begin
                F_PC <= F_PC;
            end
        end
    end

endmodule