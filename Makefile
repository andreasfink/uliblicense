##
# File: Makefile
# Project "mmlic"
# (c) 2011 SMSRelay AG
# Create: Andreas Fink (afink@smsrelay.com)
#
#	



CC=clang

ifeq ($(shell uname -s),Linux)

CFLAGS= -Isrc -std=c99 -g -O3 -fPIC -DLINUX=1 -DPOSIX  -DSCTP_IN_KERNEL=1  -Wno-trigraphs  -Wno-missing-field-initializers -Wmissing-prototypes -Wno-implicit-atomic-properties -Wno-receiver-is-weak -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -Wprotocol -Wdeprecated-declarations -Wno-sign-conversion  -fasm-blocks -fstrict-aliasing -fobjc-arc -fobjc-runtime=gnustep -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -fpascal-strings -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/root/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep -I/usr/local/include   -I/usr/local/include   -DCONFIGURATION=Release -DLINUX=1 -DSCTP_IN_KERNEL=1 -D_POSIX_SOURCE -D_BSD_SOURCE -fPIC -fobjc-runtime=gnustep -fobjc-arc -fpascal-strings -fasm-blocks -fstrict-aliasing -fdiagnostics-show-note-include-stack -Wmissing-prototypes 
LDFLAGS=  -L/usr/local/lib -lcrypto   -L/usr/local/lib -lssl  
LIBS=-L/usr/local/lib -lgnustep-base -lobjc
IEXEC=chmod 4755 /usr/sbin/dmidecode

else

CFLAGS=-DMACOSX=1 -g -O3 -Wmissing-prototypes -I. -Isrc -DCONFIGURATION=Release
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
	mkdir -p $(DESTDIR)/usr/sbin
	mkdir -p $(DESTDIR)/usr/bin
	cp mmlic $(DESTDIR)/usr/sbin/mmlic
	chmod 755 $(DESTDIR)/usr/sbin/mmlic
	chown root $(DESTDIR)/usr/sbin/mmlic
	cp mmdisp $(DESTDIR)/usr/sbin/mmdisp
	chmod 755 $(DESTDIR)/usr/sbin/mmdisp
	chown root $(DESTDIR)/usr/sbin/mmdisp
	cp mminfo $(DESTDIR)/usr/bin/mminfo
	chmod 755 $(DESTDIR)/usr/bin/mminfo
	chown root $(DESTDIR)/usr/bin/mminfo
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
