#include <stdlib.h>

struct connection;

struct connection *open_connection(short port, char *server);
int send_message(struct connection *connection_handle, char *msg, short len);
int recv_message(struct connection *connection_handle, char *msg, short len);
int close_connection(struct connection *connection_handle);
