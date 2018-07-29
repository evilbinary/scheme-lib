#!r6rs
;; Copyright 2009 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(library (srfi :98 os-environment-variables)
  (export
    (rename (lookup-process-environment get-environment-variable)
            (process-environment->alist get-environment-variables)))
  (import
    (only (core) lookup-process-environment process-environment->alist)))
