##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 01/01/17.
#邮箱:rootdebug@163.com
##########################################################


TARGET =bin/scheme
EXT=.so
UNAME_S := $(shell uname -s)
OS_NAME :=$(shell echo $(UNAME_S)| tr '[A-Z]' '[a-z]')

ifeq ($(findstring mingw32_nt,$(OS_NAME)),mingw32_nt)
  EXT=.dll
endif
SOFILES= lib/libscm/libscm$(EXT) \
		 lib/libcffi/libcffi$(EXT)  \
		 lib/libgl/libgles$(EXT)  \
		 lib/libc/libcc$(EXT) \
		 lib/libgui/libgui$(EXT)  \
		 lib/libglfw/libglfw$(EXT)  \
		 lib/libvideo/libvideo$(EXT)  \
		 lib/libalut/libalut$(EXT)  \
		 lib/libsocket/libsocket$(EXT)  \
		 lib/libglut/libglut$(EXT)  \
		 lib/scheme/scheme	\
		 lib/boot/scheme.boot	\
		 lib/boot/petite.boot	\
		 lib/libimgui/libimgui$(EXT) \
		 lib/libnanovg/libnanovg$(EXT)  \

		 
BINFILES=bin/libscm$(EXT) \
		 bin/libcffi$(EXT)  \
		 bin/libgui$(EXT)  \
		 bin/libglfw$(EXT)  \
		 bin/libgles$(EXT)  \
		 bin/libc/libc$(EXT) \
		 bin/libglut$(EXT)  \
		 bin/libnanovg$(EXT)  \
		 bin/libvideo$(EXT)  \
		 bin/libsocket$(EXT)  \
		 bin/libalut$(EXT)  \
		 bin/libimgui$(EXT) \


all: $(TARGET)
	@echo "All build finish ^_^ have fun!"

$(TARGET):  $(SOFILES)
	@for n in $^; do cp -rf $$n bin ; done

$(SOFILES):
	$(MAKE) -C lib

clean:
	$(MAKE) -C lib clean
	rm -rf bin/*.boot bin/scheme bin/*.so $(BINFILES) 

android:
	$(MAKE) -C lib android	
