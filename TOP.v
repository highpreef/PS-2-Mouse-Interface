`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 09.02.2021 15:07:40
// Design Name: Mouse Interface
// Module Name: TOP
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: This is a wrapper module used for demonstrating the mouse 
//              interface. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// 
//////////////////////////////////////////////////////////////////////////////////


module TOP(
    //Standard Inputs
    input RESET,
    input CLK,
    //IO - Mouse side
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // Mouse data information
    output [3:0] MouseStatus,
    output [7:0] MouseScroll,
    
    // Seg7 Display
    output [3:0] SEG_SELECT,
    output [7:0] LED_OUT
    );
    
    // MouseX and MouseY direction values
    wire [7:0] MouseX;
    wire [7:0] MouseY;
    
    MouseTransceiver T (
        //Standard Inputs
        .RESET(RESET),
        .CLK(CLK),
        //IO - Mouse side
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        // Mouse data information
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseScroll(MouseScroll), 
        // Seg7 Display
        .SEG_SELECT(SEG_SELECT),
        .LED_OUT(LED_OUT)
    );
    
    /*
    // Decided to imbed the seg7 wrapper inside the transceiver module
    ///////////////////////////////////////////////////////
    //Instantiate the Seg 7 Wrapper module
    Seg7Wrapper Seg7 (
        .CLK(CLK),
        .DIGIT0(MouseY[3:0]),
        .DIGIT1(MouseY[7:4]),
        .DIGIT2(MouseX[3:0]),
        .DIGIT3(MouseX[7:4]),
        .LED_OUT(LED_OUT),
        .SEG_SELECT(SEG_SELECT)
    );
    */
    
endmodule
