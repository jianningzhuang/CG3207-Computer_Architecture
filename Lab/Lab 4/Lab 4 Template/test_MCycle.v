`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 16:55:23
// Design Name: 
// Module Name: test_MCycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/* 
----------------------------------------------------------------------------------
--	(c) Shahzor Ahmad, Rajesh C Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module test_MCycle(

    );
    
    // DECLARE INPUT SIGNALs
    reg CLK = 0 ;
    reg RESET = 0 ;
    reg Start = 0 ;
    reg [1:0] MCycleOp = 0 ;
    reg [3:0] Operand1 = 0 ;
    reg [3:0] Operand2 = 0 ;

    // DECLARE OUTPUT SIGNALs
    wire [3:0] Result1 ;
    wire [3:0] Result2 ;
    wire Busy ;
    
    // INSTANTIATE DEVICE/UNIT UNDER TEST (DUT/UUT)
    MCycle dut( 
        CLK, 
        RESET, 
        Start, 
        MCycleOp, 
        Operand1, 
        Operand2, 
        Result1, 
        Result2, 
        Busy
        ) ;
    
    initial begin
        // hold reset state for 100 ns.
        #10 ;    
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b0000 ;  // 0 / 15 = 0 R 0
        Operand2 = 4'b1111 ;
        Start = 1'b1 ; // Start is asserted continously(Operations are performed back to back). To try a non-continous Start, you can uncomment the commented lines. 

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b0111 ;  // 7 / 3 = 2 R 1
        Operand2 = 4'b0011 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b1001 ;  // 9 / 2 = 4 R 1
        Operand2 = 4'b0010 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b0111 ;  // 7 / 14 = 0 R 7
        Operand2 = 4'b1110 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b1001 ;  // 9 / 8 = 1 R 1
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b1111 ;  // 15 / 9 = 1 R 6
        Operand2 = 4'b1001 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b1000 ;  // 8 / 8 = 1 R 0
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b11 ;    // Unsigned Division
        Operand1 = 4'b1000 ;  // 8 / 9 = 0 R 8
        Operand2 = 4'b1001 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b0000 ;  // 0 / -1 = 0 R 0
        Operand2 = 4'b1111 ;
        
        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b0111 ;  // 7 / 3 = 2 R 1
        Operand2 = 4'b0011 ;

        wait(Busy) ; 
        wait(~Busy) ;

        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b0111 ;  // 7 / -3 = -2 R 1
        Operand2 = 4'b1101;

        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b1001 ;  // -7 / 3 = -2 R -1
        Operand2 = 4'b0011 ;
        
        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b1001 ;  // -7 / -3 = 2 R -1
        Operand2 = 4'b1101 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b1111 ;  // -1/-7 = 0 R -1
        Operand2 = 4'b1001 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b1000 ;  // -8/-8 = 1 R 0
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b10 ;    // Signed Division
        Operand1 = 4'b1000 ;  // -8/-7 = 1 R -1
        Operand2 = 4'b1001 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 15*15 = 225
        Operand1 = 4'b1111 ;
        Operand2 = 4'b1111 ;

        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b01 ; //Unsigned Multiplication 14*15 = 210
        Operand1 = 4'b1110 ; 
        Operand2 = 4'b1111 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 8*1 = 8
        Operand1 = 4'b1000 ;
        Operand2 = 4'b0001 ;


        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b01 ; //Unsigned Multiplication 1*8 = 8
        Operand1 = 4'b0001 ; 
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 0*8 = 0
        Operand1 = 4'b0000 ;
        Operand2 = 4'b1000 ;


        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b01 ; //Unsigned Multiplication 8*7 = 56
        Operand1 = 4'b1000 ; 
        Operand2 = 4'b0111 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 8*8 = 64
        Operand1 = 4'b1000 ; 
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;   
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 0*0 = 0
        Operand1 = 4'b0000 ; 
        Operand2 = 4'b0000 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 7*7 = 49
        Operand1 = 4'b0111 ; 
        Operand2 = 4'b0111 ;

        wait(Busy) ; 
        wait(~Busy) ; 
        
        MCycleOp = 2'b01 ; //Unsigned Multiplication 9*10 = 90
        Operand1 = 4'b1001 ; 
        Operand2 = 4'b1010 ;

        wait(Busy) ; 
        wait(~Busy) ;            
        
        MCycleOp = 2'b00 ;  //Signed Multiplication -1*-1 = 1
        Operand1 = 4'b1111 ;
        Operand2 = 4'b1111 ;

        wait(Busy) ; // suspend initial block till condition becomes true  ;
        wait(~Busy) ;

        MCycleOp = 2'b00 ;  //Signed Multiplication -2*-1 = 2
        Operand1 = 4'b1110 ; 
        Operand2 = 4'b1111 ;
        
        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b00 ; //Signed Multiplication -8*1 = -8 Booth algo need change
        Operand1 = 4'b1000 ;
        Operand2 = 4'b0001 ;


        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b00 ; //Signed Multiplication 1*-8 = -8
        Operand1 = 4'b0001 ; 
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b00 ; //Signed Multiplication 0*-8 = 0
        Operand1 = 4'b0000 ;
        Operand2 = 4'b1000 ;


        wait(Busy) ; 
        wait(~Busy) ; 

        MCycleOp = 2'b00 ; //Signed Multiplication -8*7 = -56 //again Booth algo with multiplicand msb = 1 rest 0
        Operand1 = 4'b1000 ; 
        Operand2 = 4'b0111 ;

        wait(Busy) ; 
        wait(~Busy) ;

        MCycleOp = 2'b00 ; //Signed Multiplication -8*-8 = 64 //again Booth algo with multiplicand msb = 1 rest 0
        Operand1 = 4'b1000 ; 
        Operand2 = 4'b1000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b00 ; //Signed Multiplication 0*0 = 0 
        Operand1 = 4'b0000 ; 
        Operand2 = 4'b0000 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b00 ; //Signed Multiplication 7*7 = 49
        Operand1 = 4'b0111 ; 
        Operand2 = 4'b0111 ;

        wait(Busy) ; 
        wait(~Busy) ;
        
        MCycleOp = 2'b00 ; //Signed Multiplication -7*-6 = 42
        Operand1 = 4'b1001 ; 
        Operand2 = 4'b1010 ;

        wait(Busy) ; 
        wait(~Busy) ;
 
        Start = 1'b0 ;
    end    
     
    // GENERATE CLOCK       
    always begin 
        #5 CLK = ~CLK ; 
        // invert CLK every 5 time units 
    end
    
endmodule
















