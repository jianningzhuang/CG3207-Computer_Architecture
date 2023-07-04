`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
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

module Decoder(
    input [3:0] Rd,
    input [1:0] Op,
    input [5:0] Funct,
    input [3:0] MCycleFunct,
    output PCS,
    output PCWLDR,
    output RegW,
    output MemW,
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [1:0] RegSrc,
    output NoWrite,
    output reg [3:0] ALUControl,
    output reg [1:0] FlagW,
    output Start,
    output [1:0] MCycleOp
    );
    
    wire Branch;
    wire [1:0] ALUOp;
    reg [9:0] controls;
    
    //Main Decoder
    assign Branch = (Op == 2'b10);
    
    assign MemtoReg = (Op == 2'b01) & (Funct[0] == 1'b1);
    
    assign MemW = (Op == 2'b01) & (Funct[0] == 1'b0);
    
    assign ALUSrc = ~((Op == 2'b00) & (Funct[5] == 1'b0));
    
    assign ImmSrc = Op;
    
    assign RegW = (Op == 2'b00) | ((Op == 2'b01) & (Funct[0] == 1'b1));
    
    assign RegSrc[0] = (Op == 2'b10);
    
    assign RegSrc[1] = ((Op == 2'b01) && (Funct[0] == 1'b0));
    
    assign ALUOp[0] = (Op == 2'b00);
    
    assign ALUOp[1] = (Op == 2'b01) & (Funct[3] == 1'b0); //Negative offset LDR/STR
    
    // Start is set when the instruction is a MUL or DIV, when Instr[27:22] is 0 and Instr[7:4] is 4'b1001
    assign Start = (Op == 2'b00) & (Funct[5:2] == 4'b0000) & (MCycleFunct == 4'b1001);
    
    // Instr[21] = 0 for MUL and Instr[21] = 1 for DIV, 2'b01 = unsigned multiplication, 2'b11 = unsigned division
    assign MCycleOp = (Start & Funct[1]) ? 2'b11 : 2'b01; 
    
    
    //PC Logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    assign PCWLDR = (Rd == 4'b1111) & RegW & (Op == 2'b01) & (Funct[0] == 1'b1); //LDR PC
    
    
    //ALU Decoder
    assign NoWrite = (Funct[4:1] == 4'b1000 | Funct[4:1] == 4'b1001 | Funct[4:1] == 4'b1010 | Funct[4:1] == 4'b1011) & (ALUOp[0] == 1'b1); //TST, TEQ, CMP, CMN only update flags
    
    always @ (ALUOp, Funct[4:0])
    begin
        if (ALUOp[0])
        begin
            case (Funct[4:1])
                4'b0000: //AND
                begin
                    ALUControl <= 4'b0000;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end
                4'b0001: //EOR
                begin
                    ALUControl <= 4'b0001;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end
                4'b0010: //SUB
                begin
                    ALUControl <= 4'b0010;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b0011: //RSB
                begin
                    ALUControl <= 4'b0011;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b0100: //ADD
                begin
                    ALUControl <= 4'b0100;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b0101: //ADC
                begin
                    ALUControl <= 4'b0101;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b0110: //SBC
                begin
                    ALUControl <= 4'b0110;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b0111: //RSC
                begin
                    ALUControl <= 4'b0111;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                end
                4'b1000: //TST
                begin
                    ALUControl <= 4'b0000;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00; //corresponding instr with S bit clear is not DP, so still check S bit?)
                end
                4'b1001: //TEQ
                begin
                    ALUControl <= 4'b0001;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00; //corresponding instr with S bit clear is not DP, so still check S bit?)
                end
                4'b1010: //CMP
                begin
                    ALUControl <= 4'b0010;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00; //corresponding instr with S bit clear is not DP, so still check S bit?)
                end
                4'b1011: //CMN
                begin
                    ALUControl <= 4'b0100;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b11 : 2'b00; //corresponding instr with S bit clear is not DP, so still check S bit?)
                end
                4'b1100: //ORR
                begin
                    ALUControl <= 4'b1100;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end
                4'b1101: //MOV
                begin
                    ALUControl <= 4'b1101;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end
                4'b1110: //BIC
                begin
                    ALUControl <= 4'b1110;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end
                4'b1111: //MVN
                begin
                    ALUControl <= 4'b1111;
                    FlagW <= (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                end

                default: 
                begin
                    ALUControl <= 4'b0100;
                    FlagW <= 2'b00;
                end
            endcase   
        end
        else 
        begin
            ALUControl <= (ALUOp[1] == 1'b1) ? 4'b0010 : 4'b0100; //LDR/STR ALU, else case also include B signed immediate addition
            FlagW <= 2'b00;
        end
        
        
    end
endmodule





