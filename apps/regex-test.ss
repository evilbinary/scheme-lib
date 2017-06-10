;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;作者:evilbinary on 12/24/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (regex regex-ffi))
(import  (scheme) (cffi cffi) )



(define str "rootdebug@163.com")
(define pattern "ro{2,}(.*)@.{3}.(.*)")
(define err 0)

(define reg (cffi-alloc 100))
(define pmatch (cffi-alloc 100))
(define nmatch 1)

(define err-buf (cffi-alloc 1024))

;;(cffi-log #t)

(if (< (regcomp reg pattern REG_EXTENDED) 0)
    (begin 
      (regerror err reg err-buf 1024)
      (display (format "error ~a\n" (cffi-string err-buf)))))

(set! err (regexec reg str nmatch pmatch 0))
(if (= REG_NOMATCH err)
    (display "no match\n")
    (if (= 0 err)
	(begin
	  (display "match\n")
	  )
	(display (format "erro ~a\n" err))))
(regfree reg)
(cffi-free pmatch)
