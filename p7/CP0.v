`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:40:53 11/23/2022 
// Design Name: 
// Module Name:    CP0 
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
`define IM SR[15:10]                // ��Ӧ�����ж�λ��ʹ�ܶ�
`define EXL SR[1]                   // �����κ��쳣ʱ��λ1������ֹ�ж�    
`define IE SR[0]                    // ȫ���ж�ʹ�ܣ��� 1 ��ʾ�����жϣ��� 0 ��ʾ��ֹ�ж�
`define BD Cause[31]                // �ӳٲ۱�־
`define IP Cause[15:10]             // 6 λ�������ж�λ���ֱ��Ӧ 6 ���ⲿ�жϣ���Ӧλ�� 1 ��ʾ���жϣ��� 0 ��ʾ���ж�
`define ExcCode Cause[6:2]          // �쳣����

module CP0(
    input clk,
    input reset,
    input CP0_write,
    input [4:0] CP0_addr,
    input [31:0] CP0_in,     // CP0��д������
    input [31:0] EPC_in,     // �ܺ�ָ���ַ
    input BD_in,             // ����ܺ�ָ���Ƿ����ӳٲ�ָ��
    input [4:0] ExcCodeIn,   // ��¼�ж��쳣����
    input [5:0] HWInt,       // �ж��ź�
    input EXL_clr,           // EXL ��λ�ź�
    output [31:0] CP0_out,   
    output [31:0] EPC_out,   
    output Req               // �жϴ����ź�
    );
	      
	 reg [31:0] SR;
	 reg [31:0] Cause;
	 reg [31:0] EPC;
	 
	 wire interrupt, exception;


////////////////////// Read CP0 Reg Data////////////////////////////
    assign CP0_out = (CP0_addr == 5'd12) ? SR :
	                  (CP0_addr == 5'd13) ? Cause :
							(CP0_addr == 5'd14) ? EPC :
							                      32'd0;
														 
	 assign  EPC_out = EPC;
	 
///////////////////// �ж��ж��쳣////////////////////////////////////
	 assign interrupt = (((HWInt & `IM) != 6'd0) && (`EXL === 1'b0) && (`IE === 1'b1));
	 assign exception = (ExcCodeIn != 5'd0) ? 1'b1 : 1'b0;
	 assign Req = interrupt | exception;
	 
	 
//////////////////// updata CP0 ///////////////
    
	 always @(posedge clk) begin
	     if (reset == 1'b1) begin
		      EPC <= 32'd0;
				SR <= 32'd0;
				Cause <= 32'd0;
		  end else begin
		      if (Req == 1'b1) begin
				    `ExcCode <= (interrupt == 1'b1) ? 5'd0 : ExcCodeIn;
					 `EXL <= 1'b1;
					 `BD <= BD_in;
					 EPC <= (BD_in == 1'b1) ? (EPC_in - 32'd4) : EPC_in;
				end
				if (CP0_write == 1'b1) begin
				    case(CP0_addr)
					     5'd12: SR <= CP0_in; 
						  5'd13: Cause <= CP0_in;
						  5'd14: EPC <= CP0_in;
					 endcase
				end
				if (EXL_clr == 1'b1) begin
				    `EXL <= 1'b0;
				end
		      `IP <= HWInt;
		  end
	 end
	 


endmodule
