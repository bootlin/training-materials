CC?=$(CROSS_COMPILE)gcc

all: monitor tcp_client

monitor: monitor.c
	$(CC) -O0 -o$@ $^

tcp_client: tcp_client.c
	$(CC) -O0 -o$@ $^

clean:
	rm -f monitor
	rm -f tcp_client

.PHONY: clean
