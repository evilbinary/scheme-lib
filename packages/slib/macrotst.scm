;;;"macrotst.scm" Test for R4RS Macros
;;; From Revised^4 Report on the Algorithmic Language Scheme
;;; Editors: William Clinger and Jonathon Rees
;
; We intend this report to belong to the entire Scheme community, and so
; we grant permission to copy it in whole or in part without fee.  In
; particular, we encourage implementors of Scheme to use this report as
; a starting point for manuals and other documentation, modifying it as
; necessary.

;;; To run this code type
;;; (require 'macro)
;;; (macro:load "macrotst.scm")

(write "this code should print now, outer, and 7") (newline)

(write
 (let-syntax ((when (syntax-rules ()
				  ((when test stmt1 stmt2 ...)
				   (if test
				       (begin stmt1
					      stmt2 ...))))))
   (let ((if #t))
     (when if (set! if 'now))
     if)))
(newline)
;;;			==> now

(write
 (let ((x 'outer))
   (let-syntax ((m (syntax-rules () ((m) x))))
     (let ((x 'inner))
       (m)))))
(newline)
;;;			==> outer
(write
 (letrec-syntax
  ((or (syntax-rules ()
	 ((or) #f)
	 ((or e) e)
	 ((or e1 e2 ...)
	  (let ((temp e1))
	    (if temp temp (or e2 ...)))))))
  (let ((x #f)
	(y 7)
	(temp 8)
	(let odd?)
	(if even?))
    (or x
	(let temp)
	(if y)
	y))))
(newline)
;;;			==> 7
