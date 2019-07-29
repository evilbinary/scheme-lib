;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui window)
  (export window-create window-destroy window-loop
    window-get-mouse-pos window-get-mouse-x window-get-mouse-y
    window-show-fps window-post-empty-event window-set-fps-pos
    window-add-loop window-loop-one window-set-wait-mode
    window-set-size window-set-title window-set-input-mode)
  (import (scheme) (glut glut))
  (define-syntax import-platform-window
    (lambda (x)
      (syntax-case x ()
        [(_ k)
         (datum->syntax
           #'k
           `(import
              (glut glut)
              ,(case (machine-type)
                 [(arm32le) '(gui android-window)]
                 [(a6nt i3nt ta6nt ti3nt a6osx i3osx ta6osx ti3osx a6le
                   i3le ta6le ti3le)
                  '(gui pc-window)])))])))
  (import-platform-window window))

