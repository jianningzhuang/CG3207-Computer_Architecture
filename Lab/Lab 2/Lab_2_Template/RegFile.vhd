----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: RegFile
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: RegFile Module
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

entity RegFile is port(
			CLK			: in	std_logic;
			WE3			: in	std_logic;
			A1			: in	std_logic_vector(3 downto 0);
			A2			: in	std_logic_vector(3 downto 0);
			A3			: in	std_logic_vector(3 downto 0);
			WD3			: in	std_logic_vector(31 downto 0);
			R15			: in 	std_logic_vector(31 downto 0);
			RD1			: out	std_logic_vector(31 downto 0);
			RD2			: out	std_logic_vector(31 downto 0)
			);
end RegFile;

architecture RegFile_arch of RegFile is
type RegBank_type is array (0 to 15) of std_logic_vector(31 downto 0); 
-- (0 to 14) is sufficient as R15 is not stored. Kept it as (0 to 15) just to supress a warning
signal RegBank : RegBank_type := (others=> x"00000000");
begin
	-- read
	RD1 <= R15 when A1 = "1111" else RegBank(to_integer(unsigned(A1))); 
	RD2 <= R15 when A2 = "1111" else RegBank(to_integer(unsigned(A2)));
	-- write
	process(CLK)
	begin
		if CLK'event and CLK = '1' then
			if A3 /= "1111" and WE3 = '1' then
				RegBank( to_integer(unsigned(A3)) ) <=  WD3;
			end if;
		end if;
	end process;
end RegFile_arch;