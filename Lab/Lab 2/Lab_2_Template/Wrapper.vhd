----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Rajesh Panicker
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

-->>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is use as a component in TOP.vhd for Synthesis) ******* <<<<<<<<<<<<

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------
-- TOP level module interface
----------------------------------------------------------------
entity Wrapper is
		Generic 
		(
			constant N_LEDs_OUT	: integer := 8; 	-- Number of LEDs displaying Result. LED(15 downto 15-N_LEDs_OUT+1). 8 by default
			constant N_DIPs		: integer := 16;  	-- Number of DIPs. 16 by default
			constant N_PBs		: integer := 3  	-- Number of PushButtons. 3 by default
													-- [2:0] -> BTNL, BTNC, BTNR. Note that BTNU is used as PAUSE and BTND is used as RESET
		);
		Port 
		(
			DIP 			: in  STD_LOGIC_VECTOR (N_DIPs-1 downto 0);  	-- DIP switch inputs. Not debounced. Mapped to 0x00000C04. 
																			-- Only the least significant 16 bits read from this location are valid. 
			PB    			: in  STD_LOGIC_VECTOR (N_PBs-1 downto 0);  	-- PB switch inputs. Not debounced.	Mapped to 0x00000C08. 
																			-- Only the least significant 4 bits read from this location are valid. Order (3 downto 0) -> BTNU, BTNL, BTNR, BTND.
			LED_OUT			: out  STD_LOGIC_VECTOR (N_LEDs_OUT-1 downto 0);-- LED(15 downto 8) mapped to 0x00000C00. Only the least significant 8 bits written to this location are used.
			LED_PC 			: out  STD_LOGIC_VECTOR (6 downto 0); 			-- LED(6 downto 0) showing PC(8 downto 2).
			SEVENSEGHEX 	: out STD_LOGIC_VECTOR (31 downto 0); 			-- 7 Seg LED Display. Mapped to 0x00000C18. The 32-bit value will appear as 8 Hex digits on the display.
			CONSOLE_OUT 	: out STD_LOGIC_VECTOR (7 downto 0);			-- CONSOLE (UART) Output. Mapped to 0x00000C0C. The least significant 8 bits written to this location are sent to PC via UART.
																			-- Check if CONSOLE_OUT_ready (0x00000C14) is set before writing to this location (especially if your CLK_DIV_BITS is small).
																			-- Consecutive STRs to this location not permitted (there should be at least 1 instruction gap between STRs to this location).
			CONSOLE_OUT_ready: in STD_LOGIC;								-- An indication to the wrapper/processor that it is ok to write to the CONSOLE_OUT (UART hardware).
																			--  This bit should be set in the testbench to indicate that it is ok to write a new character to CONSOLE_OUT from your program.
																			--  It can be read from the address 0x00000C14.
			CONSOLE_OUT_valid : out STD_LOGIC;								-- An indication to the UART hardware that the processor has written a new data byte to be transmitted.
			CONSOLE_IN 		: in STD_LOGIC_VECTOR (7 downto 0);				-- CONSOLE (UART) Input. Mapped to 0x00000C0C. The least significant 8 bits read from this location is the character received from PC via UART.
																			-- Check if CONSOLE_IN_valid flag (0x00000C10)is set before reading from this location.
																			-- Consecutive LDRs from this location not permitted (needs at least 1 instruction spacing between LDRs).
																		    -- Also, note that there is no Tx FIFO implemented. DO NOT send characters from PC at a rate faster than 
                                                                            --  your processor (program) can read them. This means sending only 1 char every few seconds if your CLK_DIV_BITS is 26.
                                                                            -- 	This is not a problem if your processor runs at a high speed.
			CONSOLE_IN_valid : in STD_LOGIC;								-- An indication to the wrapper/processor that there is a new data byte waiting to be read from the UART hardware.
			                                                                -- This bit should be set in the testbench to indicate a new character (Else, the processor will only read in 0x00).
																			--  It can be read from the address 0x00000C10.
			CONSOLE_IN_ack 	: out STD_LOGIC;								-- An indication to the UART hardware that the processor has read the newly received data byte.
																			-- The testbench should clear CONSOLE_IN_valid when this is set.
			RESET			: in  STD_LOGIC; 								-- Active high. Implemented in TOP as not(CPU_RESET) or Internal_reset (CPU_RESET is red push button and is active low).
			CLK				: in  STD_LOGIC 								-- Divided Clock from TOP.
		);
