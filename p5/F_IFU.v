module F_IFU(
    input clk,
    input reset,
    input F_IFUen,
    input [31:0] D_npc,
    output [31:0] F_instr,
    output reg [31:0] F_PC);

    parameter IM_SIZE = 4096;
    parameter PC_base = 32'h0000_3000;
    
	reg [31:0] im [IM_SIZE-1: 0];
    reg [11:0] IM_addr;

	initial begin
		$readmemh("code.txt", im);
        F_PC <= PC_base;
	end
	
    always @(*) begin
        case (F_PC[14:12])
            3'b011: IM_addr = {2'b00, F_PC[11:2]};
            3'b100: IM_addr = {2'b01, F_PC[11:2]};
            3'b101: IM_addr = {2'b10, F_PC[11:2]};
            3'b110: IM_addr = {2'b11, F_PC[11:2]};
            default: IM_addr = 2'bxx;
        endcase
    end

	assign F_instr = im[IM_addr];

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