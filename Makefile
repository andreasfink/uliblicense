##
# File: Makefile
# Project "mmlic"
# (c) 2011 SMSRelay AG
# Create: Andreas Fink (afink@smsrelay.com)
#
#	



CC=clang
CFLAGS=-g -O3 -Wmissing-prototypes -I. -Isrc -DCONFIGURATION=Release

ifeq ($(shell uname -s),Linux)

CFLAGS+=-DLINUX=1 -fasm-blocks -fstrict-aliasing -fobjc-runtime=gnustep -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -fpascal-strings
ARCHS=
LDFLAGS=
LIBS=-L/usr/local/lib -lgnustep-base -lobjc
IEXEC=chmod 4755 /usr/sbin/dmidecode

>>>>>>> 7648bdfc48cdfe42d265e8beca80ea6ec88cc162
else

CFLAGS=-DMACOSX=1
ARCHS="-arch i386 -arch x86_64"
LDFLAGS=-framework Foundation -framework IOKit
IEXEC=
endif

all:	mminfo mmlic mmdisp
linux: dispmminfo getmminfo

dispmminfo: linux-dispmminfo.m
	clang linux-dispmminfo.m /usr/local/lib/libFoundation.so -o dispmminfo

getmminfo: linux-getmminfo.m
	clang linux-getmminfo.m /usr/local/lib/libFoundation.so  -o getmminfo


clean:
	rm mminfo
	rm mmlic
	rm mmdisp
	rm src/*.o

mminfo:	src/mminfo.m.o src/common.m.o 
	${CC} -o mminfo ${LDFLAGS} src/mminfo.m.o src/common.m.o ${LIBS}

mmlic:	src/mmlic.m.o src/common.m.o
	${CC} -o mmlic ${LDFLAGS} src/mmlic.m.o src/common.m.o ${LIBS}

mmdisp:	src/mmdisp.m.o src/common.m.o
	${CC} -o mmdisp ${LDFLAGS} src/mmdisp.m.o src/common.m.o ${LIBS}


install: mminfo mmlic mmdisp
	cp mmlic /usr/sbin/mmlic
	chmod 755 /usr/sbin/mmlic

	chown root /usr/sbin/mmlic
	cp mmdisp /usr/sbin/mmdisp
	chmod 755 /usr/sbin/mmdisp
	chown root /usr/sbin/mmdisp
	cp mminfo /usr/bin/mminfo
	chmod 755 /usr/bin/mminfo
	chown root /usr/bin/mminfo
	${IEXEC}

.o:     .c .h

.SUFFIXES: .m.o .o .m .c

src/mminfo.m.o:	src/mminfo.m
	${CC} -c ${CFLAGS} $<  -IClasses -o $@

src/common.m.o:	src/common.m
	${CC} -c ${CFLAGS} $<  -IClasses -o $@

src/mmlic.m.o:	src/mmlic.m
	${CC} -c ${CFLAGS} $<  -IClasses -o $@

src/mmdisp.m.o:	src/mmdisp.m
	${CC} -c ${CFLAGS} $<  -IClasses -o $@


install_root/usr/sbin/mmlic: mmlic
	mkdir -p install_root/usr/sbin
	cp mmlic /usr/sbin/mmlic
	chmod 755 install_root/usr/sbin/mmlic

install_root/usr/sbin/mmdisp: mmdisp
	mkdir -p install_root/usr/sbin
	cp mmlic /usr/sbin/mmdisp
	chmod 755 install_root/usr/sbin/mmdisp

install_root/usr/bin/mminfo: mminfo
	mkdir -p install_root/usr/bin
	cp mmlic /usr/bin/mminfo
	chmod 755 install_root/usr/bin/mminfo


pkg:	mmlic mmdisp mminfo
	-rm -rf install_root
	-mkdir -p install_root/usr/bin
	-mkdir -p install_root/usr/sbin
	cp mmlic install_root/usr/sbin/mmlic
	chmod 755 install_root/usr/sbin/mmlic
	chown root:wheel install_root/usr/sbin/mmlic
	cp mmdisp install_root/usr/sbin/mmdisp
	chmod 755 install_root/usr/sbin/mmdisp
	chown root:wheel install_root/usr/sbin/mmdisp
	cp mminfo install_root/usr/bin/mminfo
	chmod 755 install_root/usr/bin/mminfo
	chown root:wheel install_root/usr/bin/mminfo
	PKGPREFIX=
	VERSION=1.0
	LONGVER=1.0
	/Applications/PackageMaker.app/Contents/MacOS/PackageMaker --target 10.6 --root install_root/  --out mmlic_${VERSION}_`date +%Y%m%d%H%M`.pkg --id com.smsrelay.messagemover --version "$LONGVER" --title mmlic --install-to /  --verbose --root-volume-only --discard-forks --certificate "Developer ID Installer: SMSRelay AG"
