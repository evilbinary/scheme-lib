;;; An identity matrix.

(define i_4
  (let* ((i (make-array
             (shape 0 4 0 4)
             0))
         (d (share-array i
                         (shape 0 4)
                         (lambda (k)
                           (values k k)))))
    (do   ((k 0 (+ k 1))) ((= k 4))
      (array-set! d k 1))
    i))

(past "i_4")

(or (array-equal? i_4
                  (tabulate-array
                   (shape 0 4 0 4)
                   (lambda (j k)
                     (if (= j k) 1 0))))
    (error "failed to build i_4"))

(past "i_4 vs tabulate-array")

(or (array-equal? i_4
                  (array
                   (shape 0 4 0 4)
                   1 0 0 0
                   0 1 0 0 
                   0 0 1 0
                   0 0 0 1))
    (error "failed to array i_4"))

(past "i_4 vs array")

(or (array-equal? (share-array
                   i_4
                   (shape 0 4)
                   (lambda (k)
                     (values k k)))
                  (share-array
                   (array (shape) 1)
                   (shape 0 4)
                   (lambda (k)
                     (values))))
    (error "failed to share diagonal of i_4 or cell of 1"))

(past "i_4 diagonal")

(or (array-equal? (share-array
                   i_4
                   (shape 0 4)
                   (lambda (k)
                     (values (- 3 k) k)))
                  (share-array
                   (array (shape) 0)
                   (shape 0 4)
                   (lambda (k)
                     (values))))
    (error "failed to share codiagonal of i_4 or cell of 0"))

(past "i_4 codiagonal")

(or (array-equal? (share-array
                   i_4
                   (shape 0 2 0 2)
                   (lambda (j k)
                     (values (* 3 j) (* 3 k))))
                  (share-array
                   i_4
                   (shape 0 2 0 2)
                   (lambda (j k)
                     (values (+ j 1) (+ k 1)))))
    (error "failed to share corners or center of i_4"))

(past "i_4 corners and center")

(or (array-equal? i_4 (transpose i_4))
    (error "failed to transpose i_4"))

(past "i_4 transpose")

;;; Try a three dimensional transpose. This will also exercise matrix
;;; multiplication.

