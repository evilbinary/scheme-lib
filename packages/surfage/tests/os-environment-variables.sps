;; Copyright (c) 2009 Derick Eddington.  All rights reserved.  Licensed under an
;; MIT-style license.  My license is in the file named LICENSE from the original
;; collection this file is distributed with.  If this file is redistributed with
;; some other collection, my license must also be included.

#!r6rs
(import
  (rename (rnrs) (for-all andmap))
  (surfage s78 lightweight-testing)
  (surfage s98 os-environment-variables))

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
