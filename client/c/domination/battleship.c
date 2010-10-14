#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "connection.h"

typedef struct {
	int x,y;
} POINT;

int* coupsTires[10] = {0};

void show_usage(FILE *fd, char *name) {
  fprintf(fd, "%s serveur_name port\n", name);
}

void placementBateaux(int indice, char* buffer, char* bateau, int taille);
int voisins(int i, int j, POINT* tableau);

int main (int argc, char *argv[]) {
  struct connection *my_connection;
  char test_buf[10];
  int port;
  char *server_name;
  ssize_t r;

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

	sprintf(test_buf,"NEWGAME\n");

	r = send_message(my_connection,test_buf,8);
	r = recv_message(my_connection,test_buf,7);


  printf("End of Batlleship...\n");
  return EXIT_SUCCESS;
}

void placementBateaux(int indic, char* buffer, char* bateau,int taille)
{
	if (bateau[taille-1]=='5')
				sprintf(buffer,"SHIP;9;4;V\n");
	else if ((bateau[taille-1]=='4') && (indic==0))
				sprintf(buffer,"SHIP;1;1;H\n");
	else if ((bateau[taille-1]=='4') && (indic==1))
				sprintf(buffer,"SHIP;3;4;H\n");
	else if (bateau[taille-1]=='3')
				sprintf(buffer,"SHIP;7;2;V\n");
	else
				sprintf(buffer,"SHIP;3;6;H\n");
}

int voisins(int i, int j, POINT* tableau)
{
	int indice=0,nombreVoisins;
	
		if (!(i*(i-9) + 100*j*(j-9)))
		{
			if (!coupsTires[i][(int) 7*j/9. + 1])
			{tableau[indice].x=i;
				tableau[indice].y=(int) 7*j/9. +1;
				indice++;
			}

			if (!coupsTires[(int) 7*i/9. +1][j])
			{
				tableau[indice].x = (int) 7*i/9. +1;
				tableau[indice].y = j;
				indice++;
			}

			nombreVoisins = indice;
		}

		else if (!(i*(i-9)*j*(j-9)))
		{if (!(i*(i-9)))
			{ if (!coupsTires[i][j+1])
				{
					tableau[indice].x=i;
					tableau[indice].y=j+1;
					indice++;
				}

				if (!coupsTires[i][j-1])
				{
					tableau[indice].x=i;
					tableau[indice].y=j-1;
				}

				if (!coupsTires[(int) 7*i/9. + 1][j])
				{
					tableau[indice].x=(int) 7*i/9. + 1;
					tableau[indice].y = j;
					indice++;
				}

				nombreVoisins = indice;
			}

			else
			{ if (!coupsTires[i+1][j])
				{
					tableau[indice].x=i+1;
					tableau[indice].y=j;
					indice++;
				}

				if (!coupsTires[i-1][j])
				{
					tableau[indice].x=i-1;
					tableau[indice].y=j;
				}

				if (!coupsTires[i][7*j/9. + 1])
				{
					tableau[indice].x=i;
					tableau[indice].y = 7*j/9. + 1;
					indice++;
				}

				nombreVoisins = indice;
			}
		}

		else
		{

if (!coupsTires[i+1][j])
{

					tableau[indice].x=i+1;
					tableau[indice].y=j+1;
					indice++;
}

if (!coupsTires[i-1][j])
				{
					tableau[indice].x=i-1;
					tableau[indice].y=j;
					indice++;
				}
if (!coupsTires[i][j+1])
				{
					tableau[indice].x=i;
					tableau[indice].y=j+1;
					indice++;
				}

				
if (!coupsTires[i][j-1])
				{
					tableau[indice].x=i;
					tableau[indice].y=j-1;
					indice++;
				}

nombreVoisins = indice;
}

	return nombreVoisins;
	}
