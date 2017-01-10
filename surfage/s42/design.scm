; <PLAINTEXT>
; Design Alternatives for Eager Comprehensions
; ============================================
;
; sebastian.egner@philips.com, Eindhoven, The Netherlands, Feb-2003.
; Scheme R5RS (incl. macros), SRFI-23 (error).
;
; This file contains implementation alternatives for eager comprehensions
; and examples to find out which is better suited for a particular system.
;
; Loading the alternatives in Scheme48 (version 0.57):
;   ,open srfi-23
;   ,load ec.scm
;   ,load design.scm
;
; Loading the alternatives in PLT/DrScheme (version 202): 
;   ; open "ec.scm", click Execute
;   (load "design.scm")
;
; Loading the alternatives in SCM (version 5d7):
;   ; invoke SCM with -v on the command line
;   (require 'macro) (require 'record)
;   (load "ec.scm")
;   (load "design.scm")


; =======================================================================
; list-ec
; =======================================================================

; list-ec1
;   uses reverse and fold-ec in the obvious way.
;     + one-liner
;     + reverse could allocate result contiguous
;     - resulting list is allocated twice (unless reverse! is used)

(define-syntax list-ec1
  (syntax-rules ()
    ((list-ec etc1 etc ...)
     (reverse (fold-ec '() etc1 etc ... cons)) )))


; list-ec2
;   uses set-cdr! appending at the end of the result.
;     + no copying of the result
;     - more book-keeping in the inner loop

(define-syntax list-ec2
  (syntax-rules (nested)
    ((list-ec2 (nested q1 ...) q etc1 etc ...)
     (list-ec2 (nested q1 ... q) etc1 etc ...) )
    ((list-ec2 q1 q2             etc1 etc ...)
     (list-ec2 (nested q1 q2)    etc1 etc ...) )
    ((list-ec2 expression)
     (list-ec2 (nested) expression) )

    ((list-ec2 qualifier expression)
     (let ((result #f) (tail (list #f)))
       (set! result tail)
       (do-ec qualifier
              (begin (set-cdr! tail (list expression))
                     (set! tail (cdr tail)) ))
       (cdr result) ))))


; comparison
;   * The trade-off is book-keeping overhead vs. allocation pressure.
;     The difference in the inner loop is (set-cdr!, list, set!) vs.
;     (set!, cons), the difference 
;   * Scheme48 0.57: list-ec1 seems 5% percent faster than list-ec2.
;   * PLT 202: list-ec1 seems 25% faster than than list-ec2.

(define (perf-list-ec1 iterations n)
  (do-ec (:range i iterations) 
         (list-ec1 (:range k n) k) ))

(define (perf-list-ec2 iterations n)
  (do-ec (:range i iterations) 
         (list-ec2 (:range k n) k) ))

; try:
;   (perf-list-ec1 100000 10)
;   (perf-list-ec2 100000 10)
;   (perf-list-ec1 100 10000)
;   (perf-list-ec2 100 10000)


; =======================================================================
; string-ec
; =======================================================================

; string-ec1
;   uses list->string and list-ec in the obvious way.
;     + one-liner
;     - intermediate list is much bigger than result
;     - inherits overhead of list-ec

(define-syntax string-ec1
  (syntax-rules ()
    ((string-ec1 etc1 etc ...)
     (list->string (list-ec etc1 etc ...)) )))


; string-ec2
;   uses string-append on pieces of the result of limited length;
;   pieces are constructed with the method of string-ec1
;     + space-efficient for long results
;     - overhead for short result
;     + potentially very efficient in native code
;     - more complicated book-keeping

(define-syntax string-ec2
  (syntax-rules ()
    ((string-ec2 (nested q1 ...) q etc1 etc ...)
     (string-ec2 (nested q1 ... q) etc1 etc ...) )
    ((string-ec2 q1 q2             etc1 etc ...)
     (string-ec2 (nested q1 q2)    etc1 etc ...) )
    ((string-ec2 expression)
     (string-ec2 (nested) expression) )

    ((string-ec2 qualifier expression)
     (let ((result '()) (piece '()) (len 0) (max-len 1000))
       (do-ec qualifier
              (begin 
                (set! piece (cons expression piece))
                (set! len (+ len 1))
                (if (= len max-len)
                    (begin 
                      (set! result (cons (list->string piece) result))
                      (set! piece '())
                      (set! len 0) ))))
       (apply string-append 
              (reverse (cons (list->string piece) result)) )))))


; comparison
;   * The main question is whether the space overhead for an intermediate
;     list is acceptable. If not, string-ec1 is no option.
;   * If string-ec2 is used, the question is how to adjust max-len. It
;     can either be used as an emergency brake for very long intermediate
;     lists or it can be used to keep the total overhead limited.
;   * Scheme48 0.57: string-ec1 is 25% faster than string-ec2 for short 
;       results and still 15% faster for strings of length 10^5. However, 
;       at 10^6 (for my test configuration) string-ec1 has 'heap overflow',
;       whereas string-ec2 has no problem.
;   * PLT 202: string-ec1 is 50%..70% faster than string-ec2, both for 
;       short and for long strings.

(define (perf-string-ec1 iterations n)
  (do-ec (:range i iterations) 
         (string-ec1 (:range k n) #\a) ))

(define (perf-string-ec2 iterations n)
  (do-ec (:range i iterations) 
         (string-ec2 (:range k n) #\a) ))

; try:
;   (perf-string-ec1 100000 10)
;   (perf-string-ec2 100000 10)
;   (perf-string-ec1 10 100000)
;   (perf-string-ec2 10 100000)
;   (perf-string-ec1 1 1000000)
;   (perf-string-ec2 1 1000000)


; =======================================================================
; first-ec
; =======================================================================

; first-ec1
;   uses a non-local exit constructed by call-with-current-continuation.
;     - stack-based Schemes have problems implementing this efficiently
;     + simple, straight-forward, schemeish

(define-syntax first-ec1
  (syntax-rules (nested)
    ((first-ec1 default (nested q1 ...) q etc1 etc ...)
     (first-ec1 default (nested q1 ... q) etc1 etc ...) )
    ((first-ec1 default q1 q2             etc1 etc ...)
     (first-ec1 default (nested q1 q2)    etc1 etc ...) )
    ((first-ec1 default expression)
     (first-ec1 default (nested) expression) )

    ((first-ec1 default qualifier expression)
     (call-with-current-continuation 
      (lambda (cc)
        (do-ec qualifier (cc expression))
        default )))))


; first-ec2
;   uses :until to add an early termination to each generator.
;     + as fast as it gets
;     - copies part of the functionality of do-ec 

(define-syntax first-ec2
  (syntax-rules (nested)
    ((first-ec2 default (nested q1 ...) q etc1 etc ...)
     (first-ec2 default (nested q1 ... q) etc1 etc ...) )
    ((first-ec2 default q1 q2             etc1 etc ...)
     (first-ec2 default (nested q1 q2)    etc1 etc ...) )
    ((first-ec2 default expression)
     (first-ec2 default (nested) expression) )

    ((first-ec2 default qualifier expression)
     (let ((result default) (stop #f))
       (ec-guarded-do-ec 
         stop 
         (nested qualifier)
         (begin (set! result expression)
                (set! stop #t) ))
       result ))))

; (ec-guarded-do-ec stop (nested q ...) cmd)
;   constructs (do-ec q ... cmd) where the generators gen in q ... are
;   replaced by (:until gen stop).

(define-syntax ec-guarded-do-ec
  (syntax-rules (nested if not and or begin)

    ((ec-guarded-do-ec stop (nested (nested q1 ...) q2 ...) cmd)
     (ec-guarded-do-ec stop (nested q1 ... q2 ...) cmd) )

    ((ec-guarded-do-ec stop (nested (if test) q ...) cmd)
     (if test (ec-guarded-do-ec stop (nested q ...) cmd)) )
    ((ec-guarded-do-ec stop (nested (not test) q ...) cmd)
     (if (not test) (ec-guarded-do-ec stop (nested q ...) cmd)) )
    ((ec-guarded-do-ec stop (nested (and test ...) q ...) cmd)
     (if (and test ...) (ec-guarded-do-ec stop (nested q ...) cmd)) )
    ((ec-guarded-do-ec stop (nested (or test ...) q ...) cmd)
     (if (or test ...) (ec-guarded-do-ec stop (nested q ...) cmd)) )

    ((ec-guarded-do-ec stop (nested (begin etc ...) q ...) cmd)
     (begin etc ... (ec-guarded-do-ec stop (nested q ...) cmd)) )

    ((ec-guarded-do-ec stop (nested gen q ...) cmd)
     (do-ec 
       (:until gen stop) 
       (ec-guarded-do-ec stop (nested q ...) cmd) ))

    ((ec-guarded-do-ec stop (nested) cmd)
     (do-ec cmd) )))


; comparison
;   * The main question is whether call/cc is efficient here.
;     If it is not, first-ec1 is not an option.
;   * We simply run a loop terminating after a few iterations and 
;     measure the time it takes in total.
;   * Scheme48 0.57: first-ec2 seems to be about 15% faster than first-ec1.
;   * PLT 202: first-ec2 seems to be about factor 4 faster than first-ec1.

(define (perf-first-ec1 iterations)
  (do-ec (:range i iterations) 
         (first-ec1 0 (:range x 10) (if (= x 5)) #t) ))

(define (perf-first-ec2 iterations)
  (do-ec (:range i iterations) 
         (first-ec2 0 (:range x 10) (if (= x 5)) #t) ))

; try:
;   (perf-first-ec1 100000)
;   (perf-first-ec2 100000)


; =======================================================================
; :vector
; =======================================================================


; :vector
;    uses vector->list, append and :list for the multi-argument case.
;      + one-liner
;      - the enumerated sequence is copied
;      - the intermediate list is larger than the arguments

(define-syntax :vector1
  (syntax-rules (index)
    ((:vector1 cc var (index i) arg)
     (:do cc
          (let ((vec arg) (len 0)) 
            (set! len (vector-length vec)))
          ((i 0))
          (< i len)
          (let ((var (vector-ref vec i))))
          #t
          ((+ i 1)) ))
    ((:vector1 cc var (index i) arg1 arg2 arg ...)
     (:list cc 
            var 
            (index i) 
            (apply append (map vector->list (list arg1 arg2 arg ...))) ))
    ((:vector1 cc var arg1 arg ...)
     (:vector1 cc var (index i) arg1 arg ...) )))


; :vector2
;    runs through a list of vectors with nested loops for multi-arg.
;      + no space overhead
;      + no copying of the arguments
;      - more complicated book-keeping

(define-syntax :vector2
  (syntax-rules (index)
    ((:vector2 cc var arg)
     (:vector2 cc var (index i) arg) )
    ((:vector2 cc var (index i) arg)
     (:do cc
          (let ((vec arg) (len 0)) 
            (set! len (vector-length vec)))
          ((i 0))
          (< i len)
          (let ((var (vector-ref vec i))))
          #t
          ((+ i 1)) ))

    ((:vector2 cc var (index i) arg1 arg2 arg ...)
     (:parallel cc (:vector2 cc var arg1 arg2 arg ...) (:integers i)) )
    ((:vector2 cc var arg1 arg2 arg ...)
     (:do cc
          (let ((vec #f)
                (len 0)
                (vecs (ec-:vector-filter (list arg1 arg2 arg ...))) ))
          ((k 0))
          (if (< k len)
              #t
              (if (null? vecs)
                  #f
                  (begin (set! vec (car vecs))
                         (set! vecs (cdr vecs))
                         (set! len (vector-length vec))
                         (set! k 0)
                         #t )))
          (let ((var (vector-ref vec k))))
          #t
          ((+ k 1)) ))))

(define (ec-:vector-filter vecs)
  (if (null? vecs)
      '()
      (if (zero? (vector-length (car vecs)))
          (ec-:vector-filter (cdr vecs))
          (cons (car vecs) (ec-:vector-filter (cdr vecs))) )))

; comparison
;   * The trade-off is book-keeping overhead vs. allocation overhead.
;   * Scheme48 0.57: For short vectors :vector1 is 20% faster than 
;       :vector2. For long vectors (10^4) :vector2 is factor 2.8 
;       times faster. Break-even around n = 2.
;   * PLT 202: For short vectors, :vector1 is factor 2 faster than
;       :vector2, for long vectors (10^4) factor 1.6 slower.
;       Break-even is around n = 3.

(define (perf-:vector1 iterations n)
  (do-ec 
   (:let v (vector-of-length-ec n (:range i n) i))
   (:range i iterations) 
   (do-ec (:vector1 x v v v v v v v v v v) x) ))

(define (perf-:vector2 iterations n)
  (do-ec 
   (:let v (vector-of-length-ec n (:range i n) i))
   (:range i iterations) 
   (do-ec (:vector2 x v v v v v v v v v v) x) ))

; try:
;   (perf-:vector1 100000 1)
;   (perf-:vector2 100000 1)
;   (perf-:vector1 100 10000)
;   (perf-:vector2 100 10000)

