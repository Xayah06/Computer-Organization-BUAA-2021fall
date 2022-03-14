`include "constant.v"
module M_DM (
    input [31:0] A,
    input [31:0] M_MemData,
    input [2:0] M_MemDataType,
    input [31:0] m_data_rdata,
    input [31:0] FWD_M_GRF_rt,
    input [31:0] M_PC,
    input [31:0] M_instr,
    input [4:0] M_ExcCode,
    input M_MemWrite,
    input IntReq,
    output reg [31:0] m_data_wdata,
    output reg [31:0] M_DMRD,
    output reg [3:0] m_data_byteen,
    output [4:0] CP0_ExcCode,
    output [4:0] M_DM_RegAddr);


    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010, UHALF_TYPE = 3'b011, UBYTE_TYPE = 3'b100, NONE_TYPE = 3'b111;
    parameter AdEL_EXC = 5'd4, AdES_EXC = 5'd5, RI_EXC = 5'd10, Ov_EXC = 5'd12;


    wire lw_i, sw_i, lh_i, lhu_i, sh_i, lb_i, lbu_i, sb_i;
    wire Err_load_align4_n, Err_load_align2_n, Err_store_align4_n, Err_store_align2_n;
    wire Err_load_Timer, Err_store_Timer, Err_load_out, Err_store_out, Err_store_count;
    wire [5:0] M_opcode;
    wire [4:0] M_DM_ExcCode;
    assign M_opcode = M_instr[31:26];

    assign lb_i = (M_opcode == `LB_OP);
    assign lbu_i = (M_opcode == `LBU_OP);
    assign lh_i = (M_opcode == `LH_OP);
    assign lhu_i = (M_opcode == `LHU_OP);
    assign lw_i = (M_opcode == `LW_OP);
    assign sb_i = (M_opcode == `SB_OP);
    assign sh_i = (M_opcode == `SH_OP);
    assign sw_i = (M_opcode == `SW_OP);

    assign Err_load_align4_n = (A[1] | A[0]) & lw_i;
    assign Err_load_align2_n = A[0] & (lh_i | lhu_i);
    assign Err_load_Timer = (lh_i | lhu_i | lb_i | lbu_i) & (A <= 32'h00007f1b) & (A >= 32'h00007f00);
    assign Err_load_out = (lw_i | lh_i | lhu_i | lb_i | lbu_i) & (!(((A >= 32'h0) & (A <= 32'h00002fff)) |
                           ((A >= 32'h00007f00) & (A <= 32'h00007f0b)) |
                           ((A >= 32'h00007f10) & (A <= 32'h00007f1b))));
    assign Err_store_align4_n = (A[1] | A[0]) & sw_i;
    assign Err_store_align2_n = A[0] & sh_i;
    assign Err_store_Timer = (sh_i | sb_i) & (A <= 32'h00007f1b) & (A >= 32'h00007f00);
    assign Err_store_out = (sw_i | sh_i | sb_i) & (!(((A >= 32'h0) & (A <= 32'h00002fff)) |
                           ((A >= 32'h00007f00) & (A <= 32'h00007f0b)) |
                           ((A >= 32'h00007f10) & (A <= 32'h00007f1b))));
    assign Err_store_count = (sw_i | sh_i | sb_i) & ((A >= 32'h0000_7f08 & A <= 32'h0000_7f0b) | (A >= 32'h0000_7f18 & A <= 32'h0000_7f1b));
    
    
    assign M_DM_ExcCode = (Err_load_align4_n | Err_load_align2_n | Err_load_Timer | Err_load_out) ? AdEL_EXC :
                          (Err_store_align4_n | Err_store_align2_n | Err_store_Timer | Err_store_count | Err_store_out) ? AdES_EXC : 5'h0;

    assign CP0_ExcCode = (M_DM_ExcCode == 0) ? M_ExcCode : M_DM_ExcCode;

    
    

    always @(*) begin
        if (M_MemWrite & !IntReq) begin
            case (M_MemDataType)
					WORD_TYPE: begin
						 m_data_byteen = 4'b1111;
					end
					HALF_TYPE: begin
						 case (A[1])
							  1'b0: begin
									m_data_byteen = 4'b0011;
							  end
							  1'b1: begin
									m_data_byteen = 4'b1100;
							  end
							  default: begin
									m_data_byteen = 4'hx;
							  end
						 endcase
					end
					BYTE_TYPE: begin
						 case (A[1:0])
							  2'b00: begin
									m_data_byteen = 4'b0001;
							  end
							  2'b01: begin
									m_data_byteen = 4'b0010;
							  end
							  2'b10: begin
									m_data_byteen = 4'b0100;
							  end
							  2'b11: begin
									m_data_byteen = 4'b1000;
							  end
							  default: begin
									m_data_byteen = 4'hx;
							  end
						 endcase
					end
					default: m_data_byteen = 4'hx;
			  endcase
        end
        else begin
            m_data_byteen = 4'b0000;
        end
    end
    always @(*) begin
        case (M_MemDataType)
            WORD_TYPE: begin
                m_data_wdata = FWD_M_GRF_rt;
            end
            HALF_TYPE: begin
                case (A[1])
                    1'b0: begin
                        m_data_wdata = {16'h0, FWD_M_GRF_rt[15:0]};
                    end
                    1'b1: begin
                        m_data_wdata = {FWD_M_GRF_rt[15:0], 16'h0};
                    end
                    default: begin
                        m_data_wdata = 32'hx;
                    end
                endcase
            end
            BYTE_TYPE: begin
                case (A[1:0])
                    2'b00: begin
                        m_data_wdata = {24'h0, FWD_M_GRF_rt[7:0]};
                    end
                    2'b01: begin
                        m_data_wdata = {16'h0, FWD_M_GRF_rt[7:0], 8'h0};
                    end
                    2'b10: begin
                        m_data_wdata = {8'h0, FWD_M_GRF_rt[7:0], 16'h0};
                    end
                    2'b11: begin
                        m_data_wdata = {FWD_M_GRF_rt[7:0], 24'h0};
                    end
                    default: begin
                        m_data_wdata = 32'hx;
                    end
                endcase
            end
            default: m_data_wdata = 32'hx;
        endcase
    end

    always @(*) begin
        case (M_MemDataType)
            WORD_TYPE: begin
                M_DMRD = m_data_rdata;
            end
            HALF_TYPE: begin
                case (A[1])
                    1'b0: M_DMRD = {{16{m_data_rdata[15]}}, m_data_rdata[15:0]};
                    1'b1: M_DMRD = {{16{m_data_rdata[31]}}, m_data_rdata[31:16]};
                    default: M_DMRD = 32'hx;
                endcase
            end
            UHALF_TYPE: begin
                case (A[1])
                    1'b0: M_DMRD = {16'h0, m_data_rdata[15:0]};
                    1'b1: M_DMRD = {16'h0, m_data_rdata[31:16]};
                    default: M_DMRD = 32'hx;
                endcase
            end
            BYTE_TYPE: begin
                case (A[1:0])
                    2'b00: M_DMRD = {{24{m_data_rdata[7]}}, m_data_rdata[7:0]};
                    2'b01: M_DMRD = {{24{m_data_rdata[15]}}, m_data_rdata[15:8]};
                    2'b10: M_DMRD = {{24{m_data_rdata[23]}}, m_data_rdata[23:16]};
                    2'b11: M_DMRD = {{24{m_data_rdata[31]}}, m_data_rdata[31:24]};
                    default: M_DMRD = 32'hx;
                endcase
            end
            UBYTE_TYPE: begin
                case (A[1:0])
                    2'b00: M_DMRD = {24'h0, m_data_rdata[7:0]};
                    2'b01: M_DMRD = {24'h0, m_data_rdata[15:8]};
                    2'b10: M_DMRD = {24'h0, m_data_rdata[23:16]};
                    2'b11: M_DMRD = {24'h0, m_data_rdata[31:24]};
                    default: M_DMRD = 32'hx;
                endcase
            end
            default: M_DMRD = 32'hx;
        endcase
    end
    
endmodule