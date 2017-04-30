;;"comlist.scm" Implementation of COMMON LISP list functions for Scheme
; Copyright (C) 1991, 1993, 1995, 2001, 2003 Aubrey Jaffer.
; Copyright (C) 2000 Colin Walters
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

;;; Some of these functions may be already defined in your Scheme.
;;; Comment out those definitions for functions which are already defined.

(require 'multiarg-apply)

;;;; LIST FUNCTIONS FROM COMMON LISP

;;; Some tail-recursive optimizations made by
;;; Colin Walters <walters@cis.ohio-state.edu>
;;; AGJ restored order July 2001.

;;;@ From: hugh@ear.mit.edu (Hugh Secker-Walker)
(define (make-list k . init)
  (set! init (if (pair? init) (car init)))
  (do ((k (+ -1 k) (+ -1 k))
       (result '() (cons init result)))
      ((negative? k) result)))
;@
(define (copy-list lst) (append lst '()))
;@
(define (adjoin obj lst) (if (memv obj lst) lst (cons obj lst)))
;@
(define union
  (letrec ((onion
	    (lambda (lst1 lst2)
	      (if (null? lst1)
		  lst2
		  (onion (cdr lst1) (comlist:adjoin (car lst1) lst2))))))
    (lambda (lst1 lst2)
      (cond ((null? lst1) lst2)
	    ((null? lst2) lst1)
	    ((null? (cdr lst1)) (comlist:adjoin (car lst1) lst2))
	    ((null? (cdr lst2)) (comlist:adjoin (car lst2) lst1))
	    ((< (length lst2) (length lst1)) (onion (reverse lst2) lst1))
	    (else (onion (reverse lst1) lst2))))))
;@
(define (intersection lst1 lst2)
  (if (null? lst2)
      lst2
      (let build-intersection ((lst1 lst1)
			       (result '()))
	(cond ((null? lst1) (reverse result))
	      ((memv (car lst1) lst2)
	       (build-intersection (cdr lst1) (cons (car lst1) result)))
	      (else
	       (build-intersection (cdr lst1) result))))))
;@
(define (set-difference lst1 lst2)
  (if (null? lst2)
      lst1
      (let build-difference ((lst1 lst1)
			     (result '()))
	(cond ((null? lst1) (reverse result))
	      ((memv (car lst1) lst2) (build-difference (cdr lst1) result))
	      (else (build-difference (cdr lst1) (cons (car lst1) result)))))))
;@
(define (subset? lst1 lst2)
  (or (eq? lst1 lst2)
      (let loop ((lst1 lst1))
	(or (null? lst1)
	    (and (memv (car lst1) lst2)
		 (loop (cdr lst1)))))))
;@
(define (position obj lst)
  (define pos (lambda (n lst)
		(cond ((null? lst) #f)
		      ((eqv? obj (car lst)) n)
		      (else (pos (+ 1 n) (cdr lst))))))
  (pos 0 lst))
;@
(define (reduce-init pred? init lst)
  (if (null? lst)
      init
      (comlist:reduce-init pred? (pred? init (car lst)) (cdr lst))))
;@
(define (reduce pred? lst)
  (cond ((null? lst) lst)
	((null? (cdr lst)) (car lst))
	(else (comlist:reduce-init pred? (car lst) (cdr lst)))))
;@
(define (some pred lst . rest)
  (cond ((null? rest)
	 (let mapf ((lst lst))
	   (and (not (null? lst))
		(or (pred (car lst)) (mapf (cdr lst))))))
	(else (let mapf ((lst lst) (rest rest))
		(and (not (null? lst))
		     (or (apply pred (car lst) (map car rest))
			 (mapf (cdr lst) (map cdr rest))))))))
;@
(define (every pred lst . rest)
  (cond ((null? rest)
	 (let mapf ((lst lst))
	   (or (null? lst)
	       (and (pred (car lst)) (mapf (cdr lst))))))
	(else (let mapf ((lst lst) (rest rest))
		(or (null? lst)
		    (and (apply pred (car lst) (map car rest))
			 (mapf (cdr lst) (map cdr rest))))))))
;@
(define (notany pred . ls) (not (apply comlist:some pred ls)))
;@
(define (notevery pred . ls) (not (apply comlist:every pred ls)))
;@
(define (list-of?? predicate . bound)
  (define (errout) (apply slib:error 'list-of?? predicate bound))
  (case (length bound)
    ((0)
     (lambda (obj)
       (and (list? obj)
	    (comlist:every predicate obj))))
    ((1)
     (set! bound (car bound))
     (cond ((negative? bound)
	    (set! bound (- bound))
	    (lambda (obj)
	      (and (list? obj)
		   (<= bound (length obj))
		   (comlist:every predicate obj))))
	   (else
	    (lambda (obj)
	      (and (list? obj)
		   (<= (length obj) bound)
		   (comlist:every predicate obj))))))
    ((2)
     (let ((low (car bound))
	   (high (cadr bound)))
       (cond ((or (negative? low) (negative? high)) (errout))
	     ((< high low)
	      (set! high (car bound))
	      (set! low (cadr bound))))
       (lambda (obj)
	 (and (list? obj)
	      (<= low (length obj) high)
	      (comlist:every predicate obj)))))
    (else (errout))))
;@
(define (find-if pred? lst)
  (cond ((null? lst) #f)
	((pred? (car lst)) (car lst))
	(else (comlist:find-if pred? (cdr lst)))))
;@
(define (member-if pred? lst)
  (cond ((null? lst) #f)
	((pred? (car lst)) lst)
	(else (comlist:member-if pred? (cdr lst)))))
;@
(define (remove obj lst)
  (define head (list '*head*))
  (let remove ((lst lst)
	       (tail head))
    (cond ((null? lst))
	  ((eqv? obj (car lst)) (remove (cdr lst) tail))
	  (else
	   (set-cdr! tail (list (car lst)))
	   (remove (cdr lst) (cdr tail)))))
  (cdr head))
;@
(define (remove-if pred? lst)
  (let remove-if ((lst lst)
		  (result '()))
    (cond ((null? lst) (reverse result))
	  ((pred? (car lst)) (remove-if (cdr lst) result))
	  (else (remove-if (cdr lst) (cons (car lst) result))))))
;@
(define (remove-if-not pred? lst)
  (let remove-if-not ((lst lst)
		      (result '()))
    (cond ((null? lst) (reverse result))
	  ((pred? (car lst)) (remove-if-not (cdr lst) (cons (car lst) result)))
	  (else (remove-if-not (cdr lst) result)))))
;@
(define nconc
  (if (provided? 'rev2-procedures) append!
      (lambda args
	(cond ((null? args) '())
	      ((null? (cdr args)) (car args))
	      ((null? (car args)) (apply comlist:nconc (cdr args)))
	      (else
	       (set-cdr! (last-pair (car args))
			 (apply comlist:nconc (cdr args)))
	       (car args))))))

;;;@ From: hugh@ear.mit.edu (Hugh Secker-Walker)
(define (nreverse rev-it)
;;; Reverse order of elements of LIST by mutating cdrs.
  (cond ((null? rev-it) rev-it)
	((not (list? rev-it))
	 (slib:error "nreverse: Not a list in arg1" rev-it))
	(else (do ((reved '() rev-it)
		   (rev-cdr (cdr rev-it) (cdr rev-cdr))
		   (rev-it rev-it rev-cdr))
		  ((begin (set-cdr! rev-it reved) (null? rev-cdr)) rev-it)))))
;@
(define (last lst n)
  (comlist:nthcdr (- (length lst) n) lst))
;@
(define (butlast lst n)
  (comlist:butnthcdr (- (length lst) n) lst))
;@
(define (nthcdr n lst)
  (if (zero? n) lst (comlist:nthcdr (+ -1 n) (cdr lst))))
;@
(define (butnthcdr k lst)
  (cond ((negative? k) lst) ;(slib:error "negative argument to butnthcdr" k)
					; SIMSYNCH FIFO8 uses negative k.
	((or (zero? k) (null? lst)) '())
	(else (let ((ans (list (car lst))))
		(do ((lst (cdr lst) (cdr lst))
		     (tail ans (cdr tail))
		     (k (+ -2 k) (+ -1 k)))
		    ((or (negative? k) (null? lst)) ans)
		  (set-cdr! tail (list (car lst))))))))

;;;; CONDITIONALS
;@
(define (and? . args)
  (cond ((null? args) #t)
	((car args) (apply comlist:and? (cdr args)))
	(else #f)))
;@
(define (or? . args)
  (cond ((null? args) #f)
	((car args) #t)
	(else (apply comlist:or? (cdr args)))))

;;;@ Checks to see if a list has any duplicate MEMBERs.
(define (has-duplicates? lst)
  (cond ((null? lst) #f)
	((member (car lst) (cdr lst)) #t)
	(else (comlist:has-duplicates? (cdr lst)))))

;;;@ remove duplicates of MEMBERs of a list
(define remove-duplicates
  (letrec ((rem-dup
	    (lambda (lst nlst)
	      (cond ((null? lst) (reverse nlst))
		    ((member (car lst) nlst) (rem-dup (cdr lst) nlst))
		    (else (rem-dup (cdr lst) (cons (car lst) nlst)))))))
    (lambda (lst)
      (rem-dup lst '()))))
;@
(define list*
  (letrec ((list*1 (lambda (obj)
		     (if (null? (cdr obj))
			 (car obj)
			 (cons (car obj) (list*1 (cdr obj)))))))
    (lambda (obj1 . obj2)
      (if (null? obj2)
	  obj1
	  (cons obj1 (list*1 obj2))))))
;@
(define (atom? obj)
  (not (pair? obj)))
;@
(define (delete obj lst)
  (let delete ((lst lst))
    (cond ((null? lst) '())
	  ((equal? obj (car lst)) (delete (cdr lst)))
	  (else
	   (set-cdr! lst (delete (cdr lst)))
	   lst))))
;@
(define (delete-if pred lst)
  (let delete-if ((lst lst))
    (cond ((null? lst) '())
	  ((pred (car lst)) (delete-if (cdr lst)))
	  (else
	   (set-cdr! lst (delete-if (cdr lst)))
	   lst))))
;@
(define (delete-if-not pred lst)
  (let delete-if ((lst lst))
    (cond ((null? lst) '())
	  ((not (pred (car lst))) (delete-if (cdr lst)))
	  (else
	   (set-cdr! lst (delete-if (cdr lst)))
	   lst))))

;;; internal versions safe from name collisions.

;;(define comlist:make-list make-list)
;;(define comlist:copy-list copy-list)
(define comlist:adjoin adjoin)
;;(define comlist:union union)
;;(define comlist:intersection intersection)
;;(define comlist:set-difference set-difference)
;;(define comlist:subset? subset?)
;;(define comlist:position position)
(define comlist:reduce-init reduce-init)
;;(define comlist:reduce reduce) ; reduce is also in collect.scm
(define comlist:some some)
(define comlist:every every)
;;(define comlist:notevery notevery)
;;(define comlist:notany notany)
(define comlist:find-if find-if)
(define comlist:member-if member-if)
;;(define comlist:remove remove)
;;(define comlist:remove-if remove-if)
;;(define comlist:remove-if-not remove-if-not)
(define comlist:nconc nconc)
;;(define comlist:nreverse nreverse)
;;(define comlist:last last)
;;(define comlist:butlast butlast)
(define comlist:nthcdr nthcdr)
(define comlist:butnthcdr butnthcdr)
(define comlist:and? and?)
(define comlist:or? or?)
(define comlist:has-duplicates? has-duplicates?)
;;(define comlist:remove-duplicates remove-duplicates)
;;(define comlist:delete-if-not delete-if-not)
;;(define comlist:delete-if delete-if)
;;(define comlist:delete delete)
;;(define comlist:atom? atom?)
;;(define atom atom?)
;;(define comlist:atom atom?)
;;(define comlist:list* list*)
;;(define comlist:list-of?? list-of??)
