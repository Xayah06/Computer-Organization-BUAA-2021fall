module CP0 (
    input clk,
    input reset,
    input [4:0] A1,
    input [4:0] A2,
    input [31:0] Din,
    input [31:0] M_PC,
    input [6:2] CP0_ExcCode,
    input [5:0] HWInt,
    input M_CP0Write,
    input M_EXLClr,
    input M_isdb,
    output IntReq,
    output [31:0] fixed_EPC,
    output reg [31:0] DOut,
    output reg responseInt);

    reg [31:0] EPC, PRID;
    reg [15:10] IM, IP;
    reg [6:2] ExcCode;
    reg EXL, IE, BD;
    wire [31:0] SR, Cause, next_EPC;
    wire IReq, EReq;

    assign SR = {16'h0, IM[15:10], 8'h0, EXL, IE};
    assign Cause = {BD, 15'h0, IP[15:10], 3'h0, ExcCode[6:2], 2'h0};
    assign fixed_EPC = EPC;

    assign IReq = (|(HWInt & IM)) & IE & !EXL;  
    assign EReq = !EXL & (|CP0_ExcCode);
    assign IntReq = IReq | EReq;
    assign next_responseInt = HWInt[2] & IM[12] & IE & !EXL;  
    assign next_EPC = (IntReq) ? (M_isdb ? M_PC-4 : M_PC) : EPC;

    initial begin
        {IM, EXL, IE} <= 8'h0;
        {BD, IP, ExcCode} <= 12'h0;
        EPC <= 32'h0;
        PRID <= "IloveCO!";
        responseInt <= 1'b0;
    end
    
    always @(*) begin
        case (A1)
            5'd12: DOut = SR;
            5'd13: DOut = Cause;
            5'd14: DOut = EPC;
            5'd15: DOut = PRID; 
            default: DOut = 0;
        endcase
    end

    always @(posedge clk) begin// reset ?
        if (reset) begin
            {IM, EXL, IE} <= 8'h0;
            {BD, IP, ExcCode} <= 12'h0;
            EPC <= 32'h0;
            PRID <= "IloveCO!";
            responseInt <= 1'b0;
        end
        else begin
            IP <= HWInt;
            PRID <= PRID;
            responseInt <= next_responseInt;
            if (IntReq) begin               // error or interrupt
                {IM, EXL, IE} <= {IM, 1'b1, IE};
                BD <= M_isdb;
                ExcCode <= IReq ? 5'h0 : CP0_ExcCode;
                EPC <= next_EPC;
            end
            else if (M_EXLClr) begin          // eret
                {IM, EXL, IE} <= {IM, 1'b0, IE};
                {BD, ExcCode} <= {BD, ExcCode};
                EPC <= EPC;
            end
            else if (M_CP0Write) begin      // mtc0
                    {BD, ExcCode} <= {BD, ExcCode};
                case (A2)
                    5'd12: begin
                        {IM, EXL, IE} <= {Din[15:10], Din[1], Din[0]};
                        EPC <= EPC;
                    end
                    5'd14: begin
                        {IM, EXL, IE} <= {IM, EXL, IE};
                        EPC <= Din;
                    end
                    default: begin
                        {IM, EXL, IE} <= {IM, EXL, IE};
                        EPC <= EPC;
                    end
                endcase
            end
            else begin
                {IM, EXL, IE} <= {IM, EXL, IE};
                {BD, ExcCode} <= {BD, ExcCode};
                EPC <= EPC;
            end
        end
    end

    
endmodule