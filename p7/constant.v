`define LB_OP 	    6'b100000
`define LBU_OP      6'b100100
`define LH_OP	    6'b100001
`define LHU_OP      6'b100101
`define LW_OP	    6'b100011
`define SB_OP	    6'b101000
`define SH_OP	    6'b101001
`define SW_OP	    6'b101011

`define ADDI_OP	    6'b001000
`define ADDIU_OP	6'b001001
`define ANDI_OP	    6'b001100
`define ORI_OP		6'b001101
`define XORI_OP	    6'b001110
`define LUI_OP		6'b001111

`define SLTI_OP	    6'b001010
`define SLTIU_OP	6'b001011

`define BEQ_OP		6'b000100
`define BNE_OP		6'b000101
`define BLEZ_OP	    6'b000110
`define BGTZ_OP	    6'b000111
`define BLTZ_OP	    6'b000001
`define BGEZ_OP	    6'b000001

`define J_OP		6'b000010
`define JAL_OP		6'b000011

`define R_OP        6'b000000
`define BGEZAL_OP   6'b000001
`define BONALL_OP   6'b101010
`define MTC0_OP     6'b010000
`define MFC0_OP     6'b010000
`define ERET_OP     6'b010000


////////////////////////////////////////////////
`define ADD_FUNC    6'b100000
`define ADDU_FUNC   6'b100001
`define SUB_FUNC    6'b100010
`define SUBU_FUNC   6'b100011

`define MULT_FUNC	    6'b011000
`define MULTU_FUNC	    6'b011001
`define	DIV_FUNC		6'b011010
`define DIVU_FUNC	    6'b011011
`define MFHI_FUNC	    6'b010000
`define MFLO_FUNC	    6'b010010
`define MTHI_FUNC	    6'b010001
`define MTLO_FUNC       6'b010011

`define SLL_FUNC		6'b000000
`define SRL_FUNC		6'b000010
`define SRA_FUNC       6'b000011
`define SLLV_FUNC	    6'b000100
`define SRLV_FUNC	    6'b000110
`define SRAV_FUNC	    6'b000111

`define AND_FUNC    6'b100100
`define OR_FUNC     6'b100101
`define XOR_FUNC	6'b100110
`define NOR_FUNC	6'b100111

`define SLT_FUNC        6'b101010
`define SLTU_FUNC	    6'b101011

`define JALR_FUNC   6'b001001
`define JR_FUNC     6'b001000
`define ERET_FUNC   6'b011000
///////////////////////////////////////////////////////////////
`define BGEZ_RT     5'b00001
`define BLTZ_RT     5'b00000
`define MTC0_RS     5'b00100
`define MFC0_RS     5'b00000
