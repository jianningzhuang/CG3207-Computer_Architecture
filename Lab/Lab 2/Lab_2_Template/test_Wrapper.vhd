----------------------------------------------------------------------------------
--	(c) Rajesh Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_Wrapper IS
END test_Wrapper;
 
ARCHITECTURE behavior OF test_Wrapper IS 

constant N_LEDs_OUT	: integer := 8;
constant N_DIPs		: integer := 16;
constant N_PBs		: integer := 3;

-- Component Declaration for the Unit Under Test (UUT)
component Wrapper is

	Port 
	(
		DIP 			: in  STD_LOGIC_VECTOR (N_DIPs-1 downto 0);  	
		PB    			: in  STD_LOGIC_VECTOR (N_PBs-1 downto 0);  	
		LED_OUT			: out  STD_LOGIC_VECTOR (N_LEDs_OUT-1 downto 0);
		LED_PC 			: out  STD_LOGIC_VECTOR (6 downto 0); 			
		SEVENSEGHEX 	: out STD_LOGIC_VECTOR (31 downto 0); 			
		CONSOLE_OUT 	: out STD_LOGIC_VECTOR (7 downto 0);
		CONSOLE_OUT_ready : in STD_LOGIC;
		CONSOLE_OUT_valid : out STD_LOGIC;
		CONSOLE_IN 		: in STD_LOGIC_VECTOR (7 downto 0);
		CONSOLE_IN_valid : in STD_LOGIC;
		CONSOLE_IN_ack 	: out STD_LOGIC;
		RESET			: in  STD_LOGIC;
		CLK				: in  STD_LOGIC 
	);
end component Wrapper;

-- Signals for UUT
signal	DIP 			: STD_LOGIC_VECTOR (N_DIPs-1 downto 0) := (others=>'0') ;	
signal	PB    			: STD_LOGIC_VECTOR (N_PBs-1 downto 0):= (others=>'0') ;  	
signal	LED_OUT			: STD_LOGIC_VECTOR (N_LEDs_OUT-1 downto 0):= (others=>'0') ;
signal	LED_PC 			: STD_LOGIC_VECTOR (6 downto 0):= (others=>'0') ; 			
signal	SEVENSEGHEX 	: STD_LOGIC_VECTOR (31 downto 0):= (others=>'0') ; 			
signal	CONSOLE_OUT 	: STD_LOGIC_VECTOR (7 downto 0):= (others=>'0') ;
signal  CONSOLE_OUT_ready: STD_LOGIC := '0';
signal	CONSOLE_OUT_valid : STD_LOGIC := '0' ;
signal	CONSOLE_IN 		: STD_LOGIC_VECTOR (7 downto 0):= (others=>'0') ;
signal	CONSOLE_IN_valid : STD_LOGIC := '0';
signal	CONSOLE_IN_ack 	: STD_LOGIC := '0';
signal	RESET			: STD_LOGIC := '0'; 
signal	CLK				: STD_LOGIC := '0';	

-- Clock period definitions
constant CLK_period : time := 10 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: Wrapper PORT MAP (
	   DIP 				=> DIP 				,
	   PB    			=> PB    			,
	   LED_OUT			=> LED_OUT			,
	   LED_PC 			=> LED_PC 			,
	   SEVENSEGHEX 		=> SEVENSEGHEX 		,
	   CONSOLE_OUT 		=> CONSOLE_OUT 		,
	   CONSOLE_OUT_ready => CONSOLE_OUT_ready , 
	   CONSOLE_OUT_valid => CONSOLE_OUT_valid ,
	   CONSOLE_IN 		=> CONSOLE_IN 		,
	   CONSOLE_IN_valid => CONSOLE_IN_valid	,
	   CONSOLE_IN_ack 	=> CONSOLE_IN_ack 	,
	   RESET			=> RESET			,
	   CLK				=> CLK				
     );

-- Clock process definitions
CLK_process :process
begin
	CLK <= '0';
	wait for CLK_period/2;
	CLK <= '1';
	wait for CLK_period/2;
end process;


-- Stimulus process
stim_proc: process
begin	
	RESET <= '1';
-- hold reset state for 10 ns.
	wait for 10 ns;
	RESET <= '0';
	CONSOLE_OUT_ready <= '1'; -- ok to keep it high continously in the testbench. In reality, it will be high only if UART is ready to send a data to PC
	CONSOLE_IN <= x"50"; --'P'
	CONSOLE_IN_valid <= '1';
	wait until CONSOLE_IN_ack = '1';
	CONSOLE_IN_valid <= '0';
	wait for 105 ns;
	CONSOLE_IN <= x"41"; --'A'
	CONSOLE_IN_valid <= '1';
	wait until CONSOLE_IN_ack = '1';
	CONSOLE_IN_valid <= '0';
	wait for 105 ns;
	CONSOLE_IN <= x"0D"; --'A'
	CONSOLE_IN_valid <= '1';
	wait until CONSOLE_IN_ack = '1'; --should print "Welcome to CG3207" following this.
	CONSOLE_IN_valid <= '0';

   -- insert rest of the stimuli here 
	wait;

end process;

END;
