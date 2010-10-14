#include <stdlib.h>
#include <avr/io.h>

#include "../uart.h"


void wait_real_ms(short time) {
        short i, j;
        for (j=0; j<time; j++) {
                // on a besoin de 7 instructions pour une addition sur des shorts
                // le quartz est à 12MHz
                for (i=0; i<(12000/7); i++) {
                        asm("nop");
                }
        }
}


int main(void)
{
        unsigned char my_serial_number [8];
	unsigned char n;
        unsigned char my_char;

	// Pas besoin de configurer l'UART puisque le bootloader s'en charge
	
	uart_puts("C'est parti a 9600!\n");

	//***************************************
	//initialisation du zigbee en mode special
	//wait 1.1 second
        wait_real_ms(1100);
        uart_puts("+++");
	wait_real_ms(1100);
        
	//empty UART input fifo
	//uart_puts("ATCH11\r\n");// Set canal to 0x11
	//uart_puts("ATIDCAFE\r\n");//low address  |broadcast
	//empty UART input fifo
	uart_flush();
	uart_puts("ATSL\r");//Get serial number
        my_serial_number[0] = uart_getc();
        my_serial_number[1] = uart_getc();
        my_serial_number[2] = uart_getc();
        my_serial_number[3] = uart_getc();
        my_serial_number[4] = uart_getc();
        my_serial_number[5] = uart_getc();
        my_serial_number[6] = uart_getc();
        my_serial_number[7] = uart_getc();
	//Finish

        // set my addresse
        uart_puts("ATMYA204\r");

        uart_puts("ATID5353\r");// PAN ID = kind of sub network
        //uart_puts("ATDL1000\r");// destination address

        uart_puts("ATCH14\r");// channel 14

/*         // set baudrate to 57600 */
/*         uart_puts("ATBD6\r"); */

        // exit configuration mode
        uart_puts("ATCN\r\n");

/*         // Directly change baudrate of UART to 57600 */
/*         // UBR = fosc/(16*baud)-1 = 12*10^6/(16*115200)-1 = 12; */
/*         UBRR0 = 12; */

        // ATTENTION : il faut passer en double speed asynchronous mode avec U2X0 à 1 pour avoir 8 au lieu de 16
        //UCSR0A |= _BV(U2X0);

	//***************************************
	//On continue
        n = 0;
	uart_puts("C'est parti : pret a recevoir !\n");        
        while (1) {
                my_char = uart_getc();
                uart_putc(my_serial_number[0]);
                uart_putc(my_serial_number[1]);
                uart_putc(my_serial_number[2]);
                uart_putc(my_serial_number[3]);
                uart_putc(my_serial_number[4]);
                uart_putc(my_serial_number[5]);
                uart_putc(my_serial_number[6]);
                uart_putc(my_serial_number[7]);
                uart_puts(" : ");
                uart_put_shorthex(n);
                uart_puts(" : ");
                uart_putc(my_char);
                uart_puts("\n");
                if (my_char == 'W') {
                        uart_puts("writing Zigbee flash...\n");
                        wait_real_ms(1100);
                        uart_puts("+++");
                        wait_real_ms(1100);
                        uart_puts("ATWR\r");
                        uart_puts("ATCN\r\n");
                        uart_puts("Done\n");
                }
                n++;
        }

        return 1;
}
