;;;; "differ.scm" O(NP) Sequence Comparison Algorithm.
;;; Copyright (C) 2001, 2002, 2003, 2004, 2007 Aubrey Jaffer
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

;;@noindent
;;@code{diff:edit-length} implements the algorithm:
;;
;;@ifinfo
;;@example
;;S. Wu, E. Myers, U. Manber, and W. Miller,
;;   "An O(NP) Sequence Comparison Algorithm,"
;;   Information Processing Letters 35, 6 (1990), 317-323.
;;   @url{http://www.cs.arizona.edu/people/gene/PAPERS/np_diff.ps}
;;@end example
;;@end ifinfo
;;@ifset html
;;S. Wu, <A HREF="http://www.cs.arizona.edu/people/gene/vita.html">
;;E. Myers,</A> U. Manber, and W. Miller,
;;<A HREF="http://www.cs.arizona.edu/people/gene/PAPERS/np_diff.ps">
;;"An O(NP) Sequence Comparison Algorithm"</A>,
;;Information Processing Letters 35, 6 (1990), 317-323.
;;@end ifset
;;
;;@noindent
;;The values returned by @code{diff:edit-length} can be used to gauge
;;the degree of match between two sequences.
;;
;;@noindent
;;@code{diff:edits} and @code{diff:longest-common-subsequence} combine
;;the algorithm with the divide-and-conquer method outlined in:
;;
;;@ifinfo
;;@example
;;E. Myers and W. Miller,
;;   "Optimal alignments in linear space",
;;   Computer Application in the Biosciences (CABIOS), 4(1):11-17, 1988.
;;   @url{http://www.cs.arizona.edu/people/gene/PAPERS/linear.ps}
;;@end example
;;@end ifinfo
;;@ifset html
;;<A HREF="http://www.cs.arizona.edu/people/gene/vita.html">
;;E. Myers,</A> and W. Miller,
;;<A HREF="http://www.cs.arizona.edu/people/gene/PAPERS/linear.ps">
;;"Optimal alignments in linear space"</A>,
;;Computer Application in the Biosciences (CABIOS), 4(1):11-17, 1988.
;;@end ifset
;;
;;@noindent
;;If the items being sequenced are text lines, then the computed
;;edit-list is equivalent to the output of the @dfn{diff} utility
;;program.  If the items being sequenced are words, then it is like the
;;lesser known @dfn{spiff} program.

(require 'array)

;;; p-lim is half the number of gratuitous edits for strings of given
;;; lengths.
;;; When passed #f CC, fp:compare returns edit-distance if successful;
;;; #f otherwise (p > p-lim).  When passed CC, fp:compare returns #f.
(define (fp:compare fp fpoff CC A M B N p-lim)
  (define Delta (- N M))
  ;;(if (negative? Delta) (slib:error 'fp:compare (fp:subarray A 0 M) '> (fp:subarray B 0 N)))
  ;;(set! compares (+ 1 compares))  ;(print 'fp:compare M N p-lim)
  (let loop ((p 0))
    (do ((k (- p) (+ 1 k)))
	((>= k Delta))
      (fp:run fp fpoff k A M B N CC p))
    (do ((k (+ Delta p) (+ -1 k)))
	((<= k Delta))
      (fp:run fp fpoff k A M B N CC p))
    (let ((fpval (fp:run fp fpoff Delta A M B N CC p)))
      ;; At this point, the cost to (fpval-Delta, fpval) is Delta + 2*p
      (cond ((and (not CC) (<= N fpval)) (+ Delta (* 2 p)))
	    ((and (not (negative? p-lim)) (>= p p-lim)) #f)
	    (else (loop (+ 1 p)))))))

;;; Traces runs of matches until they end; then set fp[k]=y.
;;; If CC is supplied, set each CC[y] = min(CC[y], cost) for run.
;;; Returns furthest y reached.
(define (fp:run fp fpoff k A M B N CC p)
  (define cost (+ k p p))
  (let snloop ((y (max (+ (array-ref fp (+ -1 k fpoff)) 1)
		       (array-ref fp (+ 1 k fpoff)))))
    (define x (- y k))
    (and CC (<= y N)
	 (let ((xcst (- M x)))
	   (cond ((negative? xcst))
		 (else (array-set! CC
				   (min (+ xcst cost) (array-ref CC y))
				   y)))))
    ;;(set! tick (+ 1 tick))
    (cond ((and (< x M) (< y N)
		(eqv? (array-ref A x) (array-ref B y)))
	   (snloop (+ 1 y)))
	  (else (array-set! fp y (+ fpoff k))
		y))))

;;; Check that only 1 and -1 steps between adjacent CC entries.
;;(define (fp:step-check A M B N CC)
;;  (do ((cdx (+ -1 N) (+ -1 cdx)))
;;      ((negative? cdx))
;;    (case (- (array-ref CC cdx) (array-ref CC (+ 1 cdx)))
;;      ((1 -1) #t)
;;      (else (cond ((> 30 (car (array-dimensions CC)))
;;		   (display "A: ") (print A)
;;		   (display "B: ") (print B)))
;;	    (slib:warn
;;	     "CC" (append (list (max 0 (+ -5 cdx)) ': (min (+ 1 N) (+ 5 cdx))
;;				'of)
;;			  (array-dimensions CC))
;;	     (fp:subarray CC (max 0 (+ -5 cdx)) (min (+ 1 N) (+ 5 cdx))))))))

;;; Correct cost jumps left by fp:compare [which visits only a few (x,y)].
;;(define (smooth-costs CC N)
;;  (do ((cdx (+ -1 N) (+ -1 cdx)))	; smooth from end
;;      ((negative? cdx))
;;    (array-set! CC (min (array-ref CC cdx) (+ 1 (array-ref CC (+ 1 cdx))))
;;		cdx))
;;  (do ((cdx 1 (+ 1 cdx)))		; smooth toward end
;;      ((> cdx N))
;;    (array-set! CC (min (array-ref CC cdx) (+ 1 (array-ref CC (+ -1 cdx))))
;;		cdx))
;;  CC)

(define (diff:mid-split N RR CC cost)
  ;; RR is not longer than CC.  So do for each element of RR.
  (let loop ((cdx (+ 1 (quotient N 2)))
	     (rdx (quotient N 2)))
    ;;(if (negative? rdx) (slib:error 'negative? 'rdx))
    (cond ((eqv? cost (+ (array-ref CC rdx) (array-ref RR (- N rdx)))) rdx)
	  ((eqv? cost (+ (array-ref CC cdx) (array-ref RR (- N cdx)))) cdx)
	  (else (loop (+ 1 cdx) (+ -1 rdx))))))

;;; Return 0-based shared array.
;;; Reverse RA if END < START.
(define (fp:subarray RA start end)
  (define n-len (abs (- end start)))
  (if (< end start)
      (make-shared-array RA (lambda (idx) (list (+ -1 (- start idx)))) n-len)
      (make-shared-array RA (lambda (idx) (list (+ start idx))) n-len)))

(define (fp:init! fp fpoff fill mindx maxdx)
  (define mlim (+ fpoff mindx))
  (do ((idx (+ fpoff maxdx) (+ -1 idx)))
      ((< idx mlim))
    (array-set! fp fill idx)))

;;; Split A[start-a..end-a] (shorter array) into smaller and smaller chunks.
;;; EDX is index into EDITS.
;;; EPO is insert/delete polarity (+1 or -1)
(define (diff:divide-and-conquer fp fpoff CCRR A start-a end-a B start-b end-b edits edx epo p-lim)
  (define mid-a (quotient (+ start-a end-a) 2))
  (define len-b (- end-b start-b))
  (define len-a (- end-a start-a))
  (let ((tcst (+ p-lim p-lim (- len-b len-a))))
    (define CC (fp:subarray CCRR 0 (+ len-b 1)))
    (define RR (fp:subarray CCRR (+ len-b 1) (* 2 (+ len-b 1))))
    (define M2 (- end-a mid-a))
    (define M1 (- mid-a start-a))
    (fp:init! CC 0 (+ len-a len-b) 0 len-b)
    (fp:init! fp fpoff -1 (- (+ 1 p-lim)) (+ 1 p-lim (- len-b M1)))
    (fp:compare fp fpoff CC
		(fp:subarray A start-a mid-a) M1
		(fp:subarray B start-b end-b) len-b
		(min p-lim len-a))
    (fp:init! RR 0 (+ len-a len-b) 0 len-b)
    (fp:init! fp fpoff -1 (- (+ 1 p-lim)) (+ 1 p-lim (- len-b M2)))
    (fp:compare fp fpoff RR
		(fp:subarray A end-a mid-a)   M2
		(fp:subarray B end-b start-b) len-b
		(min p-lim len-a))
    ;;(smooth-costs CC len-b) (smooth-costs RR len-b)
    (let ((b-splt (diff:mid-split len-b RR CC tcst)))
      (define est-c (array-ref CC b-splt))
      (define est-r (array-ref RR (- len-b b-splt)))
      ;;(display "A:     ") (array-for-each display (fp:subarray A start-a mid-a)) (display " + ") (array-for-each display (fp:subarray A mid-a end-a)) (newline)
      ;;(display "B:     ") (array-for-each display (fp:subarray B start-b end-b)) (newline)
      ;;(print 'cc cc) (print 'rr (fp:subarray RR (+ 1 len-b) 0))
      ;;(print (make-string (+ 12 (* 2 b-splt)) #\-) '^  (list b-splt))
      (check-cost! 'CC est-c
		  (diff2et fp fpoff CCRR
			   A start-a mid-a
			   B start-b (+ start-b b-splt)
			   edits edx epo
			   (quotient (- est-c (- b-splt (- mid-a start-a)))
				     2)))
      (check-cost! 'RR est-r
		  (diff2et fp fpoff CCRR
			   A mid-a end-a
			   B (+ start-b b-splt) end-b
			   edits (+ est-c edx) epo
			   (quotient (- est-r (- (- len-b b-splt)
						 (- end-a mid-a)))
				     2)))
      (+ est-c est-r))))

;;; Trim; then diff sub-arrays; either one longer.  Returns edit-length
(define (diff2et fp fpoff CCRR A start-a end-a B start-b end-b edits edx epo p-lim)
  ;;  (if (< (- end-a start-a) p-lim) (slib:warn 'diff2et 'len-a (- end-a start-a) 'len-b (- end-b start-b) 'p-lim p-lim))
  (do ((bdx (+ -1 end-b) (+ -1 bdx))
       (adx (+ -1 end-a) (+ -1 adx)))
      ((not (and (<= start-b bdx)
		 (<= start-a adx)
		 (eqv? (array-ref A adx) (array-ref B bdx))))
       (do ((bsx start-b (+ 1 bsx))
	    (asx start-a (+ 1 asx)))
	   ((not (and (< bsx bdx)
		      (< asx adx)
		      (eqv? (array-ref A asx) (array-ref B bsx))))
	    ;;(print 'trim-et (- asx start-a) '+ (- end-a adx))
	    (let ((delta (- (- bdx bsx) (- adx asx))))
	      (if (negative? delta)
		  (diff2ez fp fpoff CCRR B bsx (+ 1 bdx) A asx (+ 1 adx)
			   edits edx (- epo) (+ delta p-lim))
		  (diff2ez fp fpoff CCRR A asx (+ 1 adx) B bsx (+ 1 bdx)
			   edits edx epo p-lim))))
	 ;;(set! tick (+ 1 tick))
	 ))
    ;;(set! tick (+ 1 tick))
    ))

;;; Diff sub-arrays, A not longer than B.  Returns edit-length
(define (diff2ez fp fpoff CCRR A start-a end-a B start-b end-b edits edx epo p-lim)
  (define len-a (- end-a start-a))
  (define len-b (- end-b start-b))
  ;;(if (> len-a len-b) (slib:error 'diff2ez len-a '> len-b))
  (cond ((zero? p-lim)			; B inserts only
	 (if (= len-b len-a)
	     0				; A = B; no edits
	     (let loop ((adx start-a)
			(bdx start-b)
			(edx edx))
	       (cond ((>= bdx end-b) (- len-b len-a))
		     ((>= adx end-a)
		      (do ((idx bdx (+ 1 idx))
			   (edx edx (+ 1 edx)))
			  ((>= idx end-b) (- len-b len-a))
			(array-set! edits (* epo (+ 1 idx)) edx)))
		     ((eqv? (array-ref A adx) (array-ref B bdx))
		      ;;(set! tick (+ 1 tick))
		      (loop (+ 1 adx) (+ 1 bdx) edx))
		     (else (array-set! edits (* epo (+ 1 bdx)) edx)
			   ;;(set! tick (+ 1 tick))
			   (loop adx (+ 1 bdx) (+ 1 edx)))))))
	((<= len-a p-lim)		; delete all A; insert all B
	 ;;(if (< len-a p-lim) (slib:error 'diff2ez len-a len-b 'p-lim p-lim))
	 (do ((idx start-a (+ 1 idx))
	      (jdx start-b (+ 1 jdx)))
	     ((and (>= idx end-a) (>= jdx end-b)) (+ len-a len-b))
	   (cond ((< jdx end-b)
		  (array-set! edits (* epo (+ 1 jdx)) edx)
		  (set! edx (+ 1 edx))))
	   (cond ((< idx end-a)
		  (array-set! edits (* epo (- -1 idx)) edx)
		  (set! edx (+ 1 edx))))))
	(else (diff:divide-and-conquer
	       fp fpoff CCRR A start-a end-a B start-b end-b
	       edits edx epo p-lim))))

(define (check-cost! name est cost)
  (if (not (eqv? est cost))
      (slib:warn name "cost check failed" est '!= cost)))

;;;; Routines interfacing API layer to algorithms.

(define (diff:invert-edits! edits)
  (define cost (car (array-dimensions edits)))
  (do ((idx (+ -1 cost) (+ -1 idx)))
      ((negative? idx))
    (array-set! edits (- (array-ref edits idx)) idx)))

;;; len-a < len-b
(define (edits2lcs! lcs edits A)
  (define cost (car (array-dimensions edits)))
  (define len-a (car (array-dimensions A)))
  (let loop ((edx 0)
	     (sdx 0)
	     (adx 0))
    (let ((edit (if (< edx cost) (array-ref edits edx) 0)))
      (cond ((>= adx len-a))
	    ((positive? edit)
	     (loop (+ 1 edx) sdx adx))
	    ((zero? edit)
	     (array-set! lcs (array-ref A adx) sdx)
	     (loop edx (+ 1 sdx) (+ 1 adx)))
	    ((>= adx (- -1 edit))
	     (loop (+ 1 edx) sdx (+ 1 adx)))
	    (else
	     (array-set! lcs (array-ref A adx) sdx)
	     (loop edx (+ 1 sdx) (+ 1 adx)))))))

;; A not longer than B (M <= N)
(define (diff2edits! edits fp CCRR A B)
  (define N (car (array-dimensions B)))
  (define M (car (array-dimensions A)))
  (define est (car (array-dimensions edits)))
  (let ((p-lim (quotient (- est (- N M)) 2)))
    (check-cost! 'diff2edits!
		 est
		 (diff2et fp (+ 1 p-lim)
			  CCRR A 0 M B 0 N edits 0 1 p-lim))))

;; A not longer than B (M <= N)
(define (diff2editlen fp A B p-lim)
  (define N (car (array-dimensions B)))
  (define M (car (array-dimensions A)))
  (let ((maxdx (if (negative? p-lim) (+ 1 N) (+ 1 p-lim (- N M))))
	(mindx (if (negative? p-lim) (- (+ 1 M)) (- (+ 1 p-lim)))))
    (fp:init! fp (- mindx) -1 mindx maxdx)
    (fp:compare fp (- mindx) #f A M B N p-lim)))

;;;; API

;;@args array1 array2 p-lim
;;@args array1 array2
;;@1 and @2 are one-dimensional arrays.
;;
;;The non-negative integer @3, if provided, is maximum number of
;;deletions of the shorter sequence to allow.  @0 will return @code{#f}
;;if more deletions would be necessary.
;;
;;@0 returns a one-dimensional array of length @code{(quotient (- (+
;;len1 len2) (diff:edit-length @1 @2)) 2)} holding the longest sequence
;;common to both @var{array}s.
(define (diff:longest-common-subsequence A B . p-lim)
  (define M (car (array-dimensions A)))
  (define N (car (array-dimensions B)))
  (set! p-lim (if (null? p-lim) -1 (car p-lim)))
  (let ((edits (if (< N M)
		   (diff:edits B A p-lim)
		   (diff:edits A B p-lim))))
    (and edits
	 (let* ((cost (car (array-dimensions edits)))
		(lcs (make-array A (/ (- (+ N M) cost) 2))))
	   (edits2lcs! lcs edits (if (< N M) B A))
	   lcs))))

;;@args array1 array2 p-lim
;;@args array1 array2
;;@1 and @2 are one-dimensional arrays.
;;
;;The non-negative integer @3, if provided, is maximum number of
;;deletions of the shorter sequence to allow.  @0 will return @code{#f}
;;if more deletions would be necessary.
;;
;;@0 returns a vector of length @code{(diff:edit-length @1 @2)} composed
;;of a shortest sequence of edits transformaing @1 to @2.
;;
;;Each edit is an integer:
;;@table @asis
;;@item @var{k} > 0
;;Inserts @code{(array-ref @1 (+ -1 @var{j}))} into the sequence.
;;@item @var{k} < 0
;;Deletes @code{(array-ref @2 (- -1 @var{k}))} from the sequence.
;;@end table
(define (diff:edits A B . p-lim)
  (define M (car (array-dimensions A)))
  (define N (car (array-dimensions B)))
  (define est (diff:edit-length A B (if (null? p-lim) -1 (car p-lim))))
  (and est
       (let ((CCRR (make-array (A:fixZ32b) (* 2 (+ (max M N) 1))))
	     (edits (make-array (A:fixZ32b) est)))
	 (define fp (make-array (A:fixZ32b)
				(+ (max (- N (quotient M 2))
					(- M (quotient N 2)))
				   (- est (abs (- N M))) ; 2 * p-lim
				   3)))
	 (cond ((< N M)
		(diff2edits! edits fp CCRR B A)
		(diff:invert-edits! edits))
	       (else
		(diff2edits! edits fp CCRR A B)))
	 ;;(diff:order-edits! edits est)
	 edits)))

;;@args array1 array2 p-lim
;;@args array1 array2
;;@1 and @2 are one-dimensional arrays.
;;
;;The non-negative integer @3, if provided, is maximum number of
;;deletions of the shorter sequence to allow.  @0 will return @code{#f}
;;if more deletions would be necessary.
;;
;;@0 returns the length of the shortest sequence of edits transformaing
;;@1 to @2.
(define (diff:edit-length A B . p-lim)
  (define M (car (array-dimensions A)))
  (define N (car (array-dimensions B)))
  (set! p-lim (if (null? p-lim) -1 (car p-lim)))
  (let ((fp (make-array (A:fixZ32b) (if (negative? p-lim)
					(+ 3 M N)
					(+ 3 (abs (- N M)) p-lim p-lim)))))
    (if (< N M)
	(diff2editlen fp B A p-lim)
	(diff2editlen fp A B p-lim))))

;;@example
;;(diff:longest-common-subsequence "fghiejcklm" "fgehijkpqrlm")
;;@result{} "fghijklm"
;;
;;(diff:edit-length "fghiejcklm" "fgehijkpqrlm")
;;@result{} 6
;;
;;(diff:edits "fghiejcklm" "fgehijkpqrlm")
;;@result{} #A:fixZ32b(3 -5 -7 8 9 10)
;;       ; e  c  h p q  r
;;@end example

;;(trace-all "/home/jaffer/slib/differ.scm")(set! *qp-width* 999)(untrace fp:run) ; fp:subarray
