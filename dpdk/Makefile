# binary name
APP = helloworld
 
# all source are stored in SRCS-y
SRCS-y := helloworld.c
 

PKGCONF = pkg-config

CFLAGS += -O3 $(shell $(PKGCONF) --cflags libdpdk)
LDFLAGS += $(shell $(PKGCONF) --libs libdpdk)

$(APP): $(SRCS-y) Makefile
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS)
