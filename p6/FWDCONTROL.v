module FWDCONTROL(
    input [4:0] D_A1,  
    input [4:0] D_A2, 
    input [4:0] E_A1, 
    input [4:0] E_A2, 
    input [4:0] E_A3, 
    input E_RegWrite, 
    input [4:0] M_A2, 
    input [4:0] M_A3, 
    input M_RegWrite, 
    input [4:0] W_A3, 
    input W_RegWrite,
	output [1:0] D_GRF_rs_ForwardSrc, 
    output [1:0] D_GRF_rt_ForwardSrc, 
    output [1:0] E_GRF_rs_ForwardSrc, 
    output [1:0] E_GRF_rt_ForwardSrc, 
    output [1:0] M_GRF_rt_ForwardSrc);

    assign D_GRF_rs_ForwardSrc = (((D_A1 == E_A3) && (E_A3 != 0)) & E_RegWrite) ? 2 : 
                                 (((D_A1 == M_A3) && (M_A3 != 0)) & M_RegWrite) ? 1 : 0; 
                                 
    assign D_GRF_rt_ForwardSrc = (((D_A2 == E_A3) && (E_A3 != 0)) & E_RegWrite) ? 2 : 
                                 (((D_A2 == M_A3) && (M_A3 != 0)) & M_RegWrite) ? 1 : 0; 

    assign E_GRF_rs_ForwardSrc = (((E_A1 == M_A3) && (M_A3 != 0)) & M_RegWrite) ? 2 : 
                                 (((E_A1 == W_A3) && (W_A3 != 0)) & W_RegWrite) ? 1 : 0; 

    assign E_GRF_rt_ForwardSrc = (((E_A2 == M_A3) && (M_A3 != 0)) & M_RegWrite) ? 2 : 
                                 (((E_A2 == W_A3) && (W_A3 != 0)) & W_RegWrite) ? 1 : 0; 

    assign M_GRF_rt_ForwardSrc = (((M_A2 == W_A3) && (W_A3 != 0)) & W_RegWrite) ? 1 : 0; 

    

endmodule