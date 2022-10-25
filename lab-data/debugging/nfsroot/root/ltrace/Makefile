CC=${CROSS_COMPILE}gcc

all: app

libauthent.so: authent_library.c authent_library.h
	${CC} $< -g3 -fPIC -shared -o $@

app: app.c authent_library.h libauthent.so
	${CC} $< -g3 -L. -I. -lauthent -o $@
