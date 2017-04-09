##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libnanovg.so
OBJS = nanovg.o nanovg_gl.o

LIBS =-L../libgl/   -lgles
CFLAGS = -Wall -Wformat   -I../libgl -g -DLOG -DNANOVG_GL2_IMPLEMENTATION -DNANOVG_GL2 
CXXFLAGS= -Wall -Wformat
OTHERS=

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += 
	CXXFLAGS +=
	CFLAGS +=  -fPIC   -DGLAD 
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += 
	CXXFLAGS += 
	CFLAGS+= -DGLAD 
	#CFLAGS += -DMESA_EGL_NO_X11_HEADERS   -DMESA_EGL_NO_X11_HEADERS  -L/opt/local/lib -lGL  -L/opt/local/lib  -lGLUT -lGL
	# CFLAGS+= -DANGLE -I../thirdpart/include -L../thirdpart/lib  -framework OpenGL -lfreeglut-gles -lEGL -langle_deqp_libgles2
#	CXXFLAGS += -D__APPLE__
endif

ifeq ($(UNAME_S), MINGW32_NT-6.1)
   ECHO_MESSAGE = "Windows"
	LIBS +=  
	CXXFLAGS += 
	CFLAGS += -DGLAD
	OTHERS+= #-Wl,--out-implib,libnanovg.dll.a #-Wl,-verbose 
	TARGET = libnanovg.dll
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



