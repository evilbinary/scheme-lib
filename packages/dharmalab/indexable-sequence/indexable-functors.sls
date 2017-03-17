;; Copyright 2016 Eduardo Cavazos
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(library (dharmalab indexable-sequence indexable-functors)

  (export make-indexable-fold-left
          make-indexable-fold-right
          make-indexable-for-each
          make-indexable-for-each-with-index
          make-indexable-copy
          make-indexable-map!
          make-indexable-map
          make-indexable-subseq
          make-indexable-take
          make-indexable-drop
          make-indexable-filter-to-reverse-list
          make-indexable-filter
          make-indexable-index
          make-indexable-find
          make-indexable-swap!
          make-indexable-reverse!
          make-indexable-reverse)

  (import (rnrs))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-fold-left size ref)

    (define (fold-left seq val proc)
      (let ((n (size seq)))
        (let loop ((i 0) (val val))
          (if (>= i n)
              val
              (loop (+ i 1) (proc val (ref seq i)))))))

    fold-left)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-fold-right size ref)

    (define (fold-right seq val proc)
      (let ((n (size seq)))
        (let loop ((i (- n 1)) (val val))
          (if (< i 0)
              val
              (loop (- i 1) (proc (ref seq i) val))))))

    fold-right)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-for-each size ref)

    (let ((fold-left (make-indexable-fold-left size ref)))

      (define (for-each seq proc)
        (fold-left seq #f (lambda (val elt)
                            (proc elt))))

      for-each))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-for-each-with-index size ref)

    (let ((fold-left (make-indexable-fold-left size ref)))

      (define (for-each-with-index seq proc)
        (fold-left seq 0 (lambda (i elt)
                           (proc i elt)
                           (+ i 1))))

      for-each-with-index))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-copy size ref put! new-of-size)

    (let ((for-each-with-index (make-indexable-for-each-with-index size ref)))

      (define (copy seq)
        (let ((new (new-of-size (size seq))))
          (for-each-with-index seq (lambda (i elt)
                                     (put! new i elt)))
          new))

      copy))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-map! size ref put!)

    (let ((for-each-with-index (make-indexable-for-each-with-index size ref)))

      (define (map! seq proc)
        (for-each-with-index seq
                             (lambda (i elt)
                               (put! seq i (proc elt))))
        seq)

      map!))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-map size ref put! copy)

    (let ((map! (make-indexable-map! size ref put!)))
      
      (define (map seq proc)
        (map! (copy seq) proc))

      map))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-subseq size ref put! new-of-size)

    (let ((for-each-with-index (make-indexable-for-each-with-index size ref)))

      (define (subseq seq start end)
        (let ((new (new-of-size (- end start))))
          (for-each-with-index new (lambda (i elt)
                                     (put! new i (ref seq (+ start i)))))
          new))

      subseq))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-take subseq)

    (define (take seq n)
      (subseq seq 0 n))

    take)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-drop size subseq)

    (define (drop seq n)
      (subseq seq n (size seq)))

    drop)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-filter-to-reverse-list size ref)

    (let ((fold-left (make-indexable-fold-left size ref)))

      (define (filter-to-reverse-list seq proc)
        (fold-left seq '() (lambda (ls elt)
                             (if (proc elt)
                                 (cons elt ls)
                                 ls))))

      filter-to-reverse-list))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-filter size ref put! new-of-size)

    (let ((subseq (make-indexable-subseq size ref put! new-of-size)))

      (define (filter seq proc)
        (let ((n (size seq)))
          (let ((new (new-of-size n)))
            (let loop ((i 0) (j 0))
              (if (>= i n)
                  (subseq new 0 j)
                  (let ((elt (ref seq i)))
                    (cond ((proc elt)
                           (put! new j elt)
                           (loop (+ i 1) (+ j 1)))
                          (else
                           (loop (+ i 1) j)))))))))

      filter))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-index size ref)

    (define (index seq proc)
      (let ((n (size seq)))
        (let loop ((i 0))
          (if (>= i n)
              #f
              (let ((elt (ref seq i)))
                (if (proc elt)
                    i
                    (loop (+ i 1))))))))

    index)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-find size ref)

    (let ((index (make-indexable-index size ref)))

      (define (find seq proc)

        (let ((i (index seq proc)))

          (if i (ref seq i) #f)))

      find))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-swap! ref put!)

    (define (swap! seq i j)
      (let ((a (ref seq i))
            (b (ref seq j)))
        (put! seq i b)
        (put! seq j a)
        seq))

    swap!)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-reverse! size swap!)

    (define (reverse! seq)
      (let ((n (size seq)))
        (let loop ((i 0) (j (- n 1)))
          (if (>= i j)
              seq
              (begin (swap! seq i j)
                     (loop (+ i 1) (- j 1)))))))

    reverse!)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (make-indexable-reverse copy reverse!)

    (define (reverse seq)
      (reverse! (copy seq)))

    reverse)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )