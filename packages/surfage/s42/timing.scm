; <PLAINTEXT>
; Timing for Eager Comprehensions in [outer..inner|expr]-Convention
; =================================================================
;
; sebastian.egner@philips.com, Eindhoven, The Netherlands, Feb-2003.
; Scheme R5RS (incl. macros), SRFI-23 (error).
; 
; Running the examples in Scheme48 (version 0.57):
;   ,open srfi-23
;   ,load ec.scm
;   ,load timing.scm
;
; Running the examples in PLT/DrScheme (version 202): 
;   ; open "ec.scm", click Execute
;   (load "timing.scm")
;
; Running the examples in SCM (version 5d7):
;   ; invoke SCM with -v on the command line
;   (require 'macro) (require 'record)
;   (load "ec.scm")
;   (load "timing.scm")


; =======================================================================
; Basic loops
; =======================================================================
;
; We measure execution times for (:range var n) and for (: var n),
; both as an outer loop (to measure iteration speed) or as an inner 
; loop (to measure start up overhead). For comparison the same is
; measured for a hand-coded DO-loop.

(define (perf0 n) ; reference for loop duration
  (do ((i 0 (+ i 1)))
      ((= i n))
    i))

(define (perf1 n)
  (do-ec (:range i n) i))

(define (perf2 n)
  (do-ec (: i n) i))

(define (perf0s n) ; reference for startup delay
  (do-ec (:range i n)
         (do ((i 0 (+ i 1)))
             ((= i 1))
           i)))

(define (perf1s n)
  (do-ec (:range i n) (:range j 1) i))

(define (perf2s n)
  (do-ec (:range i n) (: j 1) i))

(define n-perf 
  10000000)


; Scheme48 0.57 on HP 9000/800 server running HP-UX
; -------------------------------------------------
;
; ,time (perf0  n-perf)   19.3   ; built-in do
; ,time (perf1  n-perf)   17.0   ; faster than built-in do (?)
; ,time (perf2  n-perf)   40.4   ; due to calling the generator as procedure
;
; ,time (perf0s n-perf)   57.5   ; built-in do in the inner loop
; ,time (perf1s n-perf)   78.5   ; due to checking exact? integer?
; ,time (perf2s n-perf)  274.0   ; due to dispatch mechanism
;
; [All times are CPU time in seconds for n-perf iterations.]


; PLT 202 on Pentium III Mobile, 1 GHz, 1 GB RAM, Windows 2k
; ----------------------------------------------------------
;
; (time (perf0  n-perf))   11.1
; (time (perf1  n-perf))    7.8
; (time (perf2  n-perf))   18.1
;
; (time (perf0s n-perf))   35.2
; (time (perf1s n-perf))   42.9
; (time (perf2s n-perf))  147.8
; 
; [All times are CPU time in seconds for n-perf iterations.]


; SCM 5d7 on Pentium III Mobile, 1 GHz, 1 GB RAM, Windows 2k
; ----------------------------------------------------------
;
; (perf0  n-perf)   29.1
; (perf1  n-perf)   30.0
; (perf2  n-perf)   45.5
;
; (perf0s n-perf)   79.2
; (perf1s n-perf)  448.6
; (perf2s n-perf)  756.2
; 
; [All times are CPU time in seconds for n-perf iterations.]

