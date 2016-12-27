# scheme-lib
scheme-lib 是一个scheme使用的库。目前支持android，其它平台在规划中。
#android平台
##编译
ndk-build -B V=1 NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./Android.mk NDK_APPLICATION_MK=./Application.mk
编译后生成的库在android/src/libs/下面。
##使用
1. 先安装[scheme-release-1.1.apk][1]
2. 设置schem库路径、将动态库和packages下的文件放到所设置的库目录，例如放在/sdcard/lib/下
3. 在run界面里面输入测试代码

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
  
  ![image](https://raw.githubusercontent.com/evilbinary/scheme-lib/master/android/screenshot/helloworld.png)    
  
  [1]: https://raw.githubusercontent.com/evilbinary/scheme-lib/master/android/apk/scheme-release-1.1.apk   "scheme apk"
