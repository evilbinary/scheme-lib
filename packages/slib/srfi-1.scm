;;; "srfi-1.scm" SRFI-1 list-processing library		-*-scheme-*-
;; Copyright 2001 Aubrey Jaffer
;; Copyright 2003 Sven Hartrumpf
;; Copyright 2003-2004 Lars Buitinck
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

;			   Some pieces from:
;;;
;;; Copyright (c) 1998, 1999 by Olin Shivers. You may do as you please with
;;; this code as long as you do not remove this copyright notice or
;;; hold me liable for its use. Please send bug reports to shivers@ai.mit.edu.
;;;     -Olin

;;@code{(require 'srfi-1)}
;;@ftindex srfi-1
;;
;;@noindent
;;Implements the @dfn{SRFI-1} @dfn{list-processing library} as described
;;at @url{http://srfi.schemers.org/srfi-1/srfi-1.html}

(require 'common-list-functions)
(require 'rev2-procedures)		;for append!
(require 'multiarg-apply)
(require 'values)

;;@subheading Constructors

;;@body
;; @code{(define (xcons d a) (cons a d))}.
(define (xcons d a) (cons a d))

;;@body
;; Returns a list of length @1.  Element @var{i} is
;;@code{(@2 @var{i})} for 0 <= @var{i} < @1.
(define (list-tabulate len proc)
  (do ((i (- len 1) (- i 1))
       (ans '() (cons (proc i) ans)))
      ((< i 0) ans)))

;;@args obj1 obj2
(define cons* list*)

;;@args flist
(define list-copy copy-list)

;;@args count start step
;;@args count start
;;@args count
;;Returns a list of @1 numbers: (@2, @2+@3, @dots{},  @2+(@1-1)*@3).
(define (iota count . args)
  (let ((start (if (null? args) 0 (car args)))
	(step (if (or (null? args) (null? (cdr args))) 1 (cadr args))))
    (list-tabulate count (lambda (idx) (+ start (* step idx))))))

;;@body
;;Returns a circular list of @1, @2, @dots{}.
(define (circular-list obj1 . obj2)
  (let ((ans (cons obj1 obj2)))
    (set-cdr! (last-pair ans) ans)
    ans))

;;@subheading Predicates

;;@args obj
(define proper-list? list?)

;;@body
(define (circular-list? x)
  (let lp ((x x) (lag x))
    (and (pair? x)
	 (let ((x (cdr x)))
	   (and (pair? x)
		(let ((x   (cdr x))
		      (lag (cdr lag)))
		  (or (eq? x lag) (lp x lag))))))))

;;@body
(define (dotted-list? obj)
  (not (or (proper-list? obj) (circular-list? obj))))

;;@args obj
(define null-list? null?)

;;@body
(define (not-pair? obj) (not (pair? obj)))

;;@body
(define (list= =pred . lists)
  (or (null? lists)			; special case
      (let lp1 ((list-a (car lists)) (others (cdr lists)))
	(or (null? others)
	    (let ((list-b (car others))
		  (others (cdr others)))
	      (if (eq? list-a list-b)	; EQ? => LIST=
		  (lp1 list-b others)
		  (let lp2 ((list-a list-a) (list-b list-b))
		    (if (null-list? list-a)
			(and (null-list? list-b)
			     (lp1 list-b others))
			(and (not (null-list? list-b))
			     (=pred (car list-a) (car list-b))
			     (lp2 (cdr list-a) (cdr list-b)))))))))))

;;@subheading Selectors

;;@args pair
(define first  car)
;;@args pair
(define second cadr)
;;@args pair
(define third  caddr)
;;@args pair
(define fourth cadddr)
;;@body
(define (fifth   pair) (car    (cddddr pair)))
(define (sixth   pair) (cadr   (cddddr pair)))
(define (seventh pair) (caddr  (cddddr pair)))
(define (eighth  pair) (cadddr (cddddr pair)))
(define (ninth   pair) (car  (cddddr (cddddr pair))))
(define (tenth   pair) (cadr (cddddr (cddddr pair))))

;;@body
(define (car+cdr pair) (values (car pair) (cdr pair)))

;;@args lst k
(define (drop lst k) (nthcdr k lst))
(define (take lst k) (butnthcdr k lst))
(define (take! lst k)
  (if (or (null? lst) (<= k 0))
    '()
    (begin (set-cdr! (drop (- k 1) lst) '()) lst)))
;;@args lst k
(define take-right last)
;;@args lst k
(define drop-right butlast)
;;@args lst k
(define drop-right! drop-right)

;;@body
(define (split-at lst k)
  (let loop ((l '()) (r lst) (k k))
    (if (or (null? r) (= k 0))
      (values (reverse! l) r)
      (loop (cons (car r) l) (cdr r) (- k 1)))))
(define (split-at! lst k)
  (if (= k 0)
    (values '() lst)
    (let* ((half (drop lst (- k 1)))
	   (r (cdr half)))
      (set-cdr! half '())
      (values lst r))))

;;@body
(define (last lst . k)
  (if (null? k)
      (car (last-pair lst))
      (apply take-right lst k)))

;;@subheading Miscellaneous

;;@body
(define (length+ clist) (and (list? clist) (length clist)))

;;Append and append! are provided by R4RS and rev2-procedures.

;;@body
(define (concatenate  lists) (reduce-right append  '() lists))
(define (concatenate! lists) (reduce-right append! '() lists))

;;Reverse is provided by R4RS.
;;@args lst
(define reverse! nreverse)

;;@body
(define (append-reverse rev-head tail)
  (let lp ((rev-head rev-head) (tail tail))
    (if (null-list? rev-head) tail
	(lp (cdr rev-head) (cons (car rev-head) tail)))))
(define (append-reverse! rev-head tail)
  (let lp ((rev-head rev-head) (tail tail))
    (if (null-list? rev-head) tail
	(let ((next-rev (cdr rev-head)))
	  (set-cdr! rev-head tail)
	  (lp next-rev rev-head)))))

;;@body
(define (zip list1 . list2) (apply map list list1 list2))

;;@body
(define (unzip1 lst) (map car lst))
(define (unzip2 lst) (values (map car lst) (map cadr lst)))
(define (unzip3 lst) (values (map car lst) (map cadr lst) (map caddr lst)))
(define (unzip4 lst) (values (map car lst) (map cadr lst) (map caddr lst)
			     (map cadddr lst)))
(define (unzip5 lst) (values (map car lst) (map cadr lst) (map caddr lst)
			     (map cadddr lst) (map fifth lst)))

;;@body
(define (count pred list1 . list2)
  (cond ((null? list2)
	 (let mapf ((l list1) (count 0))
	   (if (null? l)
	       count (mapf (cdr l)
			   (+ count (if (pred (car l)) 1 0))))))
	(else (let mapf ((l list1) (rest list2) (count 0))
		(if (null? l)
		    count
		    (mapf (cdr l)
			  (map cdr rest)
			  (+ count (if (apply pred (car l) (map car rest))
				       1 0))))))))

;;@subheading Fold and Unfold

;;@args kons knil clist1 clist2 ...
(define (fold f z l1 . l)
  (set! l (cons l1 l))
  (if (any null? l)
      z
      (apply fold (cons* f (apply f (append! (map car l) (list z)))
			 (map cdr l)))))
;;@args kons knil clist1 clist2 ...
(define (fold-right f z l1 . l)
  (set! l (cons l1 l))
  (if (any null? l)
      z
      (apply f (append! (map car l)
			(list (apply fold-right (cons* f z (map cdr l))))))))
;;@args kons knil clist1 clist2 ...
(define (pair-fold f z l)		;XXX should be multi-arg
  (if (null? l)
      z
      (let ((tail (cdr l)))
	(pair-fold f (f l z) tail))))
;;@args kons knil clist1 clist2 ...
(define (pair-fold-right f z l)		;XXX should be multi-arg
  (if (null? l)
      z
      (f l (pair-fold-right f z (cdr l)))))

;;@body
(define reduce
  (let ((comlist-reduce reduce))
    (lambda args
      (apply (if (= 2 (length args))
		 comlist-reduce
		 (lambda (f ridentity list)
		   (if (null? list)
		       ridentity
		       (fold f (car list) (cdr list)))))
	     args))))
      
(define (reduce-right f ridentity list)
  (if (null? list)
      ridentity
      (let red ((l (cdr list)) (ridentity (car list)))
	(if (null? l)
	    ridentity
	    (f ridentity (red (cdr l) (car l)))))))

;;; We stop when CLIST1 runs out, not when any list runs out.
;;@args f clist1 clist2 ...
(define (map! f clist1 . lists)
  (if (pair? lists)
      (let lp ((clist1 clist1) (lists lists))
	(if (not (null-list? clist1))
	    (call-with-values ; expanded a receive call
              (lambda () (%cars+cdrs/no-test lists))
              (lambda (heads tails)
                (set-car! clist1 (apply f (car clist1) heads))
                (lp (cdr clist1) tails)))))
      ;; Fast path.
      (pair-for-each (lambda (pair) (set-car! pair (f (car pair)))) clist1))
  clist1)
;;@args f clist1 clist2 ...
(define (pair-for-each proc clist1 . lists)
  (if (pair? lists)
      (let lp ((lists (cons clist1 lists)))
	(let ((tails (%cdrs lists)))
	  (if (pair? tails)
	      (begin (apply proc lists)
		     (lp tails)))))
      ;; Fast path.
      (let lp ((lis clist1))
	(if (not (null-list? lis))
	    (let ((tail (cdr lis)))	; Grab the cdr now,
	      (proc lis)		; in case PROC SET-CDR!s LIS.
	      (lp tail))))))

(define (filter-map f l1 . l)
  (let loop ((l (cons l1 l)) (r '()))
    (if (any null? l)
      (reverse! r)
      (let ((x (apply f (map car l))))
	(loop (map! cdr l) (if x (cons x r) r))))))


;;@subheading Filtering and Partitioning

;;@args pred list
(define (filter pred lis)			; Sleazing with EQ? makes this one faster.
  (let recur ((lis lis))
    (if (null-list? lis) lis			; Use NOT-PAIR? to handle dotted lists.
	(let ((head (car lis))
	      (tail (cdr lis)))
	  (if (pred head)
	      (let ((new-tail (recur tail)))	; Replicate the RECUR call so
		(if (eq? tail new-tail) lis
		    (cons head new-tail)))
	      (recur tail))))))			; this one can be a tail call.
;;@args pred list
(define (filter! p? l)
  (call-with-values (lambda () (partition! p? l))
		    (lambda (x y) x)))

;;@args pred list
(define (partition pred lis)
  (let recur ((lis lis))
    (if (null-list? lis) (values lis lis)	; Use NOT-PAIR? to handle dotted lists.
	(let ((elt (car lis))
	      (tail (cdr lis)))
	  (call-with-values ; expanded a receive call
            (lambda () (recur tail))
            (lambda (in out)
              (if (pred elt)
                (values (if (pair? out) (cons elt in) lis) out)
                (values in (if (pair? in) (cons elt out) lis)))))))))

;;@args pred list
(define remove
  (let ((comlist-remove remove))
    (lambda (pred l)
      (if (procedure? pred)
	  (filter (lambda (x) (not (pred x))) l)
	  (comlist-remove pred l))))) ; 'remove' has incompatible semantics in comlist of SLIB!

;;@args pred list
(define (partition! p? l)
  (if (null? l)
    (values l l)
    (let ((p-ptr (cons '*unused* l)) (not-ptr (cons '*unused* l)))
      (let loop ((l l) (p-prev p-ptr) (not-prev not-ptr))
	(cond ((null? l)	(values (cdr p-ptr) (cdr not-ptr)))
	      ((p? (car l))	(begin (set-cdr! not-prev (cdr l))
				       (loop (cdr l) l not-prev)))
	      (else		(begin (set-cdr! p-prev (cdr l))
				       (loop (cdr l) p-prev l))))))))

;;@args pred list
(define (remove! pred l) (filter! (lambda (x) (not (pred x))) l))


;;@subheading Searching

;;@args pred clist
(define find find-if)
;;@args pred clist
(define find-tail member-if)

;;@args pred list
(define (span pred lis)
  (let recur ((lis lis))
    (if (null-list? lis) (values '() '())
	(let ((x (car lis)))
	  (if (pred x)
	      (call-with-values ; eliminated a receive call
                (lambda () (recur (cdr lis)))
                (lambda (prefix suffix)
                  (values (cons x prefix) suffix)))
	      (values '() lis))))))

;;@args pred list
(define (span! p? lst)
  (let loop ((l lst) (prev (cons '*unused* lst)))
    (cond ((null? l)	(values lst '()))
	  ((p? (car l))	(loop (cdr l) l))
	  (else		(begin (set-cdr! prev '()) (values lst l))))))

;;@args pred list
(define (break p? l) (span (lambda (x) (not (p? x))) l))
;;@args pred list
(define (break! p? l) (span! (lambda (x) (not (p? x))) l))

;;@args pred clist1 clist2 ...
(define (any pred lis1 . lists)
  (if (pair? lists)
      ;; N-ary case
      (call-with-values ; expanded a receive call
        (lambda () (%cars+cdrs (cons lis1 lists)))
        (lambda (heads tails)
          (and (pair? heads)
               (let lp ((heads heads) (tails tails))
                 (call-with-values ; expanded a receive call
                   (lambda () (%cars+cdrs tails))
                   (lambda (next-heads next-tails)
                     (if (pair? next-heads)
                       (or (apply pred heads) (lp next-heads next-tails))
                       (apply pred heads)))))))) ; Last PRED app is tail call.
      ;; Fast path
      (and (not (null-list? lis1))
	   (let lp ((head (car lis1)) (tail (cdr lis1)))
	     (if (null-list? tail)
		 (pred head)		; Last PRED app is tail call.
		 (or (pred head) (lp (car tail) (cdr tail))))))))
;;@args pred clist1 clist2 ...
(define (list-index pred lis1 . lists)
  (if (pair? lists)
      ;; N-ary case
      (let lp ((lists (cons lis1 lists)) (n 0))
        (call-with-values ; expanded a receive call
          (lambda () (%cars+cdrs lists))
                (lambda (heads tails)
            (and (pair? heads)
                 (if (apply pred heads) n
                   (lp tails (+ n 1)))))))
      ;; Fast path
      (let lp ((lis lis1) (n 0))
	(and (not (null-list? lis))
	     (if (pred (car lis)) n (lp (cdr lis) (+ n 1)))))))

;;@args obj list =
;;@args obj list
(define member
  (let ((old-member member))
    (lambda (obj list . pred)
      (if (null? pred)
	  (old-member obj list)
	  (let ((pred (car pred)))
	    (find-tail (lambda (ob) (pred ob obj)) list))))))

;;@subheading Deleting

;;@args x list =
;;@args x list
(define (delete-duplicates l =?)
  (let loop ((l l) (r '()))
    (if (null? l)
      (reverse! r)
      (loop (cdr l)
	    (if (member (car l) r =?) r (cons (car l) r))))))
;;@args x list =
;;@args x list
(define delete-duplicates! delete-duplicates)

;;@subheading Association lists

;;@args obj alist pred
;;@args obj alist
(define assoc
  (let ((old-assoc assoc))
    (lambda (obj alist . pred)
      (if (null? pred)
	  (old-assoc obj alist)
	  (let ((pred (car pred)))
	    (find (lambda (pair) (pred obj (car pair))) alist))))))

;; XXX maybe define the following in alist and require that module here?

;;@args key datum alist
(define (alist-cons k d l) (cons (cons k d) l))

;;@args alist
(define (alist-copy l)
  (map (lambda (x) (cons (car x) (cdr x))) l))

;;@args key alist =
;;@args key alist
(define (alist-delete k l . opt)
  (let ((key=? (if (pair? opt) (car opt) equal?)))
    (remove (lambda (x) (key=? (car x) k)) l)))
;;@args key alist =
;;@args key alist
(define (alist-delete! k l . opt)
  (let ((key=? (if (pair? opt) (car opt) equal?)))
    (remove! (lambda (x) (key=? (car x) k)) l)))

;;@subheading Set operations

;;@args = list1 @dots{}
;;Determine if a  transitive subset relation exists between the lists @2
;;@dots{}, using @1 to determine equality of list members.
(define (lset<= =? . l)
  (or (null? l)
      (letrec ((subset? (lambda (l1 l2)
			  (or (eq? l1 l2)
			      (every (lambda (x) (member x l2 =?)) l1)))))
	(let loop ((l1 (car l)) (l (cdr l)))
	  (or (null? l)
	      (let ((l2 (car l)))
		(and (subset? l1 l2)
		     (loop l2 (cdr l)))))))))

;;@args = list1 list2 @dots{}
(define (lset= =? . l)
  (or (null? l)
      (let loop ((l1 (car l)) (l (cdr l)))
	(or (null? l)
	    (let ((l2 (car l)))
	      (and (lset<= =? l1 l2)
		   (lset<= =? l2 l1)
		   (loop (if (< (length l1) (length l2)) l1 l2)
			 (cdr l))))))))

;;@args list elt1 @dots{}
(define (lset-adjoin =? l1 . l2)
  (let ((adjoin (lambda (x l)
		  (if (member x l =?) l (cons x l)))))
    (fold adjoin l1 l2)))

;;@args = list1 @dots{}
(define (lset-union =? . l)
  (let ((union (lambda (l1 l2)
		 (if (or (null? l2) (eq? l1 l2))
		   l1
		   (apply lset-adjoin (cons* =? l2 l1))))))
    (fold union '() l)))

;;@args = list1 list2 @dots{}
(define (lset-intersection =? l1 . l)
  (let loop ((l l) (r l1))
    (cond ((null? l)		r)
	  ((null? (car l))	'())
	  (else (loop (cdr l)
		      (filter (lambda (x) (member x (car l) =?)) r))))))

;;@args = list1 list2 ...
(define (lset-difference =? l1 . l)
  (call-with-current-continuation
   (lambda (return)
     (let ((diff (lambda (l1 l2)
		   (cond ((null? l2)	(return '()))
			 ((null? l1)	l2)
			 (else		(remove (lambda (x) (member x l1 =?))
						l2))))))
       (fold diff l1 l)))))

;; Alternatively definition of lset-difference, for large numbers of sets.
;(define (lset-difference =? l1 . l)
;  (set! l (cdr (delete-duplicates! (cons l1 l) eq?)))
;  (case (length l)
;    ((0)	l1)
;    ((1)	(remove (lambda (x) (member x l1 =?)) (car l)))
;    (else	(apply (lset-difference! (cons* =? (list-copy l1) l))))))

;;@args = list1 ...
(define (lset-xor =? . l)
  (let ((xor (lambda (l1 l2) (lset-union =? (lset-difference =? l1 l2)
					    (lset-difference =? l2 l1)))))
    (fold xor '() l)))

;;@args = list1 list2 ...
(define (lset-diff+intersection =? l1 . l)
  (let ((u (apply lset-union (cons =? l))))
    (values (lset-difference   =? l1 u)
	    (lset-intersection =? l1 u))))

;;@noindent
;;These are linear-update variants.  They are allowed, but not
;;required, to use the cons cells in their first list parameter to
;;construct their answer.  @code{lset-union!} is permitted to recycle
;;cons cells from any of its list arguments.

;;@args = list1 list2 ...
(define lset-intersection! lset-intersection)
;;@args = list1 list2 ...
(define (lset-difference! =? l1 . l)
  (let loop ((l l) (d l1))
    (if (or (null? l) (null? d))
      d
      (loop (cdr l)
	    (let ((l1 (car l)))
	      (if (null? l1) d (remove! (lambda (x) (member x l1 =?)) d)))))))

;;@args = list1 ...
(define (lset-union! =? . l)
  (let loop ((l l) (u '()))
    (if (null? l)
      u
      (loop (cdr l)
	    (cond ((null? (car l))	u)
		  ((eq? (car l) u)	u)
		  ((null? u)		(car l))
		  (else (append-reverse! (lset-difference! =? (car l) u)
					 u)))))))
;;@args = list1 ...
(define lset-xor!		lset-xor)

;;@args = list1 list2 ...
(define lset-diff+intersection!	lset-diff+intersection)


;;;; helper functions from the reference implementation:

;;; LISTS is a (not very long) non-empty list of lists.
;;; Return two lists: the cars & the cdrs of the lists.
;;; However, if any of the lists is empty, just abort and return [() ()].

(define (%cars+cdrs lists)
  (call-with-current-continuation
    (lambda (abort)
      (let recur ((lists lists))
        (if (pair? lists)
	    (call-with-values ; expanded a receive call
              (lambda () (car+cdr lists))
              (lambda (list other-lists)
                (if (null-list? list) (abort '() '()) ; LIST is empty -- bail out
                  (call-with-values ; expanded a receive call
                    (lambda () (car+cdr list))
                    (lambda (a d)
                      (call-with-values ; expanded a receive call
                        (lambda () (recur other-lists))
                        (lambda (cars cdrs)
                          (values (cons a cars) (cons d cdrs)))))))))
            (values '() '()))))))

;;; Like %CARS+CDRS, but blow up if any list is empty.
(define (%cars+cdrs/no-test lists)
  (let recur ((lists lists))
    (if (pair? lists)
      (call-with-values ; expanded a receive call
        (lambda () (car+cdr lists))
        (lambda (list other-lists)
          (call-with-values ; expanded a receive call
            (lambda () (car+cdr list))
            (lambda (a d)
              (call-with-values ; expanded a receive call
                (lambda () (recur other-lists))
                (lambda (cars cdrs)
                  (values (cons a cars) (cons d cdrs))))))))
      (values '() '()))))

(define (%cdrs lists)
  (call-with-current-continuation
    (lambda (abort)
      (let recur ((lists lists))
	(if (pair? lists)
	    (let ((lis (car lists)))
	      (if (null-list? lis) (abort '())
		  (cons (cdr lis) (recur (cdr lists)))))
	    '())))))
