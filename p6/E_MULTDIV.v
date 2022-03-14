module E_MULTDIV (
    input clk,
    input reset,
    input start,
    input [31:0] A,
    input [31:0] B,
    input [3:0] MULTDIVControl,
    output busy,
    output reg [31:0] HI,
    output reg [31:0] LO);

    parameter MULT_MULTDIV = 4'b0000, MULTU_MULTDIV = 4'b0001, DIV_MULTDIV = 4'b0010, DIVU_MULTDIV = 4'b0011;
    parameter MTHI_MULTDIV = 4'b0100, MTLO_MULTDIV = 4'b0101;

    reg [4:0] busytimeCNT, next_busytimeCNT;
    reg [63:0] result;

    always @(posedge clk) begin
        if (reset) begin
            busytimeCNT <= 5'h0;
            HI <= 32'h0;
            LO <= 32'h0;
        end
        else begin
            busytimeCNT <= next_busytimeCNT;
            HI <= result[63:32];
            LO <= result[31:0];
        end
    end

    always @(*) begin
        case (MULTDIVControl)
            MULT_MULTDIV: begin
                if (start) begin
                    result = $signed(A) * $signed(B);
                    next_busytimeCNT = 5;
                end
                else begin
                    result = result;
                    if (busytimeCNT == 5'h0) begin
                        next_busytimeCNT = 5'h0;
                    end
                    else begin
                        next_busytimeCNT = busytimeCNT - 1;
                    end
                end
            end
            MULTU_MULTDIV: begin
                if (start) begin
                    result = A * B;
                    next_busytimeCNT = 5;
                end
                else begin
                    result = result;
                    if (busytimeCNT == 5'h0) begin
                        next_busytimeCNT = 5'h0;
                    end
                    else begin
                        next_busytimeCNT = busytimeCNT - 1;
                    end
                end
            end
            DIV_MULTDIV: begin
                if (start) begin
                    result[63:32] = $signed(A) % $signed(B);
                    result[31:0] = $signed(A) / $signed(B);
                    next_busytimeCNT = 10;
                end
                else begin
                    result = result;
                    if (busytimeCNT == 5'h0) begin
                        next_busytimeCNT = 5'h0;
                    end
                    else begin
                        next_busytimeCNT = busytimeCNT - 1;
                    end
                end
            end
            DIVU_MULTDIV: begin
                if (start) begin
                    result[63:32] = A % B;
                    result[31:0] = A / B;
                    next_busytimeCNT = 10;
                end
                else begin
                    result = result;
                    if (busytimeCNT == 5'h0) begin
                        next_busytimeCNT = 5'h0;
                    end
                    else begin
                        next_busytimeCNT = busytimeCNT - 1;
                    end
                end
            end
            MTHI_MULTDIV: begin
                result = {A, LO};
                next_busytimeCNT = 0;
            end
            MTLO_MULTDIV: begin
                result = {HI, A};
                next_busytimeCNT = 0;
            end
            default: begin
                result = {HI, LO};
                if (busytimeCNT == 5'h0) begin
                    next_busytimeCNT = 5'h0;
                end
                else begin
                    next_busytimeCNT = busytimeCNT - 1;
                end
            end
        endcase
    end

    assign busy = (busytimeCNT != 0);

    // solution1 result <= {HI, LO} + $signed($signed(64'd0) + $signed(A) * $signed(B));
    // solution2 result <= {HI, LO} + $signed($signed({{32{A[31]}}, A[31]}) * $signed({{32{B[31]}}, B[31]}));
    // solution3 result <= $sigend({HI, LO}) + $signed(A) * $signed(B);
    // signedness 
endmodule