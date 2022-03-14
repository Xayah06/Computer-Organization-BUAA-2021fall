module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUControl,
    input [4:0] shamt,
    output reg [31:0] ALUResult,
    output reg sign);

    parameter AND_ALU = 4'b0000, OR_ALU = 4'b0001, ADDU_ALU = 4'b0010, SLL_ALU = 4'b0011, AND_N_ALU = 4'b0100;
    parameter OR_N_ALU = 4'b0101, SUBU_ALU = 4'b0110, SLT_ALU = 4'b0111, LUI_ALU = 4'b1000;

    always @(*) begin
        case (ALUControl)
            AND_ALU:        ALUResult = A & B;
            OR_ALU:         ALUResult = A | B;
            ADDU_ALU:        ALUResult = A + B;
            SLL_ALU:        ALUResult = B << shamt;
            AND_N_ALU:      ALUResult = A & ~B;
            OR_N_ALU:       ALUResult = A | ~B;
            SUBU_ALU:        ALUResult = A - B;
            SLT_ALU:        ALUResult = {{31'd0}, A < B};
            LUI_ALU:        ALUResult = B << 16;
            default:        ALUResult = 0;
        endcase
    end

    always @(*) begin
        case (ALUControl)
            SUBU_ALU:    sign = A == B;
            SLT_ALU:    sign = A < B;
            default:    sign = 0;
        endcase
    end

endmodule