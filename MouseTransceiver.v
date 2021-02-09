`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 15.01.2021 20:17:50
// Design Name: Mouse Interface
// Module Name: MouseTransceiver
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: Transceiver for the mouse interface. Handles the instantiation of the 
//              transmitter, receiver and MSM modules and the update and I/O of the
//              Mouse movement and button information. Added extra functionality to 
//              detect scroll wheel movement.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Design freedom is contrained in this module.
//////////////////////////////////////////////////////////////////////////////////


module MouseTransceiver(
    //Standard Inputs
    input RESET,
    input CLK,
    //IO - Mouse side
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    // Mouse data information
    // Added reg declaration for MouseStatus, MouseX and MouseY as it is necessary to do
    // non-blocking assignments
    output reg [3:0] MouseStatus,
    //output reg [7:0] MouseX,
    //output reg [7:0] MouseY,
    output reg [7:0] MouseScroll,
    
    // Seg7 Display
    output [3:0] SEG_SELECT,
    output [7:0] LED_OUT
    );
    reg [7:0] MouseX;
    reg [7:0] MouseY;
        
    // X, Y Limits of Mouse Position e.g. VGA Screen with 160 x 120 resolution
    parameter [7:0] MouseLimitX = 160;
    parameter [7:0] MouseLimitY = 120;
    // MouseScroll value can be any 8bit binary number
    parameter [7:0] MouseLimitScroll = 255;
    
    /////////////////////////////////////////////////////////////////////
    //TriState Signals
    //Clk
    reg ClkMouseIn;
    wire ClkMouseOutEnTrans;
    
    //Data
    wire DataMouseIn;
    wire DataMouseOutTrans;
    wire DataMouseOutEnTrans;
    
    //Clk Output - can be driven by host or device
    assign CLK_MOUSE = ClkMouseOutEnTrans ? 1'b0 : 1'bz;
    
    //Clk Input
    assign DataMouseIn = DATA_MOUSE;
    
    //Clk Output - can be driven by host or device
    assign DATA_MOUSE = DataMouseOutEnTrans ? DataMouseOutTrans : 1'bz;
    
    /////////////////////////////////////////////////////////////////////
    //This section filters the incoming Mouse clock to make sure that
    //it is stable before data is latched by either transmitter
    //or receiver modules
    reg [7:0]MouseClkFilter;
    always@(posedge CLK) begin
        if(RESET)
            ClkMouseIn <= 1'b0;
        else begin
            //A simple shift register
            MouseClkFilter[7:1] <= MouseClkFilter[6:0];
            MouseClkFilter[0] <= CLK_MOUSE;
            
            //falling edge
            if(ClkMouseIn & (MouseClkFilter == 8'h00))
                ClkMouseIn <= 1'b0;
            //rising edge
            else if(~ClkMouseIn & (MouseClkFilter == 8'hFF))
                ClkMouseIn <= 1'b1;
        end
    end
    
    ///////////////////////////////////////////////////////
    //Instantiate the Transmitter module
    wire SendByteToMouse;
    wire ByteSentToMouse;
    wire [7:0] ByteToSendToMouse;
    MouseTransmitter T(
        //Standard Inputs
        .RESET (RESET),
        .CLK(CLK),
        //Mouse IO - CLK
        .CLK_MOUSE_IN(ClkMouseIn),
        .CLK_MOUSE_OUT_EN(ClkMouseOutEnTrans),
        //Mouse IO - DATA
        .DATA_MOUSE_IN(DataMouseIn),
        .DATA_MOUSE_OUT(DataMouseOutTrans),
        .DATA_MOUSE_OUT_EN(DataMouseOutEnTrans),
        //Control
        .SEND_BYTE(SendByteToMouse),
        .BYTE_TO_SEND(ByteToSendToMouse),
        .BYTE_SENT(ByteSentToMouse)
    );
        
    ///////////////////////////////////////////////////////
    //Instantiate the Receiver module
    wire ReadEnable;
    wire [7:0] ByteRead;
    wire [1:0] ByteErrorCode;
    wire ByteReady;
    MouseReceiver R(
        //Standard Inputs
        .RESET(RESET),
        .CLK(CLK),
        //Mouse IO - CLK
        .CLK_MOUSE_IN(ClkMouseIn),
        //Mouse IO - DATA
        .DATA_MOUSE_IN(DataMouseIn),
        //Control
        .READ_ENABLE (ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteErrorCode),
        .BYTE_READY(ByteReady)
    );
    
    ///////////////////////////////////////////////////////
    //Instantiate the Master State Machine module
    wire [7:0] MouseStatusRaw;
    wire [7:0] MouseDxRaw;
    wire [7:0] MouseDyRaw;
    wire [7:0] MouseDScrollRaw;
    wire SendInterrupt;
    /*
    //ILA Debugger
    wire [5:0] MasterStateCode;
    */
    MouseMasterSM MSM(
        //Standard Inputs
        .RESET(RESET),
        .CLK(CLK),
        //Transmitter Interface
        .SEND_BYTE(SendByteToMouse),
        .BYTE_TO_SEND(ByteToSendToMouse),
        .BYTE_SENT(ByteSentToMouse),
        //Receiver Interface
        .READ_ENABLE (ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteErrorCode),
        .BYTE_READY(ByteReady),
        //Data Registers
        .MOUSE_STATUS(MouseStatusRaw),
        .MOUSE_DX(MouseDxRaw),
        .MOUSE_DY(MouseDyRaw),
        .MOUSE_DSCROLL(MouseDScrollRaw),
        .SEND_INTERRUPT(SendInterrupt)
        /*
        //ILA Debugger
        .MasterStateCode(MasterStateCode)
        */
    );
    
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
    
    /*
    //ILA Debugger
    ila_0 debugger (
        .clk(CLK), // input wire clk
        
        
        .probe0(RESET), // input wire [0:0]  probe0  
        .probe1(CLK_MOUSE), // input wire [0:0]  probe1 
        .probe2(DATA_MOUSE), // input wire [0:0]  probe2 
        .probe3(ByteErrorCode), // input wire [1:0]  probe3 
        .probe4(MasterStateCode), // input wire [5:0]  probe4 
        .probe5(ByteRead), // input wire [7:0]  probe5 
        .probe6(ByteToSendToMouse) // input wire [7:0]  probe6
    );
    */
    
    //Pre-processing - handling of overflow and signs.
    //More importantly, this keeps tabs on the actual X/Y
    //location of the mouse.
    wire signed [8:0] MouseDx;
    wire signed [8:0] MouseDy;
    wire signed [8:0] MouseDScroll;
    wire signed [8:0] MouseNewX;
    wire signed [8:0] MouseNewY;
    wire signed [8:0] MouseNewScroll;
    
    
    //DX and DY are modified to take account of overflow and direction
    /*
        if Movement Overflow bit is 1 {
            if Sign bit is negative {
                MouseDx = -256 ( {1, 00000000} )
            } else if Sign bit is positive {
                MouseDx = 255 ( {0, 11111111} )
            }
        } else if Movement Overflow bit is 0 {
            // Receive incoming dx value and append sign bit because of 2's complement
            MouseDx = {Sign bit, MouseDxRaw[7:0]}
        }
    */
    assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],8'h00} :
    {MouseStatusRaw[4],8'hFF} ) : {MouseStatusRaw[4],MouseDxRaw[7:0]};
    
    // assign the proper expression to MouseDy
    /*
     ………………
     FILL IN THIS AREA
     ………………
    */
    /*
        if Movement Overflow bit is 1 {
            if Sign bit is negative {
                MouseDy = -256 ( {1, 00000000} )
            } else if Sign bit is positive {
                MouseDy = 255 ( {0, 11111111} )
            }
        } else if Movement Overflow bit is 0 {
            // Receive incoming dy value and append sign bit because of 2's complement
            MouseDy = {Sign bit, MouseDyRaw[7:0]}
        }
    */
    assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],8'h00} :
    {MouseStatusRaw[5],8'hFF} ) : {MouseStatusRaw[5],MouseDyRaw[7:0]};
    
    // Assign proper expression to MouseDScroll. Since the mouse scroll data only changes the 4 least significant bits,
    // sign extension can be safely used.
    assign MouseDScroll = {MouseDScrollRaw[7], MouseDScrollRaw[7:0]};
    
    // calculate new mouse position
    assign MouseNewX = {1'b0,MouseX} + MouseDx;
    assign MouseNewY = {1'b0,MouseY} + MouseDy;
    assign MouseNewScroll = {1'b0,MouseScroll} + MouseDScroll;
    
    always@(posedge CLK) begin
        if(RESET) begin
            MouseStatus <= 0;
            MouseX <= MouseLimitX/2;
            MouseY <= MouseLimitY/2;
            MouseScroll <= MouseLimitScroll/2;
        end else if (SendInterrupt) begin
            //Status is stripped of all unnecessary info
            MouseStatus <= MouseStatusRaw[3:0];
            
            //X is modified based on DX with limits on max and min
            if(MouseNewX < 0)
                MouseX <= 0;
            else if(MouseNewX > (MouseLimitX-1))
                MouseX <= MouseLimitX-1;
            else
                MouseX <= MouseNewX[7:0];
            
            //Y is modified based on DY with limits on max and min
            /*
            ………………
            FILL IN THIS AREA
            ………………
            */
            // If new Mouse Position is less than 0
            if(MouseNewY < 0)
                // Set MouseY to minimum screen Y position
                MouseY <= 0;
            // If new Mouse Position is greater than max screen Y value
            else if(MouseNewY > (MouseLimitY-1))
                // Set MouseY to maximum screen Y position
                MouseY <= MouseLimitY-1;
            // If not outside boundary, receive new Mouse Y position value
            else
                MouseY <= MouseNewY[7:0];
                
            // Scroll value is modified based on DScroll with limits on its max and min value
            // Unlike the mouse coordinates, the scroll value isn't capped at the max and min value,
            // thus code to make it wrap around has been added.
            if(MouseNewScroll < 0)
                MouseScroll <= MouseLimitScroll;
            else if(MouseNewScroll > MouseLimitScroll)
                MouseScroll <= 0;
            else
                MouseScroll <= MouseNewScroll[7:0];
        end
    end
    
endmodule
