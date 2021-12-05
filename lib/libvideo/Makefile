##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libvideo.so 
OBJS = video.o
PLATFORM=
BITS =$(shell getconf LONG_BIT)


LIBS = 	-L../libgui -lgui \
	-L../libgl -lgles \
	-L../3rdparty/lib \
	-lavformat -lavcodec -lswscale -lswresample -lz -lm -lavutil \
	-L../libalut -lalut 

CFLAGS = -Wall -Wformat -g  -DGLAD \
	-I../libgl \
	-I../3rdparty/include/ \
	-I../libgui \
	-I../libalut \
	-I../libscm \


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
	extralibs_avcodec=-lm -lz -framework AudioToolbox -pthread -framework VideoToolbox -framework CoreFoundation -framework CoreMedia -framework CoreVideo -framework CoreServices
	extralibs_avformat=-lm -lbz2 -lz -Wl,-framework,CoreFoundation -Wl,-framework,Security

	LIBS += $(extralibs_avcodec) $(extralibs_avformat)
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS += -framework OpenAL  $(extralibs_avcodec) $(extralibs_avformat)
	ifeq ($(BITS), 32)
		PLATFORM=i3osx
	else
		PLATFORM=ta6osx
	endif
#	CXXFLAGS += -D__APPLE__
endif

ifeq  ($(findstring MINGW32_NT-, $(UNAME_S)), MINGW32_NT-)
   	ECHO_MESSAGE = "Windows"
	LIBS += -lopenal
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=  -I/mingw32/include -L/mingw32/lib/
	PLATFORM=ti3nt
	TARGET = libvideo.dll
endif

ifeq  ($(findstring MINGW64_NT-, $(UNAME_S)), MINGW64_NT-)
   	ECHO_MESSAGE = "Windows64"
	LIBS += -lopenal
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=  -I/mingw64/include -L/mingw64/lib/
	PLATFORM=ta6nt
	TARGET = libvideo.dll
endif

.cpp.o:
	$(CXX) $(CXXFLAGS)  -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS)  -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CC)  $(CFLAGS) $(OBJS) -shared  -o $(TARGET)  $(LIBS)

boot:
	cp ../libchez/$(PLATFORM)/*.boot .
clean:
	rm -rf $(TARGET) $(OBJS)

