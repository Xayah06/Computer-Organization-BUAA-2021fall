module string(
    input clk,
    input clr,
    input [7:0] in,
    output out);

    reg [1:0] state;
    reg [1:0] next;
    wire [1:0] type;

    assign type = (("0" <= in) && (in <= "9")) ? 2'b01 :
                  (("+" == in) || (in == "*")) ? 2'b10 :
                  2'b00;

    initial begin
        state = 2'b00;
    end


    always @(*) begin
        case (state)
            2'b00: begin
                case (type)
                    2'b01: next = 2'b01;
                    default: next = 2'b11;
                endcase
            end
            2'b01: begin
                case (type)
                    2'b10: next = 2'b10;
                    default: next = 2'b11;
                endcase
            end    
            2'b10: begin
                case (type)
                    2'b01: next = 2'b01;
                    default: next = 2'b11;
                endcase
            end
            2'b11:
                next = 2'b11;
        endcase
    end

    always @(posedge clk or posedge clr) begin
        if (clr) begin
            state <= 0;
        end
        else begin
            state <= next;
        end
    end

    assign out = (state == 2'b01);

endmodule