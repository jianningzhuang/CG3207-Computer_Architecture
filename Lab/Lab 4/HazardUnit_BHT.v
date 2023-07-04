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


module HazardUnit(
    output StallF,
    output StallD,
    output FlushD,
    output ForwardAD,
    output ForwardBD,
    input [3:0] RA1D,
    input [3:0] RA2D,
    output StallE,
    output FlushE,
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input RegWriteE,
    input Mispredicted,
    output FlushM,
    output ForwardM,
    input [3:0] WA3M,
    input RegWriteM,
    input [3:0] RA2M,
    input MemWriteM,
    input [3:0] WA3W,
    input RegWriteW,
    input MemtoRegW,
    input MCycleBusy
    );
    
    //Data Forwarding Signals
    wire Match_1D_W;
    wire Match_2D_W;
    wire Match_1E_M;
    wire Match_2E_M;
    wire Match_1E_W;
    wire Match_2E_W;
    
    // Load and Use Control Signals
    wire Match_12D_E;
    wire ldrstall;
    wire ldrStallF;
    wire ldrStallD;
    wire ldrFlushE;
    
    // MCycle Busy Control Signals
    wire MCycleBusyStallF;
    wire MCycleBusyStallD;
    wire MCycleBusyStallE;
    wire MCycleBusyFlushM;
    
    // Branch Misprediction Control Signals 
    wire MispredictionFlushD;
    wire MispredictionFlushE;
    
    //Data Forwarding Control
    assign Match_1D_W = (RA1D == WA3W);
    assign Match_2D_W = (RA2D == WA3W);
    assign Match_1E_M = (RA1E == WA3M);
    assign Match_2E_M = (RA2E == WA3M);
    assign Match_1E_W = (RA1E == WA3W);
    assign Match_2E_W = (RA2E == WA3W);

    assign ForwardAD = Match_1D_W & RegWriteW;
    assign ForwardBD = Match_2D_W & RegWriteW;
    
    always @(*) begin
        if (Match_1E_M & RegWriteM) 
        begin
            ForwardAE <= 2'b10;
        end 
        else if (Match_1E_W & RegWriteW) 
        begin
            ForwardAE <= 2'b01;
        end 
        else 
        begin
            ForwardAE <= 2'b00;
        end
        
        if (Match_2E_M & RegWriteM) 
        begin
            ForwardBE <= 2'b10;
        end 
        else if (Match_2E_W & RegWriteW) 
        begin
            ForwardBE <= 2'b01;
        end 
        else 
        begin
            ForwardBE <= 2'b00;
        end
    end
    
    assign ForwardM = (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;
    
    // Load and Use Hazard Control
    assign Match_12D_E = (RA1D == WA3E) | (RA2D == WA3E);
    assign ldrstall = Match_12D_E & MemtoRegE & RegWriteE;
    assign ldrStallF = ldrstall;
    assign ldrStallD = ldrstall;
    assign ldrFlushE = ldrstall;
    
    // MCycle Busy Control (if MCycleBusy in E, stall F, D, E stages, flush next stage M slide 34)
    assign MCycleBusyStallF = MCycleBusy;
    assign MCycleBusyStallD = MCycleBusy;
    assign MCycleBusyStallE = MCycleBusy;
    assign MCycleBusyFlushM = MCycleBusy;
   
   // Branch Misprediction Control 
    assign MispredictionFlushD = Mispredicted;
    assign MispredictionFlushE = Mispredicted;
    
    // Stall Control
    assign StallF = ldrStallF | MCycleBusyStallF;
    assign StallD = ldrStallD | MCycleBusyStallD;
    assign StallE = MCycleBusyStallE;
    
    // Flush Control
    assign FlushD = MispredictionFlushD;
    assign FlushE = ldrFlushE | MispredictionFlushE;
    assign FlushM = MCycleBusyFlushM;
    
endmodule
