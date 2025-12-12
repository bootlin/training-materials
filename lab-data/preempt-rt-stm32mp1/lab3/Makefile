CC?=$(CROSS_COMPILE)gcc

all: crc_test gpiotest pgflt

crc_test: crc_test.c
	$(CC) -O0 -o$@ $^ -lrt

gpiotest: gpiotest.c
	$(CC) -O0 -o$@ $^ -lrt -lgpiod

pgflt: pgflt.c
	$(CC) -O0 -o$@ $^ -lrt -lgpiod

clean:
	rm -f crc_test
	rm -f gpiotest

.PHONY: clean
