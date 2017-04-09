;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(library (utils strings)
         (export
            lower-camel-case
            string-split
            string-replace!
	    string-insert
	    string-delete
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

	  (define (lower-camel-case l)
           (let loop
             ((x l) (s "" ) (i 0) )
              (if (null? x)
                  s
                  (begin
                    (if (> i 0)
                        (string-set!  (car x) 0 (char-upcase (string-ref (car x) 0))))
                    (loop (cdr x) (string-append s (car x)) (+ i 1))))))

	  (define (string-insert s i new)
	    (let ((len (string-length s)))
	      (cond
	       	[(= i 0)
		 (string-append new s)]
		[(< i len)
		 (string-append (substring s 0 i)
			       new
			       (substring s i (string-length s) ))]
		[(>= i len)
		 (string-append s new)]
		)))
	  
	    (define (string-insert! s1 i1 s2 n2)
              (do ([i2 0 (fx+ i2 1)] [i1 i1 (fx+ i1 1)])
                  ((fx= i2 n2))
                (string-set! s1 i1 (string-ref s2 i2))))
	    
	    (define (string-delete str i)
	       (let ((len (string-length str)))
		 (cond
		  [(< i len)
		   (string-append (substring str 0 i)
				  (substring str (+ i 1)  (string-length str) ))]
		  [(>= i len)
		   str])) )

	    )
