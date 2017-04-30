; "fluidlet.scm", FLUID-LET for Scheme
; Copyright (C) 1998 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(require 'dynamic-wind)
;@
(defmacro fluid-let (clauses . body)
  (let ((ids (map car clauses))
	(new-tmps (map (lambda (x) (gentemp)) clauses))
	(old-tmps (map (lambda (x) (gentemp)) clauses)))
    `(let (,@(map list new-tmps (map cadr clauses))
	   ,@(map list old-tmps (map (lambda (x) #f) clauses)))
       (dynamic-wind
	   (lambda ()
	     ,@(map (lambda (ot id) `(set! ,ot ,id))
		    old-tmps ids)
	     ,@(map (lambda (id nt) `(set! ,id ,nt))
		    ids new-tmps))
	   (lambda () ,@body)
	   (lambda ()
	     ,@(map (lambda (nt id) `(set! ,nt ,id))
		    new-tmps ids)
	     ,@(map (lambda (id ot) `(set! ,id ,ot))
		    ids old-tmps))))))
