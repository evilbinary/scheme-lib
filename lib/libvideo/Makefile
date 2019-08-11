##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libvideo.so 
OBJS = video.o
PLATFORM=
BITS =$(shell getconf LONG_BIT)



CFLAGS = -Wall -Wformat -g  -DGLAD \
	-I../libgl \
	-I../3rdparty/include/ \
	-I../libgui \
	-L../libgui -lgui \
	-L../libgl -lgles \
	-L../3rdparty/lib \
	-lz -lm -lavformat -lavcodec -lswscale -lswresample  -lavutil \
	-I../libalut \
	-I../libscm \
	-L../libalut -lalut \
	-I/opt/local/include\
	-L/opt/local/lib

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
	CFLAGS += $(extralibs_avcodec) $(extralibs_avformat) -framework OpenAL
	ifeq ($(BITS), 32)
		PLATFORM=i3osx
	else
		PLATFORM=a6osx
	endif
#	CXXFLAGS += -D__APPLE__
endif

ifeq ($(findstring MINGW32_NT,$(OS_NAME)),MINGW32_NT)
   	ECHO_MESSAGE = "Windows"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += 
	CFLAGS +=
	PLATFORM=i3nt
	TARGET = libgui.dll
endif

.cpp.o:
	$(CXX) $(CXXFLAGS) $(LIBS) -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS) $(LIBS) -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CC)  $(CFLAGS) $(OBJS) -shared  -o $(TARGET) 

boot:
	cp ../libchez/$(PLATFORM)/*.boot .
clean:
	rm -rf $(TARGET) $(OBJS)

