`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2022 21:41:56
// Design Name: 
// Module Name: TB_MatrixInverter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TB_MatrixInverter;

reg clk,rst;
reg [3:0] order;
reg [15:0] matrix_data;
wire [15:0] inverted_matrix_data;
wire ready,invertible;


Matrix_Inverter     MatInv1(
   clk,rst, order, matrix_data,
    inverted_matrix_data, ready, invertible);
    
    initial
    begin
    clk=1'b0;
    rst=1'b0;
    order=4'd3;
    matrix_data=16'd0;
    #20 
    rst=1'b1;
    #10 matrix_data=16'd1;
    #10 matrix_data=-16'd2;
    #10 matrix_data=16'd3;
    #10 matrix_data=16'd2;
    #10 matrix_data=-16'd5;
    #10 matrix_data=16'd10;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd1;
    
    @ (ready)
    #300 $finish;
    
    end
    
    always 
    #5 clk=~clk;
    
    
    
    
endmodule