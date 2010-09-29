#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "connection.h"

#define MAX_STRING_LENGTH 20

struct ship {
    int X;
    int Y;
    char orientation; // 'H' or 'V'
};

struct ship ship_placement[5] = {
  {0,0,'V'},
  {1,0,'V'},
  {2,0,'V'},
  {3,0,'V'},
  {4,0,'V'}
};

void show_usage(FILE *fd, char *name) {
  fprintf(fd, "%s serveur_name port\n", name);
}

struct ship get_new_ship(void) {
  struct ship my_ship;
  my_ship.X = 0;
  my_ship.Y = 0;
  my_ship.orientation = 'H';
  return my_ship;
}

int main (int argc, char *argv[]) {
  struct connection *my_connection;
  char string_buf[MAX_STRING_LENGTH];
  int port;
  int current_ship = 0;
  int current_line = 0;
  int current_column = 0;
  int current_step = 2;
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

  while (1) {
    r = recv_message(my_connection, string_buf, MAX_STRING_LENGTH);
    if (r <= 0) {
      perror("Receiving message");
    }

    if (strncmp(string_buf, "FIRE", 4) == 0) {
      break;
    }
    else if (strncmp(string_buf, "SHIP;", 5) == 0) {
      int current_ship_length = string_buf[5] - '0';
      printf("DEBUG : placing ship of length %d\n", current_ship_length);
      // TODO !
      //ship_placement[current_ship] = get_new_ship();
      // For now ship_placement is hard coded and is not dependent of the ship length
      sprintf(string_buf, "SHIP;%1d;%1d;%c\r\n",
              ship_placement[current_ship].X,
              ship_placement[current_ship].Y,
              ship_placement[current_ship].orientation
             );

      send_message(my_connection, string_buf, 12);
      recv_message(my_connection, string_buf, MAX_STRING_LENGTH);
      if (r <= 0) {
        perror("Receiving message");
      }
      if (strncmp(string_buf, "OK", 2) == 0) {
        printf("DEBUG : placing ship of length %d SUCCESS\n", current_ship_length);
        current_ship ++;
      }
      else if (strncmp(string_buf, "ERR", 3) == 0) {
        printf("DEBUG : placing ship of length %d FAILURE, erasing the chip...\n", current_ship_length);
        ship_placement[current_ship].orientation='0';
      }
      else {
        printf("WARNING : error in protocol\n");
      }
    }
  }

  while (1) {

    if (strncmp(string_buf, "FIRE", 4) == 0) {
      sprintf(string_buf, "FIRE;%1d;%1d\r\n",
              current_column,
              current_line
             );
      send_message(my_connection, string_buf, 12);
      recv_message(my_connection, string_buf, MAX_STRING_LENGTH);
      if (r <= 0) {
        perror("Receiving message");
      }
      if (strncmp(string_buf, "OK", 2) == 0) {
        printf("DEBUG : FIRE at %d;%d SUCCESS\n", current_column, current_line);
        current_column += current_step;
        if (current_column >= 10) {
          current_line ++;
          current_column = current_line % current_step;
        }
      }
      else if (strncmp(string_buf, "ERR", 3) == 0) {
        printf("DEBUG : FIRE at %d;%d FAILURE\n", current_column, current_line);
      }
      else {
        printf("WARNING : error in protocol\n");
      }
    }
    else if (strncmp(string_buf, "YOU WIN", 7) == 0) {
      printf("YOU WIN!!\n");
      return EXIT_SUCCESS;
    }
    else if (strncmp(string_buf, "YOU LOS", 7) == 0) {
      printf("YOU LOSE :(\n");
      return EXIT_SUCCESS;
    }
    else {
      printf("WARNING : error in protocol\n");
    }

    // Read next messages
    r = recv_message(my_connection, string_buf, MAX_STRING_LENGTH);
    if (r <= 0) {
      perror("Receiving message");
    }
  }
  printf("End of Batlleship...\n");
  return EXIT_SUCCESS;
}
