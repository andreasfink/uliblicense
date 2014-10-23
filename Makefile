##
# File: Makefile
# Project "mmlic"
# (c) 2011 SMSRelay AG
# Create: Andreas Fink (afink@smsrelay.com)
#
#	


CC=clang
CFLAGS= -Isrc -DLINUX=1 -D_XOPEN_SOURCE=700 -D_BSD_SOURCE -std=c99 -g -O3 -fPIC -DLINUX=1 -Wno-trigraphs  -Wno-missing-field-initializers -Wmissing-prototypes -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -Wprotocol -Wdeprecated-declarations -Wno-sign-conversion  -fasm-blocks -fstrict-aliasing -fobjc-arc -fobjc-runtime=gnustep -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -fpascal-strings -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-nonfragile-abi -D_NONFRAGILE_ABI -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/root/GNUstep/Library/Headers -I/usr/local/include -I/usr/local/include -I/usr/local/include/openssl/   -DROUTER_CONFIG=Release
LDFLAGS= -rdynamic -pthread -fexceptions -fobjc-nonfragile-abi -fgnu-runtime -L/root/GNUstep/Library/Libraries -L/usr/local/lib -lgnustep-base -lobjc -lm -L/usr/local/lib -luuid -lsctp -lulib -lobjc -lssl -lcrypto  
EXEDIR=/usr/local/sbin

all:		mminfo mmdisp getmminfo

all-full: 	mminfo mmlic mmdisp getmminfo dispmminfo

dispmminfo: linux/linux-dispmminfo.m.o
	${CC} -o dispmminfo ${LDFLAGS} linux/linux-dispmminfo.m.o ${LIBS} ${STATIC_LIBS}

getmminfo: linux/linux-getmminfo.m.o
	${CC} -o getmminfo ${LDFLAGS} linux/linux-getmminfo.m.o ${LIBS} ${STATIC_LIBS}

mminfo:	src/mminfo.m.o src/common.m.o 
	${CC} -o mminfo ${LDFLAGS} src/mminfo.m.o src/common.m.o ${LIBS} ${STATIC_LIBS}

mmlic:	src/mmlic.m.o src/common.m.o
	${CC} -o mmlic ${LDFLAGS} src/mmlic.m.o src/common.m.o ${LIBS} ${STATIC_LIBS}

mmdisp:	src/mmdisp.m.o src/common.m.o
	${CC} -o mmdisp ${LDFLAGS} src/mmdisp.m.o src/common.m.o ${LIBS} ${STATIC_LIBS}

clean:
	rm -f linux/*.o src/*.o mminfo mmlic mmdisp getmminfo dispmminfo

.SUFFIXES: .m.o .o .m .c

%.m.o:	%.m
	${CC} -c ${CFLAGS} -x objective-c $<  ${INCLUDEDIRS} -o $@


install: mminfo mmdisp getmminfo
	mkdir -p $(DESTDIR)/usr/local/bin/
	install -b -g bin -o root -m 755 mminfo $(DESTDIR)/usr/local/bin/mminfo
	install -b -g bin -o root -m 755 mmdisp $(DESTDIR)/usr/local/bin/mmdisp
	install -b -g bin -o root -m 755 getmminfo $(DESTDIR)/usr/local/bin/getmminfo

install-full:  mminfo mmlic mmdisp getmminfo dispmminfo
	mkdir -p $(DESTDIR)/usr/local/bin/
	install -b -g bin -o root -m 755 mminfo $(DESTDIR)/usr/local/bin/mminfo
	install -b -g bin -o root -m 755 mmlic $(DESTDIR)/usr/local/bin/mmlic
	install -b -g bin -o root -m 755 mmdisp $(DESTDIR)/usr/local/bin/mmdisp
	install -b -g bin -o root -m 755 getmminfo $(DESTDIR)/usr/local/bin/getmminfo
	install -b -g bin -o root -m 755 dispmminfo $(DESTDIR)/usr/local/bin/dispmminfo
