all: pgflt gpiotest

pgflt: pgflt.c
	$(CROSS_COMPILE)gcc -O0 -o$@ $^ -lrt

gpiotest: gpiotest.c
	$(CROSS_COMPILE)gcc -O0 -o$@ $^ -lrt -lgpiod

clean:
	rm -f pgflt
	rm -f gpiotest

.PHONY: clean
