`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date:   21:06:18 24/09/2015
-- Design Name: 	ALU
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: Vivado 2015.2
-- Description: ALU Module
--
-- Dependencies:
--
-- Revision: 
-- Revision 0.01
-- Additional Comments: 
----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [3:0] ALUControl,
    input C_Flag,
    output [31:0] ALUResult,
    output [3:0] ALUFlags
    );
    
    wire [32:0] S_wider ;
    reg [32:0] Src_A_comp ;
    reg [32:0] Src_B_comp ;
    reg [31:0] ALUResult_i ;
    reg [32:0] C_0 ;
    wire N, Z, C ;
    reg V ;
    
    assign S_wider = Src_A_comp + Src_B_comp + C_0 ;
    
    always@(Src_A, Src_B, ALUControl, S_wider) begin
        // default values; help avoid latches
        C_0 <= 0 ; 
        Src_A_comp <= {1'b0, Src_A} ;
        Src_B_comp <= {1'b0, Src_B} ;
        ALUResult_i <= Src_B ;
        V <= 0 ;
    
        case(ALUControl)
            4'b0100:  //ADD, CMN
            begin
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ~^ Src_B[31] )  & ( Src_A[31] ^ S_wider[31] );          
            end
            4'b0101:  //ADC
            begin
                C_0 <= C_Flag;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ~^ Src_B[31] )  & ( Src_A[31] ^ S_wider[31] );  //overflow with carry has 3 terms?        
            end
            
            4'b0010:  //SUB, CMP
            begin
                C_0[0] <= 1 ;  
                Src_B_comp <= {1'b0, ~ Src_B} ;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ^ Src_B[31] )  & ( Src_A[31] ^ S_wider[31] );       
            end
            
            4'b0110:  //SBC
            begin
                C_0[0] <= C_Flag ;  
                Src_B_comp <= {1'b0, ~ Src_B} ;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ^ Src_B[31] )  & ( Src_A[31] ^ S_wider[31] );       
            end
            
            4'b0011:  //RSB
            begin
                C_0[0] <= 1 ;  
                Src_A_comp <= {1'b0, ~ Src_A} ;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ^ Src_B[31] )  & ( Src_B[31] ^ S_wider[31] );      //B and S opposite sign, A and B opposite sign
            end
            
            4'b0111:  //RSC
            begin
                C_0[0] <= C_Flag ;  
                Src_A_comp <= {1'b0, ~ Src_A} ;
                ALUResult_i <= S_wider[31:0] ;
                V <= ( Src_A[31] ^ Src_B[31] )  & ( Src_B[31] ^ S_wider[31] );       
            end
            
            4'b0000: ALUResult_i <= Src_A & Src_B ;  //AND, TST
            
            4'b1100: ALUResult_i <= Src_A | Src_B ;  //ORR
            
            4'b0001: ALUResult_i <= Src_A ^ Src_B ;  //EOR, TEQ
            
            4'b1110: ALUResult_i <= Src_A & (~Src_B) ;  //BIC
            
            4'b1101: ALUResult_i <= Src_B ;  //MOV 
            
            4'b1111: ALUResult_i <= ~Src_B ;  //MVN        
        endcase ;
    end
    
    assign N = ALUResult_i[31] ;
    assign Z = (ALUResult_i == 0) ? 1 : 0 ;
    assign C = S_wider[32] ;
    
    assign ALUResult = ALUResult_i ;
    assign ALUFlags = {N, Z, C, V} ;
        
endmodule













