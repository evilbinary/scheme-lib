;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (sound al)
    (export AL-LOOPING
    	AL-TRUE
    	AL-FALSE
    	AL-NONE
    	AL-BUFFER

    	al-source-i
    	al-gen-source
    	al-source-play
    	)
    (import (scheme) (utils libutil))
    (define AL-LOOPING #x1007)
    (define AL-TRUE 1)
    (define AL-FALSE 0)
    (define AL-NONE 0)
    (define AL-BUFFER #x1009)

    (define lib-name
           (case (machine-type)
             ((arm32le) "libalut.so")
             ((a6nt i3nt)  (load-lib "libopenal.dll")   "libalut.dll" )
             ((a6osx i3osx)  "libalut.so")
             ((a6le i3le) "libalut.so")))
    (define lib (load-lib lib-name))
 
    
    (define al-source-i (foreign-procedure "alSourcei" (int int int ) void ))
    (define al-gen-source  (foreign-procedure "al_gen_source" (int ) int ) )
    (define al-source-play  (foreign-procedure "alSourcePlay" (int) void ) )


    )
