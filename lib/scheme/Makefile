##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = scheme
OBJS = main.o 
PLATFORM=
BITS =$(shell getconf LONG_BIT)

LIBS =-L../libscm -lscm -lm -L/usr/local/lib -L/usr/lib/x86_64-linux-gnu/
CFLAGS = -Wall -Wformat -I../libscm -g 
CXXFLAGS= -Wall -Wformat

UNAME_S := $(shell uname -s)
OS_NAME :=$(shell echo $(UNAME_S)| tr '[A-Z]' '[a-z]')

ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += -ldl -lrt -lpthread -luuid -llz4
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS += 
	ifeq ($(BITS), 32)
		PLATFORM=i3le
	else
		LIBS +=-L/usr/lib/x86_64-linux-gnu/
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

ifeq ($(findstring mingw32_nt,$(OS_NAME)),mingw32_nt)
   ECHO_MESSAGE = "Windows"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=
endif

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CC)  $(CFLAGS) $(OBJS) -o $(TARGET)   $(LIBS)

boot:
	cp ../libchez/$(PLATFORM)/*.boot .
clean:
	rm -rf $(TARGET) $(OBJS)

