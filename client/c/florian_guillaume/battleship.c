#include <stdlib.h>
#include <stdio.h>

#include "connection.h"

void show_usage(FILE *fd, char *name) {
  fprintf(fd, "%s serveur_name port\n", name);
}

struct ship 
{
  int X,Y;
  char orientation;
};

int main (int argc, char *argv[]) {
  struct connection *my_connection;
  char test_buf[10];
  int port,taille,i;
  char *server_name;
  ssize_t envoi,reponse;
  struct ship position [5]={(0,0,'V') , (4,3,'H') , (2,5,'H') , (9,0,'V') , (0,2,'H')};
  int X,Y;
  int last_fire [2] ;

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

  sprintf("NEW_GAME",test_buf);
 
  envoi = send_message(my_connection, test_buf, 10);

  while(1)

    {

      reponse = read_message(my_connection,test_buf,10);

      if (strcmp(test_buf,"FIRE") == 0)
        {
          printf("passage en mode jeu\n");
          
          sprintf("FIRE;%d;%d",last_fire[0],last_fire[1])

          break;

        }


      else if (strncmp(test_buf, "SHIP;", 5)==0)
        {
          taille=atoi(test_buf+5);
      
          printf("la taille du bateau a placer est %d\n",taille);

          sprintf("SHIP;%d;%d;%c",position[i].X,position[i].Y,position[i].orientation,test_buf);

          send_message(my_connection,test_buf,10);

        }

      else if(strcmp(test_buf,"OK")==0)
        {
          printf("bateau %d place\n",i);

          i++;    
          
        }

      else if (strcmp(test_buf,"ERR")==0)

        {
          printf("les coordonnees sont incorrectes\n");
          printf("saisissez de nouvelles coordonnees\n");

          scanf("%d,%d",&position[i].X,&position[i].Y);
          scanf("%*c");
          scanf("%c",&position[i].orientation);

           sprintf("SHIP;%d;%d;%c",position[i].X,position[i].Y,position[i].orientation,test_buf);

          send_message(my_connection,test_buf,10);

        }

      else  

        printf(" problem\n");

      printf("fin de la bataille");

      exit(1);

    }

   for ( k=0;k<10;k++)
    {
      for(j=0;j<10;j++)
        {
           last_fire[0]++;
              
           send_message(my_connection,test_buf,10);
            
           read_message(my_connection,test_buf,10);

           if(strcmp(test_buf,"YOU WIN!")==0 || strcmp(test_buf,"YOU LOSE!")==0)
             {
               printf("%s",test_buf);
               
            }
          last[1]++;
        }
          

          
      else 
        {
          


  printf("End of Batlleship...\n");
  return EXIT_SUCCESS;
}
