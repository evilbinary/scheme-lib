;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (sound alut)
    (export 
    	alut-init
    	alut-exit
    	alut-play-file
    	alut-create-buffer-from-file
    	alut-sleep
    	alut-get-error-string
    	alut-get-error
    	)
    (import (scheme) (utils libutil))
    
    (define lib-name
           (case (machine-type)
             ((arm32le) "libalut.so")
             ((a6nt i3nt ta6nt ti3nt)  "libalut.dll")
             ((a6osx i3osx ta6osx ti3osx) "libalut.so")
             ((a6le i3le ta6le ti3le) "libalut.so")))
    (define lib (load-lib lib-name))

    (define alut-init (foreign-procedure "alut_init" () void ))
    (define alut-exit (foreign-procedure "alut_exit" () void ))
    (define alut-play-file (foreign-procedure "alut_play_file" (string) int))
    (define alut-create-buffer-from-file (foreign-procedure "alutCreateBufferFromFile" (string) int ))
    (define alut-get-error (foreign-procedure "alutGetError" () int ))
    (define alut-get-error-string (foreign-procedure "alutGetErrorString" (int) string ))
    (define alut-sleep (foreign-procedure "alutSleep" (float) int ))


    
)
