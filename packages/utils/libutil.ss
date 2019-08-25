;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (utils libutil)
  (export load-lib load-libs define-c-function lower-camel-case
    string-split string-replace! get-loaded-libs-list
    get-dynamic-ext)
  (import (scheme) (utils strings))
  (define loaded-libs-list (list))
  (define (get-loaded-libs-list) loaded-libs-list)
  (define loaded-libs (make-hashtable equal-hash equal?))
  (define (load-libs . args)
    (let loop ([arg args])
      (if (pair? arg)
          (begin (load-lib (car arg)) (loop (cdr arg))))))
  (define (load-lib name)
    (let loop ([libs (map car (library-directories))])
      (if (pair? libs)
          (begin
            (if (and (string? name)
                     (file-exists? (string-append (car libs) "/" name))
                     (eq? ""
                          (hashtable-ref
                            loaded-libs
                            (string-append (car libs) "/" name)
                            "")))
                (let ([libname (string-append (car libs) "/" name)])
                  (load-shared-object libname)
                  (set! loaded-libs-list
                    (append loaded-libs-list (list libname)))
                  (hashtable-set! loaded-libs libname name)))
            (loop (cdr libs))))))
  (define-syntax define-c-function
    (syntax-rules ()
      [(_ ret name args)
       (define name
         (foreign-procedure (string-replace!
                              #\-
                              #\_
                              (symbol->string 'name)) args
           ret))]))
  (define (get-dynamic-ext)
    (case (machine-type)
      [(arm32le) (list ".so")]
      [(a6nt i3nt ta6nt ti3nt) (list ".dll")]
      [(a6osx i3osx ta6osx ti3osx) (list ".dylib" ".so")]
      [(a6le i3le ta6le ti3le) (list ".so")])))

