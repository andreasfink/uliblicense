##
# File: Makefile
# Project "mmlic"
# (c) 2011 SMSRelay AG
# Create: Andreas Fink (afink@smsrelay.com)
#
#	



CC=clang
CFLAGS=-g -O0 -Wmissing-prototypes -I. -Isrc -DCONFIGURATION=Release


CFLAGS=-DMACOSX=1
ARCHS="-arch i386 -arch x86_64"
LDFLAGS=-framework Foundation -framework IOKit
IEXEC=

all:	getmminfo dispmminfo

dispmminfo: mac-dispmminfo.m
	clang mac-dispmminfo.m ${LDFLAGS} -o dispmminfo

getmminfo: mac-getmminfo.m
	clang mac-getmminfo.m ${LDFLAGS} -o getmminfo


clean:
	-rm getmminfo
	-rm dispmminfo