(define threed123
  (array (shape 0 1 0 2 0 3)
         'a 'b 'c
         'd 'e 'f))

(past "threed123")

(define threed312
  (array (shape 0 3 0 1 0 2)
         'a 'd
         'b 'e
         'c 'f))

(past "threed312")

(define rot231 (list 1 2 0))
  ;; 0 1 0
  ;; 0 0 1
  ;; 1 0 0

(or (array-equal? threed123
                  (apply transpose threed312 rot231))
    (error "failed to transpose three dimensions"))

(past "threed123 transpose")

;;; The frivolous board game exercises share of share of share.

;;; A three dimensional chess board with two phases: piece and colour
;;; of piece. Think of pieces in a cube with height, width and depth,
;;; and piece colours in a parallel cube. We put pink jays around and
;;; grey crows inside the board proper. Later we put in a blue rook.

(define board
  (tabulate-array
   (shape -1 9 -1 9 -1 9 0 2)
   (lambda (t u v w)
     (case w
       ((0) (if (and (< -1 u 8)
                     (< -1 v 8)
                     (< -1 t 8))
                'crow
                'jay))
       ((1) (if (and (< -1 u 8)
                     (< -1 v 8)
                     (< -1 t 8))
                'grey
                'pink))))))

(past "board")

;;; A cylinder with height 4, width 4, depth 6, both phases, centered
;;; inside the board. Top left front corner is at 0 0 0 of cylinder but
;;; 2 2 1 of board.

(define board-cylinder
  (share-array
   board
   (shape 0 4 0 4 0 6 0 2)
   (lambda (t u v w)
     (values (+ t 2) (+ u 2) (+ v 1) w))))

(past "board-cylinder")

;;; The center cube with side 2 of the cylinder, hence of the board,
;;; with both phases. Top left corner is 0 0 0 of center but 1 1 2
;;; of cylinder and 3 3 3 of board.

(define board-center
  (share-array
   board-cylinder
   (shape 0 2 0 2 0 2 0 2)
   (lambda (t u v w)
     (values (+ t 1) (+ u 1) (+ v 2) w))))

(past "board-center")

;;; Front face of center cube, in two dimensions plus phase. Top left
;;; corner is 0 0 of face but 0 0 0 of center and 1 1 2 of cylinder
;;; 3 3 3 of board.

(define board-face
  (share-array
   board-center
   (shape 0 2 0 2 0 2)
   (lambda (t u w)
     (values t u 0 w))))

(past "board-face")

;;; Left side of face in three dimensions plus phase. Top is 0 0 0 of
;;; pillar but 0 0 of face and 0 0 0 of center and 1 1 2 of cylinder
;;; and 3 3 3 of board. Bottom is 1 0 0 of pillar but 1 0 of face and
;;; 1 0 0 of center and 2 1 2 of cylinder and 4 3 3 of board.

(define board-pillar
  (share-array
   board-face
   (shape 0 2 0 1 0 1 0 2)
   (lambda (t u v w)
     (values t 0 w))))

(past "board-pillar")

;;; Pillar upside down. Now top 0 0 0 is 1 0 of face and 1 0 0 of center
;;; and 2 1 2 of cylinder and 4 3 3 of board.

(define board-reverse-pillar
  (share-array
   board-pillar
   (shape 0 2 0 1 0 1 0 2)
   (lambda (t u v w)
     (values (- 1 t) u v w))))

(past "board-reverse-pillar")

;;; Bottom of pillar.

(define board-cubicle
  (share-array
   board-pillar
   (shape 0 2)
   (lambda (w)
     (values 1 0 0 w))))

(past "board-cubicle")

;;; Top of upside down pair.

(define board-reverse-cubicle
  (share-array
   board-reverse-pillar
   (shape 0 2)
   (lambda (w)
     (values 0 0 0 w))))

(past "board-reverse-cubicle")

;;; Piece phase of cubicle.

(define board-piece
  (share-array
   board-cubicle
   (shape)
   (lambda ()
     (values 0))))

(past "board-piece")

;;; Colour phase of the other cubicle that is actually the same cubicle.

(define board-colour
  (share-array
   board-reverse-cubicle
   (shape)
   (lambda ()
     (values 1))))

(past "board-colour")

;;; Put a blue rook at the bottom of the pillar and at the top of the
;;; upside pillar.

(array-set! board-piece 'rook)
(array-set! board-colour 'blue)

(past "array-set! to board-piece and board-colour")

;;; Build the same chess position directly.

(define board-two
  (tabulate-array
   (shape -1 9 -1 9 -1 9 0 2)
   (lambda (t u v w)
     (if (and (= t 4) (= u 3) (= v 3))
         (case w
           ((0) 'rook)
           ((1) 'blue))
         (case w
           ((0) (if (and (< -1 u 8)
                         (< -1 v 8)
                         (< -1 t 8))
                    'crow
                    'jay))
           ((1) (if (and (< -1 u 8)
                         (< -1 v 8)
                         (< -1 t 8))
                    'grey
                    'pink)))))))

(past "board-two")

(or (array-equal? board board-two)
    (error "failed in three dimensional chess"))

(past "board vs board-two")

;;; Permute the dimensions of the chess board in two different ways.
;;; The transpose also exercises matrix multiplication.

(define board-three
  (share-array
   board-two
   (shape 0 2 -1 9 -1 9 -1 9)
   (lambda (w t u v)
     (values t u v w))))

(past "board-three")

(or (array-equal? board-three
                  (transpose board-two 3 0 1 2))
                                    ;; 0 0 0 1
                                    ;; 1 0 0 0
                                    ;; 0 1 0 0
                                    ;; 0 0 1 0
    (error "failed to permute chess board dimensions"))

(past "board-three vs transpose of board-two")

(or (array-equal? (share-array
                   board-two
                   (shape -1 9 0 2 -1 9 -1 9)
                   (lambda (t w u v)
                     (values t u v w)))
                  (transpose board-two 0 3 1 2))
                                    ;; 1 0 0 0
                                    ;; 0 0 0 1
                                    ;; 0 1 0 0
                                    ;; 0 0 1 0
    (error "failed to permute chess board dimensions another way"))

(past "board-two versus transpose of board-two")

;;; Just see that empty share does not crash. No index is valid. Just by
;;; the way. There is nothing to be done with it.

(define board-nothing
  (share-array
   board
   (shape 0 3 1 1 0 3)
   (lambda (t u v)
     (values 0 0 0))))

(or (array-equal? board-nothing (array (array-shape board-nothing)))
    (error "board-nothing failed"))

(past "board-nothing")

;;; ---

(or (array-equal? (tabulate-array (shape 4 8 2 5 0 1) *)
                  (tabulate-array! (shape 4 8 2 5 0 1)
                                   (lambda (v)
                                     (* (vector-ref v 0)
                                        (vector-ref v 1)
                                        (vector-ref v 2)))
                                   (vector * * *)))
    (error "tabulate-array! with vector failed"))

(past "tabulate-array! with vector")

(or (array-equal? (tabulate-array (shape 4 8 2 5 0 1) *)
                  (let ((index (share-array (make-array (shape 0 2 0 3))
                                            (shape 0 3)
                                            (lambda (k) (values 1 k)))))
                    (tabulate-array! (shape 4 8 2 5 0 1)
                                     (lambda (a)
                                       (* (array-ref a 0)
                                          (array-ref a 1)
                                          (array-ref a 2)))
                                     index)))
    (error "tabulate-array! with array failed"))

(past "tabulate-array! with array")

;;; Sum of constants

(or (array-equal?
     (array-map
      +
      (share-array (array (shape) 0) (shape 1 2 1 4) (lambda _ (values)))
      (share-array (array (shape) 1) (shape 1 2 1 4) (lambda _ (values)))
      (share-array (array (shape) 2) (shape 1 2 1 4) (lambda _ (values))))
     (array (shape 1 2 1 4) 3 3 3))
    (error "failed to map constants to their constant sum"))

(past "array-map sum")

;;; Multiplication table

(define four-by-four
  (array (shape 0 4 0 4)
         0 0 0 0
         0 1 2 3
         0 2 4 6
         0 3 6 9))

(past "four-by-four")

(or (array-equal? four-by-four (tabulate-array (shape 0 4 0 4) *))
    (error "failed to tabulate four by four"))

(past "four-by-four vs tabulate-array")

(or (array-equal?
     four-by-four
     (let ((table (make-array (shape 0 4 0 4) 19101)))
       (array-retabulate! table (array-shape table) *)
       table))
    (error "failed to retabulate four by four simply"))

(past "four-by-four vs array-retabulate!")

(or (array-equal?
     four-by-four
     (let ((table (make-array (shape 0 4 0 4) 19101)))
       (array-retabulate!
        table
        (shape 1 2 1 4)
        (lambda (v)
          (* (vector-ref v 0) (vector-ref v 1)))
        (vector - -))
       (array-retabulate!
        table
        (shape 2 4 0 4)
        (lambda (a)
          (* (array-ref a (vector 0)) (array-ref a (vector 1))))
        (make-array (shape 0 2)))
       (array-set! table 0 0 0)
       (array-set! table (vector 0 1) 0)
       (array-set! table (array (shape 0 2) 0 2) 0)
       (shape-for-each
        (shape 0 1 3 4)
        (lambda (v)
          (array-set! table v (vector-ref v 0)))
        (vector - -))
       (let ((arr (share-array
                   table
                   (shape 1 2 0 1 1 2 3 4 5 6 7 8 1 2 3 4 5 6 7 8)
                   (lambda (r k . _)
                     (values r k)))))
         (array-retabulate! arr (array-shape arr) *))
       table))
    (error "failed to retabulate four by four in a hard way"))

(past "four-by-four vs array-retabulate! on parts")

;;; An argument was missing in a call in arlib when
;;; shape-for-each was called without an index object.

(or (let ((em '()))
      (shape-for-each
       (shape 0 2 -2 0 0 1)
       (lambda (u v w)
         (set! em (cons (list u v w) em))))
      (equal? (reverse em) '((0 -2 0) (0 -1 0) (1 -2 0) (1 -1 0))))
    (error "shape-for-each without index object"))

(past "shape-for-each without index object")
                                 

;;; Exercise share-array/index!

(or (let ((arr (tabulate-array (shape 2 4 3 5 4 7) *)))
      (array-equal? (share-array/index!
                     arr
                     (array-shape arr)
                     (lambda (v) v)
                     (vector * * *))
                    arr))
    (error "share-array/index! with identity and vector failed"))

(past "share-array/index! with identity and vector")

(or (let ((arr (tabulate-array (shape 2 4 3 5 4 7) *))
          (ind (share-array (make-array (shape 0 2 0 3))
                            (shape 0 3)
                            (lambda (k) (values 1 k)))))
      (array-equal? (share-array/index!
                     arr
                     (array-shape arr)
                     (lambda (a) a) ind)
                    arr))
    (error "share-array/index! with identity and array failed"))

(past "share-array/index! with identity and array")

(or (let ((arr (tabulate-array (shape 3 5 4 5 4 7) *))
          (in (vector * *))
          (out (array (shape 0 3) 4 * *)))
      (array-equal? (share-array/index!
                     arr
                     (shape 4 5 4 7)
                     (lambda (in)
                       (array-set! out 1 (vector-ref in 0))
                       (array-set! out 2 (vector-ref in 1))
                       out)
                     in)
                    (share-array
                     arr
                     (shape 4 5 4 7)
                     (lambda (j k)
                       (values 4 j k)))))
    (error "share-array/index! with vector in array out failed"))

(past "share-array/index! with vector in array out")

(or (let ((arr (tabulate-array (shape 3 5 4 5 4 7) *))
          (in (array (shape 0 2) * *))
          (out (vector 4 * *)))
      (array-equal? (share-array/index!
                     arr
                     (shape 4 5 4 7)
                     (lambda (in)
                       (vector-set! out 1 (array-ref in 0))
                       (vector-set! out 2 (array-ref in 1))
                       out)
                     in)
                    (share-array
                     arr
                     (shape 4 5 4 7)
                     (lambda (j k)
                       (values 4 j k)))))
    (error "share-array/index! with array in vector out failed"))

(past "share-array/index! with array in vector out")

(let ((x (array (shape 2 4  3 5  4 5  5 7  6 8)
                10 11 12 13
                20 21 22 23
                30 31 32 33
                40 41 42 43)))
  (or (array-equal? (share-array/origin x 3 3 3 3 3)
                    (array-append 0 (array (shape 3 3
                                                  3 5
                                                  3 4
                                                  3 5
                                                  3 5))
                                  x))
      (error "share-array/origin against empty array-append failed"))
  (or (array-equal? (share-array/origin x 3 3 3 3 3)
                    (array-append 3 (array (shape 3 5
                                                  3 5
                                                  3 4
                                                  3 3
                                                  3 5))
                                  x))
      (error "share-array/origin against empty array-append failed")))

(past "share-array/origin against empty array-append")

(let ((a* (make-array (shape 4 6 7 9 100 101) 'a))
      (b* (make-array (shape 3 6 7 8 200 201) 'b))
      (c* (make-array (shape 0 1 2 4 300 301) 'c)))
  (or (array-equal? (array-append 1 (array-append 0 a* c*) b* b* b*)
                    (apply array (shape 4 7 7 12 100 101)
                           '(a a b b b
                             a a b b b
                             c c b b b)))
      (error "array-append failed")))

(past "array-append")

(let ((a* (make-array (shape 4 6 7 9 100 101) 'a))
      (b* (make-array (shape 3 6 7 8 200 201) 'b))
      (c* (make-array (shape 0 1 2 4 300 301) 'c)))
  (or (array-equal? (array-append 1 a* (transpose c* 1 0 2)
                                  (array-append 0 (transpose b* 1 0 2)
                                                (transpose b* 1 0 2)))
                    (apply array (shape 4 6 7 13 100 101)
                           '(a a c b b b
                             a a c b b b)))
      (error "array-append with transpose failed")))

(past "array-append with transpose")

;;; Check that share-array/index! agrees with share-array.

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? m (share-array m (shape 1 3 1 3) values))
      (error "share-array identity failed"))
  (or (array-equal? m (share-array/index!
                       m (shape 1 3 1 3)
                       (lambda (x) x)
                       (vector * *)))
      (error "share-array/index! identity with vector failed"))
  (or (array-equal? m (share-array/index!
                       m (shape 1 3 1 3)
                       (lambda (x) x)
                       (make-array (shape 0 2))))
      (error "share-array/index! identity with actor failed")))

(past "share-array/index! identity")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 3)
                     (lambda (r)
                       (values r 1)))
                    (share-array/index!
                       m (shape 1 3)
                       (lambda (x)
                         (vector (vector-ref x 0) 1))
                       (vector *)))
      (error "share-array/index! 1-d column failed")))

(past "share-array/index! 1-d column")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 3 1 3)
                     (lambda (r k)
                       (values r 1)))
                    (share-array/index!
                       m (shape 1 3 1 3)
                       (lambda (x)
                         (vector (vector-ref x 0) 1))
                       (vector * *)))
      (error "share-array/index! 2-d column failed")))

(past "share-array/index! 2-d column")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 3)
                     (lambda (k)
                       (values 1 k)))
                    (share-array/index!
                       m (shape 1 3)
                       (lambda (x)
                         (vector 1 (vector-ref x 0)))
                       (vector *)))
      (error "share-array/index! 1-d row failed")))

(past "share-array/index! 1-d row")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 2 1 3)
                     (lambda (r k)
                       (values 1 k)))
                    (share-array/index!
                       m (shape 1 2 1 3)
                       (lambda (x)
                         (vector 1 (vector-ref x 1)))
                       (vector * *)))
      (error "share-array/index! 2-d row failed")))

(past "share-array/index! 2-d row")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 3)
                     (lambda (r)
                       (values r r)))
                    (share-array/index!
                       m (shape 1 3)
                       (lambda (x)
                         (vector (vector-ref x 0) (vector-ref x 0)))
                       (vector *)))
      (error "share-array/index! diagonal failed")))

(past "share-array/index! diagonal")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape)
                     (lambda ()
                       (values 1 2)))
                    (share-array/index!
                       m (shape)
                       (lambda (x)
                         (vector 1 2))
                       (vector)))
      (error "share-array/index! 0-d corner failed")))

(past "share-array/index! 0-d corner")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 2)
                     (lambda (_)
                       (values 1 2)))
                    (share-array/index!
                       m (shape 1 2)
                       (lambda (x)
                         (vector 1 2))
                       (vector *)))
      (error "share-array/index! 1-d corner failed")))

(past "share-array/index! 1-d corner")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array
                     m (shape 1 2 1 2)
                     (lambda (r k)
                       (values 1 2)))
                    (share-array/index!
                       m (shape 1 2 1 2)
                       (lambda (x)
                         (vector 1 2))
                       (vector * *)))
      (error "share-array/index! 2-d corner failed")))

