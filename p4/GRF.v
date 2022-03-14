module GRF (
    input clk,
    input reset,
    input RegWrite,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] RegData,
	input [31:0] PC,
    output [31:0] RD1,
    output [31:0] RD2);

    reg [31:0] grf [31:0];
    integer i, handle;

    assign RD1 = grf[A1];
    assign RD2 = grf[A2];

    initial begin
		for (i = 0; i < 32; i = i + 1)
			grf[i] = 32'd0;
		//handle = $fopen("out.txt", "w");
	  end

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
			    grf[i] <= 32'd0;
        end
        else begin
            if (RegWrite) begin
                if (A3 == 5'd0) begin
                    grf[A3] <= 32'd0;
                end
                else begin
                    grf[A3] <= RegData;
						  $display("@%h: $%d <= %h", PC, A3, RegData);
						  //$fdisplay(handle, "@%h: $%d <= %h", PC, A3, RegData);
                end
                
            end
            else begin
                grf[A3] <= grf[A3];
            end
        end
    end
    
    

endmodule