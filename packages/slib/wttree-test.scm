;;
;; Copyright (C) 2010 Kazu Yamamoto
;;
;; Permission to use, copy, modify, and/or distribute this software for
;; any purpose with or without fee is hereby granted, provided that the
;; above copyright notice and this permission notice appear in all
;; copies.
;;
;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
;; PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;; PERFORMANCE OF THIS SOFTWARE.

;;
;; This code is to test "wttree.scm". Test cases are automatically
;; generated and properties are tested.
;;

;;
;; Preamble
;;

(require 'wt-tree)
(require 'srfi-1)
(require 'random)
(require 'format)
(require 'sort)

(define (sort1 lst)
  (sort lst <))

;;
;; Utilities for wt-tree
;;

(define (random-alist n)
  (zip (random-list n)))

(define integer-scale 10)

(define (random-list n)
  (let ((range (* n integer-scale)))
    (list-tabulate n
		   (lambda (dummy)
		     (random range)))))

(define (from-alist al)
  (alist->wt-tree number-wt-type al))

(define (to-list tree)
  (wt-tree/fold (lambda (k v l) (cons k l)) '() tree))

(define (uniq x)
  (define (func y z)
    (if (and (not (null? z)) (equal? y (car z)))
	z
	(cons y z)))
  (fold-right func () x))

;;
;; Engine
;;

(define number-of-range 10)

(define (ladder i)
  (let* ((unit (quotient number-of-tests number-of-range))
	 (size (* unit (+ (quotient i unit) 1))))
    size))

(define (try-test lst i)
  (let* ((func (car lst))
	 (syms (cdr lst))
	 (size (ladder i))
	 (args (map (type-to-data size) syms)))
    (if (apply func args)
	#t
	args)))

(define (type-to-data size)
  (lambda (type)
    (cond
     ((eq? type 'alist)
      (random-alist size))
     ((eq? type 'ulist)
      (uniq (sort1 (random-list size))))
     ((eq? type 'int)
      (random size))
     (else
      (error "Unknown type: " type)))))

;;
;; property tests
;;

(define (prop-alist->wt-tree alst)
  (wt-tree/valid? (from-alist alst)))

(define (prop-wt-tree/index ulst)
  (let* ((alst (zip ulst ulst))
	 (tree (from-alist alst))
	 (idx (quotient (length alst) 2)))
    (equal? (wt-tree/index tree idx) (list-ref ulst idx))))

(define (prop-wt-tree/fold alst)
  (let* ((model (uniq (sort1 (map car alst))))
	 (tree (from-alist alst))
	 (this (to-list tree)))
    (equal? model this)))

(define (prop-wt-tree/add alst k v)
  (wt-tree/valid? (wt-tree/add (from-alist alst) k v)))

(define (prop-wt-tree/delete alst)
  (let* ((tree (from-alist alst))
	 (len (length alst))
	 (k (car (list-ref alst (quotient len 2)))))
    (wt-tree/valid? (wt-tree/delete tree k))))

(define (prop-wt-tree/delete-min alst)
  (wt-tree/valid? (wt-tree/delete-min (from-alist alst))))

(define (prop-wt-tree/lookup alst)
  (let* ((tree (from-alist alst))
	 (len (length alst))
	 (k (car (list-ref alst (quotient len 2)))))
    (eq? (wt-tree/lookup tree k #f) '())))

(define (prop-wt-tree/add-lookup alst k v)
  (let ((tree (wt-tree/add (from-alist alst) k v)))
    (eq? (wt-tree/lookup tree k #f) v)))

(define (prop-wt-tree/union alst1 alst2)
  (let ((t1 (from-alist alst1))
	(t2 (from-alist alst2)))
    (wt-tree/valid? (wt-tree/union t1 t2))))

(define (prop-wt-tree/union-merge alst1 alst2)
  (let ((t1 (from-alist alst1))
	(t2 (from-alist alst2)))
    (wt-tree/valid? (wt-tree/union-merge
		     t1 t2 (lambda (key datum-1 datum-2) datum-1)))))

(define (prop-wt-tree/union-model alst1 alst2)
  (let* ((l1 (uniq (sort1 (map car alst1))))
	 (l2 (uniq (sort1 (map car alst2))))
	 (model (sort1 (lset-union eq? l1 l2)))
	 (t1 (from-alist alst1))
	 (t2 (from-alist alst2))
	 (this (sort1 (to-list (wt-tree/union t1 t2)))))
    (equal? model this)))

(define (prop-wt-tree/intersection alst1 alst2)
  (let ((t1 (from-alist alst1))
	(t2 (from-alist alst2)))
    (wt-tree/valid? (wt-tree/intersection t1 t2))))

(define (prop-wt-tree/intersection-model alst1 alst2)
  (let* ((l1 (uniq (sort1 (map car alst1))))
	 (l2 (uniq (sort1 (map car alst2))))
	 (model (sort1 (lset-intersection eq? l1 l2)))
	 (t1 (from-alist alst1))
	 (t2 (from-alist alst2))
	 (this (sort1 (to-list (wt-tree/intersection t1 t2)))))
    (equal? model this)))

(define (prop-wt-tree/difference alst1 alst2)
  (let ((t1 (from-alist alst1))
	(t2 (from-alist alst2)))
    (wt-tree/valid? (wt-tree/difference t1 t2))))

(define (prop-wt-tree/difference-model alst1 alst2)
  (let* ((l1 (uniq (sort1 (map car alst1))))
	 (l2 (uniq (sort1 (map car alst2))))
	 (model (sort1 (lset-difference eq? l1 l2)))
	 (t1 (from-alist alst1))
	 (t2 (from-alist alst2))
	 (this (sort1 (to-list (wt-tree/difference t1 t2)))))
    (equal? model this)))

;;
;; test db
;;

(define test-alist
  (list
   (list "alist->wt-tree" prop-alist->wt-tree 'alist)
   (list "wt-tree/index" prop-wt-tree/index 'ulist)
   (list "wt-tree/fold" prop-wt-tree/fold 'alist)
   (list "wt-tree/add" prop-wt-tree/add 'alist 'int 'int)
   (list "wt-tree/delete" prop-wt-tree/delete 'alist)
   (list "wt-tree/delete-min" prop-wt-tree/delete-min 'alist)
   (list "wt-tree/lookup" prop-wt-tree/lookup 'alist)
   (list "wt-tree/add-lookup" prop-wt-tree/add-lookup 'alist 'int 'int)
   (list "wt-tree/union" prop-wt-tree/union 'alist 'alist)
   (list "wt-tree/union-merge" prop-wt-tree/union-merge 'alist 'alist)
   (list "wt-tree/union-model" prop-wt-tree/union-model 'alist 'alist)
   (list "wt-tree/intersection" prop-wt-tree/intersection 'alist 'alist)
   (list "wt-tree/intersection-model" prop-wt-tree/intersection-model 'alist 'alist)
   (list "wt-tree/difference" prop-wt-tree/difference 'alist 'alist)
   (list "wt-tree/difference-model" prop-wt-tree/difference-model 'alist 'alist)))

;;
;; main
;;

(define number-of-tests 300)

(define (run-test prop)
  (let ((tag (car prop))
	(test (cdr prop)))
    (format #t "~a: testing ~d cases... " tag number-of-tests)
    (force-output)
    (let loop ((i 0))
      (cond
       ((>= i number-of-tests)
	(display "PASS\n")
	(force-output))
       (else
	(let ((ret (try-test test i)))
	  (cond
	   ((eq? ret #t)
	    (loop (+ 1 i)))
	   (else
	    (display "FAIL\n")
	    (format #t "~d/~d: ~a\n" i number-of-tests ret)))))))))

(for-each run-test test-alist)
