##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################


TARGET = libimgui.so
OBJS = main.o \
	imgui_impl_gl.o \
    imgui/imgui.o \
    imgui/imgui_draw.o \
    imgui/imgui_demo.o \
    cimgui/cimgui.o \
    cimgui/drawList.o \
    cimgui/fontAtlas.o \
    imgui_impl_glb.o \
    addons/imguistyleserializer/imguistyleserializer.o \
   

LIBS =-L../libscm -lscm  -L../libgl  -lgles
CFLAGS = -Wall -Wformat 
CXXFLAGS=  -g -std=c++11 	\
	-Wall -Wformat -Iimgui -I../libscm -I../libgl \
	-Iaddons/ \
	-Iaddons/imguistyleserializer  \


UNAME_S := $(shell uname -s)
OS_NAME :=$(shell echo $(UNAME_S)| tr '[A-Z]' '[a-z]')

ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += -lglut -lglfw
	CXXFLAGS +=  -D"__builtin_cpu_supports(x)=1" -DGLAD -I../3rdparty/include -I../libglfw  -I../libglut  -L../libglfw/  -L../libglut/ 
	CXXFLAGS += -fPIC 
	CFLAGS +=
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += 
	CXXFLAGS+= -DGLAD -I../3rdparty/include -I../libglfw  -I../libglut  -L../libglfw/  -L../libglut/ -lglut -lglfw
	#CXXFLAGS += -DMESA_EGL_NO_X11_HEADERS   -DMESA_EGL_NO_X11_HEADERS  -L/opt/local/lib -lGL -lglut 
	CFLAGS += 
#	CXXFLAGS += -D__APPLE__
endif

ifeq ($(findstring mingw32_nt,$(OS_NAME)),mingw32_nt)
   ECHO_MESSAGE = "Windows"
	LIBS += 
	CXXFLAGS+= -DGLAD -I../3rdparty/include -I../libglfw  -I../libglut  -L../libglfw/  -L../libglut/ -lglut -lglfw
	CFLAGS += -DNO_IMGUI_OPENGL_GLGENERATEMIPMAP
	TARGET = libimgui.dll
endif

.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $<
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
all: $(TARGET)
	@echo Build complete for $(ECHO_MESSAGE)

$(TARGET): $(OBJS)
	$(CXX)  $(CXXFLAGS) $(OBJS) -shared -o $(TARGET)   $(LIBS)

clean:
	rm -rf $(TARGET) $(OBJS) *.o *.so *.dll



