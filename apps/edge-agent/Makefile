CC ?= cc
CFLAGS ?= -Wall -Wextra -O2
LDFLAGS ?=
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
TARGET := edge-agent
SRC := main.c

.PHONY: all install clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

install: $(TARGET)
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 0755 "$(TARGET)" "$(DESTDIR)$(BINDIR)/$(TARGET)"

clean:
	rm -f "$(TARGET)"

