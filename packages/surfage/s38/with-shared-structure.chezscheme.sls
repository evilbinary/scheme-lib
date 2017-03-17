;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage s38 with-shared-structure)
  (export
    write-with-shared-structure
    (rename (write-with-shared-structure write/ss))
    read-with-shared-structure
    (rename (read-with-shared-structure read/ss)))
  (import
    (rnrs)
    (only (chezscheme) print-graph parameterize))
  
  (define write-with-shared-structure
    (case-lambda 
      [(obj)
       (write-with-shared-structure obj (current-output-port))]
      [(obj port)
       (parameterize ([print-graph #t])
         (write obj port))]
      [(obj port optarg)
       (assertion-violation 'write-with-shared-structure
         "this implementation does not support optarg")]))
  
  (define read-with-shared-structure read)
  
)