(past "share-array/index! 2-d corner")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m 1)
                    (share-array/index!
                     m (shape 1 3)
                     (lambda (x)
                       (vector 1 (vector-ref x 0)))
                     (vector *)))
      (error "share-array/index! with prefix 1 failed")))

(past "share-array/{prefix,index!} 1")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m (vector 1))
                    (share-array/index!
                     m (shape 1 3)
                     (lambda (x)
                       (vector 1 (vector-ref x 0)))
                     (vector *)))
      (error "share-array/prefix with vector failed")))

(past "share-array/prefix with vector")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m 2)
                    (share-array/index!
                     m (shape 1 3)
                     (lambda (x)
                       (vector 2 (vector-ref x 0)))
                     (vector *)))
      (error "share-array/index! with prefix 2 failed")))

(past "share-array/{prefix,index!} 2")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m (array (shape 0 1) 2))
                    (share-array/index!
                     m (shape 1 3)
                     (lambda (x)
                       (vector 2 (vector-ref x 0)))
                     (vector *)))
      (error "share-array/prefix with array failed")))

(past "share-array/prefix with array")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m)
                    (share-array/index!
                     m (shape 1 3 1 3)
                     (lambda (x) x)
                     (vector * *)))
      (error "share-array/index! with empty prefix failed")))

