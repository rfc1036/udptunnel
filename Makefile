PREFIX ?= /usr/local
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
CFLAGS ?= -g -O2
INSTALL ?= install
PKG_CONFIG ?= pkg-config

ifeq ($(shell $(PKG_CONFIG) --exists libsystemd || echo NO),)
CPPFLAGS += -DHAVE_SYSTEMD_SD_DAEMON_H $(shell $(PKG_CONFIG) --cflags libsystemd)
LDLIBS += $(shell $(PKG_CONFIG) --libs libsystemd)
endif

CFLAGS += -MMD -MP
CFLAGS += -Wall -Wextra

OBJECTS := log.o network.o utils.o udptunnel.o

ifneq ($(V),1)
BUILT_IN_LINK.o := $(LINK.o)
LINK.o = @echo "  LD      $@";
LINK.o += $(BUILT_IN_LINK.o)
BUILT_IN_COMPILE.c := $(COMPILE.c)
COMPILE.c = @echo "  CC      $@";
COMPILE.c += $(BUILT_IN_COMPILE.c)
endif

all: udptunnel

install: udptunnel
	@$(INSTALL) -v -d "$(DESTDIR)$(BINDIR)" && install -v -m 0755 udptunnel "$(DESTDIR)$(BINDIR)/udptunnel"

clean:
	@$(RM) -vf $(OBJECTS) $(OBJECTS:%.o=%.d) udptunnel

udptunnel: $(OBJECTS)

.PHONY: all install clean
-include *.d
