module gray(
    input Clk,
    input Reset,
    input En,
    output [2:0] Output,
    output reg Overflow);

    reg [2:0] state;
    reg [2:0] next;
    reg onext;

    initial begin
        state = 3'b000;
        Overflow = 1'b0;
    end


    always @(*) begin
        case (state)
            3'b000:begin
                next = 3'b001;
                onext = Overflow;
            end
            3'b001:begin
                next = 3'b011;
                onext = Overflow;
            end
            3'b011:begin
                next = 3'b010;
                onext = Overflow;
            end
            3'b010:begin
                next = 3'b110;
                onext = Overflow;
            end
            3'b110:begin
                next = 3'b111;
                onext = Overflow;
            end
            3'b111:begin
                next = 3'b101;
                onext = Overflow;
            end
            3'b101:begin
                next = 3'b100;
                onext = Overflow;
            end
            3'b100:begin
                next = 3'b000;
                onext = 1'b1;
            end

        endcase
    end

    always @(posedge Clk) begin
        if (Reset) begin
            state <= 3'b000;
            Overflow <= 1'b0;
        end
        else if (En) begin
            state <= next;
            Overflow <= onext;
        end
        else begin
            state <= state;
            Overflow <= Overflow;
        end
    end

    assign Output = state;

endmodule