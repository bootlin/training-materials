/*
 * TM1637.cpp
 * A library for the 4 digit display
 *
 * Copyright (c) 2012 seeed technology inc.
 * Website    : www.seeed.cc
 * Author     : Frankie.Chu
 * Create Time: 9 April,2012
 * Change Log :
 *
 * Modified by Michael Opdenacker, Bootlin, https://bootlin.com
 * to display the number of seconds since the Arduino was started.
 *
 * The MIT License (MIT)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "TM1637.h"
#define CLK 2//pins definitions for TM1637 and can be changed to other ports
#define DIO 3
TM1637 tm1637(CLK,DIO);

int reset = A0;
int videoready = A1;

void setup()
{
  tm1637.init();
  tm1637.set(BRIGHTEST);//BRIGHT_TYPICAL = 2,BRIGHT_DARKEST = 0,BRIGHTEST = 7;
  tm1637.clearDisplay();
  tm1637.point(false);

  Serial.begin(9600);
  pinMode(reset, INPUT_PULLUP); // Can't declare pins as pull-down on atmega328p
  pinMode(videoready, INPUT); // Can't set these as pull-ups as on the other side, BBB GPIO pins are not 5V tolerant
}

void loop() {

  int resetvalue, videovalue, start_time, elapsed;

  while (true) {

    resetvalue=1024;

    // Waiting for the Beaglebone Black to be resetted (reset taken low)
    while (resetvalue>100) {
      resetvalue = analogRead(reset);
      Serial.print("resetvalue=");
      Serial.println(resetvalue);
    }

    // Waiting reset to be released
    while (resetvalue<100) {
      resetvalue = analogRead(reset);
      Serial.print("resetvalue=");
      Serial.println(resetvalue);
    }

    start_time=millis();
    videovalue=0;

    while (videovalue<700) {
      elapsed = millis() - start_time;
      if (elapsed > 9999) {
        tm1637.point(true);
        tm1637.displayNum(((float) elapsed)/100, 1, false);
      }
      else
        tm1637.displayNum((float) elapsed, 0, false);
      videovalue = analogRead(videoready);
      Serial.print("videovalue=");
      Serial.println(videovalue);
      delay(10); // Sufficient delay is needed to write to the 7-segment matrix

      // Check a possible reset, meaning we should start over
      resetvalue = analogRead(reset);
      if (resetvalue<100 && elapsed>1000) {
         break;
      }
    }
  }
}
