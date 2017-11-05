;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui assimp)
    (export
     ai-import-file
    )
    (import (scheme) (utils libutil) (cffi cffi) )
    (define lib-name
      (case (machine-type)
	((arm32le) "libassimp.so")
	((a6nt i3nt ta6nt ti3nt)  "libassimp.dll")
	((a6osx i3osx ta6osx ti3osx)  "libassimp.dylib")
	((a6le i3le ta6le ti3le) "libassimp.so")))

    
    (define libassimp (load-librarys "libassimp.dylib"))

    (def-function ai-import-file
      "aiImportFile" (string int) void*)
    
)
