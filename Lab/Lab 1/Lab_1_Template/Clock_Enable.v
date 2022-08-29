//////////////////////////////////////////////////////////////////////////////////
// This module is to generate an enable signal for different display frequency based on pushbuttons
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////

module Clock_Enable(
	input clk,			// fundamental clock 1MHz
	input btnU,			// button BTNU for 4Hz speed
	input btnC,			// button BTNC for pause
	output reg enable);	// output signal used to enable the reading of next memory data

// define reg threshold to allow 4hz or 1hz frequency

reg [25:0] threshold = 0;


// define reg counter to be able to count to certain threshold value

reg [25:0] counter;

initial
begin
	counter <= 0;
end
	
	
// complete this always block by determining the enable output by counter, threshold and buttons 
always @(posedge clk)
    begin
        if (btnU)
        begin
            threshold <= 26'h0FFFFFF;
        end
        else
        begin
            threshold <= 26'h3FFFFFF;
        end
        if (btnC)
        begin
            
        end
        else
        begin
            counter <= (counter == threshold) ? 1'b0 : counter + 1;
        end
        
        enable <= (counter == 0) ? 1'b1 : 1'b0;
    end
	

	
endmodule