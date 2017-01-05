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

    #test.o

LIBS =-L../libscm -lscm 
CFLAGS = -Wall -Wformat 
CXXFLAGS= -Wall -Wformat -Iimgui -I../libscm -g -std=c++11 -DLOG \
	-Iaddons/ \
	-Iaddons/imguistyleserializer 

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S), Linux) #LINUX
	ECHO_MESSAGE = "Linux"
	LIBS += 
	CXXFLAGS += 
	CXXFLAGS += -fPIC -lGL -lglut
	CFLAGS +=
endif

ifeq ($(UNAME_S), Darwin) #APPLE
	ECHO_MESSAGE = "Mac OS X"
	LIBS += 
	CXXFLAGS += -DMESA_EGL_NO_X11_HEADERS   -DMESA_EGL_NO_X11_HEADERS  -L/opt/local/lib -lGL -lglut 
	CFLAGS +=  
#	CXXFLAGS += -D__APPLE__
endif

ifeq ($(UNAME_S), MINGW64_NT-6.3)
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
	$(CXX)  $(CXXFLAGS) $(OBJS) -shared -o $(TARGET)   $(LIBS)

clean:
	rm -rf $(TARGET) $(OBJS)



