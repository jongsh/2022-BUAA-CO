`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:39:41 11/25/2022 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
    //// CPU ///
    input [31:0] PrAddr,  // ����д��ַ
    input [31:0] PrWD,    // ����д����
    input [3:0] byteen,   // �ֽ�ʹ���ź�
	 output [31:0] PrRD,   // ��������������
	 
	 //// IO ////
	 output [31:0] DevAddr,  // ����д���ַ��ͨ��
	 output [31:0] DevWD,    // ����д�����ݣ�ͨ��
	 
	 ///// IG /////////
	 output [3:0] m_int_byteen,   // �жϷ������ֽ�ʹ��
	 
	 ///// DM /////
	 output [3:0] m_data_byteen,  // ���ݴ洢���ֽ�ʹ��
	 input [31:0] m_data_rdata,   // ���ݴ洢������������
	 
	 ///// TC0 ////////
	 output TC0_WE,          // TC0 дʹ��
	 input [31:0] TC0RD,     // TC0 ����������
	 
	 ///// TC1 /////
	 output TC1_WE,          // TC1 дʹ��
	 input [31:0] TC1RD             // TC1 ����������
    );
	 
	 wire inDM, inTC0, inTC1, inIG;
	 assign inDM = (PrAddr >= 32'h0 && PrAddr <= 32'h2fff);
	 assign inTC0 = (PrAddr >= 32'h7f00 && PrAddr <= 32'h7f0b);
	 assign inTC1 = (PrAddr >= 32'h7f10 && PrAddr <= 32'h7f1b);
	 assign inIG = (PrAddr >= 32'h7f20 && PrAddr <= 32'h7f23);
	 
	 assign DevAddr = PrAddr;
	 assign DevWD = PrWD;
	 
	 /////// CPU ///////////
	 assign PrRD = (inDM) ? m_data_rdata :
	               (inTC0) ? TC0RD :
						(inTC1) ? TC1RD : 
						          32'd0;
	 
	 
	 /////// IO ////////////////
	 assign m_data_byteen = (inDM) ? byteen : 4'b0000;
	 assign m_int_byteen = (inIG) ? byteen : 4'b0000;
	 assign TC0_WE = (inTC0) ? byteen : 4'b0000;
	 assign TC1_WE = (inTC1) ? byteen : 4'b0000;

endmodule
