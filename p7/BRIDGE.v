module BRIDGE (
    input [31:0] PrAddr,
    input [31:0] IMRD,
    input [31:0] DMRD,
    input [31:0] TC0RD,
    input [31:0] TC1RD,
    input [3:0] cpu_m_data_byteen,
    input IRQ0,
    input IRQ1,
    input interrupt,
    output [3:0] bridge_m_data_byteen,
    output TC0Write,
    output TC1Write,
    output [5:0] HWInt,
    output [31:0] PrRD);

    wire selDM, selTC0, selTC1;

    assign selIM = (PrAddr >= 32'h0000_3000) && (PrAddr <= 32'h0000_6fff);
    assign selDM = (PrAddr >= 32'h0000_0000) && (PrAddr <= 32'h0000_2fff);
    assign selTC0 = (PrAddr >= 32'h0000_7f00) && (PrAddr <= 32'h0000_7f0b);
    assign selTC1 = (PrAddr >= 32'h0000_7f10) && (PrAddr <= 32'h0000_7f1b);

    assign PrRD = selIM ? IMRD :
                  selDM ? DMRD :
                  selTC0 ? TC0RD :
                  selTC1 ? TC1RD : 0;

    assign HWInt = {3'b0, interrupt, IRQ1, IRQ0};

    assign bridge_m_data_byteen = selDM ? cpu_m_data_byteen : 4'h0;
    assign TC0Write = selTC0 & (|cpu_m_data_byteen);
    assign TC1Write = selTC1 & (|cpu_m_data_byteen);

    
    
endmodule
