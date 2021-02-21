`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 02.02.2021 11:04:53
// Design Name: Mouse Interface
// Module Name: MouseReceiverTB
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: This is the testbench for the receiver module. It tests if the 
//              module can successfully receive a specified byte, while adhering
//              to the timing and requirements set by the Mouse to Host 
//              communication of the PS/2 protocol.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: This module is simple enough to make a testbench on. The
//                      Transceiver and MSM module are very complex and thus the
//                      ILA debugger was mostly used for testing them.
// 
//////////////////////////////////////////////////////////////////////////////////


module MouseReceiverTB(

    );
    
    // Inputs
    reg CLK;
    reg RESET;
    reg CLK_MOUSE_IN;
    reg DATA_MOUSE_IN;
    reg READ_ENABLE;
    
    // Outputs
    wire [7:0] BYTE_READ;
    wire [1:0] BYTE_ERROR_CODE;
    wire BYTE_READY;
    
    // Instantiate the uut
    MouseReceiver uut (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE_IN(CLK_MOUSE_IN),
        .DATA_MOUSE_IN(DATA_MOUSE_IN),
        .READ_ENABLE(READ_ENABLE),
        .BYTE_READ(BYTE_READ),
        .BYTE_ERROR_CODE(BYTE_ERROR_CODE),
        .BYTE_READY(BYTE_READY)
    );
    
        
    always
        #10 CLK = !CLK;
        
    // Monitor important values (Displays the values at the end of the current timestep if any value changes)
    initial begin
        $monitor("Time = %d \t BYTE_READ = %b \t BYTE_ERROR_CODE = %b \t BYTE_READY = %b",$time,BYTE_READ,BYTE_ERROR_CODE,BYTE_READY);
    end
    
    initial begin
        // Initialize inputs
        #100; // wait for global reset
        RESET = 0;
        CLK = 0;
        CLK_MOUSE_IN = 1;
        DATA_MOUSE_IN = 1;
        READ_ENABLE = 1;
        
        $display("Beginning");
        
        #30000; // Wait 30us (Around 1 clock time according to the lab documentation) (has to be between 25us and 50us)
        
        // Test Reception of 0xFA
        
        // Start Bit
        DATA_MOUSE_IN = 0;
        $display("Send Start Bit = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 1
        DATA_MOUSE_IN = 0;
        $display("Send Bit 1 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 2
        DATA_MOUSE_IN = 1;
        $display("Send Bit 2 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 3
        DATA_MOUSE_IN = 0;
        $display("Send Bit 3 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 4
        DATA_MOUSE_IN = 1;
        $display("Send Bit 4 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 5
        DATA_MOUSE_IN = 1;
        $display("Send Bit 5 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 6
        DATA_MOUSE_IN = 1;
        $display("Send Bit 6 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 7
        DATA_MOUSE_IN = 1;
        $display("Send Bit 7 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Bit 8
        DATA_MOUSE_IN = 1;
        $display("Send Bit 8 = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        
        CLK_MOUSE_IN = 1;
        #10000;
        // Parity Bit
        DATA_MOUSE_IN = 1;
        $display("Parity Bit = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
    
        CLK_MOUSE_IN = 1;
        #10000;    
        // Stop Bit
        DATA_MOUSE_IN = 1;
        $display("Send Stop Bit = %b", DATA_MOUSE_IN);
        #10000;
        CLK_MOUSE_IN = 0;
        #30000;
        CLK_MOUSE_IN = 1;
        #10000;
        
        
        //Wait before ending testbench      
        #20000;
        
        $display("End");
    end
    
endmodule
