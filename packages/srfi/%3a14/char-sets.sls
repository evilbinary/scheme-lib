#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

;; TODO: Are there any issues w.r.t. R6RS Unicode support when using the
;; pre-R6RS reference implementation?  I suspect there are.

(library (srfi :14 char-sets)
  (export
    ; Predicates & comparison
    char-set? char-set= char-set<= char-set-hash
    ; Iterating over character sets
    char-set-cursor char-set-ref char-set-cursor-next end-of-char-set?
    char-set-fold char-set-unfold char-set-unfold!
    char-set-for-each char-set-map
    ; Creating character sets
    char-set-copy char-set
    list->char-set  string->char-set
    list->char-set! string->char-set!
    char-set-filter  ucs-range->char-set
    char-set-filter! ucs-range->char-set!
    ->char-set
    ; Querying character sets
    char-set->list char-set->string
    char-set-size char-set-count char-set-contains?
    char-set-every char-set-any
    ; Character-set algebra
    char-set-adjoin  char-set-delete
    char-set-adjoin! char-set-delete!
    char-set-complement  char-set-union  char-set-intersection
    char-set-complement! char-set-union! char-set-intersection!
    char-set-difference  char-set-xor  char-set-diff+intersection
    char-set-difference! char-set-xor! char-set-diff+intersection!
    ; Standard character sets
    char-set:lower-case  char-set:upper-case  char-set:title-case
    char-set:letter      char-set:digit       char-set:letter+digit
    char-set:graphic     char-set:printing    char-set:whitespace
    char-set:iso-control char-set:punctuation char-set:symbol
    char-set:hex-digit   char-set:blank       char-set:ascii
    char-set:empty       char-set:full
    )
  (import
    (except (rnrs) define-record-type)
    (rnrs mutable-strings)
    (rnrs r5rs)
    (srfi :23 error tricks)
    (srfi :9 records)
    (srfi private check-arg)
    (srfi private let-opt)
    (srfi private include))

  ;; TODO: FIXME: These two seem incorrect.
  (define (%latin1->char i)
    (integer->char i))
  (define (%char->latin1 c)
    (char->integer c))

  (SRFI-23-error->R6RS "(library (srfi :14 char-sets))"
   (include/resolve ("srfi" "%3a14") "srfi-14.scm"))
)
