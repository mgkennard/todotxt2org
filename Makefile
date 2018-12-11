prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox

install: build
	install -d "$(bindir)"
	install ".build/release/todotxt2org" "$(bindir)/todotxt2org"

uninstall:
	rm -rf "$(bindir)/todotxt2org"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

