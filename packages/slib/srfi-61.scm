;;; "srfi-61.scm" -- A more general cond clause  -*- Scheme -*-

;;; Public domain
;;; Author: Taylor Campbell
;;; URL:http://srfi.schemers.org/srfi-61/srfi-61.html

;@
(define-syntax cond
  (syntax-rules (=> else)

    ((cond (else else1 else2 ...))
     ;; The (IF #T (BEGIN ...)) wrapper ensures that there may be no
     ;; internal definitions in the body of the clause.  R5RS mandates
     ;; this in text (by referring to each subform of the clauses as
     ;; <expression>) but not in its reference implementation of COND,
     ;; which just expands to (BEGIN ...) with no (IF #T ...) wrapper.
     (if #t (begin else1 else2 ...)))

    ((cond (test => receiver) more-clause ...)
     (let ((T test))
       (cond/maybe-more T
                        (receiver T)
                        more-clause ...)))

    ((cond (generator guard => receiver) more-clause ...)
     (call-with-values (lambda () generator)
       (lambda T
         (cond/maybe-more (apply guard    T)
                          (apply receiver T)
                          more-clause ...))))

    ((cond (test) more-clause ...)
     (let ((T test))
       (cond/maybe-more T T more-clause ...)))

    ((cond (test body1 body2 ...) more-clause ...)
     (cond/maybe-more test
                      (begin body1 body2 ...)
                      more-clause ...))))

(define-syntax cond/maybe-more
  (syntax-rules ()
    ((cond/maybe-more test consequent)
     (if test
         consequent))
    ((cond/maybe-more test consequent clause ...)
     (if test
         consequent
         (cond clause ...)))))
