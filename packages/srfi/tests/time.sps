#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(import
  (rnrs)
  (rnrs mutable-pairs)
  (srfi :48 intermediate-format-strings)
  (srfi private include)
  (srfi :19 time))

(include/resolve ("srfi" "%3a19") "srfi-19-test-suite.scm")

(define (printf fmt-str . args)
  (display (apply format fmt-str args)))

(define (date->string/all-formats)
  ;; NOTE: ~x and ~X aren't doing what the SRFI 19 document says they do.
  ;;       I guess that's a bug in the reference implementation.
  (define fs
    '("~~" "~a" "~A" "~b" "~B" "~c" "~d" "~D" "~e" "~f" "~h" "~H" "~I" "~j" "~k"
      "~l" "~m" "~M" "~n" "~N" "~p" "~r" "~s" "~S" "~t" "~T" "~U" "~V" "~w" "~W"
      "~x" "~X" "~y" "~Y" "~z" "~Z" "~1" "~2" "~3" "~4" "~5"))
  (define cd (current-date))
  (display "\n;;; Running date->string format exercise\n")
  (printf "(current-date)\n=>\n~s\n" cd)
  (for-each
   (lambda (f)
     (printf "\n--- Format: ~a ----------------------------------------\n" f)
     (display (date->string cd f)) (newline))
   fs))

;;TODO
#;(define (string->date/all-formats)
  )

(date->string/all-formats)
#;(string->date/all-formats)
