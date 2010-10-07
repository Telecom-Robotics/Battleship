

#include "config.h"
#include "uart_atmega.h"

struct connection {
};


/* block until one character has been read */
uint8_t
uart_getc(void)
{
  // wait if a byte has been received
  while (!(_UCSRA_UART0 & _BV(_RXC_UART0)));
  // return received byte
  return _UDR_UART0;
}

short cnt;
/*indicates if UART is empty*/
uint8_t
uart_isempty(void)
{
  return !(_UCSRA_UART0 & _BV(_RXC_UART0));
}

/* output one character */
void
uart_putc(uint8_t data)
{
  // loop until data has been transmitted
  while (!(_UCSRA_UART0 & _BV(_UDRE_UART0)));
  // put data in buffer
  _UDR_UART0 = data;
}


/* Send a string (NULL terminated), replacing "\n" with "\r\n" */
void
uart_puts(char *line)
{
  while(*line !=0)
  {
    if (*line=='\n')
      uart_putc('\r');
    uart_putc(*line++);
  }
}

void
uart_put_shorthex(long n)
{
  int i;
  for(i=2; i!=0; i--)
  {
    unsigned char c;
    c = (n >> (4*i-4)) & 0x0f;
    if (c < 10)
      uart_putc(c+'0');
    else
      uart_putc(c-10+'A');
  }
}


void
uart_put_hex(long n)
{
  int i;
  for(i=8; i!=0; i--)
  {
    unsigned char c;
    c = (n >> (4*i-4)) & 0x0f;
    if (c < 10)
      uart_putc(c+'0');
    else
      uart_putc(c-10+'A');
  }
}

void uart_flush( void )
{
  unsigned char dummy;
  while ( UCSR0A & (1<<RXC0) ) dummy = UDR0;
}

struct connection *open_connection(short port, char *server)
{
  return 0;
}

int send_message(struct connection *connection_handle, char *msg, short len) {
  int r = 0;
  while(*msg !=0 && r<len)
  {
    if (*msg=='\n')
      uart_putc('\r');
    uart_putc(*msg++);
    r ++;
  }
  return r;
}

int recv_message(struct connection *connection_handle, char *msg, short len) {
  int r = 0;
  do {
    msg[r] = uart_getc();
    r++;
  } while (msg[r-1] != '\n' && msg[r-1] != '\r' && (r <= len));

  msg[r] = 0;
  return r;
}

int close_connection(struct connection *connection_handle) {
  return 0;
}
