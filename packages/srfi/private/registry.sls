#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(library (srfi private registry)
  (export
    expand-time-features
    run-time-features
    available-features)
  (import
    (rnrs)
    (for (prefix (srfi private platform-features) platform-)
         run expand))

  (define-syntax make-expand-time-features
    (lambda (_)
      (define SRFIs
        '((0    cond-expand)
          (1    lists)
          (2    and-let*)
        #;(5    let)
          (6    basic-string-ports)
          (8    receive)
          (9    records)
          (11   let-values)
          (13   strings)
          (14   char-sets)
          (16   case-lambda)
        #;(17   generalized-set!)
        #;(18   multithreading)
          (19   time)
        #;(21   real-time-multithreading)
          (23   error)
          (25   multi-dimensional-arrays)
          (26   cut)
          (27   random-bits)
        #;(28   basic-format-strings)
        #;(29   localization)
          (31   rec)
          (37   args-fold)
          (38   with-shared-structure)
          (39   parameters)
          (41   streams)
          (42   eager-comprehensions)
          (43   vectors)
        #;(44   collections)
          (45   lazy)
        #;(46   syntax-rules)
        #;(47   arrays)
          (48   intermediate-format-strings)
        #;(51   rest-values)
        #;(54   cat)
        #;(57   records)
        #;(59   vicinities)
        #;(60   integer-bits)
          (61   cond)
        #;(63   arrays)
          (64   testing)
        #;(66   octet-vectors)
          (67   compare-procedures)
          (69   basic-hash-tables)
        #;(71   let)
        #;(74   blobs)
          (78   lightweight-testing)
        #;(86   mu-and-nu)
        #;(87   case)
        #;(95   sorting-and-merging)
          (98   os-environment-variables)
          (99   records)))
      (define (SRFI-names x)
        (define number car)
        (define mnemonic cdr)
        (define (make-symbol . args)
          (string->symbol (apply string-append
                                 (map (lambda (a)
                                        (if (symbol? a) (symbol->string a) a))
                                      args))))
        (let* ((n-str (number->string (number x)))
               (colon-n (make-symbol ":" n-str))
               (srfi-n (make-symbol "srfi-" n-str))
               (srfi-n-m (apply make-symbol srfi-n
                                (map (lambda (m) (make-symbol "-" m))
                                     (mnemonic x)))))
          ;; The first two are recommended by SRFI-97.
          ;; The last two are the two types of SRFI-97 library name.
          (list srfi-n
                srfi-n-m
                `(srfi ,colon-n)
                `(srfi ,colon-n . ,(mnemonic x)))))
      (let ((s (apply append (map SRFI-names SRFIs)))
            (h (platform-expand-time-features))
            (o '(r6rs)))
        #`(quote #,(datum->syntax #'ignored (append s h o))))))

  (define expand-time-features (make-expand-time-features))

  (define run-time-features (platform-run-time-features))

  (define available-features (append run-time-features expand-time-features))
)
