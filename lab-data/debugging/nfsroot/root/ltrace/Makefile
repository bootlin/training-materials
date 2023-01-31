CC=${CROSS_COMPILE}gcc

all: authent

libauthent.so: authent_library.c authent_library.h
	${CC} $< -g3 -fPIC -shared -o $@

authent: authent.c authent_library.h libauthent.so
	${CC} $< -g3 -L. -I. -lauthent -o $@
