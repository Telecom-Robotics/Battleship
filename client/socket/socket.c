#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/types.h>
#include <errno.h>
#include <limits.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

#include "../connection.h"

#define DEBUG 0

struct connection {
  int fd;
};

static struct in_addr *atoaddr(char *address)
{
  struct hostent *host;
  static struct in_addr saddr;

  /* First try it as aaa.bbb.ccc.ddd. */
  saddr.s_addr = inet_addr(address);
  if ((int) saddr.s_addr != -1) {
    return &saddr;
  }
  host = gethostbyname(address);
  if (host != NULL) {
    return (struct in_addr *) *host->h_addr_list;
  }
  return NULL;
}

int sock_connect(short port, char *netaddress)
{
  struct in_addr *addr;
  struct hostent *hp;
  struct sockaddr_in address;
  int sock_fd;

  if ((hp = gethostbyname(netaddress)) == 0) {
    perror("gethostbyname");
    exit(1);
  }

  addr = atoaddr(netaddress);
  if (addr == NULL) {
    fprintf(stderr,"make_connection:  Invalid network address.\n");
    return -1;
  }
  //fprintf(stderr, "IP address : %s\n", addr->s_addr);
  memset((char *) &address, 0, sizeof(address));
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = ((struct in_addr *)(hp->h_addr))->s_addr;

  sock_fd = socket(AF_INET, SOCK_STREAM, 0);
  fprintf(stderr, "sock_fd : %d\n", sock_fd);
  if (connect(sock_fd, (struct sockaddr *) &address, sizeof(address)) < 0) {
    perror("connect");
    return -1;
  }

  return sock_fd;
}

struct connection *open_connection(short port, char *server)
{
  struct connection *c;
  c = malloc(sizeof(struct connection));
  if (c == NULL)
  {
    perror("Could not allocate memory\n");
  }
  c->fd = sock_connect(port, server);
  if (c->fd < 0) {
    free(c);
    return NULL;
  }

  return c;
}

ssize_t send_message(struct connection *connection_handle, char *msg, size_t len) {
  ssize_t r;
  r = send(connection_handle->fd, msg, len, 0);
  msg[r] = 0;
#ifdef DEBUG
  fprintf(stderr, "**** Have sent %ld bytes : %s\n", r, msg);
#endif
  return r;
}

ssize_t recv_message(struct connection *connection_handle, char *msg, size_t len) {
  ssize_t r;
  r = recv(connection_handle->fd, msg, len, 0);
  msg[r] = 0;
#ifdef DEBUG
  fprintf(stderr, "**** Have received %ld bytes : %s\n", r, msg);
#endif
  return r;
}

int close_connection(struct connection *connection_handle) {
  return close(connection_handle->fd);
}
