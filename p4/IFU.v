module IFU(
    input clk,
    input reset,
    input branch,
    input [2:0] NPCOp,
    input [31:0] ALUResult,
    output [31:0] instr,
    output [31:0] PCp4,
    output reg [31:0] PC);

    parameter IM_SIZE = 1024;
    parameter PC_base = 32'h0000_3000;
    // NPCOp
    parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100;

	reg [31:0] im [IM_SIZE-1: 0];
    reg [31:0] NPC;

	initial begin
		$readmemh("code.txt", im);
        PC = PC_base;
	end
	
	assign instr = im[PC[11:2]];
    assign PCp4 = PC + 32'd4;

    always @(*) begin
        case (NPCOp)
            PCp4_NPC: begin
                NPC = PCp4;
            end 
            BRANCH_NPC: begin
                if (branch) begin
                    NPC = PCp4 + {{14{instr[15]}}, instr[15:0], 2'b00};
                end
                else begin
                    NPC = PCp4;
                end
            end
            J_NPC: begin
                NPC = {PC[31:28], instr[25:0], 2'b00};
            end
            JR_NPC: begin
                NPC = ALUResult;
            end
            default: NPC = 32'bxxxx_xxxx;
        endcase
    end

    always @(posedge clk) begin // 同步复位
        if (reset) begin
            PC <= PC_base;
        end
        else begin
            PC <= NPC;
        end
    end

endmodule