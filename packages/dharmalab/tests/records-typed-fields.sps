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

(define-record-type++ point-2d
  (fields x y)
  (methods (neg point::neg)))

(define (point::neg p)
  (import-point-2d p)
  (make-point-2d (- x) (- y)))

(define p0 (make-point-2d 1 2))

(is-point-2d p0)

(assert (= p0.x 1))

(assert (and (= (point-2d-x (p0.neg)) -1)
             (= (point-2d-y (p0.neg)) -2)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ point-3d
  (parent point-2d)
  (fields z))

(define p1 (make-point-3d 1 2 3))

(is-point-3d p1)

(assert (equal? (list p1.x p1.y p1.z) '(1 2 3)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type++ spaceship
  (fields (pos is-point-2d)
          (vel is-point-2d)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ship
  (make-spaceship (make-point-2d 1 2)
                  (make-point-2d 3 4)))

(is-spaceship ship)

(assert (point-2d? ship.pos))
(assert (point-2d? ship.vel))

(assert (= ship.pos.x 1))
(assert (= ship.pos.y 2))

(assert (= ship.vel.x 3))
(assert (= ship.vel.y 4))

(let ((s0 (make-spaceship (make-point-2d 5 6)
                          (make-point-2d 7 8))))
  (import-spaceship s0)

  (assert (equal? (list pos.x pos.y vel.x vel.y)
                  '(5 6 7 8))))

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
;;   (fields overdraft-account)
;;   (methods
;;    (withdraw checking-account::withdraw)))

;; (define (checking-account::withdraw self amount)

;;   (import-bank-account     self)

;;   (let ()

;;     (import-checking-account self)

;;     (is-bank-account overdraft-account)

;;     (let ((overdraft-amount (- amount balance)))

;;       (when (> overdraft-amount 0)

;;         (overdraft-account.withdraw overdraft-amount)

;;         (overdraft-account.deposit overdraft-amount)))

;;     (withdraw amount)))
  
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  

