all: systemd-test

systemd-test: systemd-test.o
	${CC} $^ -o $@

clean:
	rm -f *.o systemd-test
