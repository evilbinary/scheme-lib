##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 01/01/17.
#邮箱:rootdebug@163.com
##########################################################


TARGET =bin/scheme
EXT=.so
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S), MINGW32_NT-6.1)
  EXT=.dll
endif
SOFILES= lib/libscm/libscm$(EXT) \
		 lib/libglut/libglut$(EXT)  \
		 lib/libimgui/libimgui$(EXT) \
		 lib/libcffi/libcffi$(EXT)  \
		 lib/libglfw/libglfw$(EXT)  \
		 lib/libgl/libgles$(EXT)  \
		 lib/libnanovg/libnanovg$(EXT)  \
		 lib/libgui/libgui$(EXT)  \
		 lib/libalut/libalut$(EXT)  \
		 lib/libsocket/libsocket$(EXT)  \
		 lib/libc/libc$(EXT) \
		 lib/scheme/scheme	\
		 lib/boot/scheme.boot	\
		 lib/boot/petite.boot	\
		 
BINFILES=bin/libscm$(EXT) \
		 bin/libglut$(EXT)  \
		 bin/libimgui$(EXT) \
		 bin/libcffi$(EXT)  \
		 bin/libglfw$(EXT)  \
		 bin/libgles$(EXT)  \
		 bin/libnanovg$(EXT)  \
		 bin/libgui$(EXT)  \
		 bin/libsocket$(EXT)  \
		 bin/libalut$(EXT)  \
		 bin/libc/libc$(EXT)

all: $(TARGET)
	@echo "All build finish ^_^ have fun!"

$(TARGET):  $(SOFILES)
	@for n in $^; do cp $$n bin ; done

$(SOFILES):
	$(MAKE) -C lib

clean:
	$(MAKE) -C lib clean
	rm -rf bin/*.boot bin/scheme bin/*.so $(BINFILES) 

android:
	$(MAKE) -C lib android	
