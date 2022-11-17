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
wire [2:0] state;
wire [3:0] row_counter, row_counter_2, column_counter;
wire [15:0] a11,a12,a21,a22;
Matrix_Inverter     MatInv1(
   clk,rst, order, matrix_data,
    inverted_matrix_data, ready, invertible, state, row_counter, row_counter_2, column_counter
    ,a11,a12,a21,a22);
    
    initial
    begin
    clk=1'b0;
    rst=1'b0;
    order=4'd3;
    matrix_data=16'd0;
    #20 
    rst=1'b1;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=-16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=-16'd0;
    #10 matrix_data=16'd0;
    #10 matrix_data=16'd0;
    
    @ (ready)
    #300 $finish;
    
    end
    
    always 
    #5 clk=~clk;
    
    
    
    
endmodule