module EXT(
    input [15:0] imm,
    input EXTOp,
    output reg [31:0] extended_imm);

    always @(*) begin
        if (EXTOp == 0)     extended_imm = {{16{imm[15]}}, imm} ;
        else                extended_imm = {{16'd0}, imm} ;
    end
    

endmodule