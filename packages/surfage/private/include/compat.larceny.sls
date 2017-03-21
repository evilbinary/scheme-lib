;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage private include compat)
  (export
    search-paths)
  (import
    (rnrs base)
    (primitives current-require-path getenv absolute-path-string?))
  
  (define (search-paths)
    (let ([larceny-root (getenv "LARCENY_ROOT")])
      (map (lambda (crp)
             (if (absolute-path-string? crp)
               crp
               (string-append larceny-root "/" crp)))
           (current-require-path))))

)