end Wrapper;


architecture arch_Wrapper of Wrapper is

----------------------------------------------------------------
-- ARM component declaration
----------------------------------------------------------------
component ARM is port(
			CLK			: in 	std_logic;
			RESET		: in 	std_logic;
			--Interrupt	: in	std_logic;  -- for optional future use
			Instr		: in 	std_logic_vector(31 downto 0);
			ReadData	: in 	std_logic_vector(31 downto 0);
			MemWrite	: out	std_logic;
			PC			: out	std_logic_vector(31 downto 0);
			ALUResult	: out 	std_logic_vector(31 downto 0);
			WriteData	: out 	std_logic_vector(31 downto 0)
			);
end component ARM;

----------------------------------------------------------------
-- ARM signals
----------------------------------------------------------------
signal PC 	            : STD_LOGIC_VECTOR (31 downto 0);
signal Instr 			: STD_LOGIC_VECTOR (31 downto 0);
signal ReadData			: STD_LOGIC_VECTOR (31 downto 0);
signal ALUResult		: STD_LOGIC_VECTOR (31 downto 0);
signal WriteData		: STD_LOGIC_VECTOR (31 downto 0);
signal MemWrite 		: STD_LOGIC; 

----------------------------------------------------------------
-- Address Decode signals
----------------------------------------------------------------
signal dec_DATA_CONST, dec_DATA_VAR, dec_LED, dec_DIP, dec_CONSOLE, dec_PB, dec_7SEG, dec_CONSOLE_IN_valid, dec_CONSOLE_OUT_ready: std_logic;  -- 'enable' signals from data memory address decoding

----------------------------------------------------------------
-- Memory type declaration
----------------------------------------------------------------
type MEM_128x32 is array (0 to 127) of std_logic_vector (31 downto 0); -- 128 words

----------------------------------------------------------------
-- Instruction Memory
----------------------------------------------------------------
constant INSTR_MEM : MEM_128x32 := (others => x"00000000");

----------------------------------------------------------------
-- Data (Constant) Memory
----------------------------------------------------------------
constant DATA_CONST_MEM : MEM_128x32 := (others => x"00000000");

----------------------------------------------------------------
-- Data (Variable) Memory
----------------------------------------------------------------
signal DATA_VAR_MEM : MEM_128x32 := (others=> x"00000000"); 

----------------------------------------------------------------	
----------------------------------------------------------------
-- <Wrapper architecture>
----------------------------------------------------------------
----------------------------------------------------------------	
		
begin

----------------------------------------------------------------
-- Debug LEDs
----------------------------------------------------------------			
LED_PC <= PC(15-N_LEDs_OUT+1 downto 2); -- debug showing PC

----------------------------------------------------------------
-- ARM port map
----------------------------------------------------------------
ARM1 : ARM port map ( 
			CLK         =>  CLK,
			RESET		=>	RESET,  
			--Interrupt	=> 	Interrupt,
			Instr 		=>  Instr,
			ReadData	=>  ReadData,
			MemWrite 	=>  MemWrite,
			PC          =>  PC,
			ALUResult   =>  ALUResult,			
			WriteData	=>  WriteData					
			);

----------------------------------------------------------------
-- Data memory address decoding
----------------------------------------------------------------
dec_DATA_CONST  <= '1' 	when ALUResult>=x"00000200" and ALUResult<=x"000003FC" else '0';
dec_DATA_VAR    <= '1' 	when ALUResult>=x"00000800" and ALUResult<=x"000009FC" else '0';
dec_LED 		<= '1'	when ALUResult=x"00000C00" else '0';
dec_DIP 		<= '1' 	when ALUResult=x"00000C04" else '0';
dec_PB 		    <= '1'	when ALUResult=x"00000C08" else '0';
dec_CONSOLE	    <= '1' 	when ALUResult=x"00000C0C" else '0';
dec_CONSOLE_IN_valid <= '1' when ALUResult=x"00000C10" else '0';
dec_CONSOLE_OUT_ready <= '1' when ALUResult=x"00000C14" else '0';
dec_7SEG	    <= '1' 	when ALUResult=x"00000C18" else '0';

