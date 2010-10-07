#ifndef _UART_H
#define _UART_H

#include "type.h"

uint8_t uart_getc(void);
void uart_putc(uint8_t data);
void uart_puts(char *line);
void uart_put_hex(long n);
void uart_put_shorthex(long n);
void uart_flush( void );
uint8_t uart_isempty(void);
#endif /* _UART_H */
