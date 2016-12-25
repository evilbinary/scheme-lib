;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (utils libutil)
         (export
            load-lib
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
         )