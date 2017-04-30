;;; "synchk.scm" Syntax Checking			-*-Scheme-*-
;;; Copyright (c) 1989-91 Massachusetts Institute of Technology
;;;
;;; This material was developed by the Scheme project at the
;;; Massachusetts Institute of Technology, Department of Electrical
;;; Engineering and Computer Science.  Permission to copy and modify
;;; this software, to redistribute either the original software or a
;;; modified version, and to use this software for any purpose is
;;; granted, subject to the following restrictions and understandings.
;;;
;;; 1. Any copy made of this software must include this copyright
;;; notice in full.
;;;
;;; 2. Users of this software agree to make their best efforts (a) to
;;; return to the MIT Scheme project any improvements or extensions
;;; that they make, so that these may be included in future releases;
;;; and (b) to inform MIT of noteworthy uses of this software.
;;;
;;; 3. All materials developed as a consequence of the use of this
;;; software shall duly acknowledge such use, in accordance with the
;;; usual standards of acknowledging credit in academic research.
;;;
;;; 4. MIT has made no warranty or representation that the operation
;;; of this software will be error-free, and MIT is under no
;;; obligation to provide any services, by way of maintenance, update,
;;; or otherwise.
;;;
;;; 5. In conjunction with products arising from the use of this
;;; material, there shall be no use of the name of the Massachusetts
;;; Institute of Technology nor of any adaptation thereof in any
;;; advertising, promotional, or sales literature without prior
;;; written consent from MIT in each case.

;;;; Syntax Checking
;;; written by Alan Bawden
;;; modified by Chris Hanson

(define (syntax-check pattern form)
  (if (not (syntax-match? (cdr pattern) (cdr form)))
      (syntax-error "ill-formed special form" form)))

(define (ill-formed-syntax form)
  (syntax-error "ill-formed special form" form))

(define (syntax-match? pattern object)
  (let ((match-error
	 (lambda ()
	   (impl-error "ill-formed pattern" pattern))))
    (cond ((symbol? pattern)
	   (case pattern
	     ((IDENTIFIER) (identifier? object))
	     ((DATUM EXPRESSION FORM) #t)
	     ((R4RS-BVL)
	      (let loop ((seen '()) (object object))
		(or (null? object)
		    (if (identifier? object)
			(not (memq object seen))
			(and (pair? object)
			     (identifier? (car object))
			     (not (memq (car object) seen))
			     (loop (cons (car object) seen) (cdr object)))))))
	     ((MIT-BVL) (lambda-list? object))
	     (else (match-error))))
	  ((pair? pattern)
	   (case (car pattern)
	     ((*)
	      (if (pair? (cdr pattern))
		  (let ((head (cadr pattern))
			(tail (cddr pattern)))
		    (let loop ((object object))
		      (or (and (pair? object)
			       (syntax-match? head (car object))
			       (loop (cdr object)))
			  (syntax-match? tail object))))
		  (match-error)))
	     ((+)
	      (if (pair? (cdr pattern))
		  (let ((head (cadr pattern))
			(tail (cddr pattern)))
		    (and (pair? object)
			 (syntax-match? head (car object))
			 (let loop ((object (cdr object)))
			   (or (and (pair? object)
				    (syntax-match? head (car object))
				    (loop (cdr object)))
			       (syntax-match? tail object)))))
		  (match-error)))
	     ((?)
	      (if (pair? (cdr pattern))
		  (or (and (pair? object)
			   (syntax-match? (cadr pattern) (car object))
			   (syntax-match? (cddr pattern) (cdr object)))
		      (syntax-match? (cddr pattern) object))
		  (match-error)))
	     ((QUOTE)
	      (if (and (pair? (cdr pattern))
		       (null? (cddr pattern)))
		  (eqv? (cadr pattern) object)
		  (match-error)))
	     (else
	      (and (pair? object)
		   (syntax-match? (car pattern) (car object))
		   (syntax-match? (cdr pattern) (cdr object))))))
	  (else
	   (eqv? pattern object)))))
