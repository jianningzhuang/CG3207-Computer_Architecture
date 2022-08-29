
//----------------------------------------------------------------
// Instruction Memory
//----------------------------------------------------------------
initial begin
			INSTR_MEM[0] = 32'hE59F11F8; 
			INSTR_MEM[1] = 32'hE59F21F8; 
			INSTR_MEM[2] = 32'hE59F3214; 
			INSTR_MEM[3] = 32'hE5924000; 
			INSTR_MEM[4] = 32'hE5814000; 
			INSTR_MEM[5] = 32'hE2533001; 
			INSTR_MEM[6] = 32'h1AFFFFFD; 
			INSTR_MEM[7] = 32'hE1A0100F; 
			INSTR_MEM[8] = 32'hE59F0204; 
			INSTR_MEM[9] = 32'hE58F57D4; 
			INSTR_MEM[10] = 32'hE59F57D0; 
			INSTR_MEM[11] = 32'hE59F21F4; 
			INSTR_MEM[12] = 32'hE5820000; 
			INSTR_MEM[13] = 32'hE5820004; 
			INSTR_MEM[14] = 32'hEAFFFFFE; 
			for(i = 15; i < 128; i = i+1) begin 
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
				DATA_CONST_MEM[i] = 32'h0; 
			end
end

