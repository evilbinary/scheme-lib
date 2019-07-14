;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui android)
  (export android-get-width android-get-height
    android-get-density android-get-density-dpi android-toast)
  (import (scheme) (utils libutil))
  (define lib-name
    (case (machine-type)
      [(arm32le) "liband.so"]
      [(i3osx) "liband.dylib"]))
  (define lib (load-lib lib-name))
  (define-c-function int android-get-width ())
  (define-c-function int android-get-height ())
  (define-c-function float android-get-density ())
  (define-c-function int android-get-density-dpi ())
  (define-c-function void* android-toast (string)))

