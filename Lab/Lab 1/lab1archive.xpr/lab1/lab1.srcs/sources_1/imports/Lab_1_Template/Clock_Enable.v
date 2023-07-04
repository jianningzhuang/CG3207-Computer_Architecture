//////////////////////////////////////////////////////////////////////////////////
// This module is to generate an enable signal for different display frequency based on pushbuttons
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////

module Clock_Enable(
	input clk,			// fundamental clock 100MHz
	input btnU,			// button BTNU for 4Hz speed
	input btnC,			// button BTNC for pause
	output reg enable);	// output signal used to enable the reading of next memory data

// define reg threshold to allow 4hz or 1hz frequency

reg [25:0] threshold;


// define reg counter to be able to count to certain threshold value

reg [25:0] counter;

initial
begin
    enable <= 0;
	counter <= 0;
end
	
	
// complete this always block by determining the enable output by counter, threshold and buttons 
always @(posedge clk)
    begin
        //actual threshold
        threshold <= (btnU) ? 26'h0BEBC1F : 26'h2FAF07F;
        
        //simulation threshold
        //threshold <= (btnU) ? 26'd124 : 26'd499;
        if (btnC)
            enable <= 1'b0;
        else
        begin
            counter <= counter + 1;
            if (counter >= threshold) 
            begin
                enable <= 1'b1;
                counter <= 0;
            end
            else
                enable <= 1'b0;
        end
    end
	

	
endmodule