`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2021 23:51:03
// Design Name: 
// Module Name: HazardUnit
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


module BHT(
    input CLK,
    input WE_PrPCSrc,
    input WE_PrALUResult,
    input PCSrcE,
    input [7:0] PCF,
    input [7:0] PCE,
    input [31:0] ALUResultE,
    output PrPCSrcF,
    output [31:0] PrALUResultF
    );

    reg [32:0] Table [0:63]; // 1 bit predictor, 64 etries
    reg [7:0] i;

    initial 
    begin
      for (i = 0; i < 255; i = i+1) begin
        Table[i] = 33'h0;
      end
    end


    always @ (posedge CLK)
    begin

      // BTA Mispredicted
      if (WE_PrALUResult)
        Table[PCE[7:2]][31:0] <= ALUResultE;
      
      // Branch Mispredicted
      if (WE_PrPCSrc)
        Table[PCE[7:2]][32] <= PCSrcE;
    end
    
    assign PrPCSrcF = Table[PCF[7:2]][32]; //1 bit predictor
    assign PrALUResultF = Table[PCF[7:2]][31:0];

endmodule
