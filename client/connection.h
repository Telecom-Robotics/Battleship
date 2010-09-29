#include <stdlib.h>
#include <sys/types.h>

struct connection;

struct connection *open_connection(short port, char *server);
ssize_t send_message(struct connection *connection_handle, char *msg, size_t len);
ssize_t recv_message(struct connection *connection_handle, char *msg, size_t len);
int close_connection(struct connection *connection_handle);
