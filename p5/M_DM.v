`define dmhalf dm[addr][15+16*A[1]-:16]
`define dmbyte dm[addr][7+8*A[1:0]-:8]

module M_DM (
    input [31:0] A,
    input [31:0] M_MemData,
    input clk,
    input M_MemWrite,
	input [2:0] M_MemDataType,
    input reset,
    input [31:0] M_PC,
	output M_DM_RegAddrSel,
    output reg [31:0] M_RD);

    parameter DM_SIZE = 3072;
    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010, UHALF_TYPE = 3'b011, UBYTE_TYPE = 3'b100;
	 reg [31:0] dm [DM_SIZE-1: 0];
    integer i;
    wire [11:0] addr;
	 
	 initial begin
		for (i = 0; i < DM_SIZE; i = i + 1)
			    dm[i] = 32'd0;
	  end

	
	assign addr = A[13:2];
	always @(*) begin
		case(M_MemDataType) 
			WORD_TYPE: M_RD = dm[addr];
			HALF_TYPE: M_RD = {{16{dm[addr][15+16*A[1]]}},`dmhalf};
			BYTE_TYPE: M_RD = {{24{dm[addr][7+8*A[1:0]]}}, `dmbyte};
			UHALF_TYPE: M_RD = {16'h0,`dmhalf};
			UBYTE_TYPE: M_RD = {24'h0, `dmbyte};
			default: M_RD = 32'hxxxx_xxxx;
		endcase
	end

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < DM_SIZE; i = i + 1)
			    dm[i] <= 32'd0;
        end
        else begin
            if (M_MemWrite) begin
               case(M_MemDataType) 
						WORD_TYPE: dm[addr] <= M_MemData;
						HALF_TYPE: `dmhalf <= M_MemData[15:0];
						BYTE_TYPE: `dmbyte <= M_MemData[7:0];
						default: dm[addr] <= 32'hxxxx_xxxx;
					endcase
					if (addr >= 3072) begin
						$display("A = %h, addr = %d", A, addr);
					end
					else begin
						$display("%d@%h: *%h <= %h", $time, M_PC, A, M_MemData);	
						//$display("@%h: *%h <= %h", M_PC, A, M_MemData);
					end	
            end
            else begin
                dm[addr] <= dm[addr];
            end
        end
    end

endmodule