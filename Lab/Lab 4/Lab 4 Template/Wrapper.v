`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Thao Nguyen and Rajesh Panicker
-- 
-- Create Date:   21:06:18 24/09/2015
-- Design Name: 	Wrapper (ARM Wrapper)
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool versions: Vivado 2015.2
-- Description: Wrapper for ARM processor. Not meant to be synthesized directly.
--
-- Revision 0.02
-- Additional Comments: See the notes below. The interface (entity) as well as implementation (architecture) can be modified
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

//>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is use as a component in TOP.vhd for Synthesis) ******* <<<<<<<<<<<<

module Wrapper
#(
	parameter N_LEDs_OUT      = 8,   // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs_OUT+1). 8 by default
	parameter N_DIPs = 16,           // Number of DIPs. 16 by default
	parameter N_PBs  = 3             // Number of PushButtons. 3 by default
		                             // [2:0] -> BTNL, BTNC, BTNR. Note that BTNU is used as PAUSE and BTND is used as RESET
)
(
	input  [N_DIPs-1:0] DIP, 		 		// DIP switch inputs. Not debounced. Mapped to 0x00000C04. 
	                                        // Only the least significant 16 bits read from this location are valid. 
	input  [N_PBs-1:0] PB,  				// PB switch inputs. Not debounced.	Mapped to 0x00000C08. 
	                                        // Only the least significant 4 bits read from this location are valid. Order (3 downto 0) -> BTNU, BTNL, BTNR, BTND.
	output reg [N_LEDs_OUT-1:0] LED_OUT, 	// LED(15 downto 8) mapped to 0x00000C00. Only the least significant 8 bits written to this location are used.
	output [6:0] LED_PC, 					// LED(6 downto 0) showing PC(8 downto 2).
	output reg [31:0] SEVENSEGHEX, 			// 7 Seg LED Display. Mapped to 0x00000C18. The 32-bit value will appear as 8 Hex digits on the display.
	output reg [7:0] CONSOLE_OUT,           // CONSOLE (UART) Output. Mapped to 0x00000C0C. The least significant 8 bits written to this location are sent to PC via UART.
											// Check if CONSOLE_OUT_ready (0x00000C14) is set before writing to this location (especially if your CLK_DIV_BITS is small).
											// Consecutive STRs to this location not permitted (there should be at least 1 instruction gap between STRs to this location).
	input	CONSOLE_OUT_ready,				// An indication to the wrapper/processor that it is ok to write to the CONSOLE_OUT (UART hardware).
	                                        //  This bit should be set in the testbench to indicate that it is ok to write a new character to CONSOLE_OUT from your program.
	                                        //  It can be read from the address 0x00000C14.
	output reg CONSOLE_OUT_valid,           // An indication to the UART hardware that the processor has written a new data byte to be transmitted.
	input  [7:0] CONSOLE_IN,                // CONSOLE (UART) Input. Mapped to 0x00000C0C. The least significant 8 bits read from this location is the character received from PC via UART.
	                                        // Check if CONSOLE_IN_valid flag (0x00000C10)is set before reading from this location.
											// Consecutive LDRs from this location not permitted (needs at least 1 instruction spacing between LDRs).
											// Also, note that there is no Tx FIFO implemented. DO NOT send characters from PC at a rate faster than 
											//  your processor (program) can read them. This means sending only 1 char every few seconds if your CLK_DIV_BITS is 26.
											// 	This is not a problem if your processor runs at a high speed.
	input  	CONSOLE_IN_valid,               // An indication to the wrapper/processor that there is a new data byte waiting to be read from the UART hardware.
	                                        // This bit should be set in the testbench to indicate a new character (Else, the processor will only read in 0x00).
											//  It can be read from the address 0x00000C10.
	output reg CONSOLE_IN_ack,              // An indication to the UART hardware that the processor has read the newly received data byte.
	                                        // The testbench should clear CONSOLE_IN_valid when this is set.
	input  RESET,							// Active high. Implemented in TOP as not(CPU_RESET) or Internal_reset (CPU_RESET is red push button and is active low).
	input  CLK								// Divided Clock from TOP.
);                                             

//----------------------------------------------------------------
// ARM signals
//----------------------------------------------------------------
wire[31:0] PC ;
wire[31:0] Instr ;
reg[31:0] ReadData ;
wire MemWrite ;
wire[31:0] ALUResult ;
wire[31:0] WriteData ;

//----------------------------------------------------------------
// Address Decode signals
//---------------------------------------------------------------
wire dec_DATA_CONST, dec_DATA_VAR, dec_LED, dec_DIP, dec_CONSOLE, dec_PB, dec_7SEG, dec_CONSOLE_IN_valid, dec_CONSOLE_OUT_ready;  // 'enable' signals from data memory address decoding

//----------------------------------------------------------------
// Memory declaration
//-----------------------------------------------------------------
reg [31:0] INSTR_MEM		[0:127]; // instruction memory
reg [31:0] DATA_CONST_MEM	[0:127]; // data (constant) memory
reg [31:0] DATA_VAR_MEM     [0:127]; // data (variable) memory

//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------

reg [8:0] i;

initial begin

            INSTR_MEM[0] = 32'hE59F11F8; 
			INSTR_MEM[1] = 32'hE59F21F8; 
			INSTR_MEM[2] = 32'hE59F31F8; 
			INSTR_MEM[3] = 32'hE59F4204; 
			INSTR_MEM[4] = 32'hE59F5218; 
			INSTR_MEM[5] = 32'hE59F6200; 
			INSTR_MEM[6] = 32'hE59F7210; 
			INSTR_MEM[7] = 32'hE59F820C; 
			INSTR_MEM[8] = 32'hE59FB1FC; 
			INSTR_MEM[9] = 32'hE07BC006; 
			INSTR_MEM[10] = 32'hE0FBC006; 
			INSTR_MEM[11] = 32'hE0DBC006; 
			INSTR_MEM[12] = 32'hE0FBC006; 
			INSTR_MEM[13] = 32'hE2ACD066; 
			INSTR_MEM[14] = 32'hE11B000C; 
			INSTR_MEM[15] = 32'hE33C0002; 
			INSTR_MEM[16] = 32'hE59FC200; 
			INSTR_MEM[17] = 32'hE584C000; 
			INSTR_MEM[18] = 32'hE59FC1DC; 
			INSTR_MEM[19] = 32'hE00D0C9C; 
			INSTR_MEM[20] = 32'hE59FF218; 
			INSTR_MEM[21] = 32'hE386C0FF; 
			INSTR_MEM[22] = 32'hE096D3CC; 
			INSTR_MEM[23] = 32'hE59FD1C4; 
			INSTR_MEM[24] = 32'hE09DC0AC; 
			INSTR_MEM[25] = 32'h600CC006; 
			INSTR_MEM[26] = 32'h415C000C; 
			INSTR_MEM[27] = 32'h017D008D; 
			INSTR_MEM[28] = 32'h2591C004; 
			INSTR_MEM[29] = 32'h2502C004; 
			INSTR_MEM[30] = 32'h225BB001; 
			INSTR_MEM[31] = 32'hAAFFFFE8; 
			INSTR_MEM[32] = 32'hEA000000; 
			INSTR_MEM[33] = 32'hEAFFFFF2; 
			INSTR_MEM[34] = 32'hE35500FA; 
			INSTR_MEM[35] = 32'hD59F61A0; 
			INSTR_MEM[36] = 32'hE35500E1; 
			INSTR_MEM[37] = 32'hC5846000; 
			INSTR_MEM[38] = 32'hE35500E1; 
			INSTR_MEM[39] = 32'hD59F6194; 
			INSTR_MEM[40] = 32'hE35500C8; 
			INSTR_MEM[41] = 32'hC5846000; 
			INSTR_MEM[42] = 32'hE35500C8; 
			INSTR_MEM[43] = 32'hD59F6188; 
			INSTR_MEM[44] = 32'hE35500AF; 
			INSTR_MEM[45] = 32'hC5846000; 
			INSTR_MEM[46] = 32'hE35500AF; 
			INSTR_MEM[47] = 32'hD59F6158; 
			INSTR_MEM[48] = 32'hD5846000; 
			INSTR_MEM[49] = 32'hE5936000; 
			INSTR_MEM[50] = 32'hE58F5730; 
			INSTR_MEM[51] = 32'hE3560004; 
			INSTR_MEM[52] = 32'h059F7728; 
			INSTR_MEM[53] = 32'hE3560001; 
			INSTR_MEM[54] = 32'h059F8720; 
			INSTR_MEM[55] = 32'hE3560005; 
			INSTR_MEM[56] = 32'h059F7718; 
			INSTR_MEM[57] = 32'h059F8714; 
			INSTR_MEM[58] = 32'hE2555001; 
			INSTR_MEM[59] = 32'h1AFFFFE5; 
			INSTR_MEM[60] = 32'hEAFFFFFF; 
			INSTR_MEM[61] = 32'hE5936000; 
			INSTR_MEM[62] = 32'hE58F5700; 
			INSTR_MEM[63] = 32'hE3560004; 
			INSTR_MEM[64] = 32'h059F76F8; 
			INSTR_MEM[65] = 32'hE3560001; 
			INSTR_MEM[66] = 32'h059F86F0; 
			INSTR_MEM[67] = 32'hE3560005; 
			INSTR_MEM[68] = 32'h059F76E8; 
			INSTR_MEM[69] = 32'h059F86E4; 
			INSTR_MEM[70] = 32'hE2855001; 
			INSTR_MEM[71] = 32'hE3550064; 
			INSTR_MEM[72] = 32'h1AFFFFF3; 
			INSTR_MEM[73] = 32'hEAFFFFFF; 
			INSTR_MEM[74] = 32'hE1570008; 
			INSTR_MEM[75] = 32'hC59F6110; 
			INSTR_MEM[76] = 32'hC5846000; 
			INSTR_MEM[77] = 32'hB59F6104; 
			INSTR_MEM[78] = 32'hB5846000; 
			INSTR_MEM[79] = 32'h059F6104; 
			INSTR_MEM[80] = 32'h05846000; 
			INSTR_MEM[81] = 32'hEAFFFFFF; 
			INSTR_MEM[82] = 32'hE5926000; 
			INSTR_MEM[83] = 32'hE5816000; 
			INSTR_MEM[84] = 32'hEAFFFFFC; 
			INSTR_MEM[85] = 32'hEAFFFFFE; 
			for(i = 86; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end
end

//----------------------------------------------------------------
// Data (Constant) Memory
//----------------------------------------------------------------
initial begin

            DATA_CONST_MEM[0] = 32'h00000C00; 
			DATA_CONST_MEM[1] = 32'h00000C04; 
			DATA_CONST_MEM[2] = 32'h00000C08; 
			DATA_CONST_MEM[3] = 32'h00000C0C; 
			DATA_CONST_MEM[4] = 32'h00000C10; 
			DATA_CONST_MEM[5] = 32'h00000C14; 
			DATA_CONST_MEM[6] = 32'h00000C18; 
			DATA_CONST_MEM[7] = 32'h00000000; 
			DATA_CONST_MEM[8] = 32'h000000FF; 
			DATA_CONST_MEM[9] = 32'h00000064; 
			DATA_CONST_MEM[10] = 32'h7FFFFFFF; 
			DATA_CONST_MEM[11] = 32'hFFFFFFFF; 
			DATA_CONST_MEM[12] = 32'h000000FA; 
			DATA_CONST_MEM[13] = 32'h01000100; 
			DATA_CONST_MEM[14] = 32'h00900090; 
			DATA_CONST_MEM[15] = 32'h00800080; 
			DATA_CONST_MEM[16] = 32'hAAAAAAAA; 
			DATA_CONST_MEM[17] = 32'hBBBBBBBB; 
			DATA_CONST_MEM[18] = 32'hAAAABBBB; 
			DATA_CONST_MEM[19] = 32'h00000800; 
			DATA_CONST_MEM[20] = 32'hABCD1234; 
			DATA_CONST_MEM[21] = 32'h65570A0D; 
			DATA_CONST_MEM[22] = 32'h6D6F636C; 
			DATA_CONST_MEM[23] = 32'h6F742065; 
			DATA_CONST_MEM[24] = 32'h33474320; 
			DATA_CONST_MEM[25] = 32'h2E373032; 
			DATA_CONST_MEM[26] = 32'h000A0D2E; 
			DATA_CONST_MEM[27] = 32'h00000254; 
			DATA_CONST_MEM[28] = 32'h00000084; 
			for(i = 29; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

//----------------------------------------------------------------
// Data (Variable) Memory
//----------------------------------------------------------------
initial begin
end

//----------------------------------------------------------------
// Debug LEDs
//----------------------------------------------------------------
assign LED_PC = PC[15-N_LEDs_OUT+1 : 2]; // debug showing PC

//----------------------------------------------------------------
// ARM port map
//----------------------------------------------------------------
ARM ARM1(
	CLK,
	RESET,
	Instr,
	ReadData,
	MemWrite,
	PC,
	ALUResult,
	WriteData
);

//----------------------------------------------------------------
// Data memory address decoding
//----------------------------------------------------------------
assign dec_DATA_CONST		= (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
assign dec_DATA_VAR			= (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;
assign dec_LED				= (ALUResult == 32'h00000C00) ? 1'b1 : 1'b0;
assign dec_DIP				= (ALUResult == 32'h00000C04) ? 1'b1 : 1'b0;
assign dec_PB 		   		= (ALUResult == 32'h00000C08) ? 1'b1 : 1'b0;
assign dec_CONSOLE	   		= (ALUResult == 32'h00000C0C) ? 1'b1 : 1'b0;
assign dec_CONSOLE_IN_valid	= (ALUResult == 32'h00000C10) ? 1'b1 : 1'b0;
assign dec_CONSOLE_OUT_ready= (ALUResult == 32'h00000C14) ? 1'b1 : 1'b0;
assign dec_7SEG	    		= (ALUResult == 32'h00000C18) ? 1'b1 : 1'b0;

//----------------------------------------------------------------
// Data memory read
//----------------------------------------------------------------
always@( * ) begin
if (dec_DIP)
	ReadData <= { {31-N_DIPs+1{1'b0}}, DIP } ; 
else if (dec_PB)
	ReadData <= { {31-N_PBs+1{1'b0}}, PB } ; 
else if (dec_DATA_VAR)
	ReadData <= DATA_VAR_MEM[ALUResult[8:2]] ; 
else if (dec_DATA_CONST)
	ReadData <= DATA_CONST_MEM[ALUResult[8:2]] ; 
else if (dec_CONSOLE && CONSOLE_IN_valid)
	ReadData <= {24'b0, CONSOLE_IN};
else if (dec_CONSOLE_IN_valid)
	ReadData <= {31'b0, CONSOLE_IN_valid};	
else if (dec_CONSOLE_OUT_ready)
	ReadData <= {31'b0, CONSOLE_OUT_ready};		
else
	ReadData <= 32'h0 ; 
end
			
//----------------------------------------------------------------
// Instruction memory read
//----------------------------------------------------------------
assign Instr = ( (PC >= 32'h00000000) && (PC <= 32'h000001FC) ) ? // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
                 INSTR_MEM[PC[8:2]] : 32'h00000000 ; 

//----------------------------------------------------------------
// Console read / write
//----------------------------------------------------------------
always @(posedge CLK) begin
	CONSOLE_OUT_valid <= 1'b0;
	CONSOLE_IN_ack <= 1'b0;
	if (MemWrite && dec_CONSOLE && CONSOLE_OUT_ready)
	begin
		CONSOLE_OUT <= WriteData[7:0];
		CONSOLE_OUT_valid <= 1'b1;
	end
	if (!MemWrite && dec_CONSOLE && CONSOLE_IN_valid)
		CONSOLE_IN_ack <= 1'b1;
end
// Possible spurious CONSOLE_IN_ack and a lost character since we don't have a MemRead signal. Make sure ALUResult is never 0xC0C other than when accessing UART.
// Also, the character received from PC in the CLK cycle immediately following a character read by the processor is lost. This is not that much of a problem in practice though.

//----------------------------------------------------------------
// Data Memory-mapped LED write
//----------------------------------------------------------------
always@(posedge CLK) begin
    if(RESET)
        LED_OUT <= 0 ;
    else if( MemWrite && dec_LED ) 
        LED_OUT <= WriteData[N_LEDs_OUT-1 : 0] ;
end

//----------------------------------------------------------------
// SevenSeg LED Display write
//----------------------------------------------------------------
always @(posedge CLK) begin
	if (RESET)
		SEVENSEGHEX <= 32'b0;
	else if (MemWrite && dec_7SEG)
		SEVENSEGHEX <= WriteData;
end

//----------------------------------------------------------------
// Data Memory write
//----------------------------------------------------------------
always@(posedge CLK) begin
    if( MemWrite && dec_DATA_VAR ) 
        DATA_VAR_MEM[ALUResult[8:2]] <= WriteData ;
end

endmodule
