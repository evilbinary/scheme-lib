##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libterminal.so
OBJS = terminal.o \
	libtsm/src/shl_htable.o \
	libtsm/src/tsm_render.o \
	libtsm/src/tsm_screen.o \
	libtsm/src/tsm_selection.o \
	libtsm/src/tsm_unicode.o \
	libtsm/src/tsm_vte.o \
	libtsm/src/tsm_vte_charsets.o \
	libtsm/external/wcwidth.o \
	shl_pty.o \

PLATFORM=
BITS =$(shell getconf LONG_BIT)


LIBS = -L./libtsm/src -L../libgui -lgui -L../libgl  -lgles
CFLAGS = -DGLAD -Wall -Wformat -I. -I./libtsm/src -I./libtsm/ -I./libtsm/external -I../libgui -I../libgl #-g

CXXFLAGS= -Wall -Wformat

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=  -fPIC
	ifeq ($(BITS), 32)
		PLATFORM=i3le
	else
		PLATFORM=a6le
	endif
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=
	ifeq ($(BITS), 32)
		PLATFORM=i3osx
	else
		PLATFORM=a6osx
	endif
#	CXXFLAGS += -D__APPLE__
endif

ifeq  ($(findstring MINGW32_NT-, $(UNAME_S)), MINGW32_NT-)
   	ECHO_MESSAGE = "Windows"
	LIBS += -lm 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS += #-Wno-implicit-function-declaration -Wl,--export-all-symbols -Wl,--exclude-all-symbols
	PLATFORM=i3nt
	TARGET = libc.dll

endif

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CC)  $(CFLAGS) $(OBJS) -shared  -o $(TARGET)   $(LIBS)

clean:
	rm -rf $(TARGET) $(OBJS)

