/*
  bttleship.c -- simple client to play battleship for Telecom Robotics lessons.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <avr/boot.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <util/delay.h>


#include "connection.h"
#include <uart_atmega.h>

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

char *index2(char *val, int c) {
	int i=0;
	while(val[i]!=c) ++i;
	return val+i;
}

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



void init_leds(void) {
	//On met les pins sur lesquelles sont branchées les diodes en output
	DDRD |= _BV(led_verte) | _BV(led_rouge);
}


// allumer tout pendant 1 sec
void test_leds(void) {
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

void send_str(struct connection *cn_hdl, char *str) {
	send_message(cn_hdl, str, strlen(str));
}

char *recv_str(struct connection *cn_hdl) {
	static char str[128];
	// 128B should be enough for everyone
	memset(str, 0, 128);
	recv_message(cn_hdl, str, 128);
	return str;
}

/*
 * 0: unplayed
 * 1: touched
 * 2: untouched
 */
static char map[10][10];

int place(int x, int y, int orientation/* 0 ==H; 1==V*/, int length) {
	int i,j;
	if(orientation) {
		//Vertical
		for(i=0;i<length;++i) {
			if(map[x][y+i]) {
				//Sorry ... Already a ship there ...
				for(j=0;j<i;++j) {
					map[x][y+j]=0;
				}
				return 0;
			}
			map[x][y+i]=1;
		}
	} else {
		//Horizontal
		for(i=0;i<length;++i) {
			if(map[x+i][y]) {
				//Sorry ... Already a ship there ...
				for(j=0;j<i;++j) {
					map[x+j][y]=0;
				}
				return 0;
			}
			map[x+i][y]=1;
		}
	}
	return 1;
}

int main(void)
{
	  init_leds();
	  test_leds();
	  wait_real_ms(1000);
	  test_leds();
	struct connection *my_connection;
	char cmd[128];
	memset(cmd, 0, 128);

	srand(42);

	my_connection = open_connection(0, NULL);

	char *val;
	{
		uart_puts("+++");
		wait_real_ms(1100);
		uart_puts("ATCH14\r\n");
		uart_puts("atid5353\r\n");
		uart_puts("atdlCC\r\n");
		uart_puts("atmyPH\r\n");
		uart_puts("ATCN\r\n");
	}
	send_str(my_connection, "\n");
	send_str(my_connection, "NEWGAME\n");
	{
		int length;
		int x,y;
		int i;
		int placed;
		for(i=0;i<10;++i)
			memset(map[i], 0, 10);
		while(1) {
			placed=0;
			val=recv_str(my_connection);
			
			if(strncmp("FIRE", val, 4)==0)
				break;
			if(strncmp("SHIP;", val, 5)!=0) {
				exit(-1);
			}
			length=atoi(val+5);
			if(length<2 || length>5) {
				exit(-1);
			}
			while(!placed) {
				x=rand()%10;
				y=rand()%10;
				if(x+(length)>=10 && y+(length)>=10) {
					//We're at bottom right
					x-=length;
					snprintf(cmd, 128, "SHIP;%d;%d;H\n", x, y);
					placed=place(x,y, 0, length);
				} else if(x+(length)>=10) {
					snprintf(cmd, 128, "SHIP;%d;%d;V\n", x, y);
					placed=place(x,y, 1, length);
				} else if(y+(length)>=10) {
					snprintf(cmd, 128, "SHIP;%d;%d;H\n", x, y);
					place(x,y, 1, length);
				} else {
					i=rand()%2;
					snprintf(cmd, 128, "SHIP;%d;%d;%c\n", x, y, i ? 'H' : 'V');
					placed=place(x,y, !i, length);
				}
			}
			send_str(my_connection, cmd);
			val=recv_str(my_connection);
			if(strncmp(val, "OK", 2)!=0) {
				fprintf(stderr, "Fail to place ships\n");
				return -1;
			}
		}
	}


	//Okay, we're done.
	//Now let's play.
	{
		int i;
		int x,y,j,last_x=0,last_y=0;
		for(i=0;i<10;++i)
			memset(map[i], 0, 10);
		j=0;
		int state=0;
		while(1) {
			++j;
			if(j==100)
				exit(-2);
			if(!state) {
				//No ship found
				x=0;y=0;
#if 0
				do {
					x=rand()%10;
					y=rand()%10;
				} while(map[x][y]);
#elif 0
				while(map[x][y]) {
					x+=2;
					if(x>=10) {
						y++;
						x=y%2;
					}
				}
#else
				do {
					x=rand()%10;
					y=rand()%10;
				} while(map[x][y] || (x%2 == y%2) );
#endif
			} else {
				int got=0;
				//Test au dessus
				i=0;
				x=last_x;
				y=last_y;
				while(map[x][y+i]==1 && y+i<9) ++i;
				if(map[x][y+i]==0) {
					y+=i;
					got=1;
				}
				//Test au dessous
				if(!got) {
					i=0;
					while(map[x][y-i]==1 && y-i>0) ++i;
					if(map[x][y-i]==0) {
						y-=i;
						got=1;
					}
				}
				//Test Ã  droite
				if(!got) {
					i=0;
					while(map[x+i][y]==1 && x+i<9) ++i;
					if(map[x+i][y]==0) {
						x+=i;
						got=1;
					}
				}
				//Test Ã  gauche
				if(!got) {
					i=0;
					while(map[x-i][y]==1 && x-i>0) ++i;
					if(map[x-i][y]==0) {
						x-=i;
						got=1;
					}
				}
				if(!got) {
					state=0;
					do {
						x=rand()%10;
						y=rand()%10;
					} while(map[x][y]);
				}
			}
			snprintf(cmd, 128, "FIRE;%d;%d\n", x, y);
			send_str(my_connection, cmd);
			{
				int next=0;
				while(!next) {
					val=recv_str(my_connection);
					while(val && val[0]) {
						if(strncmp(val, "TOUCH", 5)==0) {
							map[x][y]=1;
							if(strncmp(val, "TOUCHE-COULE", 9)==0) {
								state=0;
							} else {
								state=1;
								last_x=x;
								last_y=y;
							}
						} else if(strncmp(val, "COUL", 4)==0 || strncmp(val, "RATE", 4)==0) {
							map[x][y]=2;
						} else if(strncmp(val, "YOU ", 4)==0) {
							return -1;
						} else if(strncmp(val, "FIRE", 4)==0) {
							next=1;
						} else if(strncmp(val, "OK", 2)==0) {
							//Non rien...
						} else {
							//Ouais bon on se suicide mais non.
						}
						val=index2(val, '\n');
						if(val)
							val++;
					}
				}
			}
		}

	}
	return 0;
}

