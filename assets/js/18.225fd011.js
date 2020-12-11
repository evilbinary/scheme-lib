(window.webpackJsonp=window.webpackJsonp||[]).push([[18],{443:function(a,t,s){"use strict";s.r(t);var n=s(29),e=Object(n.a)({},(function(){var a=this,t=a.$createElement,s=a._self._c||t;return s("ContentSlotsDistributor",{attrs:{"slot-key":a.$parent.slotKey}},[s("h1",{attrs:{id:"_1-linux、mac下安装"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#_1-linux、mac下安装"}},[a._v("#")]),a._v(" 1 linux、mac下安装")]),a._v(" "),s("h3",{attrs:{id:"安装编译"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#安装编译"}},[a._v("#")]),a._v(" 安装编译")]),a._v(" "),s("ol",[s("li",[a._v("linux下安装"),s("code",[a._v("apt-get install freeglut3-dev libgles1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libalut-dev libopenal-dev libffi-dev uuid-dev")]),a._v("依赖库。")]),a._v(" "),s("li",[a._v("mac安装xcode command line tool。")]),a._v(" "),s("li",[a._v("执行"),s("code",[a._v("make")]),a._v("命令就可以编译，对应平台的文件在"),s("code",[a._v("bin")]),a._v("目录下。")]),a._v(" "),s("li",[a._v("进入"),s("code",[a._v("bin")]),a._v("目录，执行"),s("code",[a._v("source env.sh")]),a._v("，然后运行"),s("code",[a._v("./scheme --script ../apps/hello.ss")]),a._v("就可以运行例子。")])]),a._v(" "),s("h1",{attrs:{id:"_2-windows"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#_2-windows"}},[a._v("#")]),a._v(" 2 windows")]),a._v(" "),s("ol",[s("li",[a._v("下载"),s("a",{attrs:{href:"https://github.com/evilbinary/data/blob/master/pic/scheme-lib-2.0-win32.zip",title:"scheme-lib-2.0-win32.zip",target:"_blank",rel:"noopener noreferrer"}},[a._v("scheme-lib-2.0-win32.zip"),s("OutboundLink")],1),a._v("，解压后进入bin，打开cmd运行"),s("code",[a._v("run.bat ../apps/gui-test.ss")]),a._v("就可以运行例子了（这个压缩包里的版本非常旧了建议加社区群下载新的版本，详见文档 2.2 的下载方式）")]),a._v(" "),s("li",[a._v("编译可以参考2.2章节window下编译安装")])]),a._v(" "),s("h1",{attrs:{id:"_3-android"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#_3-android"}},[a._v("#")]),a._v(" 3 android")]),a._v(" "),s("h3",{attrs:{id:"app安装运行"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#app安装运行"}},[a._v("#")]),a._v(" app安装运行")]),a._v(" "),s("ol",[s("li",[a._v("先安装"),s("a",{attrs:{href:"https://raw.githubusercontent.com/evilbinary/scheme-lib/master/data/apk/scheme-release-1.6.apk",title:"scheme apk",target:"_blank",rel:"noopener noreferrer"}},[a._v("scheme-release-1.6.apk"),s("OutboundLink")],1),a._v("。")]),a._v(" "),s("li",[a._v("点击下载官方packages下载、点击官方apps下载。")]),a._v(" "),s("li",[a._v("打开apps 找一个cals.ss打开，然后点击运行，就可以了。")])]),a._v(" "),s("h3",{attrs:{id:"手机调试"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#手机调试"}},[a._v("#")]),a._v(" 手机调试")]),a._v(" "),s("ol",[s("li",[a._v("将手机连接电脑，开启adb调试模式（需要安装adb命令,不会用goolge）。进入"),s("code",[a._v("cd scheme-lib/android/src/packages")]),a._v("，在shell下执行"),s("code",[a._v("python sync.py")]),a._v("命令,这样每次修改后，会自动同步packages下的代码到手机"),s("code",[a._v("/sdcard/org.evilbinary.chez/lib")]),a._v("目录下面，这样方便运行了。")]),a._v(" "),s("li",[a._v("在run界面里面输入测试代码。比如:")])]),a._v(" "),s("div",{staticClass:"language-scheme extra-class"},[s("pre",{pre:!0,attrs:{class:"language-scheme"}},[s("code",[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("import")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("test")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("gles1")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("glut")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" \n"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("load")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token string"}},[a._v('"/sdcard/org.evilbinary.chez/lib/apps/hello.ss"')]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n")])])]),s("h3",{attrs:{id:"测试配置"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#测试配置"}},[a._v("#")]),a._v(" 测试配置")]),a._v(" "),s("ol",[s("li",[s("p",[a._v("在手机上输入运行代码可能不方便，所以弄了个配置文件，把需要运行的代码放到配置中会自己加载代码运行。配置文件为"),s("code",[a._v("config.xml")]),a._v("内容如下:")]),a._v(" "),s("div",{staticClass:"language-xml extra-class"},[s("pre",{pre:!0,attrs:{class:"language-xml"}},[s("code",[s("span",{pre:!0,attrs:{class:"token prolog"}},[a._v("<?xml version='1.0' encoding='utf-8' standalone='yes' ?>")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("<")]),a._v("map")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(">")])]),a._v("\n\t"),s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("<")]),a._v("string")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token attr-name"}},[a._v("name")]),s("span",{pre:!0,attrs:{class:"token attr-value"}},[s("span",{pre:!0,attrs:{class:"token punctuation attr-equals"}},[a._v("=")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v('"')]),a._v("debugCode"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v('"')])]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(">")])]),a._v('(import (test) (gles1) (glut) ) (load "/sdcard/org.evilbinary.chez/lib/apps/draw-point.ss") ;(imgui-test-hello-world) '),s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("</")]),a._v("string")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(">")])]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token tag"}},[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("</")]),a._v("map")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(">")])]),a._v("\n")])])])]),a._v(" "),s("li",[s("p",[s("code",[a._v("adb push config.xml /sdcard/org.evilbinary.chez/conf/config.xml")])])]),a._v(" "),s("li",[s("p",[a._v("打开scheme app就可以直接运行啦。")])])]),a._v(" "),s("h1",{attrs:{id:"_4-高级篇"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#_4-高级篇"}},[a._v("#")]),a._v(" 4 高级篇")]),a._v(" "),s("h2",{attrs:{id:"android使用外部库"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#android使用外部库"}},[a._v("#")]),a._v(" android使用外部库")]),a._v(" "),s("ol",[s("li",[s("p",[a._v("手工添加Android.mk和源码文件到"),s("code",[a._v("scheme-lib/android/src")]),a._v("下命名为libhadd的文件夹。\nadd.c 内容如下：")]),a._v(" "),s("div",{staticClass:"language-c extra-class"},[s("pre",{pre:!0,attrs:{class:"language-c"}},[s("code",[s("span",{pre:!0,attrs:{class:"token macro property"}},[s("span",{pre:!0,attrs:{class:"token directive-hash"}},[a._v("#")]),s("span",{pre:!0,attrs:{class:"token directive keyword"}},[a._v("include")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token string"}},[a._v("<stdio.h>")])]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token macro property"}},[s("span",{pre:!0,attrs:{class:"token directive-hash"}},[a._v("#")]),s("span",{pre:!0,attrs:{class:"token directive keyword"}},[a._v("include")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token string"}},[a._v("<stdarg.h>")])]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("int")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("add")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("int")]),a._v(" a"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(",")]),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("int")]),a._v(" b"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("{")]),a._v(" \n   "),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("return")]),a._v(" a"),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v("+")]),a._v("b"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(";")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("}")]),a._v("    \n")])])]),s("p",[a._v("Android.mk内容如下：")]),a._v(" "),s("div",{staticClass:"language-makefile extra-class"},[s("pre",{pre:!0,attrs:{class:"language-makefile"}},[s("code",[a._v("LOCAL_PATH "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v(":=")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token variable"}},[a._v("$")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("call")]),a._v(" my-dir"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("include")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token variable"}},[a._v("$")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),a._v("CLEAR_VARS"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("include")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token variable"}},[a._v("$")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),a._v("LOCAL_PATH"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("/../Optimizations.mk\nLOCAL_MODULE    "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v(":=")]),a._v(" add\nLOCAL_SRC_FILES "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v(":=")]),a._v(" add.c\nLOCAL_C_INCLUDES "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v(":=")]),a._v(" \nLOCAL_CFLAGS "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v("+=")]),a._v("  -I. -I./c/\nLOCAL_CFLAGS "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v("+=")]),a._v(" -g -Wall -DANDROID    -DINLINES -DGC_MACROS   -Wno-unused-parameter -pie -fPIE   -fPIC\nLOCAL_LDLIBS "),s("span",{pre:!0,attrs:{class:"token operator"}},[a._v("+=")]),a._v(" -ldl -llog -lz\n"),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("include")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token variable"}},[a._v("$")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),a._v("BUILD_SHARED_LIBRARY"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n")])])])]),a._v(" "),s("li",[s("p",[a._v("执行"),s("code",[a._v("make android")]),a._v("。")])]),a._v(" "),s("li",[s("p",[a._v("将编译后生成的库"),s("code",[a._v("android/src/libs/libadd.so")]),a._v(" 同步到"),s("code",[a._v("/sdcard/org.evilbinary.chez/lib")]),a._v("目录下，这样能调用外部库了。")])]),a._v(" "),s("li",[s("p",[a._v("调用外"),s("code",[a._v("libadd.so")]),a._v("库和使用代码如下：")]),a._v(" "),s("div",{staticClass:"language-scheme extra-class"},[s("pre",{pre:!0,attrs:{class:"language-scheme"}},[s("code",[s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token keyword"}},[a._v("import")]),a._v("  "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("scheme")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("utils")]),a._v(" libutil"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("load-lib")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token string"}},[a._v('"libadd.so"')]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("define-c-function")]),a._v(" int add "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("int")]),a._v(" int"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n"),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("display")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v("(")]),s("span",{pre:!0,attrs:{class:"token function"}},[a._v("add")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token number"}},[a._v("100")]),a._v(" "),s("span",{pre:!0,attrs:{class:"token number"}},[a._v("1234")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),s("span",{pre:!0,attrs:{class:"token punctuation"}},[a._v(")")]),a._v("\n")])])])])])])}),[],!1,null,null,null);t.default=e.exports}}]);