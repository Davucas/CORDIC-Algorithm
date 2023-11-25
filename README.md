# CORDIC-Algorithm
A project I did for a class where I had to implement the CORDIC algorithm in C and in Verilog

### Cordic Algorithm
The CORDIC computing technique is an algorithm used to calculate trigonometric functions in a cheap and efficient way. A CORDIC computer can calculate these trigonometric functions for a given angle, using just shifters and adders.
For the project we are using the rotation mode, this means that every iteration (i) the initial vector (represented by the angle A) rotates Δai radians. The direction of this rotation is determined by the comparison between the input angle θ and A, if A is greater than θ (A ≥ θ) then we will add Δai to A, on the other hand, if A is less than θ (A≤ θ) then we will subtract Δai from A. We do this until the desired angle is achieved.
Every iteration calculates a rotation using the following idea:

![image](https://github.com/Davucas/CORDIC-Algorithm/assets/40278318/86bedba9-b183-4105-98b5-789867b47e93)

Then we can simplify it by letting Δai be atan(2-i) and dividing out cos(Δai) from the matrix, this way we will have a constant K that we can move to the initialiser values of cosine and sine (we can skip the first iteration because 20 = 1) so the final formula will look like this:

![image](https://github.com/Davucas/CORDIC-Algorithm/assets/40278318/d6d2226e-6713-435f-a8d6-18c3b5f78c33)


![image](https://github.com/Davucas/CORDIC-Algorithm/assets/40278318/9b3ddc39-1ff9-4987-83fa-c6999f201176)

So, the initial values for the cosine, sine and A will be K, ±K and ±Δa1 respectively.

### Implementation in C
For my implementation in C, I pre-multiplied everything by 2^16 (16-bit left shift) to represent the 2.16 fixed-point format, and I used 32-bit integers to store the variables (int32_t). I also used a look-ahead table to store the values of Δai (also pre-multiplied by 2^16) and I precalculated the K (also pre-multiplied by 2^16) for the number of iterations needed.

### Implementation in Verilog
I created a module called “CORDIC” which receives 3 inputs, a 1-bit signal init, a signed register with the format [1:-16] and the clock, and has three outputs: the 1-bit signal done and the registers [1:-16] sine and cosine. We use the 1-bit signals init and done to indicate when an angle has been processed (done) and when a new one can be loaded (init). For the constant K I used a precalculated value of 39797 (for 16 iterations), and for Δai I used a lookup table. The lookup table was created using an “always @(*)” statement that contains a case/encase statement, inside I assigned delta a different value for each of the value possible values of i. It looks like this:

![image](https://github.com/Davucas/CORDIC-Algorithm/assets/40278318/4e41c8ec-3af6-485b-8d87-e82102ec74ac)

For the main loop I used a “always @(posedge clk)” statement that is executed on the positive edge of the clock (rising edge). Inside we have two sections: the init and the loop. The program can only access the init when the init 1-bit signal is set, in that case we load the target_angle and we set the initial values of the variables c,s and A (cosine, sine and angle) according to the target_angle (the way to do it was discussed in the first section of the report). Once everything is set and the init signal is 0, we check that the done signal is 0 and we do the iteration. Note that in the Verilog code, unlike in C, we don’t need the variables c_old and s_old because Verilog ‘updates’ the value of the variables assigned with ‘<=’ after the block is executed. Finally, we check if we have done the desired number of iterations and we set the output done.

This is the waveform of the testbench:

![image](https://github.com/Davucas/CORDIC-Algorithm/assets/40278318/61343234-bfa0-4212-b713-a7afd1170647)

As we can see here, first the init signal is set so the target_angle is loaded and the initial values for cosine,sine and A are set. Then once the init signal goes down to zero, the Cordic algorithm starts working and the cosine, sine, and A change. We can see that this happens for 16 cycles and then the output ‘done’ is set. Once done is set the test loads the next angle and the same process is repeated.

The Verilog code for the test bench is very simple, we generate a clock using a 1-bit register and a forever statement that toggles the clock. Then we use dumpfile and dumpvars to generate the vcd file with the waveform, and we initialise the inputs (set init, start clock, and load target_angle). Once this is done the rest of the code is just testing new target angles, to do it I used a wait statement to wait until done was set and then loading the new angle (this requires setting init too).

Note that the test waits between one input load and another with ‘#30’ this is necessary because while we load the new input the signal ‘done’ is still set (it needs another cycle after the input is loaded to be 0 again) so if we don’t wait then the test will load the next angle and the algorithm will skip the current one (is like a “latency”).

