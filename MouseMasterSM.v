`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The University of Edinburgh
// Engineer: David Jorge
// 
// Create Date: 15.01.2021 19:46:37
// Design Name: Mouse Interface
// Module Name: MouseMasterSM
// Project Name: Digital Systems Laboratory
// Target Devices: Basys 3
// Tool Versions: 
// Description: Master State Machine module that handles the PS/2 protocol by
//              controlling the reciever and transmitter modules. Added Scroll wheel
//              functionality.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Here I it was possible to have a lot of design freedom.
//                      Added the additional functionality to detect scroll wheel
//                      movement.
//////////////////////////////////////////////////////////////////////////////////


module MouseMasterSM(
    input CLK,
    input RESET,
    //Transmitter Control
    output SEND_BYTE,
    output [7:0] BYTE_TO_SEND,
    input BYTE_SENT,
    //Receiver Control
    output READ_ENABLE,
    input [7:0] BYTE_READ,
    input [1:0] BYTE_ERROR_CODE,
    input BYTE_READY,
    //Data Registers
    output [7:0] MOUSE_DX,
    output [7:0] MOUSE_DY,
    output [7:0] MOUSE_DSCROLL,
    output [7:0] MOUSE_STATUS,
    output SEND_INTERRUPT
    
    /*
    //ILA Debugger
    output [3:0] MasterStateCode
    */
    );
    
    //////////////////////////////////////////////////////////////
    // Main state machine - There is a setup sequence
    //
    // 1) Send FF -- Reset command,
    // 2) Read FA -- Mouse Acknowledge,
    // 2) Read AA -- Self-Test Pass
    // 3) Read 00 -- Mouse ID
    // 4) Send F4 -- Start transmitting command,
    // 5) Read FA -- Mouse Acknowledge,
    //
    // Scroll Wheel
    // 6) Send F3 -- Request sample rate change
    // 7) Send C8 -- Set sample rate 200
    // 8) Read FA -- Mouse Acknowledge
    // 9) Send F3 -- Request sample rate change
    // 10) Send 64 -- Set sample rate to 100
    // 8) Read FA -- Mouse Acknowledge
    // 9) Send F3 -- Request sample rate change
    // 10) Send 50 -- Set sample rate to 80
    // 11) Read FA -- Mouse Acknowledge
    // 12) Send F2 -- Request Mouse ID
    // 13) IF Read 03 -- Mouse has a functioning scroll wheel
    //     ELSE IF Read 00 -- Mouse does not have a functioning scroll wheel
    //
    // If at any time this chain is broken, the SM will restart from
    // the beginning. Once it has finished the set-up sequence, the read enable flag
    // is raised.
    // The host is then ready to read mouse information 3 bytes at a time:
    // S1) Wait for first read, When it arrives, save it to Status. Goto S2.
    // S2) Wait for second read, When it arrives, save it to DX. Goto S3.
    // S3) Wait for third read, When it arrives, save it to DY. If mouse has a scroll wheel Goto S4, else Goto S1.
    // S4) Wait for fourth read, When it arrives save it to DScroll. Goto S1
    // Send interrupt.
    
    //State Control
    reg [7:0] Curr_State, Next_State;
    reg [23:0] Curr_Counter, Next_Counter;
    
    //Transmitter Control
    reg Curr_SendByte, Next_SendByte;
    (* keep = "true" *) reg [7:0] Curr_ByteToSend, Next_ByteToSend;
    
    //Receiver Control
    reg Curr_ReadEnable, Next_ReadEnable;
    
    //Data Registers
    reg [7:0] Curr_Status, Next_Status;
    reg [7:0] Curr_Dx, Next_Dx;
    reg [7:0] Curr_Dy, Next_Dy;
    reg [7:0] Curr_DScroll, Next_DScroll;
    reg Curr_ScrollMode, Next_ScrollMode;
    reg Curr_SendInterrupt, Next_SendInterrupt;
    
    //Sequential
    always@(posedge CLK) begin
        if(RESET) begin
            Curr_State <= 8'h00;
            Curr_Counter <= 0;
            Curr_SendByte <= 1'b0;
            Curr_ByteToSend <= 8'h00;
            Curr_ReadEnable <= 1'b0;
            Curr_Status <= 8'h00;
            Curr_Dx <= 8'h00;
            Curr_Dy <= 8'h00;
            Curr_DScroll <= 8'h00;
            Curr_ScrollMode <= 1'b0;
            Curr_SendInterrupt <= 1'b0;
        end else begin
            Curr_State <= Next_State;
            Curr_Counter <= Next_Counter;
            Curr_SendByte <= Next_SendByte;
            Curr_ByteToSend <= Next_ByteToSend;
            Curr_ReadEnable <= Next_ReadEnable;
            Curr_Status <= Next_Status;
            Curr_Dx <= Next_Dx;
            Curr_Dy <= Next_Dy;
            Curr_DScroll <= Next_DScroll;
            Curr_ScrollMode <= Next_ScrollMode;
            Curr_SendInterrupt <= Next_SendInterrupt;
        end
    end
    
    //Combinatorial
    always@* begin
        Next_State = Curr_State;
        Next_Counter = Curr_Counter;
        Next_SendByte = 1'b0;
        Next_ByteToSend = Curr_ByteToSend;
        Next_ReadEnable = 1'b0;
        Next_Status = Curr_Status;
        Next_Dx = Curr_Dx;
        Next_Dy = Curr_Dy;
        Next_DScroll = Curr_DScroll;
        Next_ScrollMode = Curr_ScrollMode;
        Next_SendInterrupt = 1'b0;
        
        case(Curr_State)
            //Initialise State - Wait here for 10ms before trying to initialise the mouse
            0: begin
                Next_ScrollMode = 0;
                if(Curr_Counter == 5000000) begin // 1/100th sec at 50MHz clock
                    Next_State = 1;
                    Next_Counter = 0;
                end else
                    Next_Counter = Curr_Counter + 1'b1;
            end
            
            //Start initialisation by sending FF
            1: begin
                Next_State = 2;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hFF;
            end
            
            //Wait for confirmation of the byte being sent
            2: begin
                if(BYTE_SENT)
                    Next_State = 3;
            end
            
            //Wait for confirmation of a byte being received
            //If the byte is FA goto next state, else re-initialise.
            3: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 4;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //Wait for self-test pass confirmation
            //If the byte is AA goto next state, else re-initialise
            4: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hAA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 5;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //Wait for confirmation of a byte being received
            //If the byte is 00 goto next state (MOSUE ID ) else re-initialise
            5: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 6;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //Send F4 - to start mouse transmit
            6: begin
                Next_State = 7;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hF4;
            end
            
            //Wait for confirmation of the byte being sent
            7: if(BYTE_SENT) Next_State = 8;
            
            //Wait for confirmation of a byte being received
            // CHANGED THE EXPECTED BYTE TO FA AS THIS IS WHAT IS RECEIVED
            //If the byte is FA goto next state, else re-initialise
            8: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 9;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            // Now we can initialize the Intellimouse procedure
            // To enable the scroll wheel a series of sample rate changes
            // need to be made as follows: 
            // 1. Set sample rate 200
            // 2. Set sample rate 100
            // 3. Set sample rate 80
            // The set sample rate request command is denoted by byte '0xF3'
            9: begin
                Next_State = 10;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hF3;
            end
            
            // Wait until byte is sent
            10: begin
                if(BYTE_SENT)
                    Next_State = 11;
            end
            
            // Wait until byte is received by mouse
            // If mouse returns the acknowledge byte 'FA', proceed else reinitialize
            11: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 12;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            // Send the first of 3 sample rate changes: 
            // Set sample rate 200 (200 is C8 in hex)
            12: begin
                Next_State = 13;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hC8;
            end
            
            // Wait until byte is sent
            13: begin
                if(BYTE_SENT)
                    Next_State = 14;
            end
            
            // Wait until byte is sent
            // If mosue replies with acknowledge byte 'FA' goto next state
            // else reinitialize
            14: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 15;
                    else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            // Send byte 'F3' for sample rate change request
            15: begin
                Next_State = 16;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hF3;
            end
                        
            // Wait until byte is sent
            16: begin
                if(BYTE_SENT)
                    Next_State = 17;
            end
                        
            // Wait until byte is received by mouse
            // If mouse returns the acknowledge byte 'FA', proceed else reinitialize
            17: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 18;
                    else
                        Next_State = 0;
                end
                            
                Next_ReadEnable = 1'b1;
            end
                        
            // Send the first of 3 sample rate changes: 
            // Set sample rate 100 (100 is 64 in hex)
            18: begin
                Next_State = 19;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'h64;
            end
                        
            // Wait until byte is sent
            19: begin
                if(BYTE_SENT)
                    Next_State = 20;
            end
                        
            // Wait until byte is sent
            // If mouse replies with acknowledge byte 'FA' goto next state
            // else reinitialize
            20: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 21;
                        else
                            Next_State = 0;
                end
                            
                Next_ReadEnable = 1'b1;
            end
            
            // Send byte 'F3' for sample rate change request
            21: begin
                Next_State = 22;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hF3;
            end
                                    
            // Wait until byte is sent
            22: begin
                if(BYTE_SENT)
                    Next_State = 23;
            end
                                    
            // Wait until byte is received by mouse
            // If mouse returns the acknowledge byte 'FA', proceed else reinitialize
            23: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 24;
                    else
                        Next_State = 0;
                end
                                        
                Next_ReadEnable = 1'b1;
            end
                                    
            // Send the third and final of 3 sample rate changes: 
            // Set sample rate 80 (80 is 50 in hex)
            24: begin
                Next_State = 25;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'h50;
            end
                                    
            // Wait until byte is sent
            25: begin
                if(BYTE_SENT)
                    Next_State = 26;
            end
                                    
            // Wait until byte is sent
            // If mouse replies with acknowledge byte 'FA' goto next state
            // else reinitialize
            26: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 27;
                    else
                        Next_State = 0;
                end
                                        
                Next_ReadEnable = 1'b1;
            end
                    
            // Now the host needs to send the 'Get device ID' (0xF2) byte
            // and waits for a response. If mouse responds with '0x00' it
            // means it has a functioning scroll wheel. Otherwise it responds with '0x03'
            27: begin
                Next_State = 28;
                Next_SendByte = 1'b1;
                Next_ByteToSend = 8'hF2;
            end
            
            // Wait until byte is sent
            28: begin
                if(BYTE_SENT)
                    Next_State = 29;
            end
                                                
            // Wait until byte is sent
            // If mouse replies with acknowledge byte 'FA' goto next state
            // else reinitialize
            29: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
                        Next_State = 30;
                    else
                        Next_State = 0;
                end
                                                    
                Next_ReadEnable = 1'b1;
            end
            
            // The mouse can respond in 2 ways. By sending the 0x03 byte, meaning that
            // it has a functioning scroll wheel, or the 0x00 byte, meaning it does not
            // have a functioning scroll wheel. If it sends 0x03, instead of the usual 3
            // information bytes, it will send an additional 4th byte with the scroll wheel
            // information. Otherwise it will stick to the usual 3 information bytes.
            30: begin
                if(BYTE_READY) begin
                    if((BYTE_READ == 8'h03) & (BYTE_ERROR_CODE == 2'b00)) begin
                        Next_State = 31;
                        Next_ScrollMode = 1'b1;
                    end else if ((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00)) begin
                        Next_State = 31;
                        Next_ScrollMode = 1'b0;
                    end else
                        Next_State = 0;
                end
                                    
                Next_ReadEnable = 1'b1;
            end
            
            ///////////////////////////////////////////////////////////
            //At this point the SM has initialised the mouse.
            //Now we are constantly reading. If at any time
            //there is an error, we will re-initialise
            //the mouse - just in case.
            ///////////////////////////////////////////////////////////
            
            //Wait for the confirmation of a byte being received.
            //This byte will be the first of three, the status byte.
            //If a byte arrives, but is corrupted, then we re-initialise
            31: begin
                if(BYTE_READY) begin
                    if(BYTE_ERROR_CODE == 2'b00) begin
                        Next_State = 32;
                        Next_Status = BYTE_READ;
                    end else
                        Next_State = 0;
                end
                
                Next_Counter = 0;
                Next_ReadEnable = 1'b1;
            end
            
            //Wait for confirmation of a byte being received
            //This byte will be the second of three, the Dx byte.
            32: begin
            /*
             ………………
             FILL IN THIS AREA
             ………………
            */
                if(BYTE_READY) begin
                    if(BYTE_ERROR_CODE == 2'b00) begin
                        Next_State = 33;
                        Next_Dx = BYTE_READ;
                    end else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //Wait for confirmation of a byte being received
            //This byte will be the third of three, the Dy byte.
            33: begin
            /*
             ………………
             FILL IN THIS AREA
             ………………
            */
                if(BYTE_READY) begin
                    if(BYTE_ERROR_CODE == 2'b00) begin
                        if(Curr_ScrollMode)
                            Next_State = 34;
                        else
                            Next_State = 35;
                        Next_Dy = BYTE_READ;
                    end else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //If mouse is intellimouse then parse 4th byte, this will have the Mouse Scroll Wheel Information
            34: begin
                if(BYTE_READY) begin
                    if(BYTE_ERROR_CODE == 2'b00) begin
                        Next_DScroll = BYTE_READ;
                        Next_State = 35;
                    end else
                        Next_State = 0;
                end
                
                Next_ReadEnable = 1'b1;
            end
            
            //Send Interrupt State
            35: begin
                Next_State = 31;
                Next_SendInterrupt = 1'b1;
            end
            
            //Default State
            default: begin
                Next_State = 8'h0;
                Next_Counter = 0;
                Next_SendByte = 1'b0;
                Next_ByteToSend = 8'hFF;
                Next_ReadEnable = 1'b0;
                Next_Status = 8'h00;
                Next_Dx = 8'h00;
                Next_Dy = 8'h00;
                Next_DScroll = 8'h00;
                Next_ScrollMode = 1'b0;
                Next_SendInterrupt = 1'b0;
            end
        endcase
    end
    
    ///////////////////////////////////////////////////
    //Tie the SM signals to the IO
    
    //Transmitter
    assign SEND_BYTE = Curr_SendByte;
    assign BYTE_TO_SEND = Curr_ByteToSend;
    
    //Receiver
    assign READ_ENABLE = Curr_ReadEnable;
    
    //Output Mouse Data
    assign MOUSE_DX = Curr_Dx;
    assign MOUSE_DY = Curr_Dy;
    assign MOUSE_DSCROLL = Curr_DScroll;
    assign MOUSE_STATUS = Curr_Status;
    assign SEND_INTERRUPT = Curr_SendInterrupt;
    
    /*
    //ILA Debugger
    assign MasterStateCode = Curr_State;
    */
    
endmodule
