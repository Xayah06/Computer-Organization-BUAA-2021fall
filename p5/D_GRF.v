module D_GRF ( // forward inside GRF
    input clk,
    input reset,
    input W_RegWrite,
    input [4:0] D_A1,
    input [4:0] D_A2,
    input [4:0] W_A3,
    input [31:0] W_RegData,
	input [31:0] W_PC,
    output [31:0] D_RD1,
    output [31:0] D_RD2);

    reg [31:0] grf [31:0];
    integer i;

    assign D_RD1 = ((D_A1 == W_A3) && (W_A3 != 0) && W_RegWrite) ? W_RegData : grf[D_A1];
    assign D_RD2 = ((D_A2 == W_A3) && (W_A3 != 0) && W_RegWrite) ? W_RegData : grf[D_A2];

    initial begin
		for (i = 0; i < 32; i = i + 1)
			grf[i] = 32'd0;
	  end

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
			    grf[i] <= 32'd0;
        end
        else begin
            if (W_RegWrite) begin
                if (W_A3 == 5'd0) begin
                    grf[W_A3] <= 32'd0;
                end
                else begin
                    grf[W_A3] <= W_RegData;
						  $display("%d@%h: $%d <= %h", $time, W_PC, W_A3, W_RegData);
						  //$display("@%h: $%d <= %h", W_PC, W_A3, W_RegData);
                end
                
            end
            else begin
                grf[W_A3] <= grf[W_A3];
            end
        end
    end
    
    

endmodule