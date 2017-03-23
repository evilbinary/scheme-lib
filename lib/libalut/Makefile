##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libalut.so
OBJS = alut.o al.o

LIBS =
CFLAGS = -Wall -Wformat -I../libscm -g -DLOG
CXXFLAGS= -Wall -Wformat
OTHERS=

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=  -fPIC -lalut -lopenal
endif
ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS += -D__APPLE__   -L../3rdparty/lib -lalut -I../3rdparty/include -framework OpenAL
#	CXXFLAGS += -D__APPLE__
endif

ifeq ($(UNAME_S), MINGW32_NT-6.1)
   ECHO_MESSAGE = "Windows"
	LIBS +=  -lalut32 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS += -lscm  -DBUILD_GLLUT32
	OTHERS+= -Wl,--out-implib,libglut.dll.a #-Wl,-verbose 
	TARGET = libglut.dll
endif

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CC)  $(CFLAGS) $(OTHERS) $(OBJS) -shared -o $(TARGET)   $(LIBS)

clean:
	rm -rf $(TARGET) $(OBJS) *.a 



