`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 20.01.2021 13:39:25
// Design Name: Mouse Interface
// Module Name: Seg7Wrapper
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: Wrapper for the 7 segment display. Handles I/O for interface with
//              the 7 segment display.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Code was mostly reused from last year's lab.
// 
//////////////////////////////////////////////////////////////////////////////////


module Seg7Wrapper(
    input CLK,
    input [3:0] DIGIT0, DIGIT1, DIGIT2, DIGIT3,
    output [7:0] LED_OUT,
    output [3:0] SEG_SELECT
    );
    
    // Define trigger output, strobe output and mutiplexer output
    wire Bit17TrigOut;
    wire [1:0] StrobeCount;
    wire [3:0] MuxOut;
    
    //Instantiate a 17 bit counter. This will provide a refresh rate of 1kHz for the 7 seg display.
    // (On board clock is 100MHz) 
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
    
    //Instantiate a 2 bit counter. This counter will provide the strobe output to
    // select which of the 4 available 7 segment displays to be currently displayed
    // at a refresh rate of 1kHz (Obtained from the trigger output of the 17 bit counter).
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
    
    // Instantiate a multiplexer. This will output one of the 4 hex digits, corresponding
    // to the mouse coordinates, depending on the strobe output value.
    Multiplexer_4way Mux (
        .CONTROL(StrobeCount),
        .IN0(DIGIT0),
        .IN1(DIGIT1),
        .IN2(DIGIT2),
        .IN3(DIGIT3),
        .OUT(MuxOut)
    );
    
    // Instantiate a 7 segment display decoder. This will decode the binary values of
    // each digit to be displayed and decodes them into another binary value that
    // corresponds to which pin should be lit up in the seven segment display.
    seg7decoder Seg7 (
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut),
        .DOT_IN(1'b0),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(LED_OUT)
    );
    
endmodule
