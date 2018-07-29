#!r6rs
;; Copyright 2010 Derick Eddington.  My MIT-style license is in the file named
;; LICENSE from the original collection this file is distributed with.

(library (srfi :67 compare-procedures)
  (export
    </<=? </<? <=/<=? <=/<? <=? <? =?
    >/>=? >/>? >=/>=? >=/>? >=? >?
    boolean-compare chain<=? chain<? chain=? chain>=? chain>?
    char-compare char-compare-ci
    compare-by< compare-by<= compare-by=/< compare-by=/> compare-by>
    compare-by>= complex-compare cond-compare
    debug-compare default-compare
    if-not=? if3 if<=? if<? if=? if>=? if>? integer-compare
    kth-largest list-compare list-compare-as-vector
    max-compare min-compare not=? number-compare
    pair-compare pair-compare-car pair-compare-cdr
    pairwise-not=? rational-compare real-compare
    refine-compare select-compare string-compare string-compare-ci
    symbol-compare vector-compare vector-compare-as-list)
  (import
    (rnrs)
    (only (rnrs r5rs) modulo)
    (only (srfi :27 random-bits) random-integer)
    (srfi :23 error tricks)
    (srfi private include))

  (SRFI-23-error->R6RS "(library (srfi :67 compare-procedures))"
   (include/resolve ("srfi" "%3a67") "compare.scm"))
)