(past "share-array/{prefix,index!} e")

(let ((m (array (shape 1 3 1 3) 'a 'b 'c 'd)))
  (or (array-equal? (share-array/prefix m 1 2)
                    (share-array/index!
                     m (shape)
                     (lambda (x)
                       (vector 1 2))
                     (vector)))
      (error "share-array/index! with prefix 1 2 failed")))

(past "share-array/{prefix,index!} 1 2")

;;; Uh oh.

(let* ((hape (tabulate-array
              (shape 0 57 0 2)
              (lambda (r k)
                (case k
                  ((0) r)
                  ((1) (case r
                         ((0)  (+ r 2))
                         ((56) (+ r 4))
                         (else (+ r 1))))))))
       (tape (tabulate-array
              (shape 0 34 0 2)
              (lambda (r k)
                (case k
                  ((0) (+ r 23))
                  ((1) (case r
                         ((33) (+ r 27))
                         (else (+ r 24))))))))
       (long (make-vector 57 *))
       (shot (make-vector 34 *))
       (huge (tabulate-array!
              hape
              (lambda (ix) (vector-ref '#(a b) (vector-ref ix 0)))
              long))
       (tiny0 (share-array/index!
               huge
               tape
               (begin
                 (do ((k 0 (+ k 1)))
                   ((= k 23))
                   (vector-set! long k k))
                 (lambda (ix)
                   (do ((k 23 (+ k 1)))
                     ((= k 57))
                     (vector-set! long k (vector-ref ix (- k 23))))
                   long))
               shot))
       (tiny1 (share-array/index!
               huge
               tape
               (begin
                 (vector-set! long 0 1)
                 (do ((k 1 (+ k 1)))
                   ((= k 23))
                   (vector-set! long k k))
                 (lambda (ix)
                   (do ((k 23 (+ k 1)))
                     ((= k 57))
                     (vector-set! long k (vector-ref ix (- k 23))))
                   long))
               shot)))
  (or (and (equal? (array->vector huge) '#(a a a a b b b b))
           (equal? (array->vector tiny0) '#(a a a a))
           (equal? (array->vector tiny1) '#(b b b b)))
      (error "share-array/index! failed huge or tiny contents"))
  (or (array-equal? huge
                    (share-array/index!
                     (array (shape 4 6) 'a 'b)
                     hape
                     (lambda (ix)
                       (vector-ref '#(#(4) #(5)) (vector-ref ix 0)))
                     long))
      (error "share-array/index! failed huge"))
  (or (array-equal? tiny0
                    (share-array/index!
                     (array (shape 6 7) 'a)
                     tape
                     (lambda (ix) '#(6))
                     shot))
      (error "share-array/index! failed tiny0"))
  (or (array-equal? tiny1
                    (share-array/index!
                     (array (shape 6 7 8 9) 'b)
                     tape
                     (lambda (ix) '#(6 8))
                     shot))
      (error "share-array/index! failed tiny1")))

(past "share-array/index! huge as tiny")
