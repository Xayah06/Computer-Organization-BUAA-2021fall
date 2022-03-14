module D_NPC(
    input [31:0] D_PC,
    input [31:0] F_PC,
    input [31:0] D_instr,
    input [2:0] D_NPCOp,
    input [31:0] FWD_D_GRF_rs,
    input D_branch,
    output reg [31:0] D_npc);

	 parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100;
	

    always @(*) begin
        case (D_NPCOp)
            PCp4_NPC: begin
                D_npc = F_PC + 32'h4;
            end 
            BRANCH_NPC: begin
                if (D_branch) begin
                    D_npc = D_PC + 32'h4 + {{14{D_instr[15]}}, D_instr[15:0], 2'b00};
                end
                else begin
                    D_npc = F_PC + 32'h4;
                end
            end
            J_NPC: begin
                D_npc = {D_PC[31:28], D_instr[25:0], 2'b00};
            end
            JR_NPC: begin
                D_npc = FWD_D_GRF_rs;
            end
            default: D_npc = 32'hx;
        endcase
    end

endmodule