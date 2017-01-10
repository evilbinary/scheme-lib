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

(library (dharmalab misc srfi-1-lists-r6)

  (export

    xcons make-list list-tabulate list-copy 
    proper-list? circular-list? dotted-list? not-pair? null-list? list=
    circular-list length+
    iota
    first second third fourth fifth sixth seventh eighth ninth tenth
    car+cdr
    take       drop       
    take-right drop-right 
    take!      drop-right!
    split-at   split-at!
    last last-pair
    zip unzip1 unzip2 unzip3 unzip4 unzip5
    count
    append! append-reverse append-reverse! concatenate concatenate! 
    unfold       fold       pair-fold       reduce
    unfold-right            pair-fold-right reduce-right
    append-map append-map! map! pair-for-each filter-map map-in-order
    filter! partition! remove! 
    find-tail any every list-index
    take-while drop-while take-while!
    span break span! break!
    delete delete!
    alist-cons alist-copy
    delete-duplicates delete-duplicates!
    alist-delete alist-delete!
    reverse! 

    lset<= lset= lset-adjoin  
    lset-union  lset-intersection  lset-difference  lset-xor  
    lset-diff+intersection
    lset-union! lset-intersection! lset-difference! lset-xor!
    lset-diff+intersection!

    ;; re-exported:

    ;; append assq assv caaaar caaadr caaar caadar caaddr
    ;; caadr caar cadaar cadadr cadar caddar cadddr caddr cadr
    ;; car cdaaar cdaadr cdaar cdadar cdaddr cdadr cdar cddaar
    ;; cddadr cddar cdddar cddddr cdddr cddr cdr cons cons*
    ;; length list list-ref memq memv null? pair?
    ;; reverse set-car! set-cdr!

    ;; different than R6RS:

    ;; assoc filter find fold-right for-each map member partition remove

    )
  
  (import (surfage s1 lists)))