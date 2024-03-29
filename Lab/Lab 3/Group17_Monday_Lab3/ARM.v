`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: ARM
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ARM Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified. The implementation can be modified
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

//-- R15 is not stored
//-- Save waveform file and add it to the project
//-- Reset and launch simulation if you add interal signals to the waveform window

module ARM(
    input CLK,
    input RESET,
    //input Interrupt,  // for optional future use
    input [31:0] Instr,
    input [31:0] ReadData,
    output MemWrite,
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData
    );
    
    // RegFile signals
    //wire CLK ;
    wire WE3 ;
    wire [3:0] A1 ;
    wire [3:0] A2 ;
    wire [3:0] A3 ;
    wire [31:0] WD3 ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    // Extend Module signals
    wire [1:0] ImmSrc ;
    wire [23:0] InstrImm ;
    wire [31:0] ExtImm ;
    
    // Decoder signals
    wire [3:0] Rd ;
    wire [1:0] Op ;
    wire [5:0] Funct ;
    //wire PCS ;
    //wire RegW ;
    //wire MemW ;
    wire MemtoReg ;
    wire ALUSrc ;
    //wire [1:0] ImmSrc ;
    wire [1:0] RegSrc ;
    //wire NoWrite ;
    //wire [1:0] ALUControl ;
    //wire [1:0] FlagW ;
    
    // CondLogic signals
    //wire CLK ;
    wire PCS ;
    wire RegW ;
    wire NoWrite ;
    wire MemW ;
    wire [1:0] FlagW ;
    wire [3:0] Cond ;
    //wire [3:0] ALUFlags,
    wire PCSrc ;
    wire RegWrite ; 
    //wire MemWrite
       
    // Shifter signals
    wire [1:0] Sh ;
    wire [4:0] Shamt5 ;
    wire [31:0] ShIn ;
    wire [31:0] ShOut ;
    
    // ALU signals
    wire [31:0] Src_A ;
    wire [31:0] Src_B ;
    wire [1:0] ALUControl ;
    //wire [31:0] ALUResult ;
    wire [3:0] ALUFlags ;
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    wire [31:0] PC_IN ;
    //wire [31:0] PC ; 
    
    //MCycle signals
    //wire CLK ;
    //wire RESET ;
    wire Start ;
    wire [1:0] MCycleOp ;
    wire [31:0] Operand1 ;
    wire [31:0] Operand2 ;
    wire [31:0] Result1 ;
    wire [31:0] Result2 ;
    wire Busy ;
    wire [3:0] MCycleFunct;

    // Other internal signals here
    wire [31:0] PCPlus4 ;
    wire [31:0] PCPlus8 ;
    wire [31:0] Result ;
    
    assign PCPlus4 = PC + 32'h00000004;
    assign PCPlus8 = PCPlus4 + 32'h00000004;
    assign Result = (MemtoReg == 1'b0) ? ((Start == 1'b1) ? Result1 : ALUResult) : ReadData;
    assign WriteData = RD2;
    
    //RegFile Datapath Connections (for unconnected inputs)
    assign WE3 = RegWrite;
    assign A1 = (Start == 1'b1) ? Instr[11:8] : ((RegSrc[0] == 1'b0) ? Instr[19:16] : 4'b1111);
    assign A2 = (RegSrc[1] == 1'b0) ? Instr[3:0] : Instr[15:12];
    assign A3 = (Start == 1'b1) ? Instr[19:16] : Instr[15:12];
    assign WD3 = Result;
    assign R15 = PCPlus8;
    
    //Extend Datapath Connections
    assign InstrImm = Instr[23:0];
    
    //Decoder Datapath Connections
    assign Rd = Instr[15:12];
    assign Op = Instr[27:26];
    assign Funct = Instr[25:20];
    
    //CondLogic Datapath Connections
    assign Cond = Instr[31:28];
    
    //Shifter Datapath Connections
    assign ShIn = RD2;
    assign Shamt5 = Instr[11:7];
    assign Sh = Instr[6:5];
    
    //ALU Datapath Connections
    assign Src_A = RD1;
    assign Src_B = (ALUSrc == 1'b0) ? ShOut : ExtImm;
    
    //Program Counter Datapath Connections
    assign WE_PC = ~Busy ; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
    assign PC_IN = (PCSrc == 1'b0) ? PCPlus4 : Result;
    
    //MCycle Datapath Connections
    assign Operand1 = RD2;
    assign Operand2 = RD1;
    assign MCycleFunct = Instr[7:4];
    
    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE3,
                    A1,
                    A2,
                    A3,
                    WD3,
                    R15,
                    RD1,
                    RD2     
                );
                
     // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Rd,
                    Op,
                    Funct,
                    MCycleFunct,
                    PCS,
                    RegW,
                    MemW,
                    MemtoReg,
                    ALUSrc,
                    ImmSrc,
                    RegSrc,
                    NoWrite,
                    ALUControl,
                    FlagW,
                    Start,
                    MCycleOp
                );
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(
                    CLK,
                    PCS,
                    RegW,
                    NoWrite,
                    MemW,
                    FlagW,
                    Cond,
                    ALUFlags,
                    PCSrc,
                    RegWrite,
                    MemWrite
                );
                
    // Instantiate Shifter        
    Shifter Shifter1(
                    Sh,
                    Shamt5,
                    ShIn,
                    ShOut
                );
                
    // Instantiate ALU        
    ALU ALU1(
                    Src_A,
                    Src_B,
                    ALUControl,
                    ALUResult,
                    ALUFlags
                );                
    
    // Instantiate ProgramCounter    
    ProgramCounter ProgramCounter1(
                    CLK,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    PC  
                );     
             
    // Instantiate MCycle
    MCycle MCycle1(
                    CLK,
                    RESET,
                    Start,
                    MCycleOp,
                    Operand1,
                    Operand2,
                    Result1,
                    Result2,
                    Busy
                );                       
endmodule








