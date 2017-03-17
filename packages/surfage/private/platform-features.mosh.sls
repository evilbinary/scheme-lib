
(library (surfage private platform-features)
  
  (export OS-features implementation-features)
  
  (import
   (only (rnrs) define quote)
   (only (mosh) host-os)
   (surfage private OS-id-features))

  (define (OS-features)
    (OS-id-features
     (host-os)
     '(("linux" linux posix)
       ("bsd" linux posix)
       ("darwin" darwin posix))))

  (define (implementation-features)
    '(mosh)))
