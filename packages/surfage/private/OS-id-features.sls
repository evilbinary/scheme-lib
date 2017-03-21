;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage private OS-id-features)
  (export
    OS-id-features)
  (import 
    (rnrs))

  (define (OS-id-features OS-id features-alist)
    (define OS-id-len (string-length OS-id))
    (define (OS-id-contains? str)
      (define str-len (string-length str))
      (let loop ((i 0))
        (and (<= (+ i str-len) OS-id-len)
             (or (string-ci=? str (substring OS-id i (+ i str-len)))
                 (loop (+ 1 i))))))
    (apply append
           (map cdr (filter (lambda (x) (OS-id-contains? (car x)))
                            features-alist))))
)
