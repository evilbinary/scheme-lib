(window.webpackJsonp=window.webpackJsonp||[]).push([[16],{441:function(t,s,a){"use strict";a.r(s);var n=a(29),e=Object(n.a)({},(function(){var t=this,s=t.$createElement,a=t._self._c||s;return a("ContentSlotsDistributor",{attrs:{"slot-key":t.$parent.slotKey}},[a("h2",{attrs:{id:"概述"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#概述"}},[t._v("#")]),t._v(" 概述")]),t._v(" "),a("p",[t._v("宏的使用是scheme的最大的精华和难度，这里只是一个简单的概括，阅读者还需要寻找更多的资料，在实践中自行体会scheme宏的应用。\n鸭库中最易找到的用宏编写的程序位于 packages/utils/macro.ss中\n这个库文件中的导出的接口都是由scheme的宏（marco.ss）编写生成的，下面是一个例子")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define-syntax")]),t._v(" while\n  "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("syntax-rules")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    ["),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("_")]),t._v(" test body ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n     "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("let")]),t._v(" loop "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("when")]),t._v(" test body ... "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("loop")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("]"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("h2",{attrs:{id:"过程宏与安全宏"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#过程宏与安全宏"}},[t._v("#")]),t._v(" 过程宏与安全宏")]),t._v(" "),a("p",[t._v("这个例子的开头是这样子的：")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define-syntax")]),t._v(" while\n  "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("syntax-rules")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("p",[t._v("为何要用两个嵌套的过程定义一个宏，是因为它们不是相同类型的宏语句。\n要搞明白这个概念，首先必须先看文档 7.1 什么是宏。\nscheme是一种Lisp方言，1963年Timothy Hart提议在Lisp 1.5中加入宏，从此Lisp就有了宏，由于Lisp的宏功能强大，因此宏成为了Lisp的重要标签。但是当时的宏从表达能力上说与今天的宏还相距甚远。\n后来Scheme和Lisp方言就有了照应宏，照应宏特别强大，几乎达到理论所允许的极致，因而广泛流行。\n到了R5RS，引入了安全宏（直译是卫生宏的意思）的概念。但是卫生宏是一个有争议性的概念，诞生了许多实践，也招致了许多批评。卫生宏的诞生并没有提升宏的表达能力，这与照应宏大大提升了早期的宏的表达能力不同。而且卫生宏隐含着照应宏是“不卫生的”，但是实际上这是错的，用照应宏完全可以写出卫生宏过程本身，相反用卫生宏也是照应宏过程的（不保证写出的与语言自身实现的运行速度一样）。\n这引发了思想的混乱，因为从安全的角度说，卫生宏的反义词是过程宏。但是从版本的角度说卫生宏又是照应宏的升级。这是一个建立在同时发展两个概念基础之上的概念。")]),t._v(" "),a("p",[t._v("说回一开始的问题，define-syntax和syntax-rules到底有什么区别？\ndefine-syntax 原本是一个照应宏，可以写的比较脏（软件工程习语，指代码不合规范难读，与清洁宏的干净相对）也可以写出清洁的宏。\nsyntax-rules 是一种具备几乎所有照应功能的全清洁宏，在它作用代码块内不能出现脏代码。用syntax-rules写出来的宏肯定可以写的非常优雅。但是不具有宏的所有表现能力\n将define-syntax 中嵌套syntax-rules 是在一个可能被写成过程宏的宏定义内嵌套一个完全清洁的宏，既努力实现宏的完全清洁又为其中可能出现一些过程宏留下了空间。")]),t._v(" "),a("p",[t._v("前面说到卫生宏“诞生了许多实践”，其中就包括宏的写法，syntax-rules是一种比较流行的实践，但是也还有另一种实践是syntax-case，chez scheme 两种都支持。syntax-case的用法在此不作详细说明，只指出它和syntax-rules存在的不同。\nsyntax-case 是一种具备完全具备所有照应功能的清洁宏，但是用它也可以写出过程宏。chez 的 syntax-case 可以写出任意的照应宏。但是与传统的照应宏过程相比，syntax-case 提供了更多的辅助，更不容易写出脏宏和过程宏。")]),t._v(" "),a("p",[t._v("总结一下就是 syntax-rules 削弱了传统照应宏的表达能力，这也是它最受诟病的一点。但是削弱的程度非常低，只有非常少数的过程需要 syntax-case 去实现（例如带continue和break的循环以及产生外部定义的宏），因此目前define-syntax嵌套syntax-rules已经成为主流用法。目前鸭库中的所有宏的写法都用了这样的用法。")]),t._v(" "),a("p",[t._v("说了这么多什么是过程宏，什么是卫生宏该给出定义了。简单的说卫生宏引入的名字都会被重命名。过程宏对引入的名字则不做处理。简单的说就是卫生宏不会出现内部的标识符与外部标识符打架的情况。")]),t._v(" "),a("h2",{attrs:{id:"保留字"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#保留字"}},[t._v("#")]),t._v(" 保留字")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define-syntax")]),t._v(" for\n    "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("syntax-rules")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("to")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n      ["),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("_")]),t._v(" i "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("from")]),t._v(" to end"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v(" body ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n       "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("let")]),t._v(" loop "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("[i")]),t._v(" from]"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n         "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("when")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token operator"}},[t._v("<")]),t._v(" i end"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v(" body ... "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("loop")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token operator"}},[t._v("+")]),t._v(" i "),a("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("] "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("p",[t._v("我们引入一个新例子，就是上面这个。其中"),a("code",[t._v("syntax-rules (to)")]),t._v("中的括号内不再是空的，而是有一个"),a("code",[t._v("to")]),t._v("。其中to就是保留字，代表着在宏中起到语法分割且不被处理的字。不是所用宏定义都需要保留字，哪怕是分段的语法结构也不一定要有保留字，例如scheme的if就没有使用任何保留字。但是当读者用宏定义C语言风格式的if语句时就必须添加else保留字，对于某些语言来说，还必须增加elseif和end保留字，因此保留字可不止一个")]),t._v(" "),a("h2",{attrs:{id:"模式-映射"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#模式-映射"}},[t._v("#")]),t._v(" 模式 映射")]),t._v(" "),a("p",[t._v("为说明模式和映射的概念，此处使用伪代码重写上面的例子")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("定义宏")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("清洁宏")]),t._v("\n      [模式\n       映射] "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("p",[t._v("请仔细对比伪代码与代码的区别，上面for的宏中模式部分是"),a("code",[t._v("(_ i (from to end) body ...)")]),t._v("说明的是for宏输入的语法格式，为了调用这个宏需要有至少四个参数，这里以"),a("code",[t._v("i from end body")]),t._v("等表示。"),a("code",[t._v("...")]),t._v("表示的是不定长度的参数，值得注意的是此处的"),a("code",[t._v("...")]),t._v("表示的不定长度的参数的参数性质是与"),a("code",[t._v("body")]),t._v("性质相同的参数。\n宏中映射部分是"),a("code",[t._v("(when (< i end) body ... (loop (+ i 1))))")]),t._v("，宏的映射部分是最考量编程者水平的部分，也有很多神奇的写法。但是这里写的语法就是函数中也很常见的内容。有两点不同，就是里面的body可以是一个S表达式，而函数的一般不行。另一点请看下面的部分。")]),t._v(" "),a("h2",{attrs:{id:"照应"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#照应"}},[t._v("#")]),t._v(" 照应")]),t._v(" "),a("p",[t._v('照应性在编程中无处不在，一般而言传值、声明、定义中都有照应，上面for宏的例子中，i from 和 end 和函数的参数照应方式一致，body 也只不过是可以照应 S 表达式而已，比如body中的内容可以传入(display "marcos")，或者更多的S表达式。')]),t._v(" "),a("p",[t._v("这里说的是 "),a("code",[t._v("...")]),t._v("的照应，为了说明这一问题，继续从鸭库引用一个例子")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define-syntax")]),t._v(" defun\n  "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("syntax-rules")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("_")]),t._v(" proc args ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n     "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define")]),t._v(" proc\n       "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("lambda")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token lambda-parameter"}},[t._v("args")]),t._v(" ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("p",[t._v("这是一个实现Lisp风格定义函数的宏，语义基本和define一样，通过这个例子对于"),a("code",[t._v("...")]),t._v("的照应关系读者应该就比较明确了，凡是模式中出现的"),a("code",[t._v("...")]),t._v("，映射中也必须出现。"),a("code",[t._v("...")]),t._v("在映射中往往也和他的前一个参数一起出现，因为在宏中这"),a("code",[t._v("...")]),t._v("代表了零个或不限数量个与前面参数相同性质的参数。值得一提的是，模式和映射中都可以出现多个"),a("code",[t._v("...")]),t._v("，只要它们数量相同，而且符合scheme关于宏的要求。")]),t._v(" "),a("h2",{attrs:{id:"多模式-多映射"}},[a("a",{staticClass:"header-anchor",attrs:{href:"#多模式-多映射"}},[t._v("#")]),t._v(" 多模式 多映射")]),t._v(" "),a("p",[t._v("一般来说"),a("code",[t._v("if ... else")]),t._v("的语法结构是两段式的，而"),a("code",[t._v("if ... elseif ... else")]),t._v("的语法结构可能出现三段式乃至多段式。多段式的语法结构为了丰富表达能力可能在不同的用途时采用不同的保留字。\n比如上面提到的"),a("code",[t._v("if ... elseif ... else")]),t._v("即可以构造成"),a("code",[t._v("if ... else")]),t._v("也可以构造成"),a("code",[t._v("if ... elseif ... elseif ... elseif ... else")]),t._v("的样子。鸭库中的代码也有类似的，请看下面这个例子。")]),t._v(" "),a("div",{staticClass:"language-scheme extra-class"},[a("pre",{pre:!0,attrs:{class:"language-scheme"}},[a("code",[a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("define-syntax")]),t._v(" for\n  "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("syntax-rules")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("to")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token comment"}},[t._v(";; loop in sequence")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token comment"}},[t._v(";; (for i (0 to 10) do something...)")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("_")]),t._v(" i  "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("from")]),t._v(" to end"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v(" body ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n     "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("let")]),t._v(" loop "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("i")]),t._v(" from"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n       "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("when")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token operator"}},[t._v("<")]),t._v(" i end"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n             body ...\n             "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("loop")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token operator"}},[t._v("+")]),t._v(" i "),a("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token comment"}},[t._v(";; loop in list")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token comment"}},[t._v(";; (for i in '(a b c) do something...)")]),t._v("\n    "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("_")]),t._v(" i in lst body ..."),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n     "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("let")]),t._v(" loop "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("l")]),t._v(" lst"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n       "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("unless")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token builtin"}},[t._v("null?")]),t._v(" l"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n               "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("let")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("i")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token builtin"}},[t._v("car")]),t._v(" l"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n                 body ...\n                 "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token function"}},[t._v("loop")]),t._v(" "),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),a("span",{pre:!0,attrs:{class:"token builtin"}},[t._v("cdr")]),t._v(" l"),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),a("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])]),a("p",[t._v("下面的这个for构造的宏既实现了basic风格的for循环，又实现了Python风格的for循环，可将scheme的列表作为枚举器进行枚举。因此该宏有两个模式，两种映射")])])}),[],!1,null,null,null);s.default=e.exports}}]);