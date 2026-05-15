all: seccomp-test

seccomp-test: seccomp-test.o
	${CC} $^ -lseccomp -o $@

clean:
	rm -f *.o seccomp-test
