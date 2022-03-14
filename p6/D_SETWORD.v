module D_SETWORD(
    input [15:0] D_imm16,
    input [2:0] SetWordOp,
    input [31:0] D_PCp8,
    output reg [31:0] D_SetWordResult);


    parameter LUI_SET = 3'b000, PCp8_SET = 3'b001;

    always @(*) begin
        case (SetWordOp)
            LUI_SET: D_SetWordResult = {D_imm16, 16'h0};
            PCp8_SET: D_SetWordResult = D_PCp8; 
            default: D_SetWordResult = 32'hx;
        endcase
    end
    

endmodule