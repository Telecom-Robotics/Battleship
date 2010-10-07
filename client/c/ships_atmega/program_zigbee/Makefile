# Makefile for little tests 

# Notre AVR : ATMEGA88 à 12MHz
MCU = atmega88
F_CPU = 12000000

# Programme à construire
TARGET = program_zigbee

# Où se trouve le bootloader-launcher ?
LAUNCHER ?= ../bootloader/launcher/launch-bootloader

# Ne plus toucher ci-dessous
CC           = avr-gcc
OBJCOPY      = avr-objcopy
OBJDUMP      = avr-objdump
#AVRDUDE_PATH = ../avrdude
AVRDUDE      = avrdude
#AVRDUDE_CONF = $(AVRDUDE_PATH)/avrdude.conf
AVRDUDE_CONF = /etc/avrdude.conf
SIZE         = avr-size

#OBJECTS = $(patsubst %.c,%.o,$(shell echo *.c))
OBJECTS = program_zigbee.o ../uart.o
HEADERS = $(shell echo *.h)
CFLAGS = -g -Os -finline-limit=800 -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Wall
LDFLAGS = -L /usr/local/avr/avr/lib -mmcu=$(MCU)
AVRDUDE_BAUDRATE = 9600
AVRDUDE_FLAGS += -p $(MCU) -b $(AVRDUDE_BAUDRATE) -F -u -V
# -C $(AVRDUDE_CONF)
SERIAL_PROG = avr109
SERIAL_DEV ?= /dev/ttyS0


all: $(TARGET).hex $(TARGET).lst
	@echo "==============================="
	@echo "compiled for: $(MCU)"
	@echo -n "program size is: "
	@$(SIZE) -A $< | grep "\.sec1" | tr -s " " | cut -d" " -f2
	@echo "==============================="


$(TARGET): $(OBJECTS) $(TARGET).o

%.o: $(HEADERS)

%.hex: %
	$(OBJCOPY) -O ihex -R .eeprom $< $@

%.lst: %
	$(OBJDUMP) -h -S $< > $@


program : $(TARGET).hex
	$(LAUNCHER) $(SERIAL_DEV) $(AVRDUDE_BAUDRATE)
	$(AVRDUDE) $(AVRDUDE_FLAGS) -c $(SERIAL_PROG) -P $(SERIAL_DEV) -U flash:w:$<



clean: 
	rm -f $(TARGET).hex
	rm -f $(TARGET).lst
	rm -f *~
	rm -f *.o
	rm -f $(TARGET)
