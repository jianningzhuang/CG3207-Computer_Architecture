`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2022 15:06:34
// Design Name: 
// Module Name: simulate_Top
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


module simulate_Top(

    );
    
    reg clk;
    reg btnU;
    reg btnC;
    
    wire [15:0] led;
    wire dp;
    wire [7:0] anode;
    wire [6:0] cathode;
    
    Top sim_top(clk, btnU, btnC, led, dp, anode, cathode);
    
    initial 
    begin
        clk = 0; btnU = 0; btnC = 0; #50000;
        btnU = 0; btnC = 1; #50000;
        btnU = 1; btnC = 0; #50000;
    
    end
    
    always
    begin
        #5 clk = ~clk;
    end
endmodule
