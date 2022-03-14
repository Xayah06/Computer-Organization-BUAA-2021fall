
module MUX_d32s2(
    input [31:0] d0,
    input [31:0] d1,
    input [31:0] d2,
    input [31:0] d3,
    input [1:0] sel,
    output reg [31:0] result);
    always @(*) begin
        case (sel)
            2'b00: result = d0;
            2'b01: result = d1;
            2'b10: result = d2;
            2'b11: result = d3;
        endcase
    end
endmodule
module MUX_d32s3(
    input [31:0] d0,
    input [31:0] d1,
    input [31:0] d2,
    input [31:0] d3,
    input [31:0] d4,
    input [31:0] d5,
    input [31:0] d6,
    input [31:0] d7,
    input [2:0] sel,
    output reg [31:0] result);
    always @(*) begin
        case (sel)
            3'b000: result = d0;
            3'b001: result = d1;
            3'b010: result = d2;
            3'b011: result = d3;
            3'b100: result = d4;
            3'b101: result = d5;
            3'b110: result = d6;
            3'b111: result = d7;
        endcase
    end
endmodule
module MUX_d5s2(
    input [4:0] d0,
    input [4:0] d1,
    input [4:0] d2,
    input [4:0] d3,
    input [1:0] sel,
    output reg [4:0] result);
    always @(*) begin
        case (sel)
            2'b00: result = d0;
            2'b01: result = d1;
            2'b10: result = d2;
            2'b11: result = d3;
        endcase
    end
endmodule
module MUX_d32s1(
    input [31:0] d0,
    input [31:0] d1,
    input [0:0] sel,
    output reg [31:0] result);
    always @(*) begin
        case (sel)
            1'b0: result = d0;
            1'b1: result = d1;
        endcase
    end
endmodule
