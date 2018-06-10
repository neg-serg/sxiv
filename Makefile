VERSION := git-20170908

.SUFFIXES:

include config.mk

VPATH := $(SRCDIR)

CPPFLAGS += -I. -DVERSION=\"$(VERSION)\" -DHAVE_GIFLIB=$(HAVE_GIFLIB) -DHAVE_LIBEXIF=$(HAVE_LIBEXIF)
DEPFLAGS := -MMD -MP

LDLIBS := -lImlib2 -lX11 -lXft

ifneq ($(HAVE_GIFLIB),0)
	LDLIBS += -lgif
endif
ifneq ($(HAVE_LIBEXIF),0)
	LDLIBS += -lexif
endif

all: sxiv

SRC := autoreload_$(AUTORELOAD).c commands.c image.c main.c options.c thumbs.c util.c window.c
DEP := $(SRC:.c=.d)
OBJ := $(SRC:.c=.o)

$(OBJ): config.h Makefile

%.o: %.c
	@echo "CC $<"
	$(CC) $(CFLAGS) $(CPPFLAGS) $(DEPFLAGS) -c -o $@ $<

config.h:
	@echo "GEN $@"
	cp $(SRCDIR)/config.def.h $@

sxiv:	$(OBJ)
	@echo "LINK $@"
	$(CC) $(LDFLAGS) -o $@ $(OBJ) $(LDLIBS)

clean:
	rm -f $(OBJ) $(DEP) sxiv

install: all
	@echo "INSTALL bin/sxiv"
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp sxiv $(DESTDIR)$(PREFIX)/bin/
	chmod 755 $(DESTDIR)$(PREFIX)/bin/sxiv
	@echo "INSTALL sxiv.1"
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s!PREFIX!$(PREFIX)!g; s!VERSION!$(VERSION)!g" sxiv.1 > $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	@echo "INSTALL share/sxiv/"
	mkdir -p $(DESTDIR)$(PREFIX)/share/sxiv/exec
	cp exec/* $(DESTDIR)$(PREFIX)/share/sxiv/exec/
	chmod 755 $(DESTDIR)$(PREFIX)/share/sxiv/exec/*

uninstall:
	@echo "REMOVE bin/sxiv"
	rm -f $(DESTDIR)$(PREFIX)/bin/sxiv
	@echo "REMOVE sxiv.1"
	rm -f $(DESTDIR)$(MANPREFIX)/man1/sxiv.1
	@echo "REMOVE share/sxiv/"
	rm -rf $(DESTDIR)$(PREFIX)/share/sxiv

.PHONY: all clean install uninstall 
.SUFFIXES:

$(V).SILENT:

-include $(DEP)
