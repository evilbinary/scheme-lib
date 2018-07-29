;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import  (scheme) (cffi cffi)   )

;;(load-lib lib-name )
; (ffi-dl-test)
(load-librarys "foo")
;;(cffi-log #t)

(display "============test-normal============\n")

(define text "hello,world")
(define addr (cffi-alloc 10))

;; (display (format "addr=~x dd=~x dd2=~x ~x \n"
;; 		 (cffi-string-pointer text)
;; 		 (cffi-get-string-pointer text)
;; 		 (cffi-get-string-pointer text)
;; 		 (cffi-get-string-offset text )   ))

;; (display (format "~x\n" (print-string text)))
;; (display (format "~x\n" (print-string text)))
;; (display (format "~x\n" (print-string text)))

;; (display (format "addr=~x\n" (print-ptr text)))
;; (display (format "addr=~x\n" (print-ptr addr)))
;; (display (format "addr=~x\n" (print-ptr addr)))


(def-function floating "floating" (int float double double) int )
(def-function foovv "foo_vv" () void )
(def-function foop "foo_p" (void*) void )
(def-function foo-string "foo_string" (string) void )
(def-function foo-string-string "foo_string_string" (string) string )

(def-function foopp "foo_p_p" (void*) void* )
(def-function nvgCreateGL2 "nvgCreateGL2" (int ) void* )

(time (display (floating 6 3.141590 0.333333 2.718282) ) )
(time (display (foovv ) ) )
(time (display (foo-string "hello,world")))
(time (display (foo-string-string "hello,world")))

;; (define addr 0)
;; (define addr2 0)
;; (set! addr (cffi-alloc 100))
;; (set! addr2  (foopp addr ))

;; (display (format "addr ~x addr=~x\n" addr addr2 ))

;; (display (format "nvgCreateGL2====>~x\n" (nvgCreateGL2 10) ))

 (display "============test-normal============end\n\n")


;; ;;test struct
 (display "============test-struct============\n")
(def-struct A
  (c int  32 )
  (d double 64 )
  (i int  32 ) )

 (display "def-struct end\n")

 (define a (make-A 10 20.0 30 ) )
 (display (format  "make-A ~a end\n" a) )


(display "make-A\n")
(define b (make-A) )
(display "make-A --end\n")


(printf "sizeof=~a\n" (struct-size a))




;(printf "size of=>~a\n" (size-of '(8 32 16)))
;(printf "size of=>~a\n" (size-of '(32 8 16)))
;(printf "size of=>~a\n" (size-of '(32 8 8)))
;(printf "size of=>~a\n" (size-of '(16 16 16)))
;(printf "size of=>~a\n" (lastt (size-of '(16 16 16))))





;; ;(define-top-level-value 'aa make-A)
;; (display "define-top-level-value end \n")

;; ;((syntax->datum  `,(string->symbol "make-A") ) )

;; ;( string->procedure "make-A")
;; ;(display  (format "top-level-value======~a\n" ((top-level-value 'make-A ) ) ))



;; (display a)(newline)


;; (display (A-c a) )(newline)
;; (A-c-set! a 17)
;; (display (A-c a) )(newline)
;(display a)(newline)
;(display (record-type-descriptor?  (type-descriptor A)) )


(def-function struct1 "struct1" (A) A)
;; ; (set! b (struct1 a) )

(time (printf "struct1(a)=>~a\n" (struct1 a)))

(define temp (lisp2struct a (cffi-alloc (struct-size a))))
(printf "lisp2struct ~a\n" temp)

(define temp-a (make-A) )
(printf "struct2lisp ~a\n" (struct2lisp temp temp-a))



;; (display "============test-struct============end \n\n")

; (display (slot-value a uc) )
; (newline)
; (display (slot-value a d) )


; (let loop ()
; (time (cffi-call) )

; 	)



(time (let loop ((i 100000))
  (foo-string "hell,world")
  (foo-string "hell,world2")
  (if (> i 0)
      (loop (- i 1 )))))
