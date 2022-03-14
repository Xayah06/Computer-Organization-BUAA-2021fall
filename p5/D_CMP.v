module D_CMP(
    input [31:0] A,
    input [31:0] B,
    input [3:0] D_CMPOp,
    input stall,
    output D_cleardb,
    output reg D_branch);

    parameter EQ_CMP = 4'b0000, OPPOSITE_CMP = 4'b0001;

    always @(*) begin
        case (D_CMPOp)
            EQ_CMP : D_branch = A == B; 
            OPPOSITE_CMP: D_branch = ((A[31] == 0) & (((~A) + 1) == B)) | ((B[31] == 0) & (((~B) + 1) == A));
            default: D_branch = 1'bx;
        endcase
    end

    assign D_cleardb = (!stall) & (D_CMPOp == OPPOSITE_CMP) & (D_branch == 1'b0);
    

endmodule