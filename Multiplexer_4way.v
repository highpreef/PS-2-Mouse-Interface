`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 20.01.2021 13:16:30
// Design Name: Mouse Interface
// Module Name: Multiplexer_4way
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: This module acts as a 4 input multiplexer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Reused code from last year's lab.
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiplexer_4way(
    input [1:0] CONTROL,
    input [3:0] IN0,
    input [3:0] IN1,
    input [3:0] IN2,
    input [3:0] IN3,
    output reg [3:0] OUT
    );
    
    always@(CONTROL or IN0 or IN1 or IN2 or IN3) begin
        case(CONTROL)
            2'b00: OUT <= IN0;
            2'b01: OUT <= IN1;
            2'b10: OUT <= IN2;
            2'b11: OUT <= IN3;
            default: OUT <= 4'b0000;
        endcase
    end
endmodule
