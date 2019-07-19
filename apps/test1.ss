
(import (scheme)
        (utils libutil)
        (sound alut) (sound al) )
        
;(load-shared-object "libscm.dll")
;(load-shared-object "libglut.dll")
;
;(display "hello")
;
;(load "../../../packages/apps/hello.ss")

(define file "game_bg.wav")
(alut-init )

;(alut-create-buffer-from-file file)
;(define a (alut-play-file file))
;(al-source-i a AL-LOOPING AL-TRUE)
;(read)

(define buffer (alut-create-buffer-from-file file))
(define source (al-gen-source 1))
(display source)
(display buffer)

(al-source-i source AL-BUFFER buffer)
(al-source-i source AL-LOOPING AL-TRUE)
(al-source-play source)

(alut-sleep 10.00)
(alut-exit)
