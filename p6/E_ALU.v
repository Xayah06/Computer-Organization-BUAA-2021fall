module E_ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0] E_ALUControl,
    input [4:0] E_shamt,
    output reg [31:0] E_ALUResult);

    parameter ADD_ALU = 5'd0, ADDU_ALU = 5'd1, SUB_ALU = 5'd2, SUBU_ALU = 5'd3;
    parameter SLL_ALU = 5'd4, SRL_ALU = 5'd5, SRA_ALU = 5'd6, SLLV_ALU = 5'd7;
    parameter SRLV_ALU = 5'd8, SRAV_ALU = 5'd9, AND_ALU = 5'd10, OR_ALU = 5'd11;
    parameter XOR_ALU = 5'd12, NOR_ALU = 5'd13, SLT_ALU = 5'd14, SLTU_ALU = 5'd15;

    always @(*) begin
        case (E_ALUControl)
            ADD_ALU:    E_ALUResult = A + B;
            ADDU_ALU:    E_ALUResult = A + B;
            SUB_ALU:    E_ALUResult = A - B;
            SUBU_ALU:    E_ALUResult = A - B;
            SLL_ALU:    E_ALUResult = B << E_shamt;
            SRL_ALU:    E_ALUResult = B >> E_shamt;
            SRA_ALU:    E_ALUResult = $signed(B) >>> E_shamt;
            SLLV_ALU:    E_ALUResult = B << (A[4:0]);
            SRLV_ALU:    E_ALUResult = B >> (A[4:0]);
            SRAV_ALU:    E_ALUResult = $signed(B) >>> (A[4:0]);
            AND_ALU:    E_ALUResult = A & B;
            OR_ALU:     E_ALUResult = A | B;
            XOR_ALU:    E_ALUResult = A ^ B;
            NOR_ALU:     E_ALUResult = ~(A | B);
            SLT_ALU:    E_ALUResult = {{31'd0}, $signed($signed(A) < $signed(B))};
            SLTU_ALU:    E_ALUResult = {{31'd0}, A < B};
            default:    E_ALUResult = 0;
        endcase
    end

endmodule