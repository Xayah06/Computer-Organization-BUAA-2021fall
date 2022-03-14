module E_ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0] E_ALUControl,
    input [4:0] E_shamt,
    input [2:0] E_MemDataType,
    input E_MemWrite,
    output reg [31:0] E_ALUResult,
    output reg [4:0] E_ALU_ExcCode);

    parameter ADD_ALU = 5'd0, ADDU_ALU = 5'd1, SUB_ALU = 5'd2, SUBU_ALU = 5'd3;
    parameter SLL_ALU = 5'd4, SRL_ALU = 5'd5, SRA_ALU = 5'd6, SLLV_ALU = 5'd7;
    parameter SRLV_ALU = 5'd8, SRAV_ALU = 5'd9, AND_ALU = 5'd10, OR_ALU = 5'd11;
    parameter XOR_ALU = 5'd12, NOR_ALU = 5'd13, SLT_ALU = 5'd14, SLTU_ALU = 5'd15;
    parameter LOAD_ALU = 5'd16, STORE_ALU = 5'd17;
    parameter NONE_TYPE = 3'b111;
    parameter AdEL_EXC = 5'd4, AdES_EXC = 5'd5, RI_EXC = 5'd10, Ov_EXC = 5'd12;

    wire addOverflow, subOverflow;
    wire [32:0] b33A, b33B, b33add, b33sub;

    assign b33A = {A[31], A};
    assign b33B = {B[31], B};
    assign b33add = b33A + b33B;
    assign b33sub = b33A - b33B;
    assign addOverflow = (b33add[32] != b33add[31]);
    assign subOverflow = (b33sub[32] != b33sub[31]);

    always @(*) begin
        if (E_MemDataType == NONE_TYPE) begin
            E_ALU_ExcCode = (((E_ALUControl == ADD_ALU) & addOverflow) | ((E_ALUControl == SUB_ALU) & subOverflow)) ? Ov_EXC : 5'h0;
        end
        else begin
            if (addOverflow) begin
                E_ALU_ExcCode = (E_ALUControl == LOAD_ALU) ? AdEL_EXC :
                                (E_ALUControl == STORE_ALU) ? AdES_EXC : 5'h0;
            end
            else E_ALU_ExcCode = 5'h0;
        end
    end



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
            LOAD_ALU:   E_ALUResult = A + B;
            STORE_ALU:   E_ALUResult = A + B;
            default:    E_ALUResult = 0;
        endcase
    end

endmodule