/*
  bttleship.c -- simple client to play battleship for Telecom Robotics lessons.
*/

#include <stdlib.h>
#include <avr/boot.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <util/delay.h>


#include "connection.h"

#define led_rouge PD4 // rouge
#define led_verte PD3 // vert


// coefficient to accelerate rotation servo


// manipulation des LEDs
#define turn_off_led_rouge()  PORTD&=~(1<<led_rouge)
#define turn_off_led_verte()  PORTD&=~(1<<led_verte)
#define turn_on_led_rouge()  PORTD|=(1<<led_rouge)
#define turn_on_led_verte()  PORTD|=(1<<led_verte)
#define toggle_led_rouge()  PORTD^=(1<<led_rouge)
#define toggle_led_verte()  PORTD^=(1<<led_verte)

void wait_real_ms(short time) {
  short i, j;
  for (j=0; j<time; j++) {
    // on a besoin de 7 instructions pour une addition sur des shorts
    // le quartz est à 12MHz
    for (i=0; i<(12000/7); i++)
    {
      asm("nop");
    }
  }
}



void init_leds(void)
{
  //On met les pins sur lesquelles sont branchées les diodes en output
  DDRD |= _BV(led_verte) | _BV(led_rouge);
}


// allumer tout pendant 1 sec
void test_leds(void)
{
  turn_on_led_rouge();
  turn_on_led_verte();
  wait_real_ms(1000);
  turn_off_led_rouge();
  turn_off_led_verte();
}

// eteindre les 4 leds
void eteindre_leds (void)
{
  turn_off_led_rouge();
  turn_off_led_verte();
}

int main(void)
{
  init_leds();
  test_leds();
  wait_real_ms(1000);
  send_message(NULL, "Welcome to Battleship...\n", 25);
  test_leds();
  return 0;
}

