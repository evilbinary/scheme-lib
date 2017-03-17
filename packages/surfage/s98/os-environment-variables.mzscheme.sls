;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

;; Inspired by Danny Yoo's get-environment PLaneT package.

#!r6rs
(library (surfage s98 os-environment-variables)
  (export
    (rename (getenv get-environment-variable))
    get-environment-variables)
  (import
    (rnrs base)
    (only (scheme base) getenv)
    (scheme foreign))

  (unsafe!)

  (define environ (get-ffi-obj "environ" (ffi-lib #F) _pointer))

  (define (get-environment-variables)
    (let loop ((i 0) (accum '()))
      (let ((next (ptr-ref environ _string/locale i)))
        (if next
          (loop (+ 1 i)
                (cons (let loop ((i 0) (len (string-length next)))
                        (if (< i len)
                          (if (char=? #\= (string-ref next i))
                            (cons (substring next 0 i)
                                  (substring next (+ 1 i) len))
                            (loop (+ 1 i) len))
                          (cons next #F)))
                      accum))
          accum))))
)
