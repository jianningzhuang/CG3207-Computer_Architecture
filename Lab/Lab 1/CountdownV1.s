;----------------------------------------------------------------------------------
;--	License terms :
;--	You are free to use this code as long as you
;--		(i) DO NOT post it on any public repository;
;--		(ii) use it only for educational purposes;
;--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
;--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
;--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
;--		(vi) retain this notice in this file or any files derived from this.
;----------------------------------------------------------------------------------

	AREA    MYCODE, CODE, READONLY, ALIGN=9 ; 2^9 = 512 bytes (enough space for 128 words). Each section is aligned to an address divisible by 512.
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>
; Total number of instructions should not exceed 127 (126 excluding the last line 'halt B halt').

		LDR R1, LEDS		; Read the location LEDs to get a pointer to (address of) the LEDs into R1. R1 content will be 0x00000C00 after this step is executed.
		LDR R2, DIPS		; Read the location DIPs to get a pointer to (address of) the DIPs into R2. R2 content will be 0x00000C04 after this step is executed.		
		LDR R3, PBS
		LDR R4, SEVENSEG
		
		LDR R6, ZERO
		LDR R5, DELAY_VAL   ; Read the location DELAY_VAL (tentatively, 4) to get the number of iterations in the delay loop into R5.
		LDR R7, DELAY_VAL
		LDR R8, DELAY_VAL



main_loop
		CMP R5, #250  ;Display 10 on 7SEG if counter within 10
		LDRLE R6, TEN
		CMP R5, #225
		STRGT R6, [R4]
		
		CMP R5, #225 ;Display 9 on 7SEG if counter within 9
		LDRLE R6, NINE
		CMP R5, #200
		STRGT R6, [R4]
		
		CMP R5, #200 ;Display 8 on 7SEG if counter within 8
		LDRLE R6, EIGHT
		CMP R5, #175
		STRGT R6, [R4]
		
		CMP R5, #175 ;Display 0 on 7SEG if counter within 7 to hide countdown
		LDRLE R6, ZERO
		STRLE R6, [R4]
		
		LDR R6, [R3]
		STR R5, variable1
		
		CMP R6, #4
		LDREQ R7, variable1
		
		CMP R6, #1
		LDREQ R8, variable1
		
		CMP R6, #5
		LDREQ R7, variable1
		LDREQ R8, variable1
		
		
		SUBS R5, R5, #1
		BNE main_loop
		
		B delay_loop
		
delay_loop

		LDR R6, [R3]
		STR R5, variable1

		CMP R6, #4
		LDREQ R7, variable1
		
		CMP R6, #1
		LDREQ R8, variable1
		
		CMP R6, #5
		LDREQ R7, variable1
		LDREQ R8, variable1
		

		ADD R5, R5, #1	
		CMP R5, #100
		BNE delay_loop		
		B winner


winner
		CMP R7, R8
		
		LDRGT R6, B_WIN
		STRGT R6, [R4]
		
		LDRLT R6, A_WIN
		STRLT R6, [R4]
		
		LDREQ R6, BOTH_WIN
		STREQ R6, [R4]
		
		
		B switch

switch
		LDR R6, [R2]	
		STR R6, [R1]
		B switch
		
halt	
		B    halt 
		
		
		

; ------- <\code memory (ROM mapped to Instruction Memory) ends>

	AREA    CONSTANTS, DATA, READONLY, ALIGN=9 
; ------- <constant memory (ROM mapped to Data Memory) begins>
; All constants should be declared in this section. This section is read only (Only LDR, no STR).
; Total number of constants should not exceed 128 (124 excluding the 4 used for peripheral pointers).
; If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.

;Peripheral pointers
LEDS
		DCD 0x00000C00		; Address of LEDs. //volatile unsigned int * const LEDS = (unsigned int*)0x00000C00;  
DIPS
		DCD 0x00000C04		; Address of DIP switches. //volatile unsigned int * const DIPS = (unsigned int*)0x00000C04;
PBS
		DCD 0x00000C08		; Address of Push Buttons. Optionally used in Lab 2 and later
CONSOLE
		DCD 0x00000C0C		; Address of UART. Optionally used in Lab 2 and later
CONSOLE_IN_valid
		DCD 0x00000C10		; Address of UART. Optionally used in Lab 2 and later
CONSOLE_OUT_ready
		DCD 0x00000C14		; Address of UART. Optionally used in Lab 2 and later
SEVENSEG
		DCD 0x00000C18		; Address of 7-Segment LEDs. Optionally used in Lab 2 and later

; Rest of the constants should be declared below.
ZERO
		DCD 0x00000000		; constant 0
LSB_MASK
		DCD 0x000000FF		; constant 0xFF
DELAY_VAL
		DCD 0x000000FA		; delay time.
TEN
		DCD 0x01000100		; 10 seconds in terms of clock period and instructions in main loop
NINE
		DCD 0x00900090		; 9 seconds in terms of clock period and instructions in main loop
EIGHT
		DCD 0x00800080		; 8 seconds in terms of clock period and instructions in main loop
SEVEN
		DCD 0x00700070		; 7 seconds in terms of clock period and instructions in main loop
A_PRESS
		DCD 0x00000004		; 8 seconds in terms of clock period and instructions in main loop
B_PRESS
		DCD 0x00000001		; 7 seconds in terms of clock period and instructions in main loop
BOTH_PRESS
		DCD 0x00000005		; 8 seconds in terms of clock period and instructions in main loop
A_WIN
		DCD 0xAAAAAAAA		; 8 seconds in terms of clock period and instructions in main loop
B_WIN
		DCD 0xBBBBBBBB		; 7 seconds in terms of clock period and instructions in main loop
BOTH_WIN
		DCD 0xAAAABBBB		; 8 seconds in terms of clock period and instructions in main loop

variable1_addr
		DCD variable1		; address of variable1. Required since we are avoiding pseudo-instructions // unsigned int * const variable1_addr = &variable1;
constant1
		DCD 0xABCD1234		; // const unsigned int constant1 = 0xABCD1234;
string1   
		DCB  "\r\nWelcome to CG3207..\r\n",0	; // unsigned char string1[] = "Hello World!"; // assembler will issue a warning if the string size is not a multiple of 4, but the warning is safe to ignore
stringptr
		DCD string1			;
		
; ------- <constant memory (ROM mapped to Data Memory) ends>	


	AREA   VARIABLES, DATA, READWRITE, ALIGN=9
; ------- <variable memory (RAM mapped to Data Memory) begins>
; All variables should be declared in this section. This section is read-write.
; Total number of variables should not exceed 128. 
; No initialization possible in this region. In other words, you should write to a location before you can read from it (i.e., write to a location using STR before reading using LDR).

variable1
		DCD 0x00000000		;  // unsigned int variable1;
; ------- <variable memory (RAM mapped to Data Memory) ends>	

		END	
		
;const int* x;         // x is a non-constant pointer to constant data
;int const* x;         // x is a non-constant pointer to constant data 
;int*const x;          // x is a constant pointer to non-constant data
		