;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui stb)
    (export
     stbi-load
     )
    
    (import (scheme) (utils libutil) (cffi cffi) )
    (define lib-name
      (case (machine-type)
	((arm32le) "libnanovg.so")
	((a6nt i3nt ta6nt ti3nt)  "libnanovg.dll")
	((a6osx i3osx ta6osx ti3osx) "libnanovg.so")
	((a6le i3le ta6le ti3le) "libnanovg.so")))
    
    (define lib (load-librarys  lib-name))
    
    (def-function stbi-load
      "stbi_load" (string void* void* void* int) void*)

)
