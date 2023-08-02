`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:42 11/06/2022 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [31:0] ALU_opA,
    input [31:0] ALU_opB,
    input [4:0] ALU_opC,
    input [4:0] ALUop,
    output [31:0] ALU_result
    );
	 
	 wire [31:0] archshift;
	 
	 assign archishift = $signed(ALU_opB) >>> $signed(ALU_opC);
	 
	 // 00000��A+B�� 00001��A-B�� 00010��A��B�� 00011��A��B�� 00100��B�߼�����C; 00101: B�߼�����C; 110: B��������C
	 assign ALU_result = (ALUop == 5'd0) ? (ALU_opA + ALU_opB) :
	                     (ALUop == 5'd1) ? (ALU_opA - ALU_opB) : 
								(ALUop == 5'd2) ? (ALU_opA | ALU_opB) :
								(ALUop == 5'd3) ? (ALU_opA & ALU_opB) :
								(ALUop == 5'd4) ? (ALU_opB >> ALU_opC) :
								(ALUop == 5'd5) ? (ALU_opB << ALU_opC) :
								(ALUop == 5'd6) ? archshift : 32'd0;


endmodule
