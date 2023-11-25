`timescale 1ns/1ps

module cordic_tb();

	reg signed [1: -16] target_angle;
	reg init, clk;
	wire signed [1: -16] cosine, sine;
	wire done;

	CORDIC dut(cosine, sine, done, target_angle, init, clk);
	
	// generate the clock
	initial begin
		clk = 1'b0;
	    	forever #1 clk = ~clk;
	 end
	
	
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, cordic_tb);
		
		$monitor("TEST MONITOR: target_angle=%d, cosine=%d, sine=%d, init = %b, done = %b \n", target_angle, cosine, sine, init, done);
		// Initialize inputs
		target_angle = 18'b000000000000000000; // 0 rads
		clk = 0;
		init = 1;
		#2 init = 0;
		
		#30
		wait(done == 1);
		target_angle = 18'b000100000000000000; // 0.25 rads * 2^16
		init = 1;
		#2 init = 0;
		
		// We need to wait some time so the done signal goes to 0 before is set again
		// If we don't wait the done signal is still set when this code is executed so some of the inputs will be skipped
		#30
		wait(done == 1);
		target_angle = 18'b111100000000000000; // -0.25 rads * 2^16
		init = 1;
		#2 init = 0;
		
		#30
		wait(done == 1);
		target_angle = 18'b011000000000000000; // 1.5 rads * 2^16
		init = 1;
		#2 init = 0;
		
		#50
		wait(done == 1);
		$finish;
		
		
	end

endmodule
