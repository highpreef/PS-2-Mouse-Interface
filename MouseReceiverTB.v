`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.02.2021 11:04:53
// Design Name: 
// Module Name: MouseReceiverTB
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


module MouseReceiverTB(

    );
    
    // Inputs
    reg RESET;
    reg CLK;
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
    
    initial begin
        // Initialize inputs
        RESET = 0;
        CLK = 0;
        CLK_MOUSE_IN = 1;
        DATA_MOUSE_IN = 1;
        READ_ENABLE = 1;
        
        $display("Begin Testbench");
        
        #40000; // Wait 40us (One clock time)
        
        // Test Reception of 0xF9
        $display("Send Start Bit");
        // Start Bit
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 1 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 2 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 3 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 4 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 5 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 6 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 7 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 8 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Parity Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Stop Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        #50000;
        
        
        // Test Reception of 0xF4           
        $display("Send Start Bit");
        // Start Bit
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 1 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 2 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 3 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 4 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 5 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 6 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 7 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 8 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Parity Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Stop Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
        
        #60000;
        
        // Test Reception of 0xFA       
        $display("Send Start Bit");
        // Start Bit
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 1 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 2 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 0;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 3 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 4 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 5 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 6 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 7 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Bit 8 = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                        
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Parity Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                       
        DATA_MOUSE_IN = 1;
        #20000;
        CLK_MOUSE_IN = 0;
        #40000;
        $display("Send Stop Bit = %b", DATA_MOUSE_IN);
        CLK_MOUSE_IN = 1;
        #20000;
                
        #50000;
        
        $display("End Testbench");
    end
    
    initial begin
        $monitor("Time = %d,\tBYTE_READ = %b,\tBYTE_ERROR_CODE = %b,\tBYTE_READY = %b",$time,BYTE_READ,BYTE_ERROR_CODE,BYTE_READY);
    end
    
endmodule
