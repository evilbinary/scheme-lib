;;; "minimize.scm" finds minimum f(x) for x0 <= x <= x1.
;;; Author: Lars Arvestad
;;;
;;; This code is in the public domain.

;;@noindent
;;
;;The Golden Section Search
;;@footnote{David Kahaner, Cleve Moler, and Stephen Nash
;;@cite{Numerical Methods and Software}
;;Prentice-Hall, 1989, ISBN 0-13-627258-4}
;;algorithm finds minima of functions which
;;are expensive to compute or for which derivatives are not available.
;;Although optimum for the general case, convergence is slow,
;;requiring nearly 100 iterations for the example (x^3-2x-5).
;;
;;@noindent
;;
;;If the derivative is available, Newton-Raphson is probably a better
;;choice.  If the function is inexpensive to compute, consider
;;approximating the derivative.

;;@body
;;
;;@var{x_0} are @var{x_1} real numbers.  The (single argument)
;;procedure @var{f} is unimodal over the open interval (@var{x_0},
;;@var{x_1}).  That is, there is exactly one point in the interval for
;;which the derivative of @var{f} is zero.
;;
;;@0 returns a pair (@var{x} . @var{f}(@var{x})) where @var{f}(@var{x})
;;is the minimum.  The @var{prec} parameter is the stop criterion.  If
;;@var{prec} is a positive number, then the iteration continues until
;;@var{x} is within @var{prec} from the true value.  If @var{prec} is
;;a negative integer, then the procedure will iterate @var{-prec}
;;times or until convergence.  If @var{prec} is a procedure of seven
;;arguments, @var{x0}, @var{x1}, @var{a}, @var{b}, @var{fa}, @var{fb},
;;and @var{count}, then the iterations will stop when the procedure
;;returns @code{#t}.
;;
;;Analytically, the minimum of x^3-2x-5 is 0.816497.
;;@example
;;(define func (lambda (x) (+ (* x (+ (* x x) -2)) -5)))
;;(golden-section-search func 0 1 (/ 10000))
;;      ==> (816.4883855245578e-3 . -6.0886621077391165)
;;(golden-section-search func 0 1 -5)
;;      ==> (819.6601125010515e-3 . -6.088637561916407)
;;(golden-section-search func 0 1
;;                       (lambda (a b c d e f g ) (= g 500)))
;;      ==> (816.4965933140557e-3 . -6.088662107903635)
;;@end example
(define golden-section-search
  (let ((gss 'golden-section-search:)
	(r (/ (- (sqrt 5) 1) 2)))	; 1 / golden-section
    (lambda (f x0 x1 prec)
      (cond ((not (procedure? f)) (slib:error gss 'procedure? f))
	    ((not (number? x0)) (slib:error gss 'number? x0))
	    ((not (number? x1)) (slib:error gss 'number? x1))
	    ((>= x0 x1) (slib:error gss x0 'not '< x1)))
      (let ((stop?
	     (cond
	      ((procedure? prec) prec)
	      ((number? prec)
	       (if (>= prec 0)
		   (lambda (x0 x1 a b fa fb count) (<= (abs (- x1 x0)) prec))
		   (if (integer? prec)
		       (lambda (x0 x1 a b fa fb count) (>= count (- prec)))
		       (slib:error gss 'integer? prec))))
	      (else (slib:error gss 'procedure? prec))))
	    (a0 (+ x0 (* (- x1 x0) (- 1 r))))
	    (b0 (+ x0 (* (- x1 x0) r)))
	    (delta #f)
	    (fmax #f)
	    (fmin #f))
	(let loop ((left x0)
		   (right x1)
		   (a a0)
		   (b b0)
		   (fa (f a0))
		   (fb (f b0))
		   (count 1))
	  (define finish
	    (lambda (x fx)
	      (if (> fx fmin) (slib:warn gss fx 'not 'min (list '> fmin)))
	      (if (and (> count 9) (or (eqv? x0 left) (eqv? x1 right)))
		  (slib:warn gss 'min 'not 'found))
	      (cons x fx)))
	  (case count
	    ((1)
	     (set! fmax (max fa fb))
	     (set! fmin (min fa fb)))
	    ((2)
	     (set! fmin (min fmin fa fb))
	     (if (= fmax fa fb) (slib:error gss 'flat? fmax)))
	    (else
	     (set! fmin (min fmin fa fb))))
	  (cond ((stop? left right a b fa fb count)
		 (if (< fa fb)
		     (finish a fa)
		     (finish b fb)))
		((< fa fb)
		 (let ((a-next (+ left (* (- b left) (- 1 r)))))
		   (cond ((and delta (< delta (- b a)))
			  (finish a fa))
			 (else (set! delta (- b a))
			       (loop left b a-next a (f a-next) fa
				     (+ 1 count))))))
		(else
		 (let ((b-next (+ a (* (- right a) r))))
		   (cond ((and delta (< delta (- b a)))
			  (finish b fb))
			 (else (set! delta (- b a))
			       (loop a right b b-next fb (f b-next)
				     (+ 1 count))))))))))))
