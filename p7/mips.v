`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:31:27 11/23/2022 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mips(
    input clk,                    // ʱ���ź�
    input reset,                  // ͬ����λ�ź�
    input interrupt,              // �ⲿ�ж��ź�
    output [31:0] macroscopic_pc, // ��� PC

    output [31:0] i_inst_addr,    // IM ��ȡ��ַ��ȡָ PC��
    input  [31:0] i_inst_rdata,   // IM ��ȡ����

    output [31:0] m_data_addr,    // DM ��д��ַ
    input  [31:0] m_data_rdata,   // DM ��ȡ����
    output [31:0] m_data_wdata,   // DM ��д������
    output [3 :0] m_data_byteen,  // DM �ֽ�ʹ���ź�

    output [31:0] m_int_addr,     // �жϷ�������д���ַ
    output [3 :0] m_int_byteen,   // �жϷ������ֽ�ʹ���ź�

    output [31:0] m_inst_addr,    // M �� PC

    output w_grf_we,              // GRF дʹ���ź�
    output [4 :0] w_grf_addr,     // GRF ��д��Ĵ������
    output [31:0] w_grf_wdata,    // GRF ��д������

    output [31:0] w_inst_addr     // W �� PC
    );
	 
	 wire [5:0] HWInt;        // CPU �ⲿ�ж��ź�
	 wire TC1_IRQ, TC0_IRQ;   // Time1,Time0 �ж��ź�
	 wire TC0_WE, TC1_WE;     // Time0,TIme1 ʹ��
	 wire [31:0] TC0out;      // Time0 ��������
	 wire [31:0] TC1out;      // Time1 ��������
	 wire [3:0] CPU_byteen;   // CPU �������д�ֽ�ʹ��
	 wire [31:0] PrAddr;      // CPU ���������ַ
	 wire [31:0] PrRD;        // ���贫�ݸ� CPU ����
	 wire [31:0] PrWD;        // CPU д�����������
	 wire [31:0] DevAddr;     // ����д���ַ
	 wire [31:0] DevWD;       // ����д������
	 

///////////// Signs /////////
	 assign HWInt = {3'b000, interrupt, TC1_IRQ, TC0_IRQ};
	 assign m_data_wdata = DevWD;
	 assign m_data_addr = DevAddr;
	 assign m_int_addr = DevAddr;
	 
	 
///////////// PipleLine CPU /////////////////	
    CPU cpu (
    .clk(clk), 
    .reset(reset), 
    .i_inst_rdata(i_inst_rdata), 
    .m_data_rdata(PrRD), 
    .HWInt(HWInt), 
	 .MacroPC(macroscopic_pc),
    .i_inst_addr(i_inst_addr), 
    .m_data_addr(PrAddr), 
    .m_data_wdata(PrWD), 
    .m_data_byteen(CPU_byteen), 
    .m_inst_addr(m_inst_addr), 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr)
    );

////////// Bridge ////////////// 
    Bridge bridge (
    .PrAddr(PrAddr), 
    .PrWD(PrWD), 
    .byteen(CPU_byteen), 
    .PrRD(PrRD), 
    .DevAddr(DevAddr), 
    .DevWD(DevWD), 
    .m_int_byteen(m_int_byteen), 
    .m_data_byteen(m_data_byteen), 
    .m_data_rdata(m_data_rdata), 
    .TC0_WE(TC0_WE), 
    .TC0RD(TC0out), 
    .TC1_WE(TC1_WE), 
    .TC1RD(TC1out)
    );
	 
//////////// Time0 //////////////	 
	 TC TC0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr[31:2]), 
    .WE(TC0_WE), 
    .Din(DevWD), 
    .Dout(TC0out), 
    .IRQ(TC0_IRQ)
    );
	 
//////////// Time1 //////////////
	 TC TC1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(DevAddr[31:2]), 
    .WE(TC1_WE), 
    .Din(DevWD), 
    .Dout(TC1out), 
    .IRQ(TC1_IRQ)
    );
	 
	 

endmodule
