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

		
		LDR R1, LEDS		; Load the address of LEDs into R1. R1 = 0x00000C00 

		LDR R2, DIPS		; Load the address of DIPs into R2. R2 = 0x00000C04
		
		LDR R3, PBS			; Load the address of PBs into R3. R3 = 0x00000C08 
		
		LDR R4, SEVENSEG  	; Load the address of SEVENSEG into R4. R4 = 0x00000C18
		
		LDR R5, DELAY_VAL   ; Read the location DELAY_VAL to load the number of iterations (250) in the delay loop into R5.
		
		LDR R6, ZERO		; Read the location ZERO to load value 0 into R6.
		
		LDR R7, DELAY_VAL	; Keeps track of when Player A presses/releases button
		
		LDR R8, DELAY_VAL	; Keeps track of when Player B presses/releases button
		
		LDR R11, HUNDRED	; Read the location HUNDRED to load value 100 into R
		
instructions

		;LDR R15, HALT_ADDR  ; Jump to the halt loop && Handle LDR PC by flushing the following bad instructions

		RSBS R12, R11, R6 ; 0 - 100 = -100 (0xFFFFFFF9C) C flag not set
		
		RSCS R12, R11, R6 ; 0 - 100 - (~0) = -101 (0xFFFFFFF9B) C flag not set
		
		SUBS R12, R11, R6 ; 100 - 0 = 100 (0x64) C flag set

		RSCS R12, R11, R6 ; 0 - 100 - (~1) = -100 (0xFFFFFFF9C) C flag not set

		ORR R12, R6, #255			; R12 used as temporary value register
									; ALUResult = 0x000000FF, Set R12 to 0xFF using bitwise OR
		
		ADDS R13, R6, R12, ASR #7	; R6 = 0, R12 ASR #7 = 0x00000001
									; ALUResult = 0x00000001, C flag not set from ASR
		
		LDR R13, LARGE_VAL			; Load value 0x7FFFFFFF largest signed positive integer into R13
		
		ADDS R12, R13, R12, LSR #1	; Large Positive + Positive = Negative (Overflow V and Negative N flags set)
									; ALUResult = 0x7FFFFFFF + 0x0000007F = 0x80000007E, N and V Flags set
		
		ANDVS R12, R12, R6			; If V flag set, clear R12 back to 0 using bitwise AND
									; ALUResult = 0x00000000, Flags not updated, still N and V set
		
		CMPMI R12, R12 				; If N flag set, compare R12(0) to R12(0) (ALUControl = 01 SUB, Flags set)
									; ALUResult = 0 - 0 = 0 (Z flag set, C flag set because invert 0  = 1111...11 + 1 results in carry bit [32])
									
		CMNEQ R13, R13, LSL #1		; If Z flag set, compare not R13 with R13 LSL #1 (ALUControl = 00 ADD, Flags set)
									; ALUResult = 0x7FFFFFFF + 0xFFFFFFFE = 1 7FFF FFFD (C flag set, V flag not set since Positive + Negative no overflow)
		
		LDRCS R12, [R1, #4]			; If C flag set, Read input from DIPS using positive offset
									; ALUControl = 00 (ADD), ALUResult = 0x00000C04 = DIPS, R12 = 0x0000000F
									
		STRCS R12, [R2, #-4]		; Write to LEDS using negative offset
									; ALUControl = 01 (SUB), ALUResult = 0x00000C00 = LEDS, LED_OUT = 0x0F
		
		SUBCSS R11, R11, #1			; Decrement counter, ALUControl = 01 (SUB), C Flag still set since R11 -1 = R11 + 111...110 + 1 results in carry bit
									; Final iteration R11 = 0, R11 - 1 = 0 + 111...110 + 1 = ALUResult = 0xFFFFFFFF (only N flag set, no C flag)
		
		BGE instructions			; Check N == V
									; Final iteration N = 1, V = 0, CondEx = 0, skip and branch to main_loop
		
		B main_loop
		
		



main_loop

		CMP R5, #250  				; Display 10 on 7SEG if countdown between 9 and 10
		LDRLE R6, SHOW_TEN 			; LE checks for Z | (N ^ V), Z OR N and V opp sign
		CMP R5, #225
		STRGT R6, [R4] 				; GT (~Z) & (N ~^ V), NOT Z AND N and V same sign
		
		CMP R5, #225 				; Display 9 on 7SEG if countdown between 8 and 9
		LDRLE R6, SHOW_NINE
		CMP R5, #200
		STRGT R6, [R4]
		
		CMP R5, #200 				; Display 8 on 7SEG if countdown between 7 and 8
		LDRLE R6, SHOW_EIGHT
		CMP R5, #175
		STRGT R6, [R4]
		
		CMP R5, #175 				; Display 0 on 7SEG if countdown less than or equal to 7 to hide countdown
		LDRLE R6, ZERO
		STRLE R6, [R4]
		
		LDR R6, [R3]				; Load Button Press
		STR R5, variable1			; Store current counter value into variable 1
		
		CMP R6, #4					; If A press (100), Load current counter value into R7
		LDREQ R7, variable1
		
		CMP R6, #1					; If B press (001), Load current counter value into R8
		LDREQ R8, variable1
		
		CMP R6, #5					; If Both press (101), Load current counter value into R7 and R8
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
		

		ADD R5, R5, #1				; After countdown to 0, count back up to 2 before showing winner
		CMP R5, #100				; In this 2 seconds delay, button press still recorded, absolute value to who is closest to 0
		BNE delay_loop		
		B winner


winner
		CMP R7, R8					; Compare absolute value of time between button press and 0 for both players, lower value wins
		
		LDRGT R6, B_WIN
		STRGT R6, [R4]
		
		LDRLT R6, A_WIN
		STRLT R6, [R4]
		
		LDREQ R6, BOTH_WIN
		STREQ R6, [R4]
		
		
		B switch

switch
		LDR R6, [R2]				; Read Switches
		STR R6, [R1]				; Output to LEDs
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
HUNDRED
		DCD 0x00000064		; constant 100
LARGE_VAL
		DCD 0x7FFFFFFF		; constant max positive signed integer
LARGEST_VAL
		DCD 0xFFFFFFFF		; constant max unsigned integer
DELAY_VAL
		DCD 0x000000FA		; delay time.
SHOW_TEN
		DCD 0x01000100		; 10 seconds in terms of clock period and instructions in main loop
SHOW_NINE
		DCD 0x00900090		; 9 seconds in terms of clock period and instructions in main loop
SHOW_EIGHT
		DCD 0x00800080		; 8 seconds in terms of clock period and instructions in main loop
A_WIN
		DCD 0xAAAAAAAA		; display A as winner
B_WIN
		DCD 0xBBBBBBBB		; display B as winner
BOTH_WIN
		DCD 0xAAAABBBB		; display tie

variable1_addr
		DCD variable1		; address of variable1. Required since we are avoiding pseudo-instructions // unsigned int * const variable1_addr = &variable1;
constant1
		DCD 0xABCD1234		; // const unsigned int constant1 = 0xABCD1234;
string1   
		DCB  "\r\nWelcome to CG3207..\r\n",0	; // unsigned char string1[] = "Hello World!"; // assembler will issue a warning if the string size is not a multiple of 4, but the warning is safe to ignore
stringptr
		DCD string1			;
HALT_ADDR
		DCD 0x00000134          ; Address of the halt loop
		
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
		