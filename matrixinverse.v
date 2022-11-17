`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2022 16:34:33
// Design Name: 
// Module Name: Matrix_Inverter
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


module Matrix_Inverter(
    input clk, input rst, input [3:0] order, input [15:0] matrix_data,
    output [15:0] inverted_matrix_data, output ready, output reg invertible, output reg [2:0] state, output reg [3:0] row_counter, row_counter_2, column_counter
    ,output [15:0] a11,a12,a21,a22);
    reg [15:0] matrix_bed[0:15][0:15];
    reg [15:0] inverse_bed[0:15][0:15];
    //reg [3:0] row_counter, row_counter_2, column_counter;
    reg [2:0] next_state;
    reg [3:0] decr_order;
    wire [15:0] self_factor, zero_factor;
    wire [255:0] matrix_self_row, inverse_self_row, matrix_zero_row, inverse_zero_row, matrix_self_out, inverse_self_out, matrix_zero_out, inverse_zero_out;
    wire [255:0] matrix_subt_result, inverse_subt_result, matrix_divi_result, inverse_divi_result;
    wire [255:0] matrix_dividend, inverse_dividend, matrix_quotient, inverse_quotient;
    
    parameter s_0 = 3'd0, s_input = 3'd1, s_swap_find = 3'd2, s_swap = 3'd3, s_mkzero = 3'd4, s_divide = 3'd5, s_output = 3'd6, s_hlt = 3'd7;
    
    array_multiplier mult1 (zero_factor, matrix_self_row, inverse_self_row, matrix_self_out, inverse_self_out);
    array_multiplier mult2 (self_factor, matrix_zero_row, inverse_zero_row, matrix_zero_out, inverse_zero_out);
    array_subtractor subt1 (matrix_zero_out, inverse_zero_out, matrix_self_out, inverse_self_out, matrix_subt_result, inverse_subt_result);
    array_divider divi1(self_factor, matrix_subt_result, inverse_subt_result, matrix_divi_result, inverse_divi_result);
    array_divider divi2(self_factor, matrix_dividend, inverse_dividend, matrix_quotient, inverse_quotient);
    
    always @(posedge clk)
    begin
        if(state == s_input)
        begin
            matrix_bed[row_counter][column_counter] <= matrix_data;
            inverse_bed[row_counter][column_counter] <= (row_counter == column_counter)?16'd1:16'd0;
        end
    end
 
    assign inverted_matrix_data = inverse_bed[row_counter][column_counter];
    assign a11=matrix_bed[0][0],a12=matrix_bed[0][1],a21=matrix_bed[1][0],a22=matrix_bed[1][1];
    
    always @(posedge clk)
        begin
        if(~rst) invertible <= 1'b0;
        else
            if((state == s_divide)&(row_counter == decr_order))
            begin
                invertible <= 1'b1;
            end
        end
        
        assign ready=((state==s_output)|(state==s_hlt));
        
    
    always @(posedge clk)
        begin
            if(~rst)
            begin
                row_counter <= 4'd0;
                column_counter <= 4'd0; 
                row_counter_2 <= 4'd0;
            end
            else
            begin
                if(state == s_input || state == s_output)
                begin
                    column_counter <= (column_counter == decr_order)?4'd0:(column_counter + 1); 
                    row_counter <= (column_counter == decr_order)?((row_counter == decr_order)?4'd0:(row_counter + 1)):row_counter;
                end
                if(state == s_swap_find)
                begin
                    row_counter_2 <= (matrix_bed[row_counter_2][row_counter])?(row_counter_2):(row_counter_2 + 1);
                end
                if(state == s_swap)
                begin
                    row_counter_2 <= (row_counter==4'd0)?4'd1:4'd0;
                end
                if(state == s_mkzero)
                begin
                    row_counter_2 <= (row_counter_2 == decr_order)?(4'd0):(row_counter_2 == row_counter - 4'd1)?(row_counter_2 + 4'd2):(row_counter_2 + 4'd1);
                end
                if(state == s_divide)
                begin
                    row_counter <= (row_counter == decr_order)?(4'd0):row_counter + 1;
                    row_counter_2<=row_counter + 1;
                end
            end   
        end
        
    always @(posedge clk)
    begin
        if(~rst)
        begin
            state <= s_0;
        end
        else
        begin
            state <= next_state;
        end
    end
    
    always @(*)
    begin
        case(state)
            s_0: next_state = s_input; 
            s_input: next_state = ((row_counter == decr_order) && (column_counter == decr_order))?s_swap_find:s_input;
            s_swap_find: next_state = (matrix_bed[row_counter_2][row_counter] != 16'd0)?s_swap:((row_counter_2 == decr_order)?s_hlt:s_swap_find);
            s_swap: next_state = s_mkzero;
            s_mkzero: next_state = (row_counter_2 == decr_order | (row_counter == decr_order & row_counter_2 == decr_order - 1))?s_divide:s_mkzero;
            s_divide: next_state = (row_counter == decr_order)?s_output:s_swap_find;
            s_output: next_state = ((row_counter == decr_order) && (column_counter == decr_order))?s_hlt:s_output;
            s_hlt: next_state = s_hlt;
            default: next_state = s_0; 
        endcase
    end
   
   genvar k;
   generate
    for(k = 0; k < 16; k = k + 1)
    begin 
        assign matrix_self_row[(255 -16*k):(240 - 16*k)] = matrix_bed[row_counter][k];
        assign matrix_zero_row[(255 -16*k):(240 - 16*k)] = matrix_bed[row_counter_2][k];
        assign inverse_self_row[(255 -16*k):(240 - 16*k)] = inverse_bed[row_counter][k];
        assign inverse_zero_row[(255 -16*k):(240 - 16*k)] = inverse_bed[row_counter_2][k];
        assign matrix_dividend[(255 -16*k):(240 - 16*k)] = matrix_bed[row_counter][k];
        assign inverse_dividend[(255 -16*k):(240 - 16*k)] = inverse_bed[row_counter][k];    
    end
   endgenerate
   
    generate
    for(k = 0; k < 16; k = k + 1)
        begin
            always @(posedge clk)
                begin
                if(state == s_swap)
                begin
                    matrix_bed[row_counter][k] <= matrix_bed[row_counter_2][k];
                    matrix_bed[row_counter_2][k] <= matrix_bed[row_counter][k];
                    inverse_bed[row_counter][k] <= inverse_bed[row_counter_2][k];
                    inverse_bed[row_counter_2][k] <= inverse_bed[row_counter][k];
                end
                if(state == s_mkzero)
                begin         
                    matrix_bed[row_counter_2][k] <= matrix_divi_result[(255 - 16*k):(240 - 16*k)];
                    inverse_bed[row_counter_2][k] <= inverse_divi_result[(255 - 16*k):(240 - 16*k)];
                end
                if(state == s_divide)
                begin
                    matrix_bed[row_counter][k] <= matrix_quotient[(255 - 16*k):(240 - 16*k)];
                    inverse_bed[row_counter][k] <= inverse_quotient[(255 - 16*k):(240 - 16*k)];

                end
            end
        end
    endgenerate

   
   
   always @(posedge clk)
   begin
    decr_order <= (~rst)?(order-1):decr_order;
   end
   
   assign self_factor = matrix_bed[row_counter][row_counter];
   assign zero_factor = matrix_bed[row_counter_2][row_counter];
   
endmodule



















module array_multiplier(input [15:0] constant, input [255:0] matrix_in, inverse_in, output [255:0] matrix_out, inverse_out);
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1)
        begin
            assign matrix_out[(255 - 16*i):(240 - 16*i)] = matrix_in[(255 - 16*i):(240 - 16*i)]*constant;
            assign inverse_out[(255 - 16*i):(240 - 16*i)] = inverse_in[(255 - 16*i):(240 - 16*i)]*constant;
        end
    endgenerate
endmodule

module array_divider(input [15:0] constant, input [255:0] matrix_in, inverse_in, output [255:0] matrix_out, inverse_out);
    genvar j;
    generate
        for(j = 0; j < 16; j = j + 1)
        begin
            single_divider matrix_single_divide(matrix_in[(255 - 16*j):(240 - 16*j)], constant, matrix_out[(255 - 16*j):(240 - 16*j)]);
            single_divider inverse_single_divide(inverse_in[(255 - 16*j):(240 - 16*j)], constant, inverse_out[(255 - 16*j):(240 - 16*j)]);
        end
    endgenerate
endmodule

module array_subtractor(input [255:0] matrix_zero_in, inverse_zero_in, matrix_self_in, inverse_self_in, output [255:0] matrix_out, inverse_out);
    genvar l;
    generate
        for(l = 0; l < 16; l = l + 1)
        begin
            assign matrix_out[(255 - 16*l):(240 - 16*l)] = matrix_zero_in[(255 - 16*l):(240 - 16*l)] - matrix_self_in[(255 - 16*l):(240 - 16*l)];
            assign inverse_out[(255 - 16*l):(240 - 16*l)] = inverse_zero_in[(255 - 16*l):(240 - 16*l)] - inverse_self_in[(255 - 16*l):(240 - 16*l)];
        end
    endgenerate
endmodule

module single_divider(input signed [15:0] dividend, input signed [15:0] divisor, output signed [15:0] quotient);
    assign quotient = dividend/divisor;
endmodule