module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUOp,
    output reg [31:0] C);

    parameter AND_ALU = 4'b0010, OR_ALU = 4'b0011, ADDU_ALU = 4'b0000, SLL_ALU = 4'b0101, SRL_ALU = 4'b0110;
    parameter SRA_ALU = 4'b0111, SUBU_ALU = 4'b0001, SGTU_ALU = 4'b1000,  XOR_ALU = 4'b0100, SGT_ALU = 1001;

    always @(*) begin
        case (ALUOp)
            AND_ALU:        C = A & B;
            OR_ALU:         C = A | B;
            ADDU_ALU:        C = A + B;
            SLL_ALU:        C = A << B;
            SRL_ALU:      C = A >> B;
            SRA_ALU:       C = $signed($signed(A) >>> B);
            SUBU_ALU:        C = A - B;
            SGTU_ALU:        C = {{31'd0}, A > B};
            SGT_ALU:        C = {{31'd0}, $signed($signed(A) > $signed(B))};
            XOR_ALU:        C = A ^ B;
            default:        C = 0;
        endcase
    end



endmodule