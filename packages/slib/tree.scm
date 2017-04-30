;;"tree.scm" Implementation of COMMON LISP tree functions for Scheme
;;; Author: Aubrey Jaffer
;;;
;;; This code is in the public domain.

;; Deep copy of the tree -- new one has all new pairs.  (Called
;; tree-copy in Dybvig.)

;;@code{(require 'tree)}
;;@ftindex tree
;;
;;These are operations that treat lists a representations of trees.

;; Substitute occurrences of old equal? to new in tree.
;; Similar to tree walks in SICP without the internal define.

;; substq and substv aren't in CL.  (Names from Dybvig)

;;@args new old tree
;;@args new old tree equ?
;;@code{subst} makes a copy of @3, substituting @1 for
;;every subtree or leaf of @3 which is @code{equal?} to @2
;;and returns a modified tree.  The original @3 is unchanged, but
;;may share parts with the result.
;;
;;@code{substq} and @code{substv} are similar, but test against @2
;;using @code{eq?} and @code{eqv?} respectively.  If @code{subst} is
;;called with a fourth argument, @var{equ?} is the equality predicate.
;;
;;Examples:
;;@lisp
;;(substq 'tempest 'hurricane '(shakespeare wrote (the hurricane)))
;;   @result{} (shakespeare wrote (the tempest))
;;(substq 'foo '() '(shakespeare wrote (twelfth night)))
;;   @result{} (shakespeare wrote (twelfth night . foo) . foo)
;;(subst '(a . cons) '(old . pair)
;;       '((old . spice) ((old . shoes) old . pair) (old . pair)))
;;   @result{} ((old . spice) ((old . shoes) a . cons) (a . cons))
;;@end lisp
(define (subst new old tree . equ?)
  (set! equ? (if (null? equ?) equal? (car equ?)))
  (letrec ((walk (lambda (tree)
		   (cond ((equ? old tree) new)
			 ((pair? tree)
			  (cons (walk (car tree))
				(walk (cdr tree))))
			 (else tree)))))
    (walk tree)))
(define (substq new old tree)
  (tree:subst new old tree eq?))
(define (substv new old tree)
  (tree:subst new old tree eqv?))

;;@body
;;Makes a copy of the nested list structure @1 using new pairs and
;;returns it.  All levels are copied, so that none of the pairs in the
;;tree are @code{eq?} to the original ones -- only the leaves are.
;;
;;Example:
;;@lisp
;;(define bar '(bar))
;;(copy-tree (list bar 'foo))
;;   @result{} ((bar) foo)
;;(eq? bar (car (copy-tree (list bar 'foo))))
;;   @result{} #f
;;@end lisp
(define (copy-tree tree)
  (if (pair? tree)
      (cons (tree:copy-tree (car tree))
	    (tree:copy-tree (cdr tree)))
      tree))

(define tree:copy-tree copy-tree)
(define tree:subst subst)
