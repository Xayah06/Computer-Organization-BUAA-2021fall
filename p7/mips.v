module mips(
    input clk,                       // 时钟信号
    input reset,                     // 同步复位信号
    input interrupt,                 // 外部中断信号
    output [31:0] macroscopic_pc,    // 宏观 PC（见下文�
    output [31:0] i_inst_addr,       // 取指 PC
    input  [31:0] i_inst_rdata,      // i_inst_addr 对应�32 位指�
    output [31:0] m_data_addr,       // 数据存储器待写入地址
    input  [31:0] m_data_rdata,      // m_data_addr 对应�32 位数�    output [31:0] m_data_wdata,      // 数据存储器待写入数据
    output [3 :0] m_data_byteen,     // 字节使能信号
	 output [31:0] m_data_wdata,

    output [31:0] m_inst_addr,       // M 级PC

    output w_grf_we,                 // grf 写使能信�    output [4 :0] w_grf_addr,        // grf 待写入寄存器编号
    output [31:0] w_grf_wdata,       // grf 待写入数�
    output [31:0] w_inst_addr,        // W �PC
	 output [4:0] w_grf_addr
);

    wire [31:0] TC0RD, TC1RD, cpu_m_data_addr, bridge_data_rdata;
    wire [5:0] HWInt;
    wire [3:0] cpu_m_data_byteen, bridge_m_data_byteen;
    wire responseInt, IRQ0, IRQ1, TC0Write, TC1Write;

    assign m_data_addr = (responseInt) ? 32'h0000_7f20 : cpu_m_data_addr;
    assign m_data_byteen = (responseInt) ? 1 : bridge_m_data_byteen;

    CPU cpu(.clk(clk),
            .reset(reset),
            .macroscopic_pc(macroscopic_pc),
            .i_inst_rdata(i_inst_rdata),
            .m_data_rdata(bridge_data_rdata),
            .HWInt(HWInt),
            .i_inst_addr(i_inst_addr),
            .m_data_addr(cpu_m_data_addr),
            .m_data_wdata(m_data_wdata),
            .m_data_byteen(cpu_m_data_byteen),
            .m_inst_addr(m_inst_addr),
            .responseInt(responseInt),
            .w_grf_we(w_grf_we),
            .w_grf_addr(w_grf_addr),
            .w_grf_wdata(w_grf_wdata),
            .w_inst_addr(w_inst_addr));
    
    
    BRIDGE bridge(.PrAddr(m_data_addr),
                  .IMRD(i_inst_rdata),
                  .DMRD(m_data_rdata),
                  .TC0RD(TC0RD),
                  .TC1RD(TC1RD),
                  .cpu_m_data_byteen(cpu_m_data_byteen),
                  .IRQ0(IRQ0),
                  .IRQ1(IRQ1),
                  .interrupt(interrupt),
                  .bridge_m_data_byteen(bridge_m_data_byteen),
                  .TC0Write(TC0Write),
                  .TC1Write(TC1Write),
                  .HWInt(HWInt),
                  .PrRD(bridge_data_rdata));

    TC tc0(.clk(clk),
           .reset(reset),
           .Addr(m_data_addr[31:2]),
           .WE(TC0Write),
           .Din(m_data_wdata),
           .Dout(TC0RD),
           .IRQ(IRQ0));
    
    TC tc1(.clk(clk),
           .reset(reset),
           .Addr(m_data_addr[31:2]),
           .WE(TC1Write),
           .Din(m_data_wdata),
           .Dout(TC1RD),
           .IRQ(IRQ1));

endmodule
