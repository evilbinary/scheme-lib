;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (utils libutil)
         (export
            load-lib
            define-c-function
            lower-camel-case
            string-split
            string-replace!
         )
         (import  (scheme))
         (define loaded-libs (make-hashtable equal-hash equal?))

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
                    (if (and (file-exists? (string-append (car libs) "/" name)) 
                              (eq? "" (hashtable-ref loaded-libs (string-append (car libs) "/" name) "") ) )
                      (begin 
                        ;(display (format "load-lib ~a\n" (string-append (car libs) "/" name)) )
                        (load-shared-object (string-append (car libs) "/" name)) 
                        (hashtable-set! loaded-libs (string-append (car libs) "/" name) name )))
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

         (define (lower-camel-case l)
           (let loop
             ((x l) (s "" ) (i 0) )
              (if (null? x)
                  s
                  (begin
                    (if (> i 0)
                        (string-set!  (car x) 0 (char-upcase (string-ref (car x) 0))))
                    (loop (cdr x) (string-append s (car x)) (+ i 1))))))


         )
    