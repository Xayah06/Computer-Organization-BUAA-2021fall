`define Sspace 4'b0000
`define Sb 4'b0001
`define Sbe 4'b0010
`define Sbeg 4'b0011
`define Sbegi 4'b0100
`define Sbegin 4'b0101
`define Se 4'b0110
`define Sen 4'b0111
`define Send 4'b1000
`define Sirr 4'b1001

module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result);

    wire [7:0] loweredIn;
    reg [31:0] cnt;
    reg [3:0] state;
    reg alive;
    reg [3:0] next;
    reg [31:0] cntnext;


    parameter space = " " | 8'd32;

    assign loweredIn =  in | 8'd32 ;

    initial begin
        cnt = 0;
        alive = 1;
        state = `Sspace;
    end
    
    always @(*) begin
        case (state)
            `Sspace: begin
                case (loweredIn) 
                    "b": begin
                        next = `Sb;
                        cntnext = cnt;
                         
                    end
                    "e": begin
                        next = `Se;
                        cntnext = cnt;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sb: begin
                case (loweredIn) 
                    "e": begin
                        next = `Sbe;
                        cntnext = cnt;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sbe: begin
                case (loweredIn) 
                    "g": begin
                        next = `Sbeg;
                        cntnext = cnt;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sbeg: begin
                case (loweredIn) 
                    "i": begin
                        next = `Sbegi;
                        cntnext = cnt;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sbegi: begin
                case (loweredIn) 
                    "n": begin
                        next = `Sbegin;
                        cntnext = cnt + 1;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sbegin: begin
                case (loweredIn) 
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt - 1;
                         
                    end
                endcase
            end
            `Se: begin
                case (loweredIn) 
                    "n": begin
                        next = `Sen;
                        cntnext = cnt;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
            `Sen: begin
                case (loweredIn) 
                    "d": begin
                        next = `Send;
                        cntnext = cnt - 1;
                         
                    end
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                         
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                    end
                endcase
            end
            `Send: begin
                case (loweredIn) 
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt + 1;
                    end
                endcase
            end
            `Sirr: begin
                case (loweredIn) 
                    space: begin
                        next = `Sspace;
                        cntnext = cnt;
                    end
                    default: begin
                        next = `Sirr;
                        cntnext = cnt;
                         
                    end
                endcase
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt = 0;
            alive = 1;
            state = `Sspace;
        end
        else begin
            state <= next;
            cnt <= cntnext;
            if ( cnt[31] && cntnext[31]) begin
                alive <= 0;
            end
        end
    end

    assign result = alive && (cnt == 0);

endmodule