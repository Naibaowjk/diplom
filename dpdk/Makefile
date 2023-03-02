# binary name
APP = helloworld

# include
INCLUDE_DIR := $(shell $(HOME))/applications/dpdk/include
INCLUDES     := $(INCLUDE_DIR)
LIB_INCLUDES := $(INCLUDE_DIR)

# all source are stored in SRCS-y
SRCS-y := helloworld.c
 

PKGCONF = pkg-config


CFLAGS += -O3 $(shell $(PKGCONF) --cflags libdpdk)
LDFLAGS += $(shell $(PKGCONF) --libs libdpdk)

$(APP): $(SRCS-y) Makefile
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS)
