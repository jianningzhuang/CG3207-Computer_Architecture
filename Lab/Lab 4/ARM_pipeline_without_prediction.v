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
    
    //FETCH STAGE SIGNALS
    wire [31:0] PCF ;
    wire [31:0] PCPlus4F ;
    wire [31:0] InstrF ;
    
    //ProgramCounter signals (in Fetch Stage)
    //wire CLK ;
    //wire RESET ;
    wire WE_PC ;    
    wire [31:0] PC_IN ;
    //wire [31:0] PC ; 
    
    //DECODE STAGE SIGNALS
    
    //Pipeline Registers
    reg [31:0] InstrD = 32'h00000000;
    
    //Internal Signals
    wire [31:0] PCPlus8D ;
    wire [3:0] CondD ;
    wire [3:0] WA3D ;
    wire [3:0] RA1D ;
    wire [3:0] RA2D ;
    wire [31:0] RD1D ;
    wire [31:0] RD2D ;
    
    //RegFile signals (in Decode Stage)
    //wire CLK ;
    wire WE3 ;
    wire [3:0] A1 ;
    wire [3:0] A2 ;
    wire [3:0] A3 ;
    wire [31:0] WD3 ;
    wire [31:0] R15 ;
    wire [31:0] RD1 ;
    wire [31:0] RD2 ;
    
    //Decoder signals (in Decode Stage)
    wire [3:0] Rd ;
    wire [1:0] Op ;
    wire [5:0] Funct ;
    wire [3:0] MCycleFunct;
    wire PCSD ;
    wire PCWLDRD ;
    wire RegWD ;
    wire MemWD ;
    wire MemtoRegD ;
    wire ALUSrcD ;
    wire [1:0] ImmSrcD ;
    wire [1:0] RegSrcD ;
    wire NoWriteD ;
    wire [3:0] ALUControlD ;
    wire [1:0] FlagWD ;
    wire StartD ;
    wire [1:0] MCycleOpD ;
    
    //Extend Module signals (in Decode Stage)
    //wire [1:0] ImmSrcD ;
    wire [23:0] InstrImmD ;
    wire [31:0] ExtImmD ;
    
    // Shifter signals (in Decode Stage)
    wire [1:0] ShD ;
    wire [4:0] Shamt5D ;

    
    //EXECUTE STAGE SIGNALS
    
    //Pipeline Registers
    reg PCSE = 0;
    reg PCWLDRE = 0;
    reg RegWE = 0;
    reg MemWE = 0;
    reg [1:0] FlagWE = 2'b00;
    reg [3:0] ALUControlE = 4'b0000;
    reg MemtoRegE = 0;
    reg ALUSrcE = 0;
    reg NoWriteE = 0;
    reg StartE = 0;
    reg [1:0] MCycleOpE = 2'b00;
     
    reg [3:0] CondE = 4'b0000;
    reg [3:0] RA1E = 4'b0000;
    reg [3:0] RA2E = 4'b0000;
    reg [3:0] WA3E = 4'b0000;
    reg [31:0] RD1E = 32'h00000000;
    reg [31:0] RD2E = 32'h00000000;
    reg [4:0] Shamt5E = 5'b00000;
    reg [1:0] ShE = 2'b00;
    reg [31:0] ExtImmE = 32'h00000000;
    
    //Internal Signals
    wire [31:0] ForwardedAE; 
    wire [31:0] ForwardedBE; 
    wire [31:0] WriteDataE;
    
    //Shifter signals (in Execute Stage)
    //reg [1:0] ShE ;
    //reg [4:0] Shamt5E ;
    wire [31:0] ShInE ;
    wire [31:0] ShOutE ;
    
    //ALU signals (in Execute Stage)
    wire [31:0] Src_AE ;
    wire [31:0] Src_BE ;
    //wire [3:0] ALUControlE ;
    //wire C_FlagE ; 
    wire [31:0] ALUResultE ;
    wire [3:0] ALUFlagsE ;  
    
    //CondLogic signals (in Execute Stage)
    //wire CLK ;
    //reg PCSE ;
    //reg RegWE ;
    //reg NoWriteE ;
    //reg MemWE ;
    //reg [1:0] FlagWE ;
    //reg [3:0] CondE ;
    //wire [3:0] ALUFlagsE,
    wire PCSrcE ;
    wire PCWriteLDRE ;
    wire RegWriteE ; 
    wire MemWriteE ;
    wire C_FlagE ;  //output from the CondLogic component/module, to act as an input for the ALU component/module (to support ADC instruction) 
    
    //MCycle signals (in Execute Stage)
    //wire CLK ;
    //wire RESET ;
    //wire StartE ;
    //wire [1:0] MCycleOpE ;
    wire [31:0] Operand1E ;
    wire [31:0] Operand2E ;
    wire [31:0] Result1E ;
    wire [31:0] Result2E ;
    wire BusyE ;
    
    
    //MEMORY STAGE SIGNALS
    
    //Pipeline Registers
    reg PCWriteLDRM = 0;
    reg RegWriteM = 0;
    reg MemWriteM = 0;
    reg MemtoRegM = 0;
    reg StartM = 0;
    reg [3:0] RA2M = 4'b0000;
    reg [3:0] WA3M = 4'b0000;
    reg [31:0] ALUResultM = 32'h00000000;
    reg [31:0] WriteDataM = 32'h00000000;
    reg [31:0] Result1M = 32'h00000000;
    
    //Internal Signals
    wire [31:0] ReadDataM;
    wire [31:0] ExecuteResultM ;
    wire [31:0] ForwardedWriteDataM; 
    
    //WRITEBACK STAGE SIGNALS
    
    //Pipeline Registers
    reg PCWriteLDRW = 0;
    reg RegWriteW = 0;
    reg MemtoRegW = 0;
    reg [31:0] ReadDataW = 32'h00000000;
    reg [31:0] ExecuteResultW = 32'h00000000;
    reg [3:0] WA3W = 4'b0000;
    
    //Internal Signals
    wire [31:0] ResultW;
    
    
    //HAZARD SIGNALS
    wire StallF ;
    wire StallD ;
    wire FlushD ;
    wire ForwardAD ;
    wire ForwardBD ;
    //wire [3:0] RA1D ;
    //wire [3:0] RA2D ;
    wire StallE ;
    wire FlushE ;
    wire [1:0] ForwardAE ;
    wire [1:0] ForwardBE ;
    //reg [3:0] RA1E ;
    //reg [3:0] RA2E ;
    //reg [3:0] WA3E ;
    //reg MemtoRegE ;
    //reg RegWriteE
    //wire PCSrcE ;
    wire FlushM ;
    wire ForwardM ;
    //reg [3:0] WA3M ;
    //reg RegWriteM ; 
    //reg [3:0] RA2M ;
    //reg MemWriteM ;
    //reg [3:0] WA3W ;
    //reg RegWriteW ; 
    //reg MemtoRegW ;
    
    
    //DYNAMIC BRANCH PREDICTION
    
    //Pipeline Registers
    reg [31:0] PrALUResultD = 32'h00000000;
    reg [31:0] PrALUResultE = 32'h00000000;
    reg PrPCSrcD = 0;
    reg PrPCSrcE = 0;
    reg [31:0] PCD = 32'h00000000;
    reg [31:0] PCE = 32'h00000000;
    reg [31:0] PCPlus4D = 32'h00000000;
    reg [31:0] PCPlus4E = 32'h00000000;
    
    //Internal Signals
    wire BranchMispredicted;
    wire BTAMispredicted;
    wire Mispredicted;
    wire PC_IN_Src;

    wire PrPCSrcF;
    wire [31:0] PrALUResultF;

    
    //FETCH STAGE CONNECTIONS
    
    assign PCF = PC;
    assign PCPlus4F = PCF + 32'h00000004;
    assign InstrF = Instr;
    
    //Program Counter Datapath Connections
    assign WE_PC = ~StallF ; // Will need to control it for multi-cycle operations (Multiplication, Division) and/or Pipelining with hazard hardware.
   
    assign PC_IN_Src = Mispredicted;
    assign PC_IN = (PCWriteLDRW == 1'b1) ? ResultW : ((PCSrcE == 1'b0) ? PCPlus4F : ALUResultE);
    
    
    //DECODE STAGE CONNECTIONS
    
    //Update/Stall/Clear Pipeline Register
    always @ (posedge CLK)
    begin
        if (RESET | FlushD)
        begin
            InstrD <= 32'h00000000; //clear pipeline register
            
            PrALUResultD <= 32'h00000000;
            PrPCSrcD <= 0;
            PCD <= 32'h00000000;
            PCPlus4D <= 32'h00000000;
            
        end
        else if (~StallD)
        begin
            InstrD <= InstrF;
            
            PrALUResultD <= PrALUResultF;
            PrPCSrcD <= PrPCSrcF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
        else
        begin
            //stall signals
        end
    end
    
    assign CondD = InstrD[31:28];
    assign RA1D = (StartD == 1'b1) ? InstrD[11:8] : ((RegSrcD[0] == 1'b0) ? InstrD[19:16] : 4'b1111);
    assign RA2D = (RegSrcD[1] == 1'b0) ? InstrD[3:0] : InstrD[15:12];
    assign WA3D = (StartD == 1'b1) ? InstrD[19:16] : InstrD[15:12];
    assign PCPlus8D = PCPlus4F;
    assign RD1D = (ForwardAD == 1'b1) ? ResultW : RD1;
    assign RD2D = (ForwardBD == 1'b1) ? ResultW : RD2;
    
    //Decoder Datapath Connections
    assign Rd = InstrD[15:12];
    assign Op = InstrD[27:26];
    assign Funct = InstrD[25:20];
    assign MCycleFunct = InstrD[7:4];
    
    //RegFile Datapath Connections
    assign WE3 = RegWriteW;
    assign A1 = RA1D;
    assign A2 = RA2D;
    assign A3 = WA3W;
    assign WD3 = ResultW;
    assign R15 = PCPlus8D;
    
    //Extend Datapath Connections
    assign InstrImmD = InstrD[23:0];
    
    //Shifter Datapath Connections
    assign Shamt5D = InstrD[11:7];
    assign ShD = InstrD[6:5];
    
    //EXECUTE STAGE CONNECTIONS
    
    //Update/Stall/Clear Pipeline Register
    always @ (posedge CLK)
    begin
        if (RESET | FlushE)
        begin 
            PCSE <= 0;
            PCWLDRE <= 0;
            RegWE <= 0;
            MemWE <= 0;
            FlagWE <= 2'b00;
            ALUControlE <= 4'b0000;
            MemtoRegE <= 0;
            ALUSrcE <= 0;
            NoWriteE <= 0;
            StartE <= 0;
            MCycleOpE <= 2'b00;
    
            CondE <= 4'b0000;
            RA1E <= 4'b0000;
            RA2E <= 4'b0000;
            WA3E <= 4'b0000;
            RD1E <= 32'h00000000;
            RD2E <= 32'h00000000;
            Shamt5E <= 5'b00000;
            ShE <= 2'b00;
            ExtImmE <= 32'h00000000;
            
            PrALUResultE <= 32'h00000000;
            PrPCSrcE <= 0;
            PCE <= 32'h00000000;
            PCPlus4E <= 32'h00000000;
        end
        else if (~StallE)
        begin
            PCSE <= PCSD;
            PCWLDRE <= PCWLDRD;
            RegWE <= RegWD;
            MemWE <= MemWD;
            FlagWE <= FlagWD;
            ALUControlE <= ALUControlD;
            MemtoRegE <= MemtoRegD;
            ALUSrcE <= ALUSrcD;
            NoWriteE <= NoWriteD;
            StartE <= StartD;
            MCycleOpE <= MCycleOpD;
    
            CondE <= CondD;
            RA1E <= RA1D;
            RA2E <= RA2D;
            WA3E <= WA3D;
            RD1E <= RD1D;
            RD2E <= RD2D;
            Shamt5E <= Shamt5D;
            ShE <= ShD;
            ExtImmE <= ExtImmD;
            
            PrALUResultE <= PrALUResultD;
            PrPCSrcE <= PrPCSrcD;
            PCE <= PCD;
            PCPlus4E <= PCPlus4D;
        end
        else
        begin
            //stall signals
        end
    end
    
    //Forwarded Data
    assign ForwardedAE = (ForwardAE[1] == 1'b1) ? ExecuteResultM : ((ForwardAE[0] == 1'b1) ? ResultW : RD1E);
    assign ForwardedBE = (ForwardBE[1]== 1'b1) ? ExecuteResultM : ((ForwardBE[0] == 1'b1) ? ResultW : RD2E);
    
    //Shifter Datapath Connections
    assign ShInE = ForwardedBE;
    
    //ALU Datapath Connections
    assign Src_AE = ForwardedAE;
    assign Src_BE = (ALUSrcE == 1'b0) ? ShOutE : ExtImmE;
    
    //MCycle Datapath Connections
    assign Operand1E = ForwardedBE;
    assign Operand2E = ForwardedAE;

    assign WriteDataE = ForwardedBE;
    
    //MEMORY STAGE CONNECTIONS
    
    //Update/Stall/Clear Pipeline Register
    always @ (posedge CLK)
    begin
        if (RESET | FlushM) 
        begin
            PCWriteLDRM <= 0;
            RegWriteM <= 0;
            MemWriteM <= 0;
            MemtoRegM <= 0;
            StartM <= 0;
            RA2M <= 4'b0000;
            WA3M <= 4'b0000;
            ALUResultM <= 32'h00000000;
            WriteDataM <= 32'h00000000;
            Result1M <= 32'h00000000;
        end
        else 
        begin
            PCWriteLDRM <= PCWriteLDRE;
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            MemtoRegM <= MemtoRegE;
            StartM <= StartE;
            RA2M <= RA2E;
            WA3M <= WA3E;
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            Result1M <= Result1E;
        end
    end
    
    //Forwarded Data
    assign ForwardedWriteDataM = ForwardM ? ResultW : WriteDataM;
    
    assign ALUResult = ALUResultM;
    assign WriteData = ForwardedWriteDataM;
    assign MemWrite = MemWriteM;
    assign ReadDataM = ReadData;
    assign ExecuteResultM = (StartM) ? Result1M : ALUResultM;
    
    //WRITEBACK STAGE CONNECTIONS
    
    always @ (posedge CLK)
    begin
        if (RESET)
        begin
            PCWriteLDRW <= 0;
            RegWriteW <= 0;
            MemtoRegW <= 0;
            ReadDataW <= 32'h00000000;
            ExecuteResultW <= 32'h00000000;
            WA3W <= 4'b0000;
        end
        else 
        begin
            PCWriteLDRW <= PCWriteLDRM;
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            ReadDataW <= ReadDataM;
            ExecuteResultW <= ExecuteResultM;
            WA3W <= WA3M;
        end
    end
    
    assign ResultW = (MemtoRegW == 1'b0) ? ExecuteResultW : ReadDataW;
    
    
    //Branch Prediction Connections
    assign BTAMispredicted = PCSrcE & (ALUResultE != PrALUResultE);
    assign BranchMispredicted = PCSrcE ^ PrPCSrcE;
    //assign Mispredicted = BTAMispredicted | BranchMispredicted | PCWriteLDRW;
    assign Mispredicted = PCWriteLDRM | PCWriteLDRW;
    
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
                    ImmSrcD,
                    InstrImmD,
                    ExtImmD
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Rd,
                    Op,
                    Funct,
                    MCycleFunct,
                    PCSD,
                    PCWLDRD,
                    RegWD,
                    MemWD,
                    MemtoRegD,
                    ALUSrcD,
                    ImmSrcD,
                    RegSrcD,
                    NoWriteD,
                    ALUControlD,
                    FlagWD,
                    StartD,
                    MCycleOpD
                );
                                
    // Instantiate CondLogic
    CondLogic CondLogic1(
                    CLK,
                    PCSE,
                    PCWLDRE,
                    RegWE,
                    NoWriteE,
                    MemWE,
                    FlagWE,
                    CondE,
                    ALUFlagsE,
                    PCSrcE,
                    PCWriteLDRE,
                    RegWriteE,
                    MemWriteE,
                    C_FlagE
                );
                
    // Instantiate Shifter        
    Shifter Shifter1(
                    ShE,
                    Shamt5E,
                    ShInE,
                    ShOutE
                );
                
    // Instantiate ALU        
    ALU ALU1(
                    Src_AE,
                    Src_BE,
                    ALUControlE,
                    C_FlagE,
                    ALUResultE,
                    ALUFlagsE
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
                    StartE,
                    MCycleOpE,
                    Operand1E,
                    Operand2E,
                    Result1E,
                    Result2E,
                    BusyE
                ); 
                    
    // Instantiate Hazard Unit
    HazardUnit HazardUnit1(
                    StallF,
                    StallD,
                    FlushD,
                    ForwardAD,
                    ForwardBD,
                    RA1D,
                    RA2D,
                    StallE,
                    FlushE,
                    ForwardAE,
                    ForwardBE,
                    RA1E,
                    RA2E,
                    WA3E,
                    MemtoRegE,
                    RegWriteE,
                    PCSrcE,
                    Mispredicted,
                    FlushM,
                    ForwardM,
                    WA3M,
                    RegWriteM,
                    RA2M,
                    MemWriteM,
                    WA3W,
                    RegWriteW,
                    MemtoRegW,
                    BusyE
                );  
    // Instantiate MCycle
//    BHT BHT1(
//                    CLK,
//                    BranchMispredicted,
//                    BTAMispredicted,
//                    PCSrcE,
//                    PCF[7:0],
//                    PCE[7:0],
//                    ALUResultE,
//                    PrPCSrcF,
//                    PrALUResultF
//                ); 
               
                          
endmodule








