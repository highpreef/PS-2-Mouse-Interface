`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.01.2021 13:39:25
// Design Name: 
// Module Name: Seg7Wrapper
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


module Seg7Wrapper(
    input CLK,
    input [3:0] DIGIT0, DIGIT1, DIGIT2, DIGIT3,
    output [7:0] LED_OUT,
    output [3:0] SEG_SELECT
    );
    
    wire Bit17TrigOut;
    wire [1:0] StrobeCount;
    wire [3:0] MuxOut;
    
    //The 17 bit counter
    Generic_counter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
        )
        Bit17Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(Bit17TrigOut)
    );
    
    Generic_counter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
        )
        Bit2Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Bit17TrigOut),
        .COUNT(StrobeCount)
    );
    
    Multiplexer_4way Mux (
        .CONTROL(StrobeCount),
        .IN0(DIGIT0),
        .IN1(DIGIT1),
        .IN2(DIGIT2),
        .IN3(DIGIT3),
        .OUT(MuxOut)
    );
    
    seg7decoder Seg7 (
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut),
        .DOT_IN(1'b0),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(LED_OUT)
    );
    
endmodule
