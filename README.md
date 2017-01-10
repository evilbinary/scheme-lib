# scheme-lib
scheme-lib 是一个scheme使用的库。目前支持android mac linux，其它平台在规划中。
#linux、mac
###安装编译
1. linux下安装`apt-get install freeglut3-dev  libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev`依赖库。
2. 执行`make`命令就可以编译对应平台的文件在`bin`目录下。
3. 进入`bin`目录，执行`source env.sh`，然后运行`scheme --script ../apps/hello.ss`就可以运行例子。

###截图

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/helloworld2.png" width="400px" /><img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/showimage.png" width="400px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/draw-imge.png" width="400px" /><img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/box2d-demo.png" width="400px" />

#android
##新手入门
###环境安装
1. 先安装[scheme-release-1.1.apk][1]
2. 将手机连接电脑，开启adb调试模式（需要安装adb命令,不会用goolge）。进入`cd scheme-lib/android/src/packages`，在shell下执行`python sync.py`命令,这样每次修改后，会自动同步packages下的代码到手机`/sdcard/org.evilbinary.chez/lib`目录下面，这样方便运行了。
3. 在run界面里面输入测试代码。比如:
 
```scheme
(import (test) (gles1) (glut) ) 
(load "/sdcard/org.evilbinary.chez/lib/apps/hello.ss")
```
###demo例子
```scheme
;imgui例子
;imgui hello,world
(define (imgui-test-hello-world)
       (glut-init)
       (imgui-init)
       (imgui-scale 2.5 2.5)
       (glut-touch-event (lambda (type x y)
            (imgui-touch-event type x y)
                  ))
            (glut-key-event (lambda (event)
                  (imgui-key-event
                     (glut-event-get event 'type)
                     (glut-event-get event 'keycode)
                     (glut-event-get event 'char)
                     (glut-event-get event 'chars))
                   (if (= 4 (glut-event-get event 'keycode ))
                     (begin (imgui-exit)
                     (glut-exit)))
                  ))
         (glut-display (lambda ()
                   (imgui-render-start)
                   ;(imgui-test)
                   (imgui-set-next-window-size (imgui-make-vec2 200.0 140.0) 0)
                   (imgui-begin "evilbinary" 0)
                   (imgui-text "hello,world")
                   (imgui-end)
                   (imgui-render-end)
                  ))
         (glut-reshape (lambda(w h)
                            (imgui-resize w h)
                             ))
         (glut-main-loop)
         (imgui-exit))		
```

运行效果如下：
  
<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/helloworld.png" width="350px" />
###测试配置
1. 在手机上输入运行代码可能不方便，所以弄了个配置文件，把需要运行的代码放到配置中会自己加载代码运行。配置文件为`config.xml`内容如下:

	```xml
	<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
	<map>
		<string name="debugCode">(import (test) (gles1) (glut) ) (load "/sdcard/org.evilbinary.chez/lib/apps/draw-point.ss") ;(imgui-test-hello-world) </string>
	</map>
	```

2. `adb push config.xml /sdcard/org.evilbinary.chez/conf/config.xml`
3. 打开scheme app就可以直接运行啦。

##高级篇
###android使用外部库
1. 手工添加Android.mk和源码文件到`scheme-lib/android/src`下命名为libhadd的文件夹。
   add.c 内容如下：
	 ```c
	#include <stdio.h>
	#include <stdarg.h>
	int add(int a,int b){ 
		return a+b;
	}    
	```
	Android.mk内容如下：
	```makefile
	LOCAL_PATH := $(call my-dir)
	include $(CLEAR_VARS)
	include $(LOCAL_PATH)/../Optimizations.mk
	LOCAL_MODULE    := add
	LOCAL_SRC_FILES := add.c
	LOCAL_C_INCLUDES := 
	LOCAL_CFLAGS +=  -I. -I./c/
	LOCAL_CFLAGS += -g -Wall -DANDROID    -DINLINES -DGC_MACROS   -Wno-unused-parameter -pie -fPIE   -fPIC
	LOCAL_LDLIBS += -ldl -llog -lz
	include $(BUILD_SHARED_LIBRARY)
	```

2. 执行`make android`。
3. 将编译后生成的库`android/src/libs/libadd.so` 同步到`/sdcard/org.evilbinary.chez/lib`目录下，这样能调用外部库了。
4. 调用外`libadd.so`库和使用代码如下：
	
	```scheme
	(import  (scheme) (utils libutil) )
	(load-lib "libadd.so")
	(define-c-function int add (int int) )
	(display (add 100 1234))
	```

[1]: https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/apk/scheme-release-1.1.apk   "scheme apk"
