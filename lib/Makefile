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
	libffi libglfw \
	libnanovg

LIBSCM =./libscm/libscm.so
LIBGLUT =./libglut/libglut.so

UNAME_S := $(shell uname -s)
OS_NAME :=$(shell echo $(UNAME_S) | tr '[A-Z]' '[a-z]')


all: $(TARGET)	
	@echo Build complete for $(TARGET)
$(TARGET): $(OS_NAME) libscm.so libimgui.so libglfw.so libffi.so libgles.so libnanovg.so
	$(MAKE) -C scheme
libscm.so: $(LIBSCM) 
	$(MAKE) -C libscm

libglut.so: $(LIBGLUT)
	$(MAKE) -C libglut

libimgui.so: libglut.so libscm.so
	$(MAKE) -C libimgui

libnanovg.so: libgles.so
	$(MAKE) -C libnanovg

libglfw.so: ./libglfw/libglfw.so
	$(MAKE) -C libglfw

libffi.so: ./libffi/libffi.so
	$(MAKE) -C libffi

libgles.so: ./libgl/libgles.so
	$(MAKE) -C libgl

libalut.so: libalut.so
	$(MAKE) -C libalut

$(OS_NAME):
	@echo link... $(OS_NAME) $(LN_SRC)
	@ln -sf platform/$(OS_NAME)/boot/ boot
	@ln -sf platform/$(OS_NAME)/libscm libscm
	@ln -sf platform/$(OS_NAME)/libglut libglut
	@ln -sf platform/$(OS_NAME)/libffi/ libffi
	@ln -sf platform/$(OS_NAME)/libgl/ libgl
	@ln -sf platform/$(OS_NAME)/libglfw/ libglfw
	@ln -sf platform/$(OS_NAME)/3rdparty/ 3rdparty

android:
	@echo link... android
	@ln -sf platform/android/libscm libscm
	@ln -sf platform/android/libglut libglut
	@ln -sf platform/android/boot/ boot
	@ndk-build -B V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk	
clean:
	@for n in $(SUB_DIR); do $(MAKE) -C $$n clean; done
	rm -rf libscm libglut boot libffi libgl libglfw 3rdparty 

