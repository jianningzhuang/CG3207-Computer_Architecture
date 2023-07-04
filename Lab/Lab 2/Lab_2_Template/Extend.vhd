----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Extend
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Extend Module
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

entity Extend is port(
			ImmSrc		: in	std_logic_vector(1 downto 0);
			InstrImm		: in	std_logic_vector(23 downto 0);
			ExtImm		: out	std_logic_vector(31 downto 0)
			);
end Extend;

architecture Extend_arch of Extend is
begin
	with ImmSrc select ExtImm <=	(23 downto 0 => '0') & InstrImm(7 downto 0)				when "00", -- DP Instructions
									(19 downto 0 => '0') & InstrImm(11 downto 0)				when "01", -- LDR/STR. Did I mention sign extend for negative offsets in the class?
									(5 downto 0 => InstrImm(23)) & InstrImm(23 downto 0) & "00"	when "10", -- B
									(others => '-')											when others;
end Extend_arch;