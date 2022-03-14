module D_CMP(
    input [31:0] A,
    input [31:0] B,
    input [3:0] D_CMPOp,
    input stall,
    output D_cleardb,
    output reg D_branch);

    parameter EQ_CMP = 4'd0, OPPOSITE_CMP = 4'd1, NEQ_CMP = 4'd2, LEZ_CMP = 4'd3;
    parameter GTZ_CMP = 4'd4, LTZ_CMP = 4'd5, GEZ_CMP = 4'd6;

    always @(*) begin
        case (D_CMPOp)
            EQ_CMP : D_branch = A == B; 
            OPPOSITE_CMP: D_branch = ((A[31] == 0) & (((~A) + 1) == B)) | ((B[31] == 0) & (((~B) + 1) == A));
            NEQ_CMP: D_branch = A != B;
            LEZ_CMP: D_branch = (A[31]) | (A == 0);
            GTZ_CMP: D_branch = (!A[31]) & (A != 0);
            LTZ_CMP: D_branch = A[31];
            GEZ_CMP: D_branch = !A[31];
            default: D_branch = 1'bx;
        endcase
    end

    assign D_cleardb = (!stall) & (D_CMPOp == OPPOSITE_CMP) & (D_branch == 1'b0);
    

endmodule