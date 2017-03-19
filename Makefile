##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 01/01/17.
#邮箱:rootdebug@163.com
##########################################################


TARGET =bin/scheme

SOFILES= lib/libscm/libscm.so \
		 lib/libglut/libglut.so  \
		 lib/libimgui/libimgui.so \
		 lib/libffi/libffi.so  \
		 lib/libglfw/libglfw.so  \
		 lib/libgl/libgles.so  \
		 lib/libffi/libffi.so  \
		 lib/libnanovg/libnanovg.so  \
		 lib/libgui/libgui.so  \
		 lib/scheme/scheme	\
		 lib/boot/scheme.boot	\
		 lib/boot/petite.boot	\


all: $(TARGET)
	@echo "All build finish ^_^ have fun!"

$(TARGET):  $(SOFILES)
	@for n in $^; do cp $$n bin ; done

$(SOFILES):
	$(MAKE) -C lib
clean:
	$(MAKE) -C lib clean
	rm -rf bin/*.boot bin/scheme bin/*.so
android:
	$(MAKE) -C lib android	