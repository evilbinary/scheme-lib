;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui assimp)
  (export ai-import-file)
  (import (scheme) (utils libutil) (cffi cffi))
  (load-librarys "libassimp")
  (def-function
    ai-import-file
    "aiImportFile"
    (string int)
    void*))

