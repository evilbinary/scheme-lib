;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage private include compat)
  (export
    search-paths)
  (import
    (rnrs base)
    (only (scheme base) current-library-collection-paths path->string)
    (only (scheme mpair) list->mlist))

  (define (search-paths)
    (map path->string 
         (list->mlist (current-library-collection-paths))))
)
