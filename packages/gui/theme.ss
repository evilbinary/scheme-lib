;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui stb)
    (export
     stbi-load
     )

    (import (scheme) (utils libutil) (cffi cffi) )
    (load-librarys  "libnanovg")

    (def-function stbi-load
      "stbi_load" (string void* void* void* int) void*)

)
