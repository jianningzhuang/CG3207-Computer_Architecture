----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Shifter
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Shifter Module
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

entity Shifter is port(
			Sh			: in	std_logic_vector(1 downto 0); 
			Shamt5		: in	std_logic_vector(4 downto 0);
			ShIn		: in	std_logic_vector(31 downto 0);
			ShOut		: out	std_logic_vector(31 downto 0)		
			);
end Shifter;

architecture Shifter_arch of Shifter is
begin
	process(Sh, Shamt5, ShIn)
		variable ShTemp	: std_logic_vector(31 downto 0)	;
	begin
		ShTemp := ShIn;
		for i in 0 to 4 loop
			if Shamt5(i) = '1' then
				case Sh is
					when "00" => ShTemp := ShTemp(31-2**i downto 0) & (2**i-1 downto 0 => '0'); 	-- LSL
					when "01" => ShTemp := (2**i-1 downto 0 => '0') & ShTemp(31 downto 2**i); 		-- LSR
					when "10" => ShTemp := (2**i-1 downto 0 => ShIn(31)) & ShTemp(31 downto 2**i); 	-- ASR
					when others => ShTemp := ShTemp(2**i-1 downto 0) & ShTemp(31 downto 2**i); 		-- ROR 
				end case;
			end if;
		end loop;	
		ShOut <= ShTemp;
	end process;
end	Shifter_arch;