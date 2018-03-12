;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 2017-06-10 23:49:57.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (thread scm-ffi) 
  (export 
   activate-thread
   deactivate-thread
   slock-object
   sunlock-object
  )

 (import (scheme) (utils libutil) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libscm.so")
   ((a6nt i3nt ta6nt ti3nt) "libscm.dll")
   ((a6osx i3osx ta6osx ti3osx)  "libscm.so")
   ((a6le i3le ta6le ti3le) "libscm.so")))
 (define lib (load-lib  lib-name ))

 ;; (def-function activate-thread "Sactivate_thread"
 ;;   (void) int)

 ;;  (def-function deactivate-thread "Sdeactivate_thread"
 ;;   (void) void)


    (define activate-thread
      (foreign-procedure "Sactivate_thread"
			 () int))

    (define deactivate-thread
      (foreign-procedure "Sdeactivate_thread"
			 () void))
  
    (define slock-object
      (foreign-procedure "Slock_object"
			 () void))

    (define sunlock-object
      (foreign-procedure"Sunlock_object"
			() void))


  
  
 )
