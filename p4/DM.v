`define dmhalf dm[addr][15+16*A[1]-:16]
`define dmbyte dm[addr][7+8*A[1:0]-:8]

module DM (
    input [31:0] A,
    input [31:0] MemData,
    input clk,
    input MemWrite,
	 input [2:0] MemDataType,
    input reset,
    input [31:0] PC,
    output reg [31:0] RD);

    parameter DM_SIZE = 1024;
	 parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010;
	 reg [31:0] dm [DM_SIZE-1: 0];
    integer i;
    wire [9:0] addr;
	 
	 initial begin
		for (i = 0; i < DM_SIZE; i = i + 1)
			    dm[i] = 32'd0;
	  end

	
	assign addr = A[11:2];
	always @(*) begin
		case(MemDataType) 
			WORD_TYPE: RD = dm[addr];
			HALF_TYPE: RD = {{16{dm[addr][15+16*A[1]]}},`dmhalf};
			BYTE_TYPE: RD = {{24{dm[addr][7+8*A[1:0]]}}, `dmbyte};
			default: RD = 32'hxxxx_xxxx;
		endcase
	end

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < DM_SIZE; i = i + 1)
			    dm[i] <= 32'd0;
        end
        else begin
            if (MemWrite) begin
               case(MemDataType) 
						WORD_TYPE: dm[addr] <= MemData;
						HALF_TYPE: `dmhalf <= MemData[15:0];
						BYTE_TYPE: `dmbyte <= MemData[7:0];
						default: dm[addr] <= 32'hxxxx_xxxx;
					endcase
	            $display("@%h: *%h <= %h", PC, A, MemData);	
            end
            else begin
                dm[addr] <= dm[addr];
            end
        end
    end

endmodule