# File: Makefile
#

all:	test	plugin.so

plugin.so:	plugin.c
	${CC} -shared -o plugin.so plugin.c


%.m.o:	%.m
	${CC} -c ${CFLAGS} -x objective-c -fobjc-arc $< ${INCLUDEDIRS} -o $@


test: test.o
	${CC} -o test -ldl test.o

test.o: test.c
	${CC} -c test.c -o test.o
