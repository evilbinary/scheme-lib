#!r6rs
;; Copyright 2009 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rename (rnrs) (for-all andmap))
  (srfi :78 lightweight-testing)
  (srfi :98 os-environment-variables))

(check (list? (get-environment-variables))
       => #T)
(check (andmap (lambda (a)
                 (and (pair? a)
                      (string? (car a))
                      (positive? (string-length (car a)))
                      (string? (cdr a))))
               (get-environment-variables))
       => #T)
(check (andmap (lambda (a)
                 (let ((v (get-environment-variable (car a))))
                   (and (string? v)
                        (string=? v (cdr a)))))
               (get-environment-variables))
       => #T)
(assert (not (assoc "BLAH" (get-environment-variables))))
(check (get-environment-variable "BLAH")
       => #F)

(check-report)
