;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s14 char-sets)
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
    (surfage s23 error tricks)
    (surfage s9 records)
    (surfage private let-opt)
    (surfage private include))
  
  (define (%latin1->char i)
    (integer->char i))
  
  (define (%char->latin1 c)
    (char->integer c))
      
  (define-syntax check-arg
    (lambda (stx)
      (syntax-case stx ()
        [(_ pred val caller)
         (identifier? #'val)
         #'(unless (pred val)
             (assertion-violation caller "check-arg failed" val))])))
  
  (SRFI-23-error->R6RS "(library (surfage s14 char-sets))"
   (include/resolve ("surfage" "s14") "srfi-14.scm")))
