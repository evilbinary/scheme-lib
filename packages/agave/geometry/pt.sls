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

(library

 (agave geometry pt)

 (export (rename (pt <pt>)
                 (make-pt pt))
         pt?
         pt-x pt-x-set!
         pt-y pt-y-set!
         pt+  pt-  pt*  pt/
         pt+n pt-n pt*n pt/n
         pt-neg
         pt-norm
         pt-normalize
         pt-dot
         pt-distance)

 (import (rnrs)
         (agave glamour misc)
         )

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define-record-type pt
   (fields (mutable x)
           (mutable y)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define binary-pt-procedure
   (lambda (op)
     (lambda (a b)
       (make-pt (op (pt-x a) (pt-x b))
                (op (pt-y a) (pt-y b))))))
 
 (define pt+ (binary-pt-procedure +))
 (define pt- (binary-pt-procedure -))
 (define pt* (binary-pt-procedure *))
 (define pt/ (binary-pt-procedure /))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (pt-n-procedure op)
   (lambda (a n)
     (make-pt (op (pt-x a) n)
              (op (pt-y a) n))))

 (define pt+n (pt-n-procedure +))
 (define pt-n (pt-n-procedure -))
 (define pt*n (pt-n-procedure *))
 (define pt/n (pt-n-procedure /))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (pt-neg p)
   (make-pt (- (pt-x p))
            (- (pt-y p))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (sq n) (* n n))

 (define (pt-norm p)
   (sqrt (+ (sq (pt-x p))
            (sq (pt-y p)))))

 (define (pt-normalize p)
   (pt/n p (pt-norm p)))

 (define (pt-dot a b)
   (let ((val (pt* a b)))
     (+ (pt-x val)
        (pt-y val))))

 (define (pt-distance a b)
   (pt-norm (pt- a b)))

 )