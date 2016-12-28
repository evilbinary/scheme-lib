# scheme-lib
scheme-lib 是一个scheme使用的库。目前支持android，其它平台在规划中。
#android平台
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
  
<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/android/screenshot/helloworld.png" width="350px" />
  
##高级篇
###使用外部库
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

2. 执行`ndk-build -B V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk`。编译后生成的库在`android/src/libs/`下面。
3. 调用外libadd.so库和使用代码如下：

```scheme
   (import  (scheme) (utils libutil) )
   (load-lib "libadd.so")
   (define-c-function int add (int int) )
   (display (add 100 1234))
```

  [1]: https://raw.githubusercontent.com/evilbinary/scheme-lib/master/android/apk/scheme-release-1.1.apk   "scheme apk"
