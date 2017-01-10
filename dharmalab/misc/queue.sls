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

(library (dharmalab misc queue)

  (export new-queue
          queue-empty?
          queue-insert
          queue-remove
          queue-length
          queue-car
          queue-cdr
          queue-for-each-with-index
          queue-tabulate)

  (import (rnrs)
          (surfage s41 streams))

  (define-record-type queue (fields L R P))

  (define (new-queue)
    (make-queue (stream) (stream) (stream)))

  (define (queue-empty? q)
    (let ((L (queue-L q))
          (R (queue-R q))
          (P (queue-P q)))
      (and (stream-null? L)
           (stream-null? R)
           (stream-null? P))))

  (define (queue-length q)
    (let ((L (queue-L q))
          (R (queue-R q)))
      (+ (stream-length L)
         (stream-length R))))

  (define (rot L R A)
    (if (stream-null? L)
        (stream-cons (stream-car R) A)
        (stream-cons (stream-car L)
                     (rot (stream-cdr L)
                          (stream-cdr R)
                          (stream-cons (stream-car R) A)))))

  (define (makeq q)
    (let ((L (queue-L q))
          (R (queue-R q))
          (P (queue-P q)))
      (if (not (stream-null? P))
          (make-queue L R (stream-cdr P))
          (let ((P (rot L R (stream))))
            (make-queue P (stream) P)))))

  (define (queue-insert q e)
    (let ((L (queue-L q))
          (R (queue-R q))
          (P (queue-P q)))
      (makeq (make-queue L (stream-cons e R) P))))

  (define (queue-remove q f)
    (let ((L (queue-L q))
          (R (queue-R q))
          (P (queue-P q)))
      (f (stream-car L)
         (makeq (make-queue (stream-cdr L) R P)))))

  (define (queue-car q)
    (stream-car (queue-L q)))

  (define (queue-cdr q)
    (let ((L (queue-L q))
          (R (queue-R q))
          (P (queue-P q)))
      (makeq (make-queue (stream-cdr L) R P))))

  (define (queue-for-each-with-index f q)
    (let loop ((i 0) (q q))
      (if (not (queue-empty? q))
          (begin (f i (queue-car q))
                 (loop (+ i 1) (queue-cdr q))))))

  (define (queue-tabulate f n)
    (let loop ((i 0) (q (new-queue)))
      (if (>= i n)
          q
          (loop (+ i 1) (queue-insert q (f i))))))

  )

