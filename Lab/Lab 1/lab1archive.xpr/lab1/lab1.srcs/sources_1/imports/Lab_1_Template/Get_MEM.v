`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This module should contain the corresponding Memory data generated from Hex2ROM
// and choose the memory data to be displayed based on enable signal  
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////


module Get_MEM(
    input clk,					// fundamental clock 100MHz
	input enable,				// enable signal to read the next content
	output [31:0] data,			// 32 bits memory contents for 7-segments display
    output upper_lower);      	// 1-bit signal rerequied for LEDs, indicating which half of the Memory data is displaying on LEDs
								// upper_lower = 1 to display upper half of the Memory data on LEDs
    
// declare INSTR_MEM and DATA_CONST_MEM
reg [31:0] INSTR_MEM [0:127];
reg [31:0] DATA_CONST_MEM [0:127];

// declare indics of INSTR_MEM and DATA_CONST_MEM
reg [8:0] addr;
reg [8:0] i, j;

initial
begin
	////////////////////////////////////////////////////////////////
    // Instruction Memory
    ////////////////////////////////////////////////////////////////

	INSTR_MEM[0] = 32'hE59F11F8; 
	INSTR_MEM[1] = 32'hE59F21F8; 
	INSTR_MEM[2] = 32'hE59F3214; 
	INSTR_MEM[3] = 32'hE5924000; 
	INSTR_MEM[4] = 32'hE5814000; 
	INSTR_MEM[5] = 32'hE2533001; 
	INSTR_MEM[6] = 32'h1AFFFFFD; 
	INSTR_MEM[7] = 32'hEAFFFFF9; 
	INSTR_MEM[8] = 32'hE1A0100F; 
	INSTR_MEM[9] = 32'hE59F0200; 
	INSTR_MEM[10] = 32'hE58F57D0; 
	INSTR_MEM[11] = 32'hE59F57CC; 
	INSTR_MEM[12] = 32'hE59F21F0; 
	INSTR_MEM[13] = 32'hE5820000; 
	INSTR_MEM[14] = 32'hE5820004; 
	INSTR_MEM[15] = 32'hEAFFFFFE; 
	for(i = 16; i < 128; i = i+1) begin 
		INSTR_MEM[i] = i; 
	end
	
	////////////////////////////////////////////////////////////////
    // Data (Constant) Memory
    ////////////////////////////////////////////////////////////////	

	DATA_CONST_MEM[0] = 32'h00000C00; 
	DATA_CONST_MEM[1] = 32'h00000C04; 
	DATA_CONST_MEM[2] = 32'h00000C08; 
	DATA_CONST_MEM[3] = 32'h00000C0C; 
	DATA_CONST_MEM[4] = 32'h00000C10; 
	DATA_CONST_MEM[5] = 32'h00000C14; 
	DATA_CONST_MEM[6] = 32'h00000C18; 
	DATA_CONST_MEM[7] = 32'h00000000; 
	DATA_CONST_MEM[8] = 32'h000000FF; 
	DATA_CONST_MEM[9] = 32'h00000002; 
	DATA_CONST_MEM[10] = 32'h00000800; 
	DATA_CONST_MEM[11] = 32'hABCD1234; 
	DATA_CONST_MEM[12] = 32'h65570A0D; 
	DATA_CONST_MEM[13] = 32'h6D6F636C; 
	DATA_CONST_MEM[14] = 32'h6F742065; 
	DATA_CONST_MEM[15] = 32'h33474320; 
	DATA_CONST_MEM[16] = 32'h2E373032; 
	DATA_CONST_MEM[17] = 32'h000A0D2E; 
	DATA_CONST_MEM[18] = 32'h00000230; 
	for(i = 19; i < 128; i = i+1) begin 
		DATA_CONST_MEM[i] = i; 
	end
	    
	// Initial address
	
	addr <= 9'b0;

end

// determine upper_lower by corresponding input

assign upper_lower = ~addr[0];

// determine corresponding memory data that should be displayed on 7-segments

assign data = (addr[8]) ? DATA_CONST_MEM[addr[7:1]] : INSTR_MEM[addr[7:1]];

// determine memory index "addr" accordingly
always @(posedge clk)
begin
    addr <= (enable) ? addr + 1 : addr;

end
	
endmodule
