//`define K 39797
`timescale 1ns/1ps


module CORDIC (output signed[1:-16] cosine,
                  output signed[1:-16] sine,
                  output done,
                  input signed[1:-16] target_angle,
                  input init, clk);
    
	reg d=0;
	integer i;
	reg signed [1:-16] c, s, A, delta;
	//reg [15: 0] delta = {51472, 30386, 16055, 8150, 4091, 2047, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2};	
	
	always @(*)
		begin
			case (i)
				0: delta <= 18'b001100100100010000;
				1: delta <= 18'b000111011010110010;
				2: delta <= 18'b000011111010110111;
				3: delta <= 18'b000001111111010110;
				4: delta <= 18'b000000111111111011;
				5: delta <= 18'b000000011111111111;
				6: delta <= 18'b000000010000000000;
				7: delta <= 18'b000000001000000000;
				8: delta <= 18'b000000000100000000;
				9: delta <= 18'b000000000010000000;
				10: delta <= 18'b00000000001000000;
				11: delta <= 18'b00000000000100000;
				12: delta <= 18'b00000000000010000;
				13: delta <= 18'b00000000000001000;
				14: delta <= 18'b00000000000000100;
				15: delta <= 18'b00000000000000010;
			endcase
		end
	
	always @(posedge clk)
		begin
			if (init)
				begin
					//$display("############################################################# \n");
					d <= 0;	// Reset d to 0 (done = 0)
					c <= 18'b001001101101110101;	//39797 (K)
					
					//$display("INITIALISING \n");
					//$display("Sign = %d \n", target_angle[1]);
					
					// If its positive or zero
					if ( target_angle[1] == 0)
						begin
							// If its zero
							if (target_angle == 0)
								begin
									s <= 18'b110110010010001011; //-39797 (-K)
									//s <= -39797;
									//A <= -51472;
									A <= 18'b110011011011110000; // -51472
								end
							// If its positive but not zero
							else 
								begin
									s <= 18'b001001101101110101; //39797 (K)
									//s <= 39797;
									//A <= 51472;
									A <= 18'b001100100100010000; // 51472
								end
						end
					// If its negative
					else
						begin
							s <= 18'b110110010010001011; //-39797
							//s <= -39797;
							//A <= -51472;
							A <= 18'b110011011011110000; // -51472
						end
					i <= 1;
				end
			
			else
				begin
					// It only works if d (done) is not 1
					if ( d == 0) begin 
						//$display("############################################################# \n");
						// Start iterations
						i <= i+1;
						
						//$display("Iteration: %d \n", i);
						//$display("C=%d, S=%d, delta=%d, i=%d, A = %b \n", c, s, delta, i, A);
						
						if (A < target_angle)
							begin	
								//$display("Undershoot \n");
								A <= A + delta;
								c <= c - (s >>> i);
								s <= s + (c >>> i);
							end
						
						else
							begin
								//$display("Overshoot \n");
								A <= A - delta;
								c <= c + (s >>> i);
								s <= s - (c >>> i);
							end
						
						
						if (i > 14)
							begin
								//$display("DONE \n");
								d <=1;
							end
						else
							begin
								d <=0;
							end
					end
				end
		end
	
	assign done = d;
	assign cosine = c;
	assign sine = s;
	
	
endmodule