----------------------------------------------------------------
-- Data memory read
----------------------------------------------------------------
ReadData 	<= (31-N_DIPs downto 0 => '0') & DIP						when dec_DIP = '1' 
                else (31-N_PBs downto 0 => '0') & PB					when dec_PB = '1' 
				else DATA_VAR_MEM(conv_integer(ALUResult(8 downto 2)))	when dec_DATA_VAR = '1'
				else DATA_CONST_MEM(conv_integer(ALUResult(8 downto 2)))when dec_DATA_CONST = '1'
				else x"000000" & CONSOLE_IN 							when dec_CONSOLE = '1' and CONSOLE_IN_valid = '1'
				else (0=>CONSOLE_IN_valid, others=>'0')					when dec_CONSOLE_IN_valid = '1'
				else (0=>CONSOLE_OUT_ready, others=>'0')				when dec_CONSOLE_OUT_ready = '1'
				else (others=>'0');
				
----------------------------------------------------------------
-- Instruction memory read
----------------------------------------------------------------
Instr <= INSTR_MEM(conv_integer(PC(8 downto 2))) 
			when PC>=x"00000000" and PC<=x"000001FC" -- To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
			else x"00000000";

----------------------------------------------------------------
-- Console read / write
----------------------------------------------------------------
write_CONSOLE_n_ack: process (CLK)
begin
	if CLK'event and CLK = '1' then
		CONSOLE_OUT_valid <= '0';
		CONSOLE_IN_ack <= '0'; 
		if MemWrite = '1' and dec_CONSOLE = '1' and CONSOLE_OUT_ready = '1' then
			CONSOLE_OUT <= WriteData(7 downto 0);
			CONSOLE_OUT_valid <= '1';
		end if;
		if MemWrite = '0' and dec_CONSOLE = '1' and CONSOLE_IN_valid = '1' then 
			CONSOLE_IN_ack <= '1';
		end if;
		-- Possible spurious CONSOLE_IN_ack and a lost character since we don't have a MemRead signal. Make sure ALUResult is never 0xC0C other than when accessing UART.
		-- Also, the character received from PC in the CLK cycle immediately following a character read by the processor is lost. This is not that much of a problem in practice though.	
	end if;
end process;			

----------------------------------------------------------------
-- Data Memory-mapped LED write
----------------------------------------------------------------
write_LED: process (CLK)
begin
	if CLK'event and CLK = '1' then
		if RESET = '1' then
			LED_OUT <= (others=> '0');
		elsif MemWrite = '1' and  dec_LED = '1' then
			LED_OUT <= WriteData(N_LEDs_OUT-1 downto 0);
		end if;
	end if;
end process;

----------------------------------------------------------------
-- SevenSeg LED Display write
----------------------------------------------------------------
write_SevenSeg: process (CLK)
begin
    if CLK'event and CLK = '1' then
    	if RESET = '1' then
    		SEVENSEGHEX <= (others=> '0');
        elsif MemWrite = '1' and dec_7SEG = '1' then
            SEVENSEGHEX <= WriteData;
        end if;
    end if;
end process;

----------------------------------------------------------------
-- Data Memory write
----------------------------------------------------------------
write_DATA_VAR_MEM: process (CLK)
begin
    if CLK'event and CLK = '1' then
        if MemWrite = '1' and dec_DATA_VAR = '1' then
            DATA_VAR_MEM(conv_integer(ALUResult(8 downto 2))) <= WriteData;
        end if;
    end if;
end process;

end arch_Wrapper;
----------------------------------------------------------------	
----------------------------------------------------------------
-- </Wrapper architecture>
----------------------------------------------------------------
----------------------------------------------------------------
