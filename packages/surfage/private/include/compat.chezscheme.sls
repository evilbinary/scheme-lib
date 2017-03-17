
(library (surfage private include compat)

  (export search-paths)

  (import (chezscheme))

  (define (search-paths)
    (map car (library-directories)))

  )