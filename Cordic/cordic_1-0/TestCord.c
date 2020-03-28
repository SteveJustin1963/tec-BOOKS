/****************************************************************************
*
* Name: TestCord.c
*
* Synopsis: Test program for the Cordic module
*
* Copyright 1999  Grant R. Griffin
*
*                          The Wide Open License (WOL)
*
* Permission to use, copy, modify, distribute and sell this software and its
* documentation for any purpose is hereby granted without fee, provided that
* the above copyright notice and this license appear in all source copies. 
* THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY OF
* ANY KIND. See http://www.dspguru.com/wol.htm for more information.
*
*****************************************************************************/

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include "cordic.h"


/****************************************************************************/
double db(double linear)
{
  #define SMALL 1e-15

  if (linear < SMALL) {
    linear = SMALL;
  }

  return 20.0 * log10(linear);
}

/****************************************************************************/
int main(void)
{
  #define MAX_L               15
  #define TEST_MAG            10.0
  #define STEP_RADS           (PI / 180)          /* one-degree steps */
  #define DEGREES_TO_RADS(x)  (x / 180.0 * PI)

  int max_L;
  double I, Q, phase_in, phase_out, mag_out, I_out, Q_out;
  double mag_err, phase_err, I_err, Q_err;
  double mag_err_max, phase_err_max, cos_sin_err_max;

  for (;;) {

    do {
      max_L = 0;
      printf("\nEnter maximum L >= 3, (0 to quit) : ");
      scanf("%i", &max_L);
      if (max_L == 0) {
        exit(0);
      }
    } while (max_L < 3);

    cordic_construct(max_L);

    cordic_get_cos_sin(11.0 / 180 * PI, &I_out, &Q_out);

    cordic_get_mag_phase(1.0, 0.0, &mag_out, &phase_out);

    mag_err_max = phase_err_max = cos_sin_err_max = 0.0;
    for (phase_in = -PI; phase_in <= PI; phase_in += STEP_RADS) {
      I = cos(phase_in) * TEST_MAG;
      Q = sin(phase_in) * TEST_MAG;

      cordic_get_mag_phase(I, Q, &mag_out, &phase_out);
      mag_err = fabs(TEST_MAG - mag_out);
      phase_err = fabs(phase_in - phase_out);
      if (mag_err > mag_err_max) mag_err_max = mag_err;
      if (phase_err > phase_err_max) phase_err_max = phase_err;

      I = cos(phase_in);
      Q = sin(phase_in);

      cordic_get_cos_sin(phase_in, &I_out, &Q_out);
      I_err = fabs(I - I_out);
      Q_err = fabs(Q - Q_out);

      if (I_err > cos_sin_err_max) cos_sin_err_max = I_err;
      if (Q_err > cos_sin_err_max) cos_sin_err_max = Q_err;

    }

    /* normalize errors */
    mag_err_max /= TEST_MAG;   
    phase_err_max /= (2.0 * PI);
    
    printf("Maximum errors:\n");
    printf("  mag = %5.3lf dB, phase = %5.3lf dB, cos_sin = %5.3lf dB\n",
           db(mag_err_max), db(phase_err_max), db(cos_sin_err_max));

    cordic_destruct();
  }

  return 0;
}