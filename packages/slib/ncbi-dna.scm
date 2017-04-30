;;;; "ncbi-dna.scm" Read and manipulate NCBI-format nucleotide sequences
;;; Copyright (C) 2003 Aubrey Jaffer
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

(require 'array)
(require 'scanf)
(require 'string-case)
(require 'string-search)
(require 'array-for-each)
(require 'multiarg-apply)
(require-if 'compiling 'printf)	;used by cDNA:report-base-count

;;@code{(require 'ncbi-dma)}
;;@ftindex ncbi-dma

(define (ncbi:read-DNA-line port)
  (define lst (scanf-read-list
	       " %d %[acgt] %[acgt] %[acgt] %[acgt] %[acgt] %[acgt]" port))
  (cond ((or (null? lst) (eof-object? lst)) #f)
	((not (eqv? 1 (modulo (car lst) 60)))
	 (slib:warn 'bad 'idx lst) #f)
	(else (apply string-append (cdr lst)))))

;;@body
;;Reads the NCBI-format DNA sequence following the word @samp{ORIGIN}
;;from @1.
(define (ncbi:read-DNA-sequence port)
  (find-string-from-port? "ORIGIN" port)
  (find-string-from-port? (string #\newline) port)
  (do ((lne (ncbi:read-DNA-line port) (ncbi:read-DNA-line port))
       (lns '() (cons lne lns)))
      ((not lne) (apply string-append (reverse lns)))))

;;@body
;;Reads the NCBI-format DNA sequence following the word @samp{ORIGIN}
;;from @1.
(define (ncbi:read-file file)
  (call-with-input-file file ncbi:read-DNA-sequence))

;;@body
;;Replaces @samp{T} with @samp{U} in @1
(define (mRNA<-cDNA str)
  (array-for-each
   (lambda (chr)
     (case chr
       ((#\a) #\a)
       ((#\t) #\u)
       ((#\c) #\c)
       ((#\g) #\g)
       ((#\A) #\A)
       ((#\T) #\U)
       ((#\C) #\C)
       ((#\G) #\G)
       (else chr)))
   str))

(define cDNA:codons
  '((TTT phe #\F) (TCT ser #\S) (TAT tyr #\Y) (TGT cys #\C)
    (TTC phe #\F) (TCC ser #\S) (TAC tyr #\Y) (TGC cys #\C)
    (TTA leu #\L) (TCA ser #\S) (TAA)         (TGA) ;stops
    (TTG leu #\L) (TCG ser #\S) (TAG)         (TGG trp #\W)
    (CTT leu #\L) (CCT pro #\P) (CAT his #\H) (CGT arg #\R)
    (CTC leu #\L) (CCC pro #\P) (CAC his #\H) (CGC arg #\R)
    (CTA leu #\L) (CCA pro #\P) (CAA gln #\Q) (CGA arg #\R)
    (CTG leu #\L) (CCG pro #\P) (CAG gln #\Q) (CGG arg #\R)
    (ATT ile #\I) (ACT thr #\T) (AAT asn #\N) (AGT ser #\S)
    (ATC ile #\I) (ACC thr #\T) (AAC asn #\N) (AGC ser #\S)
    (ATA ile #\I) (ACA thr #\T) (AAA lys #\K) (AGA arg #\R)
    (ATG met #\M) (ACG thr #\T) (AAG lys #\K) (AGG arg #\R)
    (GTT val #\V) (GCT ala #\A) (GAT asp #\D) (GGT gly #\G)
    (GTC val #\V) (GCC ala #\A) (GAC asp #\D) (GGC gly #\G)
    (GTA val #\V) (GCA ala #\A) (GAA glu #\E) (GGA gly #\G)
    (GTG val #\V) (GCG ala #\A) (GAG glu #\E) (GGG gly #\G)))

;;@body
;;Returns a list of three-letter symbol codons comprising the protein
;;sequence encoded by @1 starting with its first occurence of
;;@samp{atg}.
(define (codons<-cDNA cDNA)
  (define len (string-length cDNA))
  (define start #f)
  (set! start (substring-ci? "atg" cDNA))
  (if (not start) (slib:warn 'missed 'start))
  (let loop ((protein '(*N*))
	     (cdx (or start 0)))
    (if (<= len cdx) (slib:error 'reached 'end cdx))
    (let ((codon (string-ci->symbol (substring cDNA cdx (+ 3 cdx)))))
      (define asc (assq codon cDNA:codons))
      (cond ((not asc)
	     (slib:warn 'mystery 'codon codon)
	     (reverse (cons '*C* protein)))
	    ((null? (cdr asc)) (reverse (cons '*C* protein)))
	    (else (loop (cons codon protein) (+ 3 cdx)))))))

;;@body
;;Returns a list of three-letter symbols for the protein sequence
;;encoded by @1 starting with its first occurence of @samp{atg}.
(define (protein<-cDNA cDNA)
  (define len (string-length cDNA))
  (define start #f)
  (set! start (substring-ci? "atg" cDNA))
  (if (not start) (slib:warn 'missed 'start))
  (let loop ((protein '(*N*))
	     (cdx (or start 0)))
    (if (<= len cdx) (slib:error 'reached 'end cdx))
    (let ((codon (string-ci->symbol (substring cDNA cdx (+ 3 cdx)))))
      (define asc (assq codon cDNA:codons))
      (cond ((not asc)
	     (slib:warn 'mystery 'codon codon)
	     (reverse (cons '*C* protein)))
	    ((null? (cdr asc)) (reverse (cons '*C* protein)))
	    (else (loop (cons (cadr asc) protein) (+ 3 cdx)))))))

;;@body
;;Returns a string of one-letter amino acid codes for the protein
;;sequence encoded by @1 starting with its first occurence of
;;@samp{atg}.
(define (P<-cDNA cDNA)
  (define len (string-length cDNA))
  (define start #f)
  (set! start (substring-ci? "atg" cDNA))
  (if (not start) (slib:warn 'missed 'start))
  (let loop ((protein '())
	     (cdx (or start 0)))
    (if (<= len cdx) (slib:error 'reached 'end cdx))
    (let ((codon (string-ci->symbol (substring cDNA cdx (+ 3 cdx)))))
      (define asc (assq codon cDNA:codons))
      (cond ((not asc) (slib:error 'mystery 'codon codon))
	    ((null? (cdr asc)) (list->string (reverse protein)))
	    (else (loop (cons (caddr asc) protein) (+ 3 cdx)))))))

;;@
;;These cDNA count routines provide a means to check the nucleotide
;;sequence with the @samp{BASE COUNT} line preceding the sequence from
;;NCBI.

;;@body
;;Returns a list of counts of @samp{a}, @samp{c}, @samp{g}, and
;;@samp{t} occurrencing in @1.
(define (cDNA:base-count cDNA)
  (define cnt:a 0)
  (define cnt:c 0)
  (define cnt:g 0)
  (define cnt:t 0)
  (array-for-each (lambda (chr)
		    (case chr
		      ((#\a #\A) (set! cnt:a (+ 1 cnt:a)))
		      ((#\c #\C) (set! cnt:c (+ 1 cnt:c)))
		      ((#\g #\G) (set! cnt:g (+ 1 cnt:g)))
		      ((#\t #\T) (set! cnt:t (+ 1 cnt:t)))
		      (else (slib:error 'cDNA:base-count 'unknown 'base chr))))
		  cDNA)
  (list cnt:a cnt:c cnt:g cnt:t))

;;@body
;;Prints the counts of @samp{a}, @samp{c}, @samp{g}, and @samp{t}
;;occurrencing in @1.
(define (cDNA:report-base-count cDNA)
  (require 'printf)
  (apply printf "BASE COUNT   %6d a %6d c %6d g %6d t\\n"
	 (cDNA:base-count cDNA)))
