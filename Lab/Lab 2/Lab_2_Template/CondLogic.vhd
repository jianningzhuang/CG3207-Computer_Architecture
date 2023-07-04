----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: CondLogic
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: CondLogic Module
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

entity CondLogic is port(
			CLK			: in	std_logic;
			PCS			: in	std_logic;
			RegW		: in	std_logic;
			NoWrite		: in	std_logic;
			MemW		: in	std_logic;
			FlagW		: in	std_logic_vector(1 downto 0);
			Cond		: in	std_logic_vector(3 downto 0);
			ALUFlags	: in	std_logic_vector(3 downto 0);
			PCSrc		: out	std_logic;
			RegWrite	: out	std_logic;
			MemWrite	: out	std_logic
			);
end CondLogic;

architecture CondLogic_arch of CondLogic is
	signal CondEx		: std_logic;
	signal N, Z, C, V	: std_logic := '0';
	--<extra signals, if any>
begin
	
	--<additional logic here>
	with Cond select CondEx <= 	Z						when "0000",	-- EQ
								not Z					when "0001",	-- NE
								C						when "0010",	-- CS / HS
								not C					when "0011",	-- CC / LO
								N						when "0100",	-- MI
								not N					when "0101",	-- PL
								V						when "0110",	-- VS
								not V					when "0111",	-- VC									
								not Z and C				when "1000",	-- HI
								Z or not C				when "1001",	-- LS
								N xnor V				when "1010",	-- GE
								N xor V					when "1011",	-- LT
								not Z and (N xnor V)	when "1100", 	-- GT
								Z or (N xor V)			when "1101",	-- LE
								'1'						when "1110",	-- AL
								'-'						when others;	-- unpredictable
								
end CondLogic_arch;