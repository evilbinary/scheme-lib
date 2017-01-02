;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (utils libutil)
         (export
            load-lib
            define-c-function
         )
         (import  (scheme))
          (define (string-split str separator)
                (let f ((i 0) (n (string-length str)))
                  (cond
                    ((= i n) (list (substring str 0 n) ))
                    ((char=? (string-ref str i) separator)
                       (cons (substring str 0 i)
                             (string-split (substring str (+ i 1) n) separator)))
                    (else (f (+ i 1) n)))))
         (define (load-lib name)
            (let  loop ((libs (map car (library-directories)) ))
              (if (pair? libs)
                  (begin
                    (if (file-exists? (string-append (car libs) "/" name))
                        (load-shared-object (string-append (car libs) "/" name)) )
                  (loop (cdr libs))))) )
         (define (string-replace! old new str)
                    (let loop
                      ((len (- (string-length str) 1))
                       (i 0))
                       ;(display (format "len=~a i=~a old=~a new=~a~%" len i old (string-ref str i)))
                      (cond
                        ((< i len )
                          (begin
                            (if (eq? (string-ref str i) old)
                               (string-set! str i new)  str))
                          (loop len (+ i 1)))

                        ((>= i len) str)
                        )))
         (define-syntax define-c-function
                    (syntax-rules ()
                      ((_ ret name args)
                       (define name
                         (foreign-procedure (string-replace! #\- #\_ (symbol->string 'name) ) args ret)))))
         )