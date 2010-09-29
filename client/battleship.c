#include <stdlib.h>
#include <stdio.h>

#include "connection.h"

void show_usage(FILE *fd, char *name) {
  fprintf(fd, "%s serveur_name port\n", name);
}

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

  r = send_message(my_connection, test_buf, 10);

  printf("End of Batlleship...\n");
  return EXIT_SUCCESS;
}
