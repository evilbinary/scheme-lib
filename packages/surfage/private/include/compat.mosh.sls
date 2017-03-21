(library (surfage private include compat)
  (export
    search-paths)
  (import
    (rnrs base)
    (only (mosh) library-path))

  (define (search-paths)
    (library-path))
)
