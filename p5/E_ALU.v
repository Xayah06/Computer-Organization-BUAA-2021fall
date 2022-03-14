module E_ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] E_ALUControl,
    input [4:0] E_shamt,
    output reg [31:0] E_ALUResult);

    parameter AND_ALU = 4'b0000, OR_ALU = 4'b0001, ADDU_ALU = 4'b0010, SLL_ALU = 4'b0011, AND_N_ALU = 4'b0100;
    parameter OR_N_ALU = 4'b0101, SUBU_ALU = 4'b0110, SLT_ALU = 4'b0111, LUI_ALU = 4'b1000;

    always @(*) begin
        case (E_ALUControl)
            AND_ALU:        E_ALUResult = A & B;
            OR_ALU:         E_ALUResult = A | B;
            ADDU_ALU:        E_ALUResult = A + B;
            SLL_ALU:        E_ALUResult = B << E_shamt;
            AND_N_ALU:      E_ALUResult = A & ~B;
            OR_N_ALU:       E_ALUResult = A | ~B;
            SUBU_ALU:        E_ALUResult = A - B;
            SLT_ALU:        E_ALUResult = {{31'd0}, A < B};
            LUI_ALU:        E_ALUResult = B << 16;
            default:        E_ALUResult = 0;
        endcase
    end

endmodule