`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This module can be used directly to display 32-bit INSTR or DATA_CONST on the 7-segments in HEX format
// DO NOT modify this module, but only instantiate it in the TOP module
// 7-segments display is NOT compulsory for Lab 1 demonstration
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////

module Seven_Seg(
    input clk,  // fundamental frequency 100MHz
    input [31:0] data,   // 32-bit MEM contents willing to display on 7-segments
    output reg [3:0] anode, // anodes for 7-segments
    output dp,  // dot point for 7-segments
    output reg [6:0] cathode, // cathodes for 7-segments
    input upper_lower
    );
    
    reg [3:0] enable;   // 4-bit signal to indicate which 7-segment unit is enabled (active LOW)
    reg [3:0] data_disp; // display data_disp for each 7-segment unit, 0 to F, therefore 4 bits.
    reg [16:0] count_fast = 17'b0;  // counter for slowering down 100MHz to 1kHz for 7-segments multiplexing
    reg seven_seg_enable = 1'b0;    // 1-bit enable signal for 1kHz multiplexing speed of 7-segments
        
     initial begin
        anode = 4'hF;  // disable all anode signals of 7-segments (active LOW)
        cathode = 7'b1111111;    // disable all cathode signals of 7-segments (active HIGH)
        enable = 4'b0001;   // multiplexing signal for eight 7-segment units, turn on the most right one initially
     end
     
     assign dp = 1'b0;  // disable all dot points
     
     always @(posedge clk) begin
         count_fast <= count_fast+1;    // fast counter is enabled by the fundamental frequency 100MHz
         if(count_fast == 17'h1869F) begin  // counter should count from 0 to 99,999 for 1kHz
            seven_seg_enable <= 1'b1;   // set the enable flag signal 
            count_fast <= 17'b0;    // reset the counter
         end
         else seven_seg_enable <= 0;    // clear the enable flag signal if counter doesn't reach 99,999
     end
     
     always @(posedge clk) begin
         if(seven_seg_enable) begin // when 7-segments are enabled, multiplexing eight 7-segment units on by one
            enable <= (enable == 4'h8)? 4'h1 : (enable << 1); //eight 7-segment units are turned on 1 by 1, with frequency 1kHz
            anode <= ~enable;   // anode signal is active LOW
         end
     end
            
      always @ (*) begin                       
        case (anode)    // assigning the 32-bit data_disp to each 7-segment unit
            4'b1110 : data_disp = upper_lower? data[19:16] : data[3:0];
            4'b1101 : data_disp = upper_lower? data[23:20] : data[7:4];
            4'b1011 : data_disp = upper_lower? data[27:24] : data[11:8];
            4'b0111 : data_disp = upper_lower? data[31:28] : data[15:12];
            default : data_disp = 4'h0;
        endcase 
        case (data_disp) // based on 4-bit data_disp, turn on/off corresponding cathode signals
            4'h0 : cathode = 7'b1000000; 
            4'h1 : cathode = 7'b1111001;
            4'h2 : cathode = 7'b0100100;
            4'h3 : cathode = 7'b0110000;
            4'h4 : cathode = 7'b0011001;
            4'h5 : cathode = 7'b0010010;
            4'h6 : cathode = 7'b0000010;
            4'h7 : cathode = 7'b1111000;
            4'h8 : cathode = 7'b0000000;
            4'h9 : cathode = 7'b0010000;
            4'hA : cathode = 7'b0001000;
            4'hB : cathode = 7'b0000011;
            4'hC : cathode = 7'b1000110;
            4'hD : cathode = 7'b0100001;
            4'hE : cathode = 7'b0000110;
            4'hF : cathode = 7'b0001110;
         endcase
    end 
endmodule
