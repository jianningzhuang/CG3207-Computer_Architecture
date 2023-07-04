----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.08.2015 19:51:11
-- Design Name: 
-- Module Name: simple_count - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simple_count is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (3 downto 0));
end simple_count;

architecture Behavioral of simple_count is

signal count: std_logic_vector (29 downto 0) := (others=>'0');

begin

process (clk) 
begin
   if clk'event and clk = '1' then
      if enable='0' then
         count <= count + 1;
      end if;
   end if;
end process;
 
led <= count(29 downto 26);
						


end Behavioral;



