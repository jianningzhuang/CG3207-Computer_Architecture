----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: PC
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: PC Module
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is port(
			CLK			: in	std_logic;
			RESET		: in 	std_logic;
			WE_PC		: in	std_logic; -- write enable
			PC_IN		: in	std_logic_vector(31 downto 0);
			PC			: out	std_logic_vector(31 downto 0) := (others => '0')
			);
end ProgramCounter;

architecture ProgramCounter_arch of ProgramCounter is
begin
	process(CLK)
	begin
		if CLK'event and CLK = '1' then
			if RESET = '1' then
				PC <= (others => '0');
			elsif WE_PC = '1' then
				PC <= PC_IN;
			end if;			
		end if;		
	end process;
end ProgramCounter_arch;