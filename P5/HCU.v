`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:33:18 11/07/2022 
// Design Name: 
// Module Name:    HCU 
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
module HCU(
    input [31:0] D_instr,
    input [31:0] E_instr,
    input [31:0] M_instr,
	 input [3:0] D_rs_Tuse,
	 input [3:0] D_rt_Tuse,
	 input [3:0] E_rs_Tuse,
	 input [3:0] E_rt_Tuse,
	 input [3:0] E_Tnew,
	 input [3:0] M_rt_Tuse,
	 input [3:0] M_Tnew,
	 input [3:0] W_Tnew,
	 input E_GRF_write,
    input M_GRF_write,
	 input W_GRF_write,
    input [4:0] E_GRF_A3,
    input [4:0] M_GRF_A3,
    input [4:0] W_GRF_A3,
	 input [3:0] M_GRF_DatatoReg,
    input [3:0] E_GRF_DatatoReg,
	 input [3:0] W_GRF_DatatoReg,
	 output reg [4:0] D_FW_rs_sel,
	 output reg [4:0] D_FW_rt_sel,
	 output reg [4:0] E_FW_rs_sel,
	 output reg [4:0] E_FW_rt_sel,
	 output reg [4:0] M_FW_rt_sel,
	 output stall,
	 output E_flush
    );
	 
	 wire [4:0] D_rs;
	 wire [4:0] D_rt;
	 wire [4:0] E_rs;
	 wire [4:0] E_rt;
	 wire [4:0] M_rt;
	 assign D_rs = D_instr[25:21];
	 assign D_rt = D_instr[20:16];
	 assign E_rs = E_instr[25:21];
	 assign E_rt = E_instr[20:16];
	 assign M_rt = M_instr[20:16];
	 
	 // �ж�����
	 wire stall_1;
	 wire stall_2;
	 wire stall_3;
	 wire stall_4;
	 assign stall_1 = (D_rs == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0 && D_rs_Tuse < E_Tnew);
	 assign stall_2 = (D_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0 && D_rs_Tuse < M_Tnew);
	 assign stall_3 = (D_rt == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0 && D_rt_Tuse < E_Tnew);
	 assign stall_4 = (D_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0 && D_rt_Tuse < M_Tnew);
	 assign stall = stall_1 || stall_2 || stall_3 || stall_4;
	 assign E_flush = stall;
	 
	 
	 // �ж�D����ˮ
	 always @(*) begin
	     // rs
		  if (D_rs == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0) begin
		      if (E_Tnew == 4'd0) begin  // ת��
					 D_FW_rs_sel = (E_GRF_DatatoReg == 4'd2) ? 5'd1 :
                              (E_GRF_DatatoReg == 4'd3) ? 5'd2 :
                                                          5'd0;										
				end else begin                      // ������ˮ
					 D_FW_rs_sel = 5'd0;
				end
		  end else if (D_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin  // ת��
					 D_FW_rs_sel = (M_GRF_DatatoReg == 4'd2) ? 5'd3 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd5 :
										(M_GRF_DatatoReg == 4'd0) ? 5'd4 :
                                                          5'd0;										
				end else begin                      // ������ˮ
					 D_FW_rs_sel = 5'd0;
				end
		  end else begin
				D_FW_rs_sel = 5'd0;
		  end
		  // rt
		  if (D_rt == E_GRF_A3 && E_GRF_write == 1'b1 && E_GRF_A3 != 5'd0) begin
		      if (E_Tnew == 4'd0) begin  // ת��
					 D_FW_rt_sel = (E_GRF_DatatoReg == 4'd2) ? 5'd1 :
                              (E_GRF_DatatoReg == 4'd3) ? 5'd2 :
                                                          5'd0;										
				end else begin                      // ������ˮ
					 D_FW_rt_sel = 5'd0;
				end
		  end else if (D_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin  // ת��
					 D_FW_rt_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd4 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd3 :
										(M_GRF_DatatoReg == 4'd3) ? 5'd5 : 
                                                          5'd0;										
				end else begin                      // ������ˮ
					 D_FW_rt_sel = 5'd0;
				end
		  end else begin
				D_FW_rt_sel = 5'd0;
		  end
		    
	 end
	 
	 // �ж� E ����ˮ
	 // 00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: W_ALUout; 00101: W_DMout; 00110: W_PC+8; 00111: W_CMP_result
	 always @(*) begin
	     // rs
	     if (E_rs == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin         // ת��
                E_FW_rs_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd1 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd2 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd3 :
                                                          5'd0;										
            end else begin                   // ������ˮ
                E_FW_rs_sel = 5'd0;
            end				
        end else if (E_rs == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin
		      if (W_Tnew == 4'd0) begin      // ת��
				    E_FW_rs_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd4 :
                              (W_GRF_DatatoReg == 4'd1) ? 5'd5 :
                              (W_GRF_DatatoReg == 4'd2) ? 5'd6 : 
                              (W_GRF_DatatoReg == 4'd3) ? 5'd7 :
                                                          5'd0;										
				end else begin                 // ��ˮ
				    E_FW_rs_sel = 5'd0;
				end
		  end else begin
		      E_FW_rs_sel = 5'd0;
		  end
        
		  // rt
		  if (E_rt == M_GRF_A3 && M_GRF_write == 1'b1 && M_GRF_A3 != 5'd0) begin
		      if (M_Tnew == 4'd0) begin         // ת��
                E_FW_rt_sel = (M_GRF_DatatoReg == 4'd0) ? 5'd1 :
                              (M_GRF_DatatoReg == 4'd2) ? 5'd2 :
                              (M_GRF_DatatoReg == 4'd3) ? 5'd3 :
                                                          5'd0;										
            end else begin                   // ������ˮ
                E_FW_rt_sel = 5'd0;
            end				
		  end else if (E_rt == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin
		      if (W_Tnew == 4'd0) begin        // ת��
				    E_FW_rt_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd4 :
					               (W_GRF_DatatoReg == 4'd1) ? 5'd5 :
										(W_GRF_DatatoReg == 4'd2) ? 5'd6 :
										(W_GRF_DatatoReg == 4'd3) ? 5'd7 :
										                            5'd0;
				end
		  end else begin
		      E_FW_rt_sel = 5'd0;
		  end
	 end
	 
	 // �ж� M ����ˮ
    // 00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result
    always @(*) begin
        // rt
		  if (M_rt == W_GRF_A3 && W_GRF_write == 1'b1 && W_GRF_A3 != 5'd0) begin 
		      M_FW_rt_sel = (W_GRF_DatatoReg == 4'd0) ? 5'd1 :
				              (W_GRF_DatatoReg == 4'd1) ? 5'd2 :
								  (W_GRF_DatatoReg == 4'd2) ? 5'd3 :
								  (W_GRF_DatatoReg == 4'd3) ? 5'd4 :
								                              5'd0;
		  end else begin
		      M_FW_rt_sel = 5'd0;
		  end
    end	 

endmodule