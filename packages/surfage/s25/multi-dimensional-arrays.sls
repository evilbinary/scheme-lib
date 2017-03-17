#!r6rs
;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage s25 multi-dimensional-arrays)
  (export
    array?
    make-array
    shape
    array
    array-rank
    array-start
    array-end
    array-ref
    array-set!
    share-array)
  (import
    (surfage s25 multi-dimensional-arrays all))
)
