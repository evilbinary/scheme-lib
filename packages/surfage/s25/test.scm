;;; array test
;;; 2001 Jussi Piitulainen

(define past
  (let ((stones '()))
    (lambda stone
      (if (null? stone)
          (reverse stones)
          (set! stones (cons (apply (lambda (stone) stone) stone) stones))))))

(define (tail n)
  (if (< n (length (past)))
      (list-tail (past) (- (length (past)) n))
      (past)))

;;; Simple tests

(or (and (shape)
         (shape -1 -1)
         (shape -1 0)
         (shape -1 1)
         (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8))
    (error "(shape ...) failed"))

(past "shape")

(or (and (make-array (shape))
         (make-array (shape) *)
         (make-array (shape -1 -1))
         (make-array (shape -1 -1) *)
         (make-array (shape -1 1))
         (make-array (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8 1 2 3 4) *))
    (error "(make-array (shape ...) [o]) failed"))

(past "make-array")

(or (and (array (shape) *)
         (array (shape -1 -1))
         (array (shape -1 1) * *)
         (array (shape 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8) *))
    (error "(array (shape ...) ...) failed"))

(past "array")

(or (and (= (array-rank (shape)) 2)
         (= (array-rank (shape -1 -1)) 2)
         (= (array-rank (shape -1 1)) 2)
         (= (array-rank (shape 1 2 3 4 5 6 7 8)) 2))
    (error "(array-rank (shape ...)) failed"))

(past "array-rank of shape")

(or (and (= (array-rank (make-array (shape))) 0)
         (= (array-rank (make-array (shape -1 -1))) 1)
         (= (array-rank (make-array (shape -1 1))) 1)
         (= (array-rank (make-array (shape 1 2 3 4 5 6 7 8))) 4))
    (error "(array-rank (make-array ...)) failed"))

(past "array-rank of make-array")

(or (and (= (array-rank (array (shape) *)) 0)
         (= (array-rank (array (shape -1 -1))) 1)
         (= (array-rank (array (shape -1 1) * *)) 1)
         (= (array-rank (array (shape 1 2 3 4 5 6 7 8) *)) 4))
    (error "(array-rank (array ...)) failed"))

(past "array-rank of array")

(or (and (= (array-start (shape -1 -1) 0) 0)
         (= (array-start (shape -1 -1) 1) 0)
         (= (array-start (shape -1 1) 0) 0)
         (= (array-start (shape -1 1) 1) 0)
         (= (array-start (shape 1 2 3 4 5 6 7 8) 0) 0)
         (= (array-start (shape 1 2 3 4 5 6 7 8) 1) 0))
    (error "(array-start (shape ...)) failed"))

(past "array-start of shape")

(or (and (= (array-end (shape -1 -1) 0) 1)
         (= (array-end (shape -1 -1) 1) 2)
         (= (array-end (shape -1 1) 0) 1)
         (= (array-end (shape -1 1) 1) 2)
         (= (array-end (shape 1 2 3 4 5 6 7 8) 0) 4)
         (= (array-end (shape 1 2 3 4 5 6 7 8) 1) 2))
    (error "(array-end (shape ...)) failed"))

(past "array-end of shape")

(or (and (= (array-start (make-array (shape -1 -1)) 0) -1)
         (= (array-start (make-array (shape -1 1)) 0) -1)
         (= (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 0) 1)
         (= (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 1) 3)
         (= (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 2) 5)
         (= (array-start (make-array (shape 1 2 3 4 5 6 7 8)) 3) 7))
    (error "(array-start (make-array ...)) failed"))

(past "array-start of make-array")

(or (and (= (array-end (make-array (shape -1 -1)) 0) -1)
         (= (array-end (make-array (shape -1 1)) 0) 1)
         (= (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 0) 2)
         (= (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 1) 4)
         (= (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 2) 6)
         (= (array-end (make-array (shape 1 2 3 4 5 6 7 8)) 3) 8))
    (error "(array-end (make-array ...)) failed"))

(past "array-end of make-array")

(or (and (= (array-start (array (shape -1 -1)) 0) -1)
         (= (array-start (array (shape -1 1) * *) 0) -1)
         (= (array-start (array (shape 1 2 3 4 5 6 7 8) *) 0) 1)
         (= (array-start (array (shape 1 2 3 4 5 6 7 8) *) 1) 3)
         (= (array-start (array (shape 1 2 3 4 5 6 7 8) *) 2) 5)
         (= (array-start (array (shape 1 2 3 4 5 6 7 8) *) 3) 7))
    (error "(array-start (array ...)) failed"))

(past "array-start of array")

(or (and (= (array-end (array (shape -1 -1)) 0) -1)
         (= (array-end (array (shape -1 1) * *) 0) 1)
         (= (array-end (array (shape 1 2 3 4 5 6 7 8) *) 0) 2)
         (= (array-end (array (shape 1 2 3 4 5 6 7 8) *) 1) 4)
         (= (array-end (array (shape 1 2 3 4 5 6 7 8) *) 2) 6)
         (= (array-end (array (shape 1 2 3 4 5 6 7 8) *) 3) 8))
    (error "(array-end (array ...)) failed"))

(past "array-end of array")

(or (and (eq? (array-ref (make-array (shape) 'a)) 'a)
         (eq? (array-ref (make-array (shape -1 1) 'b) -1) 'b)
         (eq? (array-ref (make-array (shape -1 1) 'c) 0) 'c)
         (eq? (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd) 1 3 5 7) 'd))
    (error "array-ref of make-array with arguments failed"))

(past "array-ref of make-array with arguments")

(or (and (eq? (array-ref (make-array (shape) 'a) '#()) 'a)
         (eq? (array-ref (make-array (shape -1 1) 'b) '#(-1)) 'b)
         (eq? (array-ref (make-array (shape -1 1) 'c) '#(0)) 'c)
         (eq? (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd)
                         '#(1 3 5 7))
              'd))
    (error "array-ref of make-array with vector failed"))

(past "array-ref of make-array with vector")

(or (and (eq? (array-ref (make-array (shape) 'a)
                         (array (shape 0 0)))
              'a)
         (eq? (array-ref (make-array (shape -1 1) 'b)
                         (array (shape 0 1) -1))
              'b)
         (eq? (array-ref (make-array (shape -1 1) 'c)
                         (array (shape 0 1) 0))
              'c)
         (eq? (array-ref (make-array (shape 1 2 3 4 5 6 7 8) 'd)
                         (array (shape 0 4) 1 3 5 7))
              'd))
    (error "(array-ref of make-array with array failed"))

(past "array-ref of make-array with array")

(or (and (let ((arr (make-array (shape) 'o)))
           (array-set! arr 'a)
           (eq? (array-ref arr) 'a))
         (let ((arr (make-array (shape -1 1) 'o)))
           (array-set! arr -1 'b)
           (array-set! arr 0 'c)
           (and (eq? (array-ref arr -1) 'b)
                (eq? (array-ref arr 0) 'c)))
         (let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
           (array-set! arr 1 3 5 7 'd)
           (eq? (array-ref arr 1 3 5 7) 'd)))
    (error "array-set! with arguments failed"))

(past "array-set! of make-array with arguments")

(or (and (let ((arr (make-array (shape) 'o)))
           (array-set! arr '#() 'a)
           (eq? (array-ref arr) 'a))
         (let ((arr (make-array (shape -1 1) 'o)))
           (array-set! arr '#(-1) 'b)
           (array-set! arr '#(0) 'c)
           (and (eq? (array-ref arr -1) 'b)
                (eq? (array-ref arr 0) 'c)))
         (let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
           (array-set! arr '#(1 3 5 7) 'd)
           (eq? (array-ref arr 1 3 5 7) 'd)))
    (error "array-set! with vector failed"))

(past "array-set! of make-array with vector")

(or (and (let ((arr (make-array (shape) 'o)))
           (array-set! arr 'a)
           (eq? (array-ref arr) 'a))
         (let ((arr (make-array (shape -1 1) 'o)))
           (array-set! arr (array (shape 0 1) -1) 'b)
           (array-set! arr (array (shape 0 1) 0) 'c)
           (and (eq? (array-ref arr -1) 'b)
                (eq? (array-ref arr 0) 'c)))
         (let ((arr (make-array (shape 1 2 3 4 5 6 7 8) 'o)))
           (array-set! arr (array (shape 0 4) 1 3 5 7) 'd)
           (eq? (array-ref arr 1 3 5 7) 'd)))
    (error "array-set! with arguments failed"))

(past "array-set! of make-array with array")

;;; Share and change:
;;;
;;;  org     brk     swp            box
;;;
;;;   0 1     1 2     5 6
;;; 6 a b   2 a b   3 d c   0 2 4 6 8: e
;;; 7 c d   3 e f   4 f e
;;; 8 e f

(or (let* ((org (array (shape 6 9 0 2) 'a 'b 'c 'd 'e 'f))
           (brk (share-array
                 org
                 (shape 2 4 1 3)
                 (lambda (r k)
                   (values
                    (+ 6 (* 2 (- r 2)))
                    (- k 1)))))
           (swp (share-array
                 org
                 (shape 3 5 5 7)
                 (lambda (r k)
                   (values
                    (+ 7 (- r 3))
                    (- 1 (- k 5))))))
           (box (share-array
                 swp
                 (shape 0 1 2 3 4 5 6 7 8 9)
                 (lambda _ (values 4 6))))
           (org-contents (lambda ()
                           (list (array-ref org 6 0) (array-ref org 6 1)
                                 (array-ref org 7 0) (array-ref org 7 1)
                                 (array-ref org 8 0) (array-ref org 8 1))))
           (brk-contents (lambda ()
                           (list (array-ref brk 2 1) (array-ref brk 2 2)
                                 (array-ref brk 3 1) (array-ref brk 3 2))))
           (swp-contents (lambda ()
                           (list (array-ref swp 3 5) (array-ref swp 3 6)
                                 (array-ref swp 4 5) (array-ref swp 4 6))))
           (box-contents (lambda ()
                           (list (array-ref box 0 2 4 6 8)))))
      (and (equal? (org-contents) '(a b c d e f))
           (equal? (brk-contents) '(a b e f))
           (equal? (swp-contents) '(d c f e))
           (equal? (box-contents) '(e))
           (begin (array-set! org 6 0 'x) #t)
           (equal? (org-contents) '(x b c d e f))
           (equal? (brk-contents) '(x b e f))
           (equal? (swp-contents) '(d c f e))
           (equal? (box-contents) '(e))
           (begin (array-set! brk 3 1 'y) #t)
           (equal? (org-contents) '(x b c d y f))
           (equal? (brk-contents) '(x b y f))
           (equal? (swp-contents) '(d c f y))
           (equal? (box-contents) '(y))
           (begin (array-set! swp 4 5 'z) #t)
           (equal? (org-contents) '(x b c d y z))
           (equal? (brk-contents) '(x b y z))
           (equal? (swp-contents) '(d c z y))
           (equal? (box-contents) '(y))
           (begin (array-set! box 0 2 4 6 8 'e) #t)
           (equal? (org-contents) '(x b c d e z))
           (equal? (brk-contents) '(x b e z))
           (equal? (swp-contents) '(d c z e))
           (equal? (box-contents) '(e))))
    (error "shared change failed"))

(past "shared change")

;;; Check that arrays copy the shape specification

(or (let ((shp (shape 10 12)))
      (let ((arr (make-array shp))
            (ars (array shp * *))
            (art (share-array (make-array shp) shp (lambda (k) k))))
        (array-set! shp 0 0 '?)
        (array-set! shp 0 1 '!)
        (and (= (array-rank shp) 2)
             (= (array-start shp 0) 0)
             (= (array-end shp 0) 1)
             (= (array-start shp 1) 0)
             (= (array-end shp 1) 2)
             (eq? (array-ref shp 0 0) '?)
             (eq? (array-ref shp 0 1) '!)
             (= (array-rank arr) 1)
             (= (array-start arr 0) 10)
             (= (array-end arr 0) 12)
             (= (array-rank ars) 1)
             (= (array-start ars 0) 10)
             (= (array-end ars 0) 12)
             (= (array-rank art) 1)
             (= (array-start art 0) 10)
             (= (array-end art 0) 12))))
    (error "array-set! of shape failed"))

(past "array-set! of shape")

;;; Check that index arrays work even when they share
;;;
;;; arr       ixn
;;;   5  6      0 1
;;; 4 nw ne   0 4 6
;;; 5 sw se   1 5 4

(or (let ((arr (array (shape 4 6 5 7) 'nw 'ne 'sw 'se))
          (ixn (array (shape 0 2 0 2) 4 6 5 4)))
      (let ((col0 (share-array
                   ixn
                   (shape 0 2)
                   (lambda (k)
                     (values k 0))))
            (row0 (share-array
                   ixn
                   (shape 0 2)
                   (lambda (k)
                     (values 0 k))))
            (wor1 (share-array
                   ixn
                   (shape 0 2)
                   (lambda (k)
                     (values 1 (- 1 k)))))
            (cod (share-array
                  ixn
                  (shape 0 2)
                  (lambda (k)
                    (case k
                      ((0) (values 1 0))
                      ((1) (values 0 1))))))
            (box (share-array
                  ixn
                  (shape 0 2)
                  (lambda (k)
                    (values 1 0)))))
        (and (eq? (array-ref arr col0) 'nw)
             (eq? (array-ref arr row0) 'ne)
             (eq? (array-ref arr wor1) 'nw)
             (eq? (array-ref arr cod) 'se)
             (eq? (array-ref arr box) 'sw)
             (begin
               (array-set! arr col0 'ul)
               (array-set! arr row0 'ur)
               (array-set! arr cod 'lr)
               (array-set! arr box 'll)
               #t)
             (eq? (array-ref arr 4 5) 'ul)
             (eq? (array-ref arr 4 6) 'ur)
             (eq? (array-ref arr 5 5) 'll)
             (eq? (array-ref arr 5 6) 'lr)
             (begin
               (array-set! arr wor1 'xx)
               (eq? (array-ref arr 4 5) 'xx)))))
    (error "array access with sharing index array failed"))

(past "array access with sharing index array")

;;; Check that shape arrays work even when they share
;;;
;;; arr             shp       shq       shr       shs
;;;    1  2  3  4      0  1      0  1      0  1      0  1 
;;; 1 10 12 16 20   0 10 12   0 12 20   0 10 10   0 12 12
;;; 2 10 11 12 13   1 10 11   1 11 13   1 11 12   1 12 12
;;;                                     2 12 16
;;;                                     3 13 20

(or (let ((arr (array (shape 1 3 1 5) 10 12 16 20 10 11 12 13)))
      (let ((shp (share-array
                  arr
                  (shape 0 2 0 2)
                  (lambda (r k)
                    (values (+ r 1) (+ k 1)))))
            (shq (share-array
                  arr
                  (shape 0 2 0 2)
                  (lambda (r k)
                    (values (+ r 1) (* 2 (+ 1 k))))))
            (shr (share-array
                  arr
                  (shape 0 4 0 2)
                  (lambda (r k)
                    (values (- 2 k) (+ r 1)))))
            (shs (share-array
                  arr
                  (shape 0 2 0 2)
                  (lambda (r k)
                    (values 2 3)))))
        (and (let ((arr-p (make-array shp)))
               (and (= (array-rank arr-p) 2)
                    (= (array-start arr-p 0) 10)
                    (= (array-end arr-p 0) 12)
                    (= (array-start arr-p 1) 10)
                    (= (array-end arr-p 1) 11)))
             (let ((arr-q (array shq * * * *  * * * *  * * * *  * * * *)))
               (and (= (array-rank arr-q) 2)
                    (= (array-start arr-q 0) 12)
                    (= (array-end arr-q 0) 20)
                    (= (array-start arr-q 1) 11)
                    (= (array-end arr-q 1) 13)))
             (let ((arr-r (share-array
                           (array (shape) *)
                           shr
                           (lambda _ (values)))))
               (and (= (array-rank arr-r) 4)
                    (= (array-start arr-r 0) 10)
                    (= (array-end arr-r 0) 10)
                    (= (array-start arr-r 1) 11)
                    (= (array-end arr-r 1) 12)
                    (= (array-start arr-r 2) 12)
                    (= (array-end arr-r 2) 16)
                    (= (array-start arr-r 3) 13)
                    (= (array-end arr-r 3) 20)))
             (let ((arr-s (make-array shs)))
               (and (= (array-rank arr-s) 2)
                    (= (array-start arr-s 0) 12)
                    (= (array-end arr-s 0) 12)
                    (= (array-start arr-s 1) 12)
                    (= (array-end arr-s 1) 12))))))
    (error "sharing shape array failed"))

(past "sharing shape array")

(let ((super (array (shape 4 7 4 7)
                    1 * *
                    * 2 *
                    * * 3))
      (subshape (share-array
                 (array (shape 0 2 0 3)
                        * 4 *
                        * 7 *)
                 (shape 0 1 0 2)
                 (lambda (r k)
                   (values k 1)))))
  (let ((sub (share-array super subshape (lambda (k) (values k k)))))
    ;(array-equal? subshape (shape 4 7))
    (or (and (= (array-rank subshape) 2)
             (= (array-start subshape 0) 0)
             (= (array-end subshape 0) 1)
             (= (array-start subshape 1) 0)
             (= (array-end subshape 1) 2)
             (= (array-ref subshape 0 0) 4)
             (= (array-ref subshape 0 1) 7))
        (error "sharing subshape failed"))
    ;(array-equal? sub (array (shape 4 7) 1 2 3))
    (or (and (= (array-rank sub) 1)
             (= (array-start sub 0) 4)
             (= (array-end sub 0) 7)
             (= (array-ref sub 4) 1)
             (= (array-ref sub 5) 2)
             (= (array-ref sub 6) 3))
        (error "sharing with sharing subshape failed"))))

(past "sharing with sharing subshape")
