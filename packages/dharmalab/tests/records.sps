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

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import (rnrs)
        (dharmalab records define-record-type))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ point
  (fields x y)
  (methods (neg point::neg)))

(define (point::neg p)
  (import-point p)
  (make-point (- x) (- y)))

(define p0 (make-point 1 2))

(is-point p0)

(assert (= p0.x 1))

(assert (and (= (point-x (p0.neg)) -1)
             (= (point-y (p0.neg)) -2)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ point-3d
  (parent point)
  (fields z))

(define p1 (make-point-3d 1 2 3))

(is-point-3d p1)

(assert (equal? (list p1.x p1.y p1.z) '(1 2 3)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ spaceship
  (fields pos vel))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ship (make-spaceship (make-point 1 2) (make-point 3 4)))

(is-spaceship ship)

(is-point ship.pos)

(assert (equal? (list ship.pos.x
                      ship.pos.y)
                '(1 2)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ bank-account
  (fields (mutable balance))
  (methods
   (deposit  bank-account::deposit)
   (withdraw bank-account::withdraw)))

(define (bank-account::deposit self amount)
  (import-bank-account self)
  (balance! (+ balance amount)))

(define (bank-account::withdraw self amount)
  (import-bank-account self)
  (when (> amount balance)
    (error #t "Account overdrawn"))
  (balance! (- balance amount))
  balance)

(define b0 (make-bank-account 0))

(is-bank-account b0)

(b0.deposit 100)

(assert (= b0.balance 100))

(b0.withdraw 50)

(assert (= b0.balance 50))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (define-record-type++ checking-account
;;   (parent bank-account)
;;   (fields overdraft-account)
;;   (methods
;;    (withdraw checking-account::withdraw)))

;; (define (checking-account::withdraw self amount)

;;   (import-checking-account     self)

;;   (is-bank-account overdraft-account)

;;   (let ((overdraft-amount (- amount balance)))

;;     (when (> overdraft-amount 0)

;;       (overdraft-account.withdraw overdraft-amount)

;;       (overdraft-account.deposit overdraft-amount)))

;;   (withdraw amount))
  
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  

