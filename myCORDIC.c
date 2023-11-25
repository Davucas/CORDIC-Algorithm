#include <stdint.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N 16  // number of Cordic iterations
#define K 39797    // Its K*2^16 for 16 iterations


// Lookup table of delta in radians for 16 iterations, multiplied by 2^16
const int32_t delta[N] = {51472, 30386, 16055, 8150, 4091, 2047, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2};
void Cordic (int32_t angle, int32_t *sine, int32_t *cosine);



int main(int argc, char *argv[]) {
    
    int32_t angle, s, c;
    
    // We asume the input is already pre-multiplied by 2^16
    if (argc == 2) {
        angle = atoi(argv[1]);
    }
    else angle = 0; // If the user doesn't specify an input angle, the default is 0
    
    Cordic( angle, &s, &c );
    // Print the result in different formats
    printf("S: %d, %f \n", s, (float)s / (1 << 16));
    printf("C: %d, %f \n", c, (float)c / (1 << 16));
    
    return 0;
    
    /* IGNORE THIS
      This is only a test for the CORDIC algorithm, it tries every possible input in the range -PI/2 to PI/2
      to see the maximum error and the accuracy of the implementation, but this is not needed to perform the algorithm so it can be ignored
    
    int32_t angle = -M_PI_2 * (1<<16);
    int32_t max = M_PI_2 * (1<<16);
    int32_t s, c;
    int32_t errorc = 0;
    int32_t errors = 0;
    int32_t maxerrorc = -1;
    int32_t maxerrors = -1;
        
    while (angle < max) {
        //printf("Angle input: %d \n", angle);
        
        Cordic(angle, &s, &c);
        
        // For the system routines
        double an = (double)angle / (1 << 16);
        errorc = fabs(c - (int32_t)round( cos(an) * (1 << 16) ));
        errors = fabs(s - (int32_t)round( sin(an) * (1 << 16) ));
        
        if (errorc > maxerrorc) maxerrorc = errorc;
        if (errors > maxerrors) maxerrors = errors;
        
        //printf("Error S: %d, Error C: %d \n", errors, errorc);
        // Increasing the angle by 1 is like increasing it by 2^-16 in the 2.16 fixed-point representation
        angle += 1;
    }
    printf("Number of iterations: %d \n", N);
    printf("MaxError Sine: %d, MaxError Cosine: %d \n", maxerrors, maxerrorc);
    
    return 0;
    */
}



void Cordic (int32_t angle, int32_t *sine, int32_t *cosine) {
    
    // This is the Cordic method
    
    int32_t c = K;    // initial value of c
    int32_t A, s;
    
    if (angle <= 0) {
        s = -K;          // initial value of s if angle is negative (-K)*2^16
	A = -delta[0];   // initial value of A if angle is negative
    }
    else {
	s = K;          // initial value of s if angle is positive (K)*2^16
	A = delta[0];   // initial value of A if angle is positive 
    }
    
    // Main loop
    for (int i = 1; i < N; i++) {
        int32_t c_old = c;
        int32_t s_old = s;
        int32_t angle_lookup = delta[i];
        
        if (A < angle) {
	    A = A + angle_lookup;
            c= c_old - (s_old >> i);
            s = s_old + (c_old >> i);
        }
	else {
	    A = A - angle_lookup;
            c = c_old + (s_old >> i);
            s = s_old - (c_old >> i);
        }
        printf("%d: delta: %d, C_old: %d, C_new: %d, S_old: %d, S_new: %d \n", i, delta[i], c_old, c, s_old, s);
    }
        
    // "Return" the values for sine and cosine to the main function
    *sine = s;
    *cosine = c;
}
