# scheme-lib
scheme-lib 是一个scheme使用的库。目前支持android osx linux windows，其它平台在规划中。

官方主页：[http://scheme-lib.evilbinary.org/](http://scheme-lib.evilbinary.org/)
QQ群：Lisp兴趣小组239401374


### 安装编译

# linux

1. linux下安装`apt-get install freeglut3-dev  libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev  libalut-dev libopenal-dev libffi-dev`依赖库。
2. 执行`make`命令就可以编译，对应平台的文件在`bin`目录下。
3. 进入`bin`目录，执行`source env.sh`，然后运行`./scheme --script ../apps/hello.ss`就可以运行例子。

# osx
1. mac安装xcode command line tool。
2. brew或者port安装glfw ffmpeg开发库
3. 执行`make`命令就可以编译，对应平台的文件在`bin`目录下。
4. 进入`bin`目录，执行`source env.sh`，然后运行`./scheme --script ../apps/hello.ss`就可以运行例子。

# windows
1. 下载已经去除了，因为有人说抱怨运行报错，这下你只能自己编译。真需要的话，加群下载。

# 在使用scheme lib的项目
scheme lib官方网站：[http://scheme-lib.evilbinary.org/](http://scheme-lib.evilbinary.org/)  
letsgo 莱茨狗抢狗软件：[https://github.com/scheme-lib/letsgo](https://github.com/scheme-lib/letsgo)  


### 截图

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/editor.jpg" width="400px" /><img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/editor2.png" width="400px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/wechat-demo.png" width="400px" /><img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/new-gui2.jpg" width="400px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/game-demo.png" width="400px" /><img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/new-gui.jpg" width="400px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/draw-image.png" width="400px" /> <img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/box2d-demo.png" width="400px" />

# android
## 新手入门
### 环境安装 手机版
1. 先安装[scheme-release-1.5.apk][1]
2. 点击下载app库和package库
3. 下载成功后点击运行计算机demo或者直接打开apps里面的应用demo点击运行

运行效果如下：

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/m-game2.png" width="350px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/m-game.png" width="350px" />

<img src="https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/screenshot/helloworld.png" width="350px" />

### 测试配置
1. 在手机上输入运行代码可能不方便，所以弄了个配置文件，把需要运行的代码放到配置中会自己加载代码运行。配置文件为`config.xml`内容如下:

	```xml
	<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
	<map>
		<string name="debugCode">(import (test) (gles1) (glut) ) (load "/sdcard/org.evilbinary.chez/lib/apps/draw-point.ss") ;(imgui-test-hello-world) </string>
	</map>
	```

2. `adb push config.xml /sdcard/org.evilbinary.chez/scm/conf/config.xml`
3. 打开scheme app就可以直接运行啦。

## 高级篇
### android使用外部库
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

[1]: https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/apk/scheme-release-1.5.apk   "scheme apk"
[2]: https://github.com/evilbinary/data/blob/master/pic/scheme-lib-2.0-win32.zip  "scheme-lib-2.0-win32.zip"
