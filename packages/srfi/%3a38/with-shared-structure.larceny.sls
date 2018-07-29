;;; SRFI 38: External Representation of Data With Shared Structure
;;;
;;; $Id: %3a38.sls 6149 2009-03-19 02:41:56Z will $
;;;
;;; See <http://srfi.schemers.org/srfi-38/srfi-38.html> for the full document.
;;;
;;; This file contains code that is copyrighted by two separate
;;; SRFI-style copyrights.
;;;
;;; The code for write-with-shared-structure is attributed to
;;; Al Petrovsky and copyrighted by Ray Dillinger.
;;;
;;; All other code was written by William D Clinger.

(library (srfi :38 with-shared-structure)

  (export write-with-shared-structure write/ss
          read-with-shared-structure  read/ss)

  (import (rnrs base)
          (rnrs unicode)
          (rnrs bytevectors)
          (only (rnrs lists) memq)
          (rnrs control)
          (only (rnrs io ports) port? textual-port?)
          (rnrs io simple)
          (rnrs hashtables)
          (rnrs mutable-strings)
          (rnrs mutable-pairs)
          (srfi :99 records procedural)
          (only (srfi :99 records inspection) record?))

;;; Copyright (C) Ray Dillinger 2003. All Rights Reserved. 
;;;
;;; This document and translations of it may be copied and furnished to
;;; others, and derivative works that comment on or otherwise explain it
;;; or assist in its implementation may be prepared, copied, published and
;;; distributed, in whole or in part, without restriction of any kind,
;;; provided that the above copyright notice and this paragraph are
;;; included on all such copies and derivative works. However, this
;;; document itself may not be modified in any way, such as by removing
;;; the copyright notice or references to the Scheme Request For
;;; Implementation process or editors, except as needed for the purpose of
;;; developing SRFIs in which case the procedures for copyrights defined
;;; in the SRFI process must be followed, or as required to translate it
;;; into languages other than English.
;;;
;;; The limited permissions granted above are perpetual and will not be
;;; revoked by the authors or their successors or assigns.
;;;
;;; This document and the information contained herein is provided on an
;;; "AS IS" basis and THE AUTHOR AND THE SRFI EDITORS DISCLAIM ALL
;;; WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY
;;; WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE ANY
;;; RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A
;;; PARTICULAR PURPOSE.

;;; A printer that shows all sharing of substructures.  Uses the Common
;;; Lisp print-circle notation: #n# refers to a previous substructure
;;; labeled with #n=.   Takes O(n^2) time.

;;; Code attributed to Al* Petrofsky, modified by Dillinger.  
;;;
;;; Modified December 2008 by Will Clinger to use R6RS-style hashtables
;;; and to recognize R6RS data structures.  Now runs in O(n) time if
;;; the hashtable accesses are O(1).

(define (write-with-shared-structure obj . optional-port)

  (define (lookup key state)
    (hashtable-ref state key #f))

  (define (present? key state)
    (hashtable-contains? state key))

  (define (updated-state key val state)
    (hashtable-set! state key val)
    state)

  ;; An object is interesting if it might have a mutable state.
  ;; An interesting object is especially interesting if it has
  ;; a standard external representation (according to SRFI 38)
  ;; that might contain the object itself.  The interesting
  ;; objects described by the R5RS or R6RS are:
  ;;
  ;;     pairs             (especially interesting)
  ;;     vectors           (especially interesting)
  ;;     strings
  ;;     bytevectors
  ;;     records
  ;;     ports
  ;;     hashtables
  ;;
  ;; We treat zero-length vectors, strings, and bytevectors
  ;; as uninteresting because they don't have a mutable state
  ;; and the reference implementation for SRFI 38 also treated
  ;; them as uninteresting.

  (define (interesting? obj)
    (or (pair? obj)
        (and (vector? obj) (not (zero? (vector-length obj))))
        (and (string? obj) (not (zero? (string-length obj))))
        (bytevector? obj)
        (record? obj)
        (port? obj)
        (hashtable? obj)))

  ;; The state has an entry for each interesting part of OBJ.  The
  ;; associated value will be:
  ;;  -- a number if the part has been given one,
  ;;  -- #t if the part will need to be assigned a number but has not been yet,
  ;;  -- #f if the part will not need a number.
  ;; The state also associates a symbol (counter) with the most
  ;; recently assigned number.
  ;; Returns a state with new entries for any parts that had
  ;; numbers assigned.

  (define (write-obj obj state outport)

    (define (write-interesting state)
      (cond ((pair? obj)
             (display "(" outport)
             (let write-cdr ((obj (cdr obj))
                             (state (write-obj (car obj) state outport)))
               (cond ((and (pair? obj)
                           (not (lookup obj state)))
                      (display " " outport)
                      (write-cdr (cdr obj)
                                 (write-obj (car obj) state outport)))
                     ((null? obj)
                      (display ")" outport)
                      state)
                     (else
                      (display " . " outport)
                      (let ((state (write-obj obj state outport)))
                        (display ")" outport)
                        state)))))
            ((vector? obj)
             (display "#(" outport)
             (let ((len (vector-length obj)))
               (let write-vec ((i 1)
                               (state (write-obj (vector-ref obj 0)
                                                 state outport)))
                 (cond ((= i len) (display ")" outport) state)
                       (else (display " " outport)
                             (write-vec (+ i 1)
                                        (write-obj (vector-ref obj i)
                                                   state outport)))))))
            ;; else it's a string or something
            (else (write obj outport) state)))

    (cond ((interesting? obj)
           (let ((val (lookup obj state)))
             (cond ((not val)
                    (write-interesting state))
                   ((number? val) 
                    (begin (display "#" outport)
                           (write val outport)
                           (display "#" outport)
                           state))
                   (else
                    (let* ((n (+ 1 (lookup 'counter state)))
                           (state (updated-state 'counter n state)))
                      (begin (display "#" outport)
                             (write n outport) 
                             (display "=" outport))
                      (write-interesting (updated-state obj n state)))))))
          (else (write obj outport) state)))

  ;; Scan computes the initial value of the state, which maps each
  ;; interesting part of the object to #t if it occurs multiple times,
  ;; #f if only once.

  (define (scan obj state)
    (cond ((not (interesting? obj)) state)
          ((present? obj state)
           (updated-state obj #t state))
          (else
           (let ((state (updated-state obj #f state)))
             (cond ((pair? obj) (scan (car obj) (scan (cdr obj) state)))
                   ((vector? obj)
                    (let ((len (vector-length obj)))
                      (do ((i 0 (+ 1 i))
                           (state state (scan (vector-ref obj i) state)))
                          ((= i len) state))))
                   (else state))))))

  (let* ((state (make-eq-hashtable))
         (state (scan obj state))
         (state (updated-state 'counter 0 state))
         (outport (if (eq? '() optional-port)
                      (current-output-port)
                      (car optional-port))))
    (write-obj obj state outport)
    ;; We don't want to return the big state that write-obj just returned.
    (if #f #f)))


;;; Copyright (C) William D Clinger (2008). All Rights Reserved.
;;; 
;;; Permission is hereby granted, free of charge, to any
;;; person obtaining a copy of this software and associated
;;; documentation files (the "Software"), to deal in the
;;; Software without restriction, including without
;;; limitation the rights to use, copy, modify, merge,
;;; publish, distribute, sublicense, and/or sell copies of
;;; the Software, and to permit persons to whom the Software
;;; is furnished to do so, subject to the following
;;; conditions:
;;; 
;;; The above copyright notice and this permission notice
;;; shall be included in all copies or substantial portions
;;; of the Software.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
;;; ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
;;; TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
;;; PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
;;; SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
;;; IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; read-with-shared-structure
;
; Based on Clinger's reference implementation of get-datum.
;
; The scanner's state machine and the recursive descent parser
; were generated by Will Clinger's LexGen and ParseGen, so the
; parser can be extended or customized by regenerating those
; parts.
;
; LexGen and ParseGen are available at
; http://www.ccs.neu.edu/home/will/Research/SW2006/*.tar.gz
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Fixup objects are used to implement SRFI 38.

(define rtd:fixup-object
  (make-rtd 'fixup-object
            '#((immutable index)
               (mutable ready)
               (mutable value))))

(define make-raw-fixup-object (rtd-constructor rtd:fixup-object))

(define (make-fixup-object index)
  (make-raw-fixup-object index #f #f))

(define fixup-object? (rtd-predicate rtd:fixup-object))

(define fixup-ready? (rtd-accessor rtd:fixup-object 'ready))

(define fixup-index (rtd-accessor rtd:fixup-object 'index))

(define fixup-value (rtd-accessor rtd:fixup-object 'value))

(define (fixup-ready! fixup obj)
  (raw-fixup-value! fixup obj)
  (raw-fixup-ready! fixup #t))

(define raw-fixup-ready! (rtd-mutator rtd:fixup-object 'ready))
(define raw-fixup-value! (rtd-mutator rtd:fixup-object 'value))

; The exported entry point.

(define (read-with-shared-structure . rest)
  (cond ((null? rest)
         (read-with-shared-structure-local (current-input-port)))
        ((and (null? (cdr rest))
              (input-port? (car rest))
              (textual-port? (car rest)))
         (read-with-shared-structure-local (car rest)))
        (else
         (assertion-violation 'read-with-shared-structure
                              "illegal argument(s)" rest))))

(define (read-with-shared-structure-local input-port)

  ; Constants and local variables.

  (let* (; Constants.

         ; initial length of string_accumulator

         (initial_accumulator_length 64)

         ; Encodings of error messages.

         (errLongToken 1)                 ; extremely long token
         (errIncompleteToken 2)      ; any lexical error, really
         (errIllegalHexEscape 3)                 ; illegal \x...
         (errIllegalNamedChar 4)                 ; illegal #\...
         (errIllegalString 5)                   ; illegal string
         (errIllegalSymbol 6)                   ; illegal symbol
         (errNoDelimiter 7)      ; missing delimiter after token
         (errSRFI38 8)                           ; illegal #...#
         (errBug 9)            ; bug in reader, shouldn't happen
         (errLexGenBug 10)                        ; can't happen

         ; Important but unnamed non-Ascii characters.

         (char:nel    (integer->char #x85))
         (char:ls     (integer->char #x2028))

         ; State for one-token buffering in lexical analyzer.

         (kindOfNextToken 'z1)      ; valid iff nextTokenIsReady
         (nextTokenIsReady #f)

         (tokenValue "")  ; string associated with current token

         ; A string buffer for the characters of the current token.
         ; Resized as necessary.

         (string_accumulator (make-string initial_accumulator_length))

         ; Number of characters in string_accumulator.

         (string_accumulator_length 0)

         ; Hook for recording source locations.

         (locationStart #f)

         ; Hash table for SRFI 38, or #f.

         (shared-structures #f)

        )

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Hand-coding scanner0 makes a small but worthwhile difference.
    ;
    ; The most common characters are spaces, parentheses, newlines,
    ; semicolons, and lower case Ascii letters.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    ; Scanning for the start of a token.

    (define (scanner0)
      (define (loop c)
        (cond ((not (char? c))
               (accept 'eofobj))
              ((or (char=? c #\space)
                   (char=? c #\newline))
               (read-char input-port)
               (loop (peek-char input-port)))
              (else
               (state0 c))))
      (loop (peek-char input-port)))

    ; Consuming a semicolon comment.

    (define (scanner1)
      (define (loop c)
        (cond ((not (char? c))
               (accept 'eofobj))
              ((char=? c #\newline)
               (scanner0))
              (else
               (loop (read-char input-port)))))
      (loop (read-char input-port)))
  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; LexGen generated the code for the state machine.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (define (state0 c)
    (case c
      ((#\`) (consumeChar) (accept 'backquote))
      ((#\') (consumeChar) (accept 'quote))
      ((#\]) (consumeChar) (accept 'rbracket))
      ((#\[) (consumeChar) (accept 'lbracket))
      ((#\)) (consumeChar) (accept 'rparen))
      ((#\() (consumeChar) (accept 'lparen))
      ((#\tab #\newline #\vtab #\page #\return #\space)
       (consumeChar)
       (begin
         (set! string_accumulator_length 0)
         (state0 (scanChar))))
      ((#\;) (consumeChar) (state213 (scanChar)))
      ((#\#) (consumeChar) (state212 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state141 (scanChar)))
      ((#\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\g
        #\h
        #\i
        #\j
        #\k
        #\l
        #\m
        #\n
        #\o
        #\p
        #\q
        #\r
        #\s
        #\t
        #\u
        #\v
        #\w
        #\x
        #\y
        #\z
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F
        #\G
        #\H
        #\I
        #\J
        #\K
        #\L
        #\M
        #\N
        #\O
        #\P
        #\Q
        #\R
        #\S
        #\T
        #\U
        #\V
        #\W
        #\X
        #\Y
        #\Z
        #\!
        #\$
        #\%
        #\&
        #\*
        #\/
        #\:
        #\<
        #\=
        #\>
        #\?
        #\^
        #\_
        #\~)
       (consumeChar)
       (state13 (scanChar)))
      ((#\\) (consumeChar) (state12 (scanChar)))
      ((#\-) (consumeChar) (state9 (scanChar)))
      ((#\+) (consumeChar) (state8 (scanChar)))
      ((#\.) (consumeChar) (state7 (scanChar)))
      ((#\") (consumeChar) (state5 (scanChar)))
      ((#\,) (consumeChar) (state1 (scanChar)))
      (else
       (if ((lambda (c)
              (and (char? c)
                   (> (char->integer c) 127)
                   (let ((cat (char-general-category c)))
                     (memq cat
                           '(Lu Ll
                                Lt
                                Lm
                                Lo
                                Mn
                                Nl
                                No
                                Pd
                                Pc
                                Po
                                Sc
                                Sm
                                Sk
                                So
                                Co)))))
            c)
           (begin (consumeChar) (state13 (scanChar)))
           (if (eof-object? c)
               (begin (consumeChar) (accept 'eofobj))
               (if ((lambda (c) (and (char? c) (char-whitespace? c)))
                    c)
                   (begin
                     (consumeChar)
                     (begin
                       (set! string_accumulator_length 0)
                       (state0 (scanChar))))
                   (if ((lambda (c)
                          (and (char? c) (char=? c (integer->char 133))))
                        c)
                       (begin
                         (consumeChar)
                         (begin
                           (set! string_accumulator_length 0)
                           (state0 (scanChar))))
                       (scannerError errIncompleteToken))))))))
  (define (state1 c)
    (case c
      ((#\@) (consumeChar) (accept 'splicing))
      (else (accept 'comma))))
  (define (state2 c)
    (case c
      ((#\") (consumeChar) (accept 'string))
      ((#\newline #\return)
       (consumeChar)
       (state5 (scanChar)))
      ((#\\) (consumeChar) (state4 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state2 (scanChar)))
      (else
       (if (char? c)
           (begin (consumeChar) (state5 (scanChar)))
           (if ((lambda (c)
                  (and (char? c) (char=? c (integer->char 8232))))
                c)
               (begin (consumeChar) (state5 (scanChar)))
               (if ((lambda (c)
                      (and (char? c) (char=? c (integer->char 133))))
                    c)
                   (begin (consumeChar) (state5 (scanChar)))
                   (scannerError errIncompleteToken)))))))
  (define (state3 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state2 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state4 c)
    (case c
      ((#\a
        #\b
        #\t
        #\n
        #\v
        #\f
        #\r
        #\"
        #\\
        #\newline
        #\return
        #\space)
       (consumeChar)
       (state5 (scanChar)))
      ((#\x) (consumeChar) (state3 (scanChar)))
      (else
       (if ((lambda (c)
              (and (char? c) (char=? c (integer->char 8232))))
            c)
           (begin (consumeChar) (state5 (scanChar)))
           (if ((lambda (c)
                  (and (char? c) (char=? c (integer->char 133))))
                c)
               (begin (consumeChar) (state5 (scanChar)))
               (scannerError errIncompleteToken))))))
  (define (state5 c)
    (case c
      ((#\") (consumeChar) (accept 'string))
      ((#\newline #\return)
       (consumeChar)
       (state5 (scanChar)))
      ((#\\) (consumeChar) (state4 (scanChar)))
      (else
       (if (char? c)
           (begin (consumeChar) (state5 (scanChar)))
           (if ((lambda (c)
                  (and (char? c) (char=? c (integer->char 8232))))
                c)
               (begin (consumeChar) (state5 (scanChar)))
               (if ((lambda (c)
                      (and (char? c) (char=? c (integer->char 133))))
                    c)
                   (begin (consumeChar) (state5 (scanChar)))
                   (scannerError errIncompleteToken)))))))
  (define (state6 c)
    (case c
      ((#\.) (consumeChar) (accept 'id))
      (else (scannerError errIncompleteToken))))
  (define (state7 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state130 (scanChar)))
      ((#\.) (consumeChar) (state6 (scanChar)))
      (else (accept 'period))))
  (define (state8 c)
    (case c
      ((#\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state203 (scanChar)))
      ((#\.) (consumeChar) (state149 (scanChar)))
      ((#\n) (consumeChar) (state148 (scanChar)))
      ((#\i) (consumeChar) (state143 (scanChar)))
      (else (accept 'id))))
  (define (state9 c)
    (case c
      ((#\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state203 (scanChar)))
      ((#\.) (consumeChar) (state149 (scanChar)))
      ((#\n) (consumeChar) (state148 (scanChar)))
      ((#\i) (consumeChar) (state143 (scanChar)))
      ((#\>) (consumeChar) (state13 (scanChar)))
      (else (accept 'id))))
  (define (state10 c)
    (case c
      ((#\;) (consumeChar) (state13 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state10 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state11 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state10 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state12 c)
    (case c
      ((#\x) (consumeChar) (state11 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state13 c)
    (case c
      ((#\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\g
        #\h
        #\i
        #\j
        #\k
        #\l
        #\m
        #\n
        #\o
        #\p
        #\q
        #\r
        #\s
        #\t
        #\u
        #\v
        #\w
        #\x
        #\y
        #\z
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F
        #\G
        #\H
        #\I
        #\J
        #\K
        #\L
        #\M
        #\N
        #\O
        #\P
        #\Q
        #\R
        #\S
        #\T
        #\U
        #\V
        #\W
        #\X
        #\Y
        #\Z
        #\!
        #\$
        #\%
        #\&
        #\*
        #\/
        #\:
        #\<
        #\=
        #\>
        #\?
        #\^
        #\_
        #\~
        #\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\+
        #\-
        #\.
        #\@)
       (consumeChar)
       (state13 (scanChar)))
      ((#\\) (consumeChar) (state12 (scanChar)))
      (else
       (if ((lambda (c)
              (and (char? c)
                   (let ((cat (char-general-category c)))
                     (memq cat '(Nd Mc Me)))))
            c)
           (begin (consumeChar) (state13 (scanChar)))
           (if ((lambda (c)
                  (and (char? c)
                       (> (char->integer c) 127)
                       (let ((cat (char-general-category c)))
                         (memq cat
                               '(Lu Ll
                                    Lt
                                    Lm
                                    Lo
                                    Mn
                                    Nl
                                    No
                                    Pd
                                    Pc
                                    Po
                                    Sc
                                    Sm
                                    Sk
                                    So
                                    Co)))))
                c)
               (begin (consumeChar) (state13 (scanChar)))
               (accept 'id))))))
  (define (state14 c)
    (case c
      ((#\#) (consumeChar) (accept 'sharinguse))
      ((#\=) (consumeChar) (accept 'sharingdef))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state14 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state15 c)
    (case c
      ((#\@) (consumeChar) (accept 'unsyntaxsplicing))
      (else (accept 'unsyntax))))
  (define (state16 c)
    (case c
      ((#\() (consumeChar) (accept 'bvecstart))
      (else (scannerError errIncompleteToken))))
  (define (state17 c)
    (case c
      ((#\8) (consumeChar) (state16 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state18 c)
    (case c
      ((#\u) (consumeChar) (state17 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state19 c)
    (case c
      ((#\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\g
        #\h
        #\i
        #\j
        #\k
        #\l
        #\m
        #\n
        #\o
        #\p
        #\q
        #\r
        #\s
        #\t
        #\u
        #\v
        #\w
        #\x
        #\y
        #\z
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F
        #\G
        #\H
        #\I
        #\J
        #\K
        #\L
        #\M
        #\N
        #\O
        #\P
        #\Q
        #\R
        #\S
        #\T
        #\U
        #\V
        #\W
        #\X
        #\Y
        #\Z)
       (consumeChar)
       (state19 (scanChar)))
      (else (accept 'character))))
  (define (state20 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state20 (scanChar)))
      (else (accept 'character))))
  (define (state21 c)
    (case c
      ((#\a #\b #\c #\d #\e #\f #\A #\B #\C #\D #\E #\F)
       (consumeChar)
       (state21 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state20 (scanChar)))
      ((#\g
        #\h
        #\i
        #\j
        #\k
        #\l
        #\m
        #\n
        #\o
        #\p
        #\q
        #\r
        #\s
        #\t
        #\u
        #\v
        #\w
        #\x
        #\y
        #\z
        #\G
        #\H
        #\I
        #\J
        #\K
        #\L
        #\M
        #\N
        #\O
        #\P
        #\Q
        #\R
        #\S
        #\T
        #\U
        #\V
        #\W
        #\X
        #\Y
        #\Z)
       (consumeChar)
       (state19 (scanChar)))
      (else (accept 'character))))
  (define (state22 c)
    (case c
      ((#\x) (consumeChar) (state21 (scanChar)))
      ((#\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\g
        #\h
        #\i
        #\j
        #\k
        #\l
        #\m
        #\n
        #\o
        #\p
        #\q
        #\r
        #\s
        #\t
        #\u
        #\v
        #\w
        #\y
        #\z
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F
        #\G
        #\H
        #\I
        #\J
        #\K
        #\L
        #\M
        #\N
        #\O
        #\P
        #\Q
        #\R
        #\S
        #\T
        #\U
        #\V
        #\W
        #\X
        #\Y
        #\Z)
       (consumeChar)
       (state19 (scanChar)))
      (else
       (if (char? c)
           (begin (consumeChar) (accept 'character))
           (scannerError errIncompleteToken)))))
  (define (state23 c)
    (case c
      ((#\i #\I #\e #\E)
       (consumeChar)
       (state58 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state24 c)
    (case c
      ((#\+ #\-) (consumeChar) (state57 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state33 (scanChar)))
      ((#\#) (consumeChar) (state23 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state25 c)
    (case c
      ((#\i #\I #\e #\E)
       (consumeChar)
       (state88 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state26 c)
    (case c
      ((#\+ #\-) (consumeChar) (state87 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state63 (scanChar)))
      ((#\#) (consumeChar) (state25 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state27 c)
    (case c
      ((#\i #\I #\e #\E)
       (consumeChar)
       (state126 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state28 c)
    (case c
      ((#\+ #\-) (consumeChar) (state125 (scanChar)))
      ((#\0 #\1) (consumeChar) (state93 (scanChar)))
      ((#\#) (consumeChar) (state27 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state29 c)
    (case c
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      ((#\#) (consumeChar) (state29 (scanChar)))
      (else (accept 'number))))
  (define (state30 c)
    (case c
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state30 (scanChar)))
      ((#\#) (consumeChar) (state29 (scanChar)))
      (else (accept 'number))))
  (define (state31 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state30 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state32 c)
    (case c
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      ((#\#) (consumeChar) (state32 (scanChar)))
      ((#\/) (consumeChar) (state31 (scanChar)))
      (else (accept 'number))))
  (define (state33 c)
    (case c
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state33 (scanChar)))
      ((#\#) (consumeChar) (state32 (scanChar)))
      ((#\/) (consumeChar) (state31 (scanChar)))
      (else (accept 'number))))
  (define (state34 c)
    (case c
      ((#\f) (consumeChar) (state38 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state35 c)
    (case c
      ((#\n) (consumeChar) (state34 (scanChar)))
      (else (accept 'number))))
  (define (state36 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      (else (accept 'number))))
  (define (state37 c)
    (case c
      ((#\0) (consumeChar) (state36 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state38 c)
    (case c
      ((#\.) (consumeChar) (state37 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state39 c)
    (case c
      ((#\n) (consumeChar) (state38 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state40 c)
    (case c
      ((#\a) (consumeChar) (state39 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state41 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state108 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state41 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state42 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state41 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state43 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state43 (scanChar)))
      ((#\/) (consumeChar) (state42 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state44 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state44 (scanChar)))
      ((#\#) (consumeChar) (state43 (scanChar)))
      ((#\/) (consumeChar) (state42 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state45 c)
    (case c
      ((#\n) (consumeChar) (state107 (scanChar)))
      ((#\i) (consumeChar) (state102 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state44 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state46 c)
    (case c
      ((#\#) (consumeChar) (state192 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state46 (scanChar)))
      (else (accept 'number))))
  (define (state47 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state46 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state48 c)
    (case c
      ((#\#) (consumeChar) (state48 (scanChar)))
      ((#\/) (consumeChar) (state47 (scanChar)))
      (else (accept 'number))))
  (define (state49 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state49 (scanChar)))
      ((#\#) (consumeChar) (state48 (scanChar)))
      ((#\/) (consumeChar) (state47 (scanChar)))
      (else (accept 'number))))
  (define (state50 c)
    (case c
      ((#\n) (consumeChar) (state183 (scanChar)))
      ((#\i) (consumeChar) (state179 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state49 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state51 c)
    (case c
      ((#\+ #\-) (consumeChar) (state50 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state49 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state52 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state52 (scanChar)))
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      (else (accept 'number))))
  (define (state53 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state53 (scanChar)))
      ((#\#) (consumeChar) (state52 (scanChar)))
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      (else (accept 'number))))
  (define (state54 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state53 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state55 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state55 (scanChar)))
      ((#\/) (consumeChar) (state54 (scanChar)))
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      (else (accept 'number))))
  (define (state56 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state56 (scanChar)))
      ((#\#) (consumeChar) (state55 (scanChar)))
      ((#\/) (consumeChar) (state54 (scanChar)))
      ((#\@) (consumeChar) (state51 (scanChar)))
      ((#\+ #\-) (consumeChar) (state45 (scanChar)))
      (else (accept 'number))))
  (define (state57 c)
    (case c
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state56 (scanChar)))
      ((#\n) (consumeChar) (state40 (scanChar)))
      ((#\i) (consumeChar) (state35 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state58 c)
    (case c
      ((#\+ #\-) (consumeChar) (state57 (scanChar)))
      ((#\0
        #\1
        #\2
        #\3
        #\4
        #\5
        #\6
        #\7
        #\8
        #\9
        #\a
        #\b
        #\c
        #\d
        #\e
        #\f
        #\A
        #\B
        #\C
        #\D
        #\E
        #\F)
       (consumeChar)
       (state33 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state59 c)
    (case c
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      ((#\#) (consumeChar) (state59 (scanChar)))
      (else (accept 'number))))
  (define (state60 c)
    (case c
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state60 (scanChar)))
      ((#\#) (consumeChar) (state59 (scanChar)))
      (else (accept 'number))))
  (define (state61 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state60 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state62 c)
    (case c
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      ((#\#) (consumeChar) (state62 (scanChar)))
      ((#\/) (consumeChar) (state61 (scanChar)))
      (else (accept 'number))))
  (define (state63 c)
    (case c
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state63 (scanChar)))
      ((#\#) (consumeChar) (state62 (scanChar)))
      ((#\/) (consumeChar) (state61 (scanChar)))
      (else (accept 'number))))
  (define (state64 c)
    (case c
      ((#\f) (consumeChar) (state68 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state65 c)
    (case c
      ((#\n) (consumeChar) (state64 (scanChar)))
      (else (accept 'number))))
  (define (state66 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      (else (accept 'number))))
  (define (state67 c)
    (case c
      ((#\0) (consumeChar) (state66 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state68 c)
    (case c
      ((#\.) (consumeChar) (state67 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state69 c)
    (case c
      ((#\n) (consumeChar) (state68 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state70 c)
    (case c
      ((#\a) (consumeChar) (state69 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state71 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state108 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state71 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state72 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state71 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state73 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state73 (scanChar)))
      ((#\/) (consumeChar) (state72 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state74 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state74 (scanChar)))
      ((#\#) (consumeChar) (state73 (scanChar)))
      ((#\/) (consumeChar) (state72 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state75 c)
    (case c
      ((#\n) (consumeChar) (state107 (scanChar)))
      ((#\i) (consumeChar) (state102 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state74 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state76 c)
    (case c
      ((#\#) (consumeChar) (state192 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state76 (scanChar)))
      (else (accept 'number))))
  (define (state77 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state76 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state78 c)
    (case c
      ((#\#) (consumeChar) (state78 (scanChar)))
      ((#\/) (consumeChar) (state77 (scanChar)))
      (else (accept 'number))))
  (define (state79 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state79 (scanChar)))
      ((#\#) (consumeChar) (state78 (scanChar)))
      ((#\/) (consumeChar) (state77 (scanChar)))
      (else (accept 'number))))
  (define (state80 c)
    (case c
      ((#\n) (consumeChar) (state183 (scanChar)))
      ((#\i) (consumeChar) (state179 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state79 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state81 c)
    (case c
      ((#\+ #\-) (consumeChar) (state80 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state79 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state82 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state82 (scanChar)))
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      (else (accept 'number))))
  (define (state83 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state83 (scanChar)))
      ((#\#) (consumeChar) (state82 (scanChar)))
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      (else (accept 'number))))
  (define (state84 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state83 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state85 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state85 (scanChar)))
      ((#\/) (consumeChar) (state84 (scanChar)))
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      (else (accept 'number))))
  (define (state86 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state86 (scanChar)))
      ((#\#) (consumeChar) (state85 (scanChar)))
      ((#\/) (consumeChar) (state84 (scanChar)))
      ((#\@) (consumeChar) (state81 (scanChar)))
      ((#\+ #\-) (consumeChar) (state75 (scanChar)))
      (else (accept 'number))))
  (define (state87 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state86 (scanChar)))
      ((#\n) (consumeChar) (state70 (scanChar)))
      ((#\i) (consumeChar) (state65 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state88 c)
    (case c
      ((#\+ #\-) (consumeChar) (state87 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7)
       (consumeChar)
       (state63 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state89 c)
    (case c
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      ((#\#) (consumeChar) (state89 (scanChar)))
      (else (accept 'number))))
  (define (state90 c)
    (case c
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      ((#\0 #\1) (consumeChar) (state90 (scanChar)))
      ((#\#) (consumeChar) (state89 (scanChar)))
      (else (accept 'number))))
  (define (state91 c)
    (case c
      ((#\0 #\1) (consumeChar) (state90 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state92 c)
    (case c
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      ((#\#) (consumeChar) (state92 (scanChar)))
      ((#\/) (consumeChar) (state91 (scanChar)))
      (else (accept 'number))))
  (define (state93 c)
    (case c
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      ((#\0 #\1) (consumeChar) (state93 (scanChar)))
      ((#\#) (consumeChar) (state92 (scanChar)))
      ((#\/) (consumeChar) (state91 (scanChar)))
      (else (accept 'number))))
  (define (state94 c)
    (case c
      ((#\f) (consumeChar) (state98 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state95 c)
    (case c
      ((#\n) (consumeChar) (state94 (scanChar)))
      (else (accept 'number))))
  (define (state96 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      (else (accept 'number))))
  (define (state97 c)
    (case c
      ((#\0) (consumeChar) (state96 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state98 c)
    (case c
      ((#\.) (consumeChar) (state97 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state99 c)
    (case c
      ((#\n) (consumeChar) (state98 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state100 c)
    (case c
      ((#\a) (consumeChar) (state99 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state101 c)
    (case c
      ((#\f) (consumeChar) (state105 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state102 c)
    (case c
      ((#\n) (consumeChar) (state101 (scanChar)))
      (else (accept 'number))))
  (define (state103 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      (else (scannerError errIncompleteToken))))
  (define (state104 c)
    (case c
      ((#\0) (consumeChar) (state103 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state105 c)
    (case c
      ((#\.) (consumeChar) (state104 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state106 c)
    (case c
      ((#\n) (consumeChar) (state105 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state107 c)
    (case c
      ((#\a) (consumeChar) (state106 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state108 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state108 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state109 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1) (consumeChar) (state109 (scanChar)))
      ((#\#) (consumeChar) (state108 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state110 c)
    (case c
      ((#\0 #\1) (consumeChar) (state109 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state111 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state111 (scanChar)))
      ((#\/) (consumeChar) (state110 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state112 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1) (consumeChar) (state112 (scanChar)))
      ((#\#) (consumeChar) (state111 (scanChar)))
      ((#\/) (consumeChar) (state110 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state113 c)
    (case c
      ((#\0 #\1) (consumeChar) (state112 (scanChar)))
      ((#\n) (consumeChar) (state107 (scanChar)))
      ((#\i) (consumeChar) (state102 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state114 c)
    (case c
      ((#\#) (consumeChar) (state192 (scanChar)))
      ((#\0 #\1) (consumeChar) (state114 (scanChar)))
      (else (accept 'number))))
  (define (state115 c)
    (case c
      ((#\0 #\1) (consumeChar) (state114 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state116 c)
    (case c
      ((#\#) (consumeChar) (state116 (scanChar)))
      ((#\/) (consumeChar) (state115 (scanChar)))
      (else (accept 'number))))
  (define (state117 c)
    (case c
      ((#\0 #\1) (consumeChar) (state117 (scanChar)))
      ((#\#) (consumeChar) (state116 (scanChar)))
      ((#\/) (consumeChar) (state115 (scanChar)))
      (else (accept 'number))))
  (define (state118 c)
    (case c
      ((#\n) (consumeChar) (state183 (scanChar)))
      ((#\i) (consumeChar) (state179 (scanChar)))
      ((#\0 #\1) (consumeChar) (state117 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state119 c)
    (case c
      ((#\+ #\-) (consumeChar) (state118 (scanChar)))
      ((#\0 #\1) (consumeChar) (state117 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state120 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state120 (scanChar)))
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      (else (accept 'number))))
  (define (state121 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1) (consumeChar) (state121 (scanChar)))
      ((#\#) (consumeChar) (state120 (scanChar)))
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      (else (accept 'number))))
  (define (state122 c)
    (case c
      ((#\0 #\1) (consumeChar) (state121 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state123 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state123 (scanChar)))
      ((#\/) (consumeChar) (state122 (scanChar)))
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      (else (accept 'number))))
  (define (state124 c)
    (case c
      ((#\i) (consumeChar) (accept 'number))
      ((#\0 #\1) (consumeChar) (state124 (scanChar)))
      ((#\#) (consumeChar) (state123 (scanChar)))
      ((#\/) (consumeChar) (state122 (scanChar)))
      ((#\@) (consumeChar) (state119 (scanChar)))
      ((#\+ #\-) (consumeChar) (state113 (scanChar)))
      (else (accept 'number))))
  (define (state125 c)
    (case c
      ((#\0 #\1) (consumeChar) (state124 (scanChar)))
      ((#\n) (consumeChar) (state100 (scanChar)))
      ((#\i) (consumeChar) (state95 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state126 c)
    (case c
      ((#\+ #\-) (consumeChar) (state125 (scanChar)))
      ((#\0 #\1) (consumeChar) (state93 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state127 c)
    (case c
      ((#\d #\D) (consumeChar) (state205 (scanChar)))
      ((#\b #\B) (consumeChar) (state126 (scanChar)))
      ((#\o #\O) (consumeChar) (state88 (scanChar)))
      ((#\x #\X) (consumeChar) (state58 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state128 c)
    (case c
      ((#\+ #\-) (consumeChar) (state204 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state141 (scanChar)))
      ((#\.) (consumeChar) (state129 (scanChar)))
      ((#\#) (consumeChar) (state127 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state129 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state130 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state130 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state136 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state135 (scanChar)))
      ((#\|) (consumeChar) (state132 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state130 (scanChar)))
      (else (accept 'number))))
  (define (state131 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state131 (scanChar)))
      (else (accept 'number))))
  (define (state132 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state131 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state133 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state133 (scanChar)))
      ((#\|) (consumeChar) (state132 (scanChar)))
      (else (accept 'number))))
  (define (state134 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state133 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state135 c)
    (case c
      ((#\+ #\-) (consumeChar) (state134 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state133 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state136 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state136 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state135 (scanChar)))
      ((#\|) (consumeChar) (state132 (scanChar)))
      (else (accept 'number))))
  (define (state137 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state137 (scanChar)))
      (else (accept 'number))))
  (define (state138 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state138 (scanChar)))
      ((#\#) (consumeChar) (state137 (scanChar)))
      (else (accept 'number))))
  (define (state139 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state138 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state140 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state140 (scanChar)))
      ((#\/) (consumeChar) (state139 (scanChar)))
      ((#\.) (consumeChar) (state136 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state135 (scanChar)))
      ((#\|) (consumeChar) (state132 (scanChar)))
      (else (accept 'number))))
  (define (state141 c)
    (case c
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state141 (scanChar)))
      ((#\#) (consumeChar) (state140 (scanChar)))
      ((#\/) (consumeChar) (state139 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state135 (scanChar)))
      ((#\|) (consumeChar) (state132 (scanChar)))
      ((#\.) (consumeChar) (state130 (scanChar)))
      (else (accept 'number))))
  (define (state142 c)
    (case c
      ((#\f) (consumeChar) (state146 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state143 c)
    (case c
      ((#\n) (consumeChar) (state142 (scanChar)))
      (else (accept 'number))))
  (define (state144 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      (else (accept 'number))))
  (define (state145 c)
    (case c
      ((#\0) (consumeChar) (state144 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state146 c)
    (case c
      ((#\.) (consumeChar) (state145 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state147 c)
    (case c
      ((#\n) (consumeChar) (state146 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state148 c)
    (case c
      ((#\a) (consumeChar) (state147 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state149 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state150 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state150 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state156 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state155 (scanChar)))
      ((#\|) (consumeChar) (state152 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state150 (scanChar)))
      (else (accept 'number))))
  (define (state151 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state151 (scanChar)))
      (else (accept 'number))))
  (define (state152 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state151 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state153 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state153 (scanChar)))
      ((#\|) (consumeChar) (state152 (scanChar)))
      (else (accept 'number))))
  (define (state154 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state153 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state155 c)
    (case c
      ((#\+ #\-) (consumeChar) (state154 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state153 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state156 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\#) (consumeChar) (state156 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state155 (scanChar)))
      ((#\|) (consumeChar) (state152 (scanChar)))
      (else (accept 'number))))
  (define (state157 c)
    (case c
      ((#\f) (consumeChar) (state161 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state158 c)
    (case c
      ((#\n) (consumeChar) (state157 (scanChar)))
      (else (accept 'number))))
  (define (state159 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      (else (scannerError errIncompleteToken))))
  (define (state160 c)
    (case c
      ((#\0) (consumeChar) (state159 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state161 c)
    (case c
      ((#\.) (consumeChar) (state160 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state162 c)
    (case c
      ((#\n) (consumeChar) (state161 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state163 c)
    (case c
      ((#\a) (consumeChar) (state162 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state164 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state165 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state165 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state171 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state170 (scanChar)))
      ((#\|) (consumeChar) (state167 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state165 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state166 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state166 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state167 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state166 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state168 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state168 (scanChar)))
      ((#\|) (consumeChar) (state167 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state169 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state168 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state170 c)
    (case c
      ((#\+ #\-) (consumeChar) (state169 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state168 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state171 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state171 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state170 (scanChar)))
      ((#\|) (consumeChar) (state167 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state172 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state172 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state173 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state173 (scanChar)))
      ((#\#) (consumeChar) (state172 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state174 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state173 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state175 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state175 (scanChar)))
      ((#\/) (consumeChar) (state174 (scanChar)))
      ((#\.) (consumeChar) (state171 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state170 (scanChar)))
      ((#\|) (consumeChar) (state167 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state176 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state176 (scanChar)))
      ((#\#) (consumeChar) (state175 (scanChar)))
      ((#\/) (consumeChar) (state174 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state170 (scanChar)))
      ((#\|) (consumeChar) (state167 (scanChar)))
      ((#\.) (consumeChar) (state165 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state177 c)
    (case c
      ((#\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state176 (scanChar)))
      ((#\.) (consumeChar) (state164 (scanChar)))
      ((#\n) (consumeChar) (state163 (scanChar)))
      ((#\i) (consumeChar) (state158 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state178 c)
    (case c
      ((#\f) (consumeChar) (state181 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state179 c)
    (case c
      ((#\n) (consumeChar) (state178 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state180 c)
    (case c
      ((#\0) (consumeChar) (accept 'number))
      (else (scannerError errIncompleteToken))))
  (define (state181 c)
    (case c
      ((#\.) (consumeChar) (state180 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state182 c)
    (case c
      ((#\n) (consumeChar) (state181 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state183 c)
    (case c
      ((#\a) (consumeChar) (state182 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state184 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state185 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state185 c)
    (case c
      ((#\#) (consumeChar) (state191 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state190 (scanChar)))
      ((#\|) (consumeChar) (state187 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state185 (scanChar)))
      (else (accept 'number))))
  (define (state186 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state186 (scanChar)))
      (else (accept 'number))))
  (define (state187 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state186 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state188 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state188 (scanChar)))
      ((#\|) (consumeChar) (state187 (scanChar)))
      (else (accept 'number))))
  (define (state189 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state188 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state190 c)
    (case c
      ((#\+ #\-) (consumeChar) (state189 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state188 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state191 c)
    (case c
      ((#\#) (consumeChar) (state191 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state190 (scanChar)))
      ((#\|) (consumeChar) (state187 (scanChar)))
      (else (accept 'number))))
  (define (state192 c)
    (case c
      ((#\#) (consumeChar) (state192 (scanChar)))
      (else (accept 'number))))
  (define (state193 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state193 (scanChar)))
      ((#\#) (consumeChar) (state192 (scanChar)))
      (else (accept 'number))))
  (define (state194 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state193 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state195 c)
    (case c
      ((#\#) (consumeChar) (state195 (scanChar)))
      ((#\/) (consumeChar) (state194 (scanChar)))
      ((#\.) (consumeChar) (state191 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state190 (scanChar)))
      ((#\|) (consumeChar) (state187 (scanChar)))
      (else (accept 'number))))
  (define (state196 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state196 (scanChar)))
      ((#\#) (consumeChar) (state195 (scanChar)))
      ((#\/) (consumeChar) (state194 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state190 (scanChar)))
      ((#\|) (consumeChar) (state187 (scanChar)))
      ((#\.) (consumeChar) (state185 (scanChar)))
      (else (accept 'number))))
  (define (state197 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state196 (scanChar)))
      ((#\.) (consumeChar) (state184 (scanChar)))
      ((#\n) (consumeChar) (state183 (scanChar)))
      ((#\i) (consumeChar) (state179 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state198 c)
    (case c
      ((#\+ #\-) (consumeChar) (state197 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state196 (scanChar)))
      ((#\.) (consumeChar) (state184 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state199 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state199 (scanChar)))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      (else (accept 'number))))
  (define (state200 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state200 (scanChar)))
      ((#\#) (consumeChar) (state199 (scanChar)))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      (else (accept 'number))))
  (define (state201 c)
    (case c
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state200 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state202 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\#) (consumeChar) (state202 (scanChar)))
      ((#\/) (consumeChar) (state201 (scanChar)))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\.) (consumeChar) (state156 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state155 (scanChar)))
      ((#\|) (consumeChar) (state152 (scanChar)))
      (else (accept 'number))))
  (define (state203 c)
    (case c
      ((#\i #\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state203 (scanChar)))
      ((#\#) (consumeChar) (state202 (scanChar)))
      ((#\/) (consumeChar) (state201 (scanChar)))
      ((#\@) (consumeChar) (state198 (scanChar)))
      ((#\+ #\-) (consumeChar) (state177 (scanChar)))
      ((#\e #\E #\s #\S #\f #\F #\d #\D #\l #\L)
       (consumeChar)
       (state155 (scanChar)))
      ((#\|) (consumeChar) (state152 (scanChar)))
      ((#\.) (consumeChar) (state150 (scanChar)))
      (else (accept 'number))))
  (define (state204 c)
    (case c
      ((#\I) (consumeChar) (accept 'number))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state203 (scanChar)))
      ((#\.) (consumeChar) (state149 (scanChar)))
      ((#\n) (consumeChar) (state148 (scanChar)))
      ((#\i) (consumeChar) (state143 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state205 c)
    (case c
      ((#\+ #\-) (consumeChar) (state204 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state141 (scanChar)))
      ((#\.) (consumeChar) (state129 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state206 c)
    (case c
      ((#\i #\I #\e #\E)
       (consumeChar)
       (state205 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state207 c)
    (case c
      ((#\#) (consumeChar) (state206 (scanChar)))
      ((#\+ #\-) (consumeChar) (state204 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state141 (scanChar)))
      ((#\.) (consumeChar) (state129 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state208 c)
    (case c
      ((#\s) (consumeChar) (accept 'miscflag))
      (else (scannerError errIncompleteToken))))
  (define (state209 c)
    (case c
      ((#\r) (consumeChar) (state208 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state210 c)
    (case c
      ((#\6) (consumeChar) (state209 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state211 c)
    (case c
      ((#\r) (consumeChar) (state210 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state212 c)
    (case c
      ((#\`) (consumeChar) (accept 'quasisyntax))
      ((#\') (consumeChar) (accept 'syntax))
      ((#\() (consumeChar) (accept 'vecstart))
      ((#\t #\T #\f #\F)
       (consumeChar)
       (accept 'boolean))
      ((#\;) (consumeChar) (accept 'commentdatum))
      ((#\|) (consumeChar) (accept 'comment))
      ((#\!) (consumeChar) (state211 (scanChar)))
      ((#\d #\D) (consumeChar) (state207 (scanChar)))
      ((#\i #\I #\e #\E)
       (consumeChar)
       (state128 (scanChar)))
      ((#\b #\B) (consumeChar) (state28 (scanChar)))
      ((#\o #\O) (consumeChar) (state26 (scanChar)))
      ((#\x #\X) (consumeChar) (state24 (scanChar)))
      ((#\\) (consumeChar) (state22 (scanChar)))
      ((#\v) (consumeChar) (state18 (scanChar)))
      ((#\,) (consumeChar) (state15 (scanChar)))
      ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
       (consumeChar)
       (state14 (scanChar)))
      (else (scannerError errIncompleteToken))))
  (define (state213 c)
    (case c
      (else
       (if ((lambda (c)
              (and (char? c)
                   (not (char=? c (integer->char 10)))))
            c)
           (begin (consumeChar) (state213 (scanChar)))
           (begin
             (set! string_accumulator_length 0)
             (state0 (scanChar)))))))
  (define (state214 c)
    (case c
      (else
       (begin
         (set! string_accumulator_length 0)
         (state0 (scanChar))))))
  (define (state215 c)
    (case c (else (accept 'comment))))
  (define (state216 c)
    (case c (else (accept 'commentdatum))))
  (define (state217 c)
    (case c (else (accept 'miscflag))))
  (define (state218 c)
    (case c (else (accept 'boolean))))
  (define (state219 c)
    (case c (else (accept 'number))))
  (define (state220 c)
    (case c (else (accept 'character))))
  (define (state221 c)
    (case c (else (accept 'vecstart))))
  (define (state222 c)
    (case c (else (accept 'bvecstart))))
  (define (state223 c)
    (case c (else (accept 'syntax))))
  (define (state224 c)
    (case c (else (accept 'quasisyntax))))
  (define (state225 c)
    (case c (else (accept 'unsyntaxsplicing))))
  (define (state226 c)
    (case c (else (accept 'sharingdef))))
  (define (state227 c)
    (case c (else (accept 'sharinguse))))
  (define (state228 c)
    (case c (else (accept 'eofobj))))
  (define (state229 c)
    (case c (else (accept 'id))))
  (define (state230 c)
    (case c (else (accept 'string))))
  (define (state231 c)
    (case c (else (accept 'lparen))))
  (define (state232 c)
    (case c (else (accept 'rparen))))
  (define (state233 c)
    (case c (else (accept 'lbracket))))
  (define (state234 c)
    (case c (else (accept 'rbracket))))
  (define (state235 c)
    (case c (else (accept 'quote))))
  (define (state236 c)
    (case c (else (accept 'backquote))))
  (define (state237 c)
    (case c (else (accept 'splicing))))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; End of state machine generated by LexGen.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; ParseGen generated the code for the strong LL(1) parser.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
(define (parse-outermost-datum)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart
       miscflag
       id
       string
       character
       number
       boolean
       sharingdef
       sharinguse)
     (let ((ast1 (parse-datum))) (identity ast1)))
    ((eofobj) (begin (consume-token!) (makeEOF)))
    (else
     (parse-error
       '<outermost-datum>
       '(backquote
          boolean
          bvecstart
          character
          comma
          eofobj
          id
          lbracket
          lparen
          miscflag
          number
          quasisyntax
          quote
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-datum)
  (case (next-token)
    ((sharinguse)
     (let ((ast1 (parse-sharinguse)))
       (makeSharingUse ast1)))
    ((sharingdef)
     (let ((ast1 (parse-sharingdef)))
       (let ((ast2 (parse-udatum)))
         (makeSharingDef ast1 ast2))))
    ((boolean
       number
       character
       string
       id
       miscflag
       bvecstart
       vecstart
       lparen
       lbracket
       quote
       backquote
       comma
       splicing
       syntax
       quasisyntax
       unsyntax
       unsyntaxsplicing)
     (let ((ast1 (parse-udatum))) (identity ast1)))
    (else
     (parse-error
       '<datum>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          quasisyntax
          quote
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-udatum)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart)
     (let ((ast1 (parse-location)))
       (let ((ast2 (parse-structured)))
         (makeStructured ast1 ast2))))
    ((miscflag) (begin (consume-token!) (makeFlag)))
    ((id) (begin (consume-token!) (makeSym)))
    ((string) (begin (consume-token!) (makeString)))
    ((character) (begin (consume-token!) (makeChar)))
    ((number) (begin (consume-token!) (makeNum)))
    ((boolean) (begin (consume-token!) (makeBool)))
    (else
     (parse-error
       '<udatum>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          quasisyntax
          quote
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-structured)
  (case (next-token)
    ((bvecstart)
     (let ((ast1 (parse-bytevector))) (identity ast1)))
    ((vecstart)
     (let ((ast1 (parse-vector))) (identity ast1)))
    ((lparen
       lbracket
       quote
       backquote
       comma
       splicing
       syntax
       quasisyntax
       unsyntax
       unsyntaxsplicing)
     (let ((ast1 (parse-list))) (identity ast1)))
    (else
     (parse-error
       '<structured>
       '(backquote
          bvecstart
          comma
          lbracket
          lparen
          quasisyntax
          quote
          splicing
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-string)
  (case (next-token)
    ((string) (begin (consume-token!) (makeString)))
    (else (parse-error '<string> '(string)))))

(define (parse-symbol)
  (case (next-token)
    ((id) (begin (consume-token!) (makeSym)))
    (else (parse-error '<symbol> '(id)))))

(define (parse-list)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote)
     (let ((ast1 (parse-abbreviation)))
       (identity ast1)))
    ((lbracket)
     (begin
       (consume-token!)
       (let ((ast1 (parse-blst2))) (identity ast1))))
    ((lparen)
     (begin
       (consume-token!)
       (let ((ast1 (parse-list2))) (identity ast1))))
    (else
     (parse-error
       '<list>
       '(backquote
          comma
          lbracket
          lparen
          quasisyntax
          quote
          splicing
          syntax
          unsyntax
          unsyntaxsplicing)))))

(define (parse-list2)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart
       miscflag
       id
       string
       character
       number
       boolean
       sharingdef
       sharinguse)
     (let ((ast1 (parse-datum)))
       (let ((ast2 (parse-list3))) (cons ast1 ast2))))
    ((rparen) (begin (consume-token!) (emptyList)))
    (else
     (parse-error
       '<list2>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          quasisyntax
          quote
          rparen
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-list3)
  (case (next-token)
    ((rparen
       period
       sharinguse
       sharingdef
       boolean
       number
       character
       string
       id
       miscflag
       bvecstart
       vecstart
       lparen
       lbracket
       quote
       backquote
       comma
       splicing
       syntax
       quasisyntax
       unsyntax
       unsyntaxsplicing)
     (let ((ast1 (parse-data)))
       (let ((ast2 (parse-list4)))
         (pseudoAppend ast1 ast2))))
    (else
     (parse-error
       '<list3>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          period
          quasisyntax
          quote
          rparen
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-list4)
  (case (next-token)
    ((period)
     (begin
       (consume-token!)
       (let ((ast1 (parse-datum)))
         (if (eq? (next-token) 'rparen)
             (begin (consume-token!) (identity ast1))
             (parse-error '<list4> '(rparen))))))
    ((rparen) (begin (consume-token!) (emptyList)))
    (else (parse-error '<list4> '(period rparen)))))

(define (parse-blst2)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart
       miscflag
       id
       string
       character
       number
       boolean
       sharingdef
       sharinguse)
     (let ((ast1 (parse-datum)))
       (let ((ast2 (parse-blst3))) (cons ast1 ast2))))
    ((rbracket) (begin (consume-token!) (emptyList)))
    (else
     (parse-error
       '<blst2>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          quasisyntax
          quote
          rbracket
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-blst3)
  (case (next-token)
    ((rbracket
       period
       sharinguse
       sharingdef
       boolean
       number
       character
       string
       id
       miscflag
       bvecstart
       vecstart
       lparen
       lbracket
       quote
       backquote
       comma
       splicing
       syntax
       quasisyntax
       unsyntax
       unsyntaxsplicing)
     (let ((ast1 (parse-data)))
       (let ((ast2 (parse-blst4)))
         (pseudoAppend ast1 ast2))))
    (else
     (parse-error
       '<blst3>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          period
          quasisyntax
          quote
          rbracket
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-blst4)
  (case (next-token)
    ((period)
     (begin
       (consume-token!)
       (let ((ast1 (parse-datum)))
         (if (eq? (next-token) 'rbracket)
             (begin (consume-token!) (identity ast1))
             (parse-error '<blst4> '(rbracket))))))
    ((rbracket) (begin (consume-token!) (emptyList)))
    (else (parse-error '<blst4> '(period rbracket)))))

(define (parse-abbreviation)
  (case (next-token)
    ((quote backquote
            comma
            splicing
            syntax
            quasisyntax
            unsyntax
            unsyntaxsplicing)
     (let ((ast1 (parse-abbrev-prefix)))
       (let ((ast2 (parse-datum))) (list ast1 ast2))))
    (else
     (parse-error
       '<abbreviation>
       '(backquote
          comma
          quasisyntax
          quote
          splicing
          syntax
          unsyntax
          unsyntaxsplicing)))))

(define (parse-abbrev-prefix)
  (case (next-token)
    ((unsyntaxsplicing)
     (begin (consume-token!) (symUnsyntax-splicing)))
    ((unsyntax)
     (begin (consume-token!) (symUnsyntax)))
    ((quasisyntax)
     (begin (consume-token!) (symQuasisyntax)))
    ((syntax) (begin (consume-token!) (symSyntax)))
    ((splicing)
     (begin (consume-token!) (symSplicing)))
    ((comma) (begin (consume-token!) (symUnquote)))
    ((backquote)
     (begin (consume-token!) (symBackquote)))
    ((quote) (begin (consume-token!) (symQuote)))
    (else
     (parse-error
       '<abbrev-prefix>
       '(backquote
          comma
          quasisyntax
          quote
          splicing
          syntax
          unsyntax
          unsyntaxsplicing)))))

(define (parse-vector)
  (case (next-token)
    ((vecstart)
     (begin
       (consume-token!)
       (let ((ast1 (parse-data)))
         (if (eq? (next-token) 'rparen)
             (begin (consume-token!) (list2vector ast1))
             (parse-error '<vector> '(rparen))))))
    (else (parse-error '<vector> '(vecstart)))))

(define (parse-bytevector)
  (case (next-token)
    ((bvecstart)
     (begin
       (consume-token!)
       (let ((ast1 (parse-octets)))
         (if (eq? (next-token) 'rparen)
             (begin (consume-token!) (list2bytevector ast1))
             (parse-error '<bytevector> '(rparen))))))
    (else (parse-error '<bytevector> '(bvecstart)))))

(define (parse-data)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart
       miscflag
       id
       string
       character
       number
       boolean
       sharingdef
       sharinguse)
     (let ((ast1 (parse-datum)))
       (let ((ast2 (parse-data))) (cons ast1 ast2))))
    ((rparen period rbracket) (emptyList))
    (else
     (parse-error
       '<data>
       '(backquote
          boolean
          bvecstart
          character
          comma
          id
          lbracket
          lparen
          miscflag
          number
          period
          quasisyntax
          quote
          rbracket
          rparen
          sharingdef
          sharinguse
          splicing
          string
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-octets)
  (case (next-token)
    ((number)
     (let ((ast1 (parse-octet)))
       (let ((ast2 (parse-octets))) (cons ast1 ast2))))
    ((rparen) (emptyList))
    (else (parse-error '<octets> '(number rparen)))))

(define (parse-octet)
  (case (next-token)
    ((number) (begin (consume-token!) (makeOctet)))
    (else (parse-error '<octet> '(number)))))

(define (parse-location)
  (case (next-token)
    ((unsyntaxsplicing
       unsyntax
       quasisyntax
       syntax
       splicing
       comma
       backquote
       quote
       lbracket
       lparen
       vecstart
       bvecstart)
     (sourceLocation))
    (else
     (parse-error
       '<location>
       '(backquote
          bvecstart
          comma
          lbracket
          lparen
          quasisyntax
          quote
          splicing
          syntax
          unsyntax
          unsyntaxsplicing
          vecstart)))))

(define (parse-sharingdef)
  (case (next-token)
    ((sharingdef)
     (begin (consume-token!) (sharingDef)))
    (else (parse-error '<sharingdef> '(sharingdef)))))

(define (parse-sharinguse)
  (case (next-token)
    ((sharinguse)
     (begin (consume-token!) (sharingUse)))
    (else (parse-error '<sharinguse> '(sharinguse)))))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; End of LL(1) parser generated by ParseGen.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Lexical analyzer.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    ; next-token and consume-token! are called by the parser.
  
    ; Returns the current token.
  
    (define (next-token)
      (if nextTokenIsReady
          kindOfNextToken
          (begin (set! string_accumulator_length 0)
                 (scanner0))))
  
    ; Consumes the current token.
  
    (define (consume-token!)
      (set! nextTokenIsReady #f))
  
    ; Called by the lexical analyzer's state machine.
  
    (define (scannerError msg)
      (define msgtxt
        (cond ((= msg errLongToken)
               "Amazingly long token")
              ((= msg errIncompleteToken)
               "Incomplete or illegal token")
              ((= msg errIllegalHexEscape)
               "Illegal hex escape")
              ((= msg errIllegalNamedChar)
               "Illegal character syntax")
              ((= msg errIllegalString)
               "Illegal string syntax")
              ((= msg errIllegalSymbol)
               "Illegal symbol syntax")
              ((= msg errSRFI38)
               "Illegal SRFI 38 syntax")
              ((= msg errNoDelimiter)
               "Missing delimiter")
              ((= msg errLexGenBug)
               "Bug in lexical analyzer (generated)")
              (else "Bug in lexical analyzer")))
      (let* ((c (scanChar))
             (next (if (char? c) (string c) ""))
             (msgtxt (string-append msgtxt
                                    ": "
                                    (substring string_accumulator
                                               0
                                               string_accumulator_length)
                                    next)))

        ; must avoid infinite loop on current input port

        (consumeChar)
        (error 'get-datum
               (string-append "Lexical Error: " msgtxt " ")
               input-port))
      (next-token))
  
    ; Accepts a token of the given kind, returning that kind.
    ;
    ; For some kinds of tokens, a value for the token must also
    ; be recorded in tokenValue.  Most of those tokens must be
    ; followed by a delimiter.
    ;
    ; Some magical tokens require special processing.
  
    (define (accept t)
      (case t

       ((comment)
        ; The token is #|, which starts a nested comment.
        (scan-nested-comment)
        (next-token))

       ((commentdatum)
        ; The token is #; so parse and ignore the next datum.
        (parse-datum)
        (next-token))

       ((id boolean number character string miscflag period
         sharingdef sharinguse)

        (set! tokenValue
              (substring string_accumulator
                         0 string_accumulator_length))

        (cond ((and (eq? t 'miscflag)
                    (string=? tokenValue "#!r6rs"))
               (next-token))

              ((or (delimiter? (scanChar))
                   (eq? t 'string)
                   (eq? t 'sharingdef)                                ; SRFI 38
                   (eq? t 'sharinguse))                               ; SRFI 38
               (set! kindOfNextToken t)
               (set! nextTokenIsReady #t)
               t)

              (else
               (scannerError errNoDelimiter))))

       (else
        (set! kindOfNextToken t)
        (set! nextTokenIsReady #t)
        t)))

    ; Having seen a #| token, scans and discards the entire comment.

    (define (scan-nested-comment)
      (define (loop depth)
        (let ((c (scanChar)))
          (cond ((= depth 0) #t)
                ((eof-object? c)
                 (scannerError errIncompleteToken))
                ((char=? c #\#)
                 (consumeChar)
                 (if (char=? (scanChar) #\|)
                     (begin (consumeChar) (loop (+ depth 1)))
                     (loop depth)))
                ((char=? c #\|)
                 (consumeChar)
                 (if (char=? (scanChar) #\#)
                     (begin (consumeChar) (loop (- depth 1)))
                     (loop depth)))
                (else
                 (consumeChar)
                 (loop depth)))))
      (loop 1))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Character i/o, so to speak.
    ; Uses the input-port as input.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    (define (scanChar)
      (peek-char input-port))

    ; Consumes the current character.  Returns unspecified values.
  
    (define (consumeChar)
      (if (< string_accumulator_length (string-length string_accumulator))
          (let ((c (read-char input-port)))
            (if (char? c)
                (begin
                 (string-set! string_accumulator
                              string_accumulator_length
                              c)
                 (set! string_accumulator_length
                       (+ string_accumulator_length 1)))))
          (begin (expand-accumulator) (consumeChar))))

    ; Doubles the size of string_accumulator while
    ; preserving its contents.

    (define (expand-accumulator)
      (let* ((n (string-length string_accumulator))
             (new (make-string (* 2 n))))
        (do ((i 0 (+ i 1)))
            ((= i n))
          (string-set! new i (string-ref string_accumulator i)))
        (set! string_accumulator new)))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Miscellaneous utility routines.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Determines whether its argument is a <delimiter>.

    (define (delimiter? c)
      (case c
       ((#\( #\) #\[ #\] #\" #\; #\#)
        #t)
       (else
        (or (not (char? c))
            (char-whitespace? c)))))         

    ; Given the integer parsed from a hex escape,
    ; returns the corresponding Unicode character.

    (define (checked-integer->char n)
      (if (or (< n #xd800)
              (<= #xe000 n #x10ffff))
          (integer->char n)
          (scannerError errIllegalHexEscape)))

    ; Given a string and the index at the beginning of nonempty
    ; sequence of hexadecimal characters followed by a semicolon,
    ; returns two values:
    ;     the numerical value of the hex characters
    ;     the index following the semicolon

    (define (hex-escape s i)
      (let ((n (string-length s)))
        (define (loop i val)
          (if (>= i n)
              (scannerError errIllegalHexEscape)
              (let ((c (string-ref s i)))
                (case c
                 ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
                  (loop (+ i 1)
                        (+ (* 16 val)
                           (- (char->integer c) (char->integer #\0)))))
                 ((#\a #\b #\c #\d #\e #\f)
                  (loop (+ i 1)
                        (+ (* 16 val)
                           10
                           (- (char->integer c) (char->integer #\a)))))
                 ((#\A #\B #\C #\D #\E #\F)
                  (loop (+ i 1)
                        (+ (* 16 val)
                           10
                           (- (char->integer c) (char->integer #\A)))))
                 ((#\;)
                  (values val (+ i 1)))
                 (else (scannerError errIllegalHexEscape))))))
        (loop i 0)))
  
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Action procedures called by the parser.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Hook for recording source locations.
    ; Called by some action routines.

    (define (record-source-location x loc) x)

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (define (emptyList) '())
  
    (define (identity x) x)

    (define (list2bytevector octets) (u8-list->bytevector octets))

    (define (list2vector vals) (list->vector vals))
  
    (define (makeBool)
      (let ((x (case (string-ref tokenValue 1)
                ((#\t #\T) #t)
                ((#\f #\F) #f)
                (else (scannerError errBug)))))
        (record-source-location x locationStart)))
  
    (define (makeChar)
      (let* ((n (string-length tokenValue))
             (x (cond ((= n 3)
                       (string-ref tokenValue 2))
                      ((char=? #\x (string-ref tokenValue 2))
                       (checked-integer->char
                        (string->number (substring tokenValue 3 n) 16)))
                      (else
                       (let* ((s (substring tokenValue 2 n))
                              (sym (string->symbol s)))
                         (case sym
                          ((nul)               #\nul)
                          ((alarm)             #\alarm)
                          ((backspace)         #\backspace)
                          ((tab)               #\tab)
                          ((linefeed newline)  #\linefeed)
                          ((vtab)              #\vtab)
                          ((page)              #\page)
                          ((return)            #\return)
                          ((esc)               #\esc)
                          ((space)             #\space)
                          ((delete)            #\delete)
                          (else
                           (scannerError errIllegalNamedChar))))))))
        (record-source-location x locationStart)))

    (define (makeEOF) (eof-object))

    (define (makeFlag)

      ; The draft R6RS allows implementation-specific extensions
      ; of the form #!..., which are processed here.
      ; Note that the #!r6rs flag is a comment, handled by accept,
      ; so that flag will never be seen here.

      (accept 'miscflag)
      (parse-error '<miscflag> '(miscflag)))
  
    (define (makeNum)
      (let ((x (string->number tokenValue)))
        (if x
            (record-source-location x locationStart)
            (begin (accept 'number)
                   (parse-error '<number> '(number))))))
  
    (define (makeOctet)
      (let ((n (string->number tokenValue)))
        (if (and (exact? n) (integer? n) (<= 0 n 255))
            (record-source-location n locationStart)
            (begin (accept 'octet)
                   (parse-error '<octet> '(octet))))))
  
    (define (makeString)

      ; Must strip off outer double quotes and deal with escapes.
      ;
      ; i is the next index into tokenValue
      ; n is the exclusive upper bound for i
      ; newstring is a string that might become the result
      ; j is the next index into newstring

      (define (loop i n newstring j)
        (if (>= i n)
            (if (= j (string-length newstring))
                newstring
                (substring newstring 0 j))
            (let ((c (string-ref tokenValue i)))
              (cond ((or (char=? c #\return)
                         (char=? c #\linefeed)
                         (char=? c char:nel)
                         (char=? c char:ls))
                     (string-set! newstring j #\linefeed)
                     (let* ((i+1 (+ i 1))
                            (i+1 (if (and (char=? c #\return)
                                          (< i+1 n))
                                     (let ((c2 (string-ref tokenValue i+1)))
                                       (if (or (char=? c2 #\linefeed)
                                               (char=? c2 char:nel))
                                           (+ i 2)
                                           i+1))
                                     i+1)))
                       (loop i+1 n newstring (+ j 1))))
                    ((char=? c #\\)
                     (if (< (+ i 1) n)
                         (let ((c2 (string-ref tokenValue (+ i 1))))
                           (case c2
                            ((#\a)
                             (string-set! newstring j #\alarm)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\b)
                             (string-set! newstring j #\backspace)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\t)
                             (string-set! newstring j #\tab)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\n)
                             (string-set! newstring j #\linefeed)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\v)
                             (string-set! newstring j #\vtab)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\f)
                             (string-set! newstring j #\page)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\r)
                             (string-set! newstring j #\return)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\" #\\)
                             (string-set! newstring j c2)
                             (loop (+ i 2) n newstring (+ j 1)))
                            ((#\x)
                             (call-with-values
                              (lambda () (hex-escape tokenValue (+ i 2)))
                              (lambda (sv i)
                                (string-set! newstring
                                             j
                                             (checked-integer->char sv))
                                (loop i n newstring (+ j 1)))))
                            (else
                             (ignore-escaped-line-ending (+ i 1)
                                                         n newstring j #f))))
                     (scannerError errIllegalString)))
                    (else
                     (string-set! newstring j c)
                     (loop (+ i 1) n newstring (+ j 1)))))))

      ; Ignores <intraline whitespace>* <line ending> <intraline whitespace>*
      ; after? is true iff the <line ending> has already been ignored.
      ; The other arguments are the same as for loop above.

      (define (ignore-escaped-line-ending i n newstring j after?)
        (cond ((< i n)
               (let ((c (string-ref tokenValue i)))
                 (cond ((or (char=? c #\tab)
                            (eq? 'Zs (char-general-category c)))
                        (ignore-escaped-line-ending (+ i 1)
                                                    n newstring j after?))
                       (after?
                        (loop i n newstring j))
                       ((or (char=? c #\return)
                            (char=? c #\linefeed)
                            (char=? c char:nel)
                            (char=? c char:ls))
                        (let* ((i+1 (+ i 1))
                               (i+1 (if (and (char=? c #\return)
                                             (< i+1 n))
                                        (let ((c2 (string-ref
                                                   tokenValue i+1)))
                                          (if (or (char=? c2 #\linefeed)
                                                  (char=? c2 char:nel))
                                              (+ i 2)
                                              i+1))
                                        i+1)))
                          (ignore-escaped-line-ending i+1 n newstring j #t)))
                       (else
                        (scannerError errIllegalString)))))
              (after?
               (loop i n newstring j))
              (else
               (scannerError errIllegalString))))

      (let* ((n (string-length tokenValue))
             (s (loop 1 (- n 1) (make-string (- n 2)) 0)))
        (record-source-location s locationStart)))

    (define (makeStructured loc0 x)
      (record-source-location x loc0))

    (define (makeSym)
      (let ((n (string-length tokenValue)))
        (define (return sym)
          sym)
        (define (loop i)
          (if (= i n)
              (return (string->symbol tokenValue))
              (let ((c (string-ref tokenValue i)))
                (cond ((or (char=? c #\\)
                           (char=? c #\#))
                       (slow-loop i
                                  (reverse
                                   (string->list (substring tokenValue 0 i)))))
                      (else
                       (loop (+ i 1)))))))
        (define (slow-loop i chars)
          (if (= i n)
              (return (string->symbol (list->string (reverse chars))))
              (let ((c (string-ref tokenValue i)))
                (cond ((char=? c #\\)
                       (cond ((and (< (+ i 1) n)
                                   (char=? (string-ref tokenValue (+ i 1))
                                           #\x))
                              (call-with-values
                               (lambda () (hex-escape tokenValue (+ i 2)))
                               (lambda (sv i)
                                 (slow-loop i
                                            (cons (checked-integer->char sv)
                                                  chars)))))
                             (else
                              (scannerError errIllegalSymbol))))
                      (else (slow-loop (+ i 1) (cons c chars)))))))
        (loop 0)))

    ; Like append, but allows the last argument to be a non-list.
  
    (define (pseudoAppend vals terminus)
      (if (null? vals)
          terminus
          (cons (car vals)
                (pseudoAppend (cdr vals) terminus))))

    ; Hook for associating source locations with tokens.

    (define (sourceLocation) 0)

    (define (symBackquote) 'quasiquote)
    (define (symQuasisyntax) 'quasisyntax)
    (define (symQuote) 'quote)
    (define (symSplicing) 'unquote-splicing)
    (define (symSyntax) 'syntax)
    (define (symUnquote) 'unquote)
    (define (symUnsyntax) 'unsyntax)
    (define (symUnsyntax-splicing) 'unsyntax-splicing)
  
    ; Action routines for SRFI 38.
    ;
    ; The shared-structures hashtable defines a mapping from
    ; indexes to fixup objects.
    ;
    ; A fixup object is a record with two mutable fields:
    ;     ready: #t if the object field is ready, else #f
    ;     value: if ready, the object that will replace the
    ;            fixup object during a post-pass

    (define (sharingDef)
      (let* ((index
              (string->number
               (substring tokenValue 1 (- (string-length tokenValue) 1))))
             (fixup (make-fixup-object index)))
        (if (not shared-structures)
            (set! shared-structures
                  (make-hashtable values =)))
        (hashtable-set! shared-structures index fixup)
        fixup))

    (define (sharingUse)
      (let* ((index
              (string->number
               (substring tokenValue 1 (- (string-length tokenValue) 1)))))
        (if (not shared-structures)
            (scannerError errSRFI38))
        (let ((fixup (hashtable-ref shared-structures index #f)))
          (if (not fixup)
              (scannerError errSRFI38))
          fixup)))

    (define (makeSharingDef fixup datum)
      (fixup-ready! fixup datum)
      datum)

    (define (makeSharingUse fixup)
      fixup)

    ;; After everything has been read, a second pass prepares
    ;; and then executes the side effects needed to recreate
    ;; the shared structure.

    (define (srfi38-postpass x)
      (let ((fixups '()))

        (define (add-fixup! fixup-object kind . rest)
          (if (fixup-ready? fixup-object)
              (set! fixups
                    (cons (cons (fixup-value fixup-object)
                                (cons kind rest))
                          fixups))
              (assertion-violation 'read-with-shared-structure
                                   "undefined index"
                                   (fixup-index fixup-object))))

        (define (postpass x)
          (cond ((pair? x)
                 (if (fixup-object? (car x))
                     (add-fixup! (car x) 'set-car! x)
                     (postpass (car x)))
                 (if (fixup-object? (cdr x))
                     (add-fixup! (cdr x) 'set-cdr! x)
                     (postpass (cdr x))))
                ((vector? x)
                 (do ((n (vector-length x))
                      (i 0 (+ i 1)))
                     ((= i n))
                   (let ((y (vector-ref x i)))
                     (if (fixup-object? y)
                         (add-fixup! y 'vector-set! x i)
                         (postpass y)))))
                (else #f)))

        (define (fixup! fixup)
          (let ((value (car fixup))
                (kind (cadr fixup))
                (container (caddr fixup))
                (rest (cdddr fixup)))
            (case kind
             ((set-car!)
              (set-car! container value))
             ((set-cdr!)
              (set-cdr! container value))
             ((vector-set!)
              (vector-set! container (car rest) value))
             (else
              (assert #f)))))

      (if shared-structures
          (begin (postpass x)
                 (for-each fixup! fixups)
                 (if (fixup-object? x)
                     (fixup-value x)
                     x))
          x)))


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; Error procedure called by the parser.
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    (define (parse-error nonterminal expected-terminals)
      (let* ((culprit (next-token))
             (culprit-as-string (symbol->string culprit))
             (culprit-as-string
              (if (memq culprit expected-terminals)
                  (string-append "illegal " culprit-as-string)
                  culprit-as-string))
             (msg (string-append
                   "Syntax error while parsing "
                   (symbol->string nonterminal)
                   (string #\newline)
                   "  Encountered "
                   culprit-as-string
                   " while expecting "
                   (case nonterminal
                    ((<datum> <outermost-datum> <data>)
                     "a datum")
                    (else
                     (string-append
                      (string #\newline)
                      "  "
                      (apply string-append
                             (map (lambda (terminal)
                                    (string-append " "
                                                   (symbol->string terminal)))
                                  expected-terminals)))))
                   (string #\newline))))
        (error 'get-datum msg input-port)))

    ; The list of tokens that can start a datum in R6RS mode.

    (define datum-starters
      '(backquote
        boolean
        bvecstart
        character
        comma
        id
        lbracket
        lparen
        miscflag
        number
        quasisyntax
        quote
        splicing
        string
        syntax
        unsyntax
        unsyntaxsplicing
        vecstart))
  
    (srfi38-postpass (parse-outermost-datum))))

  (define write/ss write-with-shared-structure)
  (define read/ss read-with-shared-structure)
)
