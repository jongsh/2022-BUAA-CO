`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:38:59 10/25/2022 
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
    input clk,
    input reset
    );
	 
	 wire [31:0] PCnext;
	 wire [31:0] PC;
	 wire [25:0] instr_imm26;   // ������imm26
	 wire [15:0] instr_imm16;   // ������imm16
	 wire [5:0] instr_op;       // opcode�ֶ�
	 wire [5:0] instr_func;     // Rָ���func
	 wire [4:0] instr_shamt;    // Rָ����λshamt
	 wire [4:0] instr_rd;       // �Ĵ���rd
	 wire [4:0] instr_rt;       // �Ĵ���rt
	 wire [4:0] instr_rs;       // �Ĵ���rs
	 wire [31:0] regRD1;        // GRF �����ĵ�һ���Ĵ�������
	 wire [31:0] regRD2;        // GRF �����ĵڶ����Ĵ�������
	 wire [31:0] EXTout;        // EXT ������ź�
	 wire [31:0] opA;           // ALU ������A
	 wire [31:0] opB;           // ALU ������B
	 wire CMPresult;            // ALU ����ıȽ��ź�
	 wire [31:0] ALUresult;     // ALU ������
	 wire [11:0] instrAddr;
	 wire [31:0] instr;       // 32 λָ�������
	 wire [4:0] regAddr3;     // GRF ��д���ַ
	 wire [31:0] regWD;       // GRF ��д������
	 wire [11:0] MemAddr;     // DM д���ַ
	 wire [31:0] MemWD;      // DM д������
	 wire [31:0] MemReadData;  // DM ����������
	 // �����ź�
	 wire [1:0] NPCop;       // NPC ���������ź�
	 wire RegWrite;          // GRF дʹ���ź�
	 wire [1:0] RegDst;      // GRF �� regWD ����ѡ���ź�
	 wire [1:0] EXTop;       // EXT �����ź�
	 wire ALUSrc;            // ALU�� operationB ����ѡ���ź� 
	 wire [2:0] ALUop;       // ALU �����ź�
	 wire [2:0] CMPop;      // ALU �Ƚ��ź�
	 wire MemWrite;          // DM дʹ���ź�
	 wire [2:0] DatatoReg;   // GRF ���������
	 
	 assign instr_imm26 = instr[25:0];   // ������imm26
    assign instr_imm16 = instr[15:0];   // ������imm16
    assign instr_func = instr[5:0];     // Rָ���func
    assign instr_op = instr[31:26];     // opcode�ֶ�
    assign instr_shamt = instr[10:6];   // Rָ����λshamt
	 assign instr_rd = instr[15:11];     // �Ĵ���rd
	 assign instr_rt = instr[20:16];     // �Ĵ���rt
	 assign instr_rs = instr[25:21];     // �Ĵ���rs
	 assign instrAddr = PC[13:2];        // ָ���ַ 
	 assign regAddr3 = (RegDst == 2'b00) ? instr_rd :   // GRF д��ַѡ��
	                   (RegDst == 3'b01) ? instr_rt :
							 (RegDst == 3'b10) ? 5'd31 :
							 5'd0;
	 assign regWD = (DatatoReg == 3'b000) ? ALUresult :
	                (DatatoReg == 3'b001) ? MemReadData :
						 (DatatoReg == 3'b010) ? (PC + 32'd4) :
						 (DatatoReg == 3'b011) ? {31'd0,CMPresult} :
						 32'd0;
	 assign MemAddr = ALUresult[13:2];
	 assign MemWD = regRD2;
	 assign opA = regRD1;
	 assign opB = (ALUSrc == 1'b0) ? regRD2 : EXTout;
	 
	 // some output message
	 always @(posedge clk) begin
	     if (reset != 1'b1) begin
		      if (RegWrite == 1'b1) begin
				    $display("@%h: $%d <= %h", PC, regAddr3, regWD);
				end else if (MemWrite == 1'b1) begin
				    $display("@%h: *%h <= %h", PC, ALUresult, MemWD);
				end
		  end
	 end
	 
	 // PC ʵ����
	 PC pc (
    .PCnext(PCnext), 
    .clk(clk), 
    .reset(reset), 
    .PC(PC)
    );
	 // NPC ʵ����
	 NPC npc (
    .imm26(instr_imm26), 
    .imm16(instr_imm16), 
    .regRa(regRD1), 
    .PC(PC), 
    .NPCop(NPCop), 
    .CMPResult(CMPresult), 
    .PCnext(PCnext)
    );
	 // IM ʵ����
	 IM im (
    .instrAddr(instrAddr), 
    .instr(instr)
    );
	 // GRF ʵ����
	 GRF grf (
    .clk(clk), 
    .reset(reset), 
    .GRFWrite(RegWrite), 
    .regAddr1(instr_rs), 
    .regAddr2(instr_rt), 
    .regAddr3(regAddr3), 
    .regWD(regWD), 
    .RD1(regRD1), 
    .RD2(regRD2)
    );
	 // DM ʵ����
	 DM dm (
    .clk(clk), 
    .reset(reset), 
    .MemWrite(MemWrite), 
    .MemAddr(MemAddr), 
    .MemWD(MemWD), 
    .MemReadData(MemReadData)
    );
	 // EXT ʵ����
	 EXT ext (
    .EXTin(instr_imm16), 
    .EXTop(EXTop), 
    .EXTout(EXTout)
    );
	 // ALU ʵ����
	 ALU alu (
    .operationA(opA), 
    .operationB(opB), 
    .shamtC(instr_shamt), 
    .ALUop(ALUop), 
    .CMPop(CMPop), 
    .ALUresult(ALUresult), 
    .CMPresult(CMPresult)
    );
	 // Controller ʵ����
	 Controller controller (
    .instr_op(instr_op), 
    .instr_func(instr_func), 
    .RegWrite(RegWrite), 
    .RegDst(RegDst), 
    .EXTop(EXTop), 
    .NPCop(NPCop), 
    .ALUSrc(ALUSrc), 
    .ALUop(ALUop), 
    .CMPop(CMPop), 
    .MemWrite(MemWrite), 
    .DatatoReg(DatatoReg)
    );
	 

endmodule
