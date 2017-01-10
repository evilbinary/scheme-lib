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

(library (dharmalab misc list-fp)

  (export filter map for-each find-tail take-while drop-while any every
          count)

  (import (except (rnrs) filter map for-each))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (list-recursion f g h)
    (define (rec fun lst)
      (let loop ((lst lst))
        (if (null? lst)
            (f lst)
            (let ((hd (car lst))
                  (tl (cdr lst)))
              (let ((val (fun hd)))
                (if val
                    (g loop val hd tl)
                    (h loop val hd tl)))))))
    rec)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (null  x) '())
  (define (true  x) #t)
  (define (false x) #f)
  (define (zero  x) 0)

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define (cons-head-recur loop vl hd tl)
    (cons hd (loop tl)))

  (define (cons-val-recur loop vl hd tl)
    (cons vl (loop tl)))

  (define (recur loop vl hd tl)
    (loop tl))

  (define (add-1-recur loop vl hd tl)
    (+ 1 (loop tl)))

  (define (done x)
    (lambda (loop vl hd tl)
      x))

  (define done-null  (done '()))
  (define done-true  (done #t))
  (define done-false (done #f))
  (define done-zero  (done 0))

  (define done-list
    (lambda (loop vl hd tl)
      (cons hd tl)))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (define filter     (list-recursion null  cons-head-recur recur))
  (define map        (list-recursion null  cons-val-recur  cons-val-recur))
  (define for-each   (list-recursion null  recur           recur))
  (define find-tail  (list-recursion false done-list       recur))
  (define take-while (list-recursion null  cons-head-recur done-null))
  (define drop-while (list-recursion null  recur           done-list))
  (define any        (list-recursion false done-true       recur))
  (define every      (list-recursion true  recur           done-false))
  (define count      (list-recursion zero  add-1-recur     recur))

  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )