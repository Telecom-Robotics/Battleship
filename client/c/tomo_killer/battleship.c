#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <time.h>
#include <unistd.h>

#include <connection.h>

void show_usage(FILE *fd, char *name) {
	fprintf(fd, "%s serveur_name port\n", name);
}

void send_str(struct connection *cn_hdl, char *str) {
	send_message(cn_hdl, str, strlen(str));
}

char *recv_str(struct connection *cn_hdl) {
	static char str[128];
	// 128B should be enough for everyone
	bzero(str, 128);
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
				printf("Conflict found\n");
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
				printf("Conflict found\n");
				return 0;
			}
			map[x+i][y]=1;
		}
	}
	return 1;
}

int main (int argc, char *argv[]) {
	struct connection *my_connection;
	int port;
	char *server_name;
	char *cmd;

	srand(time(NULL));
	printf("Welcome to Battleship!\n");

	if (argc != 3) {
		show_usage(stderr, argv[0]);
		return EXIT_FAILURE;
	}

	server_name = argv[1];
	port = atoi(argv[2]);

	my_connection = open_connection(port, server_name);
	if (my_connection == NULL) {
		fprintf(stderr, "Problem while opening connection on %s:%d\n", server_name, port);
		return EXIT_FAILURE;
	}

	char *val;
	send_str(my_connection, "NEWGAME\n");
	{
		int length;
		int x,y;
		int i;
		int placed;
		for(i=0;i<10;++i)
			bzero(map[i], 10);
				{
					int x,y;
					for(x=0;x<10;++x) {
						for(y=0;y<10;++y)
							printf("%d ", map[x][y]);
						printf("\n");
					}
				}
				printf("\n\n");
		while(1) {
			placed=0;
			val=recv_str(my_connection);
			
			if(strncmp("FIRE", val, 4)==0)
				break;
			if(strncmp("SHIP;", val, 5)!=0) {
				fprintf(stderr, "Wrong protocol, byebye (%s:%s:%d)\n", __FILE__, __FUNCTION__, __LINE__);
				exit(-1);
			}
			length=atoi(val+5);
			if(length<2 || length>5) {
				fprintf(stderr, "Wrong protocol, byebye (%s:%s:%d)\n", __FILE__, __FUNCTION__, __LINE__);
				exit(-1);
			}
			while(!placed) {
				x=rand()%10;
				y=rand()%10;
				if(x+(length)>=10 && y+(length)>=10) {
					//We're at bottom right
					x-=length;
					asprintf(&cmd, "SHIP;%d;%d;H\n", x, y);
					placed=place(x,y, 0, length);
					printf("\t0\n");
				} else if(x+(length)>=10) {
					asprintf(&cmd, "SHIP;%d;%d;V\n", x, y);
					placed=place(x,y, 1, length);
					printf("\t1\n");
				} else if(y+(length)>=10) {
					asprintf(&cmd, "SHIP;%d;%d;H\n", x, y);
					place(x,y, 1, length);
					printf("\t2\n");
				} else {
					i=rand()%2;
					asprintf(&cmd, "SHIP;%d;%d;%c\n", x, y, i ? 'H' : 'V');
					placed=place(x,y, !i, length);
					printf("\t3\n");
				}
			}
			send_str(my_connection, cmd);
			val=recv_str(my_connection);
			if(strncmp(val, "OK", 2)!=0) {
				fprintf(stderr, "Fail to place ships\n");
				{
					int x,y;
					for(x=0;x<10;++x) {
						for(y=0;y<10;++y)
							printf("%d ", map[x][y]);
						printf("\n");
					}
				}
				return -1;
			}
		}
	}


	//Okay, we're done.
	//Now let's play.
	{
		int i;
		int x,y,j,last_x,last_y;
		for(i=0;i<10;++i)
			bzero(map[i], 10);
		j=0;
		int state=0;
		while(1) {
			++j;
			printf("j=%d\n", j);
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
				printf("Hahahaa!\n");
				int got=0;
				//Test au dessus
				i=0;
				x=last_x;
				y=last_y;
				printf("(%d):%d:%d:%d\n", __LINE__, x, y, got);
				while(map[x][y+i]==1 && y+i<9) ++i;
				if(map[x][y+i]==0) {
					y+=i;
					got=1;
				}
				printf("(%d):%d:%d:%d\n", __LINE__, x, y, got);
				//Test au dessous
				if(!got) {
					i=0;
					while(map[x][y-i]==1 && y-i>0) ++i;
					if(map[x][y-i]==0) {
						y-=i;
						got=1;
					}
				}
				printf("(%d):%d:%d:%d\n", __LINE__, x, y, got);
				//Test à droite
				if(!got) {
					i=0;
					while(map[x+i][y]==1 && x+i<9) ++i;
					if(map[x+i][y]==0) {
						x+=i;
						got=1;
					}
				}
				printf("(%d):%d:%d:%d\n", __LINE__, x, y, got);
				//Test à gauche
				if(!got) {
					i=0;
					while(map[x-i][y]==1 && x-i>0) ++i;
					if(map[x-i][y]==0) {
						x-=i;
						got=1;
					}
				}
				printf("(%d):%d:%d:%d\n", __LINE__, x, y, got);
				if(!got) {
					printf("Agaaaaaaaaa?\n");
					{
						int x,y;
						for(x=0;x<10;++x) {
							for(y=0;y<10;++y)
								printf("%d ", map[x][y]);
							printf("\n");
						}
						printf("last_x=%d,last_y=%d\n", last_x, last_y);
					}
					state=0;
					do {
						x=rand()%10;
						y=rand()%10;
					} while(map[x][y]);
				}
			}
			asprintf(&cmd, "FIRE;%d;%d\n", x, y);
			printf("%s", cmd);
			send_str(my_connection, cmd);
			{
				int next=0;
				while(!next) {
					val=recv_str(my_connection);
					printf("%s\n", val);
					while(val && val[0]) {
						if(strncmp(val, "TOUCH", 5)==0) {
							printf("%dx%d=1\n", x, y);
							map[x][y]=1;
							if(strncmp(val, "TOUCHE-COULE", 9)==0) {
								state=0;
							} else {
								state=1;
								last_x=x;
								last_y=y;
							}
						} else if(strncmp(val, "COUL", 4)==0 || strncmp(val, "RATE", 4)==0) {
							printf("%dx%d=2\n", x, y);
							map[x][y]=2;
						} else if(strncmp(val, "YOU ", 4)==0) {
							printf("FINI(%s)\n", val);
							return -1;
						} else if(strncmp(val, "FIRE", 4)==0) {
							next=1;
						} else if(strncmp(val, "OK", 2)==0) {
							//Non rien...
						} else {
							printf("Unknown val:'%s'(%p)={%d}\n", val, val, val[0]);
						}
						val=index(val, '\n');
						if(val)
							val++;
					}
				}
			}
		}

	}

	printf("End of Batlleship...\n");
	return EXIT_SUCCESS;
}
