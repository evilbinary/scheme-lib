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
    (only (core) write-with-shared-structure read-with-shared-structure))
)
