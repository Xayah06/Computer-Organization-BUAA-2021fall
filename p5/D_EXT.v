module D_EXT(
    input [15:0] D_imm16,
    input D_EXTOp,
    output reg [31:0] D_imm32);

    always @(*) begin
        if (D_EXTOp == 0)    D_imm32 = {{16{D_imm16[15]}}, D_imm16} ;
        else                D_imm32 = {{16'd0}, D_imm16} ;
    end
    

endmodule