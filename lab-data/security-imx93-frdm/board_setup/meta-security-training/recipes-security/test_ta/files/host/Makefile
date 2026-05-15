OBJS = test_ta_host.o


.PHONY: all
all: test_ta_host

test_ta_host: $(OBJS)
	$(CC) -o $@ $< -lteec

.PHONY: clean
clean:
	rm -f $(OBJS) test_ta_host

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
