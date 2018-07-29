;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui assimp)
    (export
     ai-import-file
    )
    (import (scheme) (utils libutil) (cffi cffi) )
  (load-librarys "libassimp")

    (def-function ai-import-file
      "aiImportFile" (string int) void*)

)
