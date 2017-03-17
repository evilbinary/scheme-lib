#!r6rs
;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

(library (surfage s25 multi-dimensional-arrays arlib)
  (export
    array-shape
    array-length
    array-size
    array-equal?
    shape-for-each
    array-for-each-index
    tabulate-array
    tabulate-array!
    array-retabulate!
    array-map
    array-map!
    array->vector
    array->list
    share-array/prefix
    share-row
    share-column
    share-array/origin
    share-array/index!
    array-append
    transpose
    share-nths)
  (import
    (rnrs)
    (rnrs r5rs)
    (surfage s23 error tricks)
    (surfage s25 multi-dimensional-arrays all)
    (surfage private include))

  (SRFI-23-error->R6RS "(library (surfage s25 multi-dimensional-arrays arlib))"
   (include/resolve ("surfage" "s25") "arlib.scm"))
)
