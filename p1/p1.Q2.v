module alu(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUOp,
    output [31:0] C);
    
    reg [31:0] ans;
    assign C = ans;

    always @(*) begin
        case (ALUOp)
            3'b000:
                ans = A + B;
            3'b001:
                ans = A - B;
            3'b010:
                ans = A & B;
            3'b011:
                ans = A | B;
            3'b100:
                ans = A >> B;
            3'b101:
                ans = $signed(A) >>> B;
            default:
                ans = ans;
        endcase
    end
endmodule