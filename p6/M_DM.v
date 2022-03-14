module M_DM (
    input [31:0] A,
    input [31:0] M_MemData,
    input [2:0] M_MemDataType,
    input [31:0] m_data_rdata,
    input [31:0] FWD_M_GRF_rt,
    input [31:0] M_PC,
    input [31:0] M_instr,
    input M_MemWrite,
    output reg [31:0] m_data_wdata,
    output reg [31:0] M_DMRD,
    output reg [3:0] m_data_byteen,
    output [4:0] M_DM_RegAddr);

    assign M_DM_RegAddr = 4'bx;

    parameter WORD_TYPE = 3'b000, HALF_TYPE = 3'b001, BYTE_TYPE = 3'b010, UHALF_TYPE = 3'b011, UBYTE_TYPE = 3'b100;
    

    always @(*) begin
        if (M_MemWrite) begin
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