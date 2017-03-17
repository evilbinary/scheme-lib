;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (surfage s64 testing)
  (export
    test-begin
    test-end test-assert test-eqv test-eq test-equal
    test-approximate test-error test-apply test-with-runner
    test-match-nth test-match-all test-match-any test-match-name
    test-skip test-expect-fail test-read-eval-string
    test-group test-runner-group-path test-group-with-cleanup
    test-result-ref test-result-set! test-result-clear test-result-remove
    test-result-kind test-passed?
    (rename (%test-log-to-file test-log-to-file))
    ; Misc test-runner functions
    test-runner? test-runner-reset test-runner-null
    test-runner-simple test-runner-current test-runner-factory test-runner-get
    test-runner-create test-runner-test-name
    ;; test-runner field setter and getter functions - see %test-record-define:
    test-runner-pass-count test-runner-pass-count!
    test-runner-fail-count test-runner-fail-count!
    test-runner-xpass-count test-runner-xpass-count!
    test-runner-xfail-count test-runner-xfail-count!
    test-runner-skip-count test-runner-skip-count!
    test-runner-group-stack test-runner-group-stack!
    test-runner-on-test-begin test-runner-on-test-begin!
    test-runner-on-test-end test-runner-on-test-end!
    test-runner-on-group-begin test-runner-on-group-begin!
    test-runner-on-group-end test-runner-on-group-end!
    test-runner-on-final test-runner-on-final!
    test-runner-on-bad-count test-runner-on-bad-count!
    test-runner-on-bad-end-name test-runner-on-bad-end-name!
    test-result-alist test-result-alist!
    test-runner-aux-value test-runner-aux-value!
    ;; default/simple call-back functions, used in default test-runner,
    ;; but can be called to construct more complex ones.
    test-on-group-begin-simple test-on-group-end-simple
    test-on-bad-count-simple test-on-bad-end-name-simple
    test-on-final-simple test-on-test-end-simple)
  (import
    (rnrs base)
    (rnrs control)
    (rnrs exceptions)
    (rnrs io simple)
    (rnrs lists)
    (rename (rnrs eval) (eval rnrs:eval))
    (rnrs mutable-pairs)
    (surfage s0 cond-expand)
    (only (surfage s1 lists) reverse!)
    (surfage s6 basic-string-ports)
    (surfage s9 records)
    (surfage s39 parameters)
    (surfage s23 error tricks)
    (surfage private include))

  (define (eval form)
    (rnrs:eval form (environment '(rnrs)
                                 '(rnrs eval)
                                 '(rnrs mutable-pairs)
                                 '(rnrs mutable-strings)
                                 '(rnrs r5rs))))

  (define %test-log-to-file
    (case-lambda
      (() test-log-to-file)
      ((val) (set! test-log-to-file val))))
  
  (SRFI-23-error->R6RS "(library (surfage s64 testing))"
   (include/resolve ("surfage" "s64") "testing.scm"))
)
