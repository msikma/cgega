# Copyright (C) 2015-2016, Michiel Sikma <michiel@sikma.org>
# MIT license

CC        = ${DJGPP_CC}
CFLAGS    = -DHAVE_STDBOOL_H=1 -Wall -Wno-unused -mtune=i386 -I.
LDFLAGS   = 

TITLE     = CGEGA Engine
COPYRIGHT = (C) 2015-2016, Michiel Sikma (MIT license)
URL       = https://github.com/msikma/cgega

BIN       = cgega.exe
SRCDIR    = src
DISTDIR   = dist
STATICDIR = static

# Static files, e.g. the readme.txt file, that get copied straight to
# the dist directory.
STATIC    = $(shell find ${STATICDIR} -name "*.*" -not -name ".*" -type f ! -path ${STATICRES}?* 2> /dev/null)
STATICDEST= $(subst ${STATICDIR},${DISTDIR},${STATIC})

# All source files (*.c) and their corresponding object files.
SRC       = $(shell find ${SRCDIR} -name "*.c" 2> /dev/null)
OBJS      = $(SRC:%.c=%.o)

# Some information from Git that we'll use for the version indicator file.
HASH      = $(shell git rev-parse --short HEAD | awk '{print toupper($0)}')
BRANCH    = $(shell git describe --all | sed s@heads/@@ | awk "{print toupper($0)}")
COUNT     = $(shell git rev-list HEAD --count)
DATE      = $(shell date +"%Y-%m-%d %T")
VDEF      = -DCGEGA_NAME="\"${TITLE}\"" -DCGEGA_URL="\"${URL}\"" -DCGEGA_COPYRIGHT="\"${COPYRIGHT}\"" -DCGEGA_VERSION="\"${TITLE}\r\nBuild: ${COUNT}-${BRANCH} ${DATE} (${HASH})\r\n\""

# Check if a DJGPP compiler exists.
ifndef DJGPP_CC
  $(error To compile CGEGA, you need to set the DJGPP_CC environment variable to a DJGPP GCC binary, e.g. /usr/local/djgpp/bin/i586-pc-msdosdjgpp-gcc)
endif

.PHONY: clean static res
default: all

${DISTDIR}:
	mkdir -p ${DISTDIR}

%.o: %.c
	${CC} -c -o $@ $? ${CFLAGS}

# Pass on the version string to the version.c file.
src/utils/version.o: src/utils/version.c
	${CC} -c -o $@ $? ${CFLAGS} ${VDEF}

${DISTDIR}/${BIN}: ${OBJS}
	${CC} -o ${DISTDIR}/${BIN} $+ ${LDFLAGS}

${STATICDEST}: ${DISTDIR}
	@mkdir -p $(shell dirname $@)
	cp $(subst ${DISTDIR},${STATICDIR},$@) $@

all: ${DISTDIR} ${DISTDIR}/${BIN} ${STATICDEST}

static: ${STATICDEST}

clean:
	rm -rf ${DISTDIR}
	rm -f ${OBJS}
