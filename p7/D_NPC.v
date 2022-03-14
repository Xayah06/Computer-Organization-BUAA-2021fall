module D_NPC(
    input [31:0] D_PC,
    input [31:0] F_PC,
    input [31:0] D_instr,
    input [2:0] D_NPCOp,
    input [31:0] FWD_D_GRF_rs,
    input D_branch,
    input [31:0] fixed_EPC,
    input stall,
    input IntReq,
    output reg [31:0] D_npc,
    output reg F_isdb,
    output D_cleardb);

	parameter PCp4_NPC = 3'b000, BRANCH_NPC = 3'b001, J_NPC = 3'b010, JR_NPC = 3'b100, EPC_NPC = 3'b101;
	wire align_n;
    assign align_n = (|D_npc[1:0]) | (D_npc < 32'h0000_3000) | (D_npc > 32'h0000_6ffc);
    assign D_cleardb = (!stall) & ((D_NPCOp == EPC_NPC));

    always @(*) begin
        if (IntReq) begin
            D_npc = 32'h00004180;
            F_isdb = 1'b0;
        end
        else begin
            case (D_NPCOp)
                PCp4_NPC: begin
                    D_npc = F_PC + 32'h4;
                    F_isdb = 1'b0;
                end 
                BRANCH_NPC: begin
                    if (D_branch) begin
                        D_npc = D_PC + 32'h4 + {{14{D_instr[15]}}, D_instr[15:0], 2'b00};
                    end
                    else begin
                        D_npc = F_PC + 32'h4;
                    end
                    F_isdb = 1'b1;
                end
                J_NPC: begin
                    D_npc = {D_PC[31:28], D_instr[25:0], 2'b00};
                    F_isdb = 1'b1;
                end
                JR_NPC: begin
                    D_npc = FWD_D_GRF_rs;
                    F_isdb = 1'b1;
                end
                EPC_NPC: begin
                    D_npc = fixed_EPC;
                    F_isdb = 1'b0;
                end
                default: begin
                    D_npc = F_PC + 32'h4;
                    F_isdb = 1'b0;
                end
            endcase
        end
    end

endmodule