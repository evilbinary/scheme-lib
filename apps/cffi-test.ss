;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import  (scheme) (cffi cffi)  )


; (ffi-dl-test)
(load-librarys "foo.so")


; (display "============test-normal============\n")

; (def-function floating "floating" (int float double double) int )
; (def-function foovv "foo_vv" () void )
; (def-function foop "foo_p" (void*) void )
; (def-function foo-string "foo_string" (string) void )
; (def-function foo-string-string "foo_string_string" (string) string )

; (time (display (floating 6 3.141590 0.333333 2.718282) ) )
; (time (display (foovv ) ) )
; (time (display (foo-string "hello,world")))
; (time (display (foo-string-string "hello,world")))

; (display "============test-normal============end\n\n")


;;test struct
(display "============test-struct============\n")
(def-struct A
			(c char  64 )
			(d double 64 )
			(i int  64 )
			)
(display "def-struct end\n")

(define a (make-A 10 20.0 30 ) )
(display (format  "make-A ~a end\n" a) )


(display "make-A\n")
(define b (make-A) )
(display "make-A --end\n")

;(define-top-level-value 'aa make-A)
(display "define-top-level-value end \n")

;((syntax->datum  `,(string->symbol "make-A") ) )

;( string->procedure "make-A")
;(display  (format "top-level-value======~a\n" ((top-level-value 'make-A ) ) ))



(display a)(newline)


(display (A-c a) )(newline)
(A-c-set! a 17)
(display (A-c a) )(newline)
;(display a)(newline)
;(display (record-type-descriptor?  (type-descriptor A)) )
(def-function struct1 "struct1" (A) A)
; (set! b (struct1 a) )

(time (display (struct1 a)))


(display "============test-struct============end \n\n")

; (display (slot-value a uc) )
; (newline)
; (display (slot-value a d) )


; (let loop ()
; (time (cffi-call) )

; 	)

