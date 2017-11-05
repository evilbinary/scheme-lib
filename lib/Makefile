##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################

ROOT := $(shell pwd)
SRC := $(ROOT)

TARGET =scheme/scheme

SUB_DIR :=  libscm \
	libglut libimgui \
	scheme	libgl \
	libcffi libglfw \
	libnanovg libgui \
	libalut \
	libc

LIBSCM =./libscm/libscm.so
LIBGLUT =./libglut/libglut.so
LIBFFI = ./libcffi/libcffi.so
LIBGLFW = ./libglfw/libglfw.so
LIBGLES= ./libgl/libgles.so
LIBSOCKET=./libsocket/libsocket.so

UNAME_S := $(shell uname -s)
OS_NAME :=$(shell echo $(UNAME_S) | tr '[A-Z]' '[a-z]')
LIBS_ALL= libscm.so libimgui.so libglfw.so libcffi.so libgles.so libnanovg.so \
	libalut.so libgui.so libsocket.so libc.so

ifeq ($(UNAME_S), MINGW32_NT-6.1)
  OS_NAME:=windows
  LIBSCM =./libscm/libscm.dll
  LIBGLUT =./libglut/libglut.dll
  LIBFFI = ./libcffi/libcffi.dll
  LIBGLFW = ./libglfw/libglfw.dll
  LIBGLES= ./libgl/libgles.dll
  LIBC=./libc/libc.dll
endif

all: $(TARGET)	
	@echo Build complete for $(TARGET)
$(TARGET): $(OS_NAME) $(LIBS_ALL)
	$(MAKE) -C scheme
libscm.so: $(LIBSCM) 
	$(MAKE) -C libscm

libc.so:
	$(MAKE) -C libc
libglut.so: $(LIBGLUT)
	$(MAKE) -C libglut

libimgui.so: libglut.so libscm.so
	$(MAKE) -C libimgui

libnanovg.so: libgles.so
	$(MAKE) -C libnanovg

libglfw.so: $(LIBGLFW)
	$(MAKE) -C libglfw

libcffi.so: $(LIBFFI)
	$(MAKE) -C libcffi

libgles.so: $(LIBGLES) 
	$(MAKE) -C libgl

libalut.so: libalut.so
	$(MAKE) -C libalut

libgui.so: libgui.so libnanovg.so
	$(MAKE) -C libgui

libsocket.so:
	$(MAKE) -C libsocket

$(OS_NAME):
	@echo link... $(OS_NAME) $(LN_SRC)
ifeq (,$(wildcard boot))
	@ln -sf platform/$(OS_NAME)/boot/ boot
	@ln -sf platform/$(OS_NAME)/libscm libscm
	@ln -sf platform/$(OS_NAME)/libglut libglut
	@ln -sf platform/$(OS_NAME)/libcffi/ libcffi
	@ln -sf platform/$(OS_NAME)/libgl/ libgl
	@ln -sf platform/$(OS_NAME)/libglfw/ libglfw
	@ln -sf platform/$(OS_NAME)/3rdparty/ 3rdparty
endif

android:
	@echo link... android
	@ln -sf platform/android/libscm libscm
	@ln -sf platform/android/libglut libglut
	@ln -sf platform/android/boot/ boot
	@ndk-build -B V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk	
clean:
	@for n in $(SUB_DIR); do $(MAKE) -C $$n clean; done
	rm -rf libscm libglut boot libffi libgl libglfw 3rdparty 

