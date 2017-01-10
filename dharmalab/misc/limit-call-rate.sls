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

(library (dharmalab misc limit-call-rate)

  (export limit-call-rate)

  (import (rnrs)
          (surfage s19 time))

  (define (current-time-in-nanoseconds)
    (let ((val (current-time)))
      (+ (* (time-second val) 1000000000)
         (time-nanosecond val))))

  ;; (define-syntax limit-call-rate
  ;;   (syntax-rules ()
  ;;     ((limit-call-rate calls-per-second (proc param ...))
  ;;      (let ((last-call-time 0)
  ;;            (nanoseconds-per-call (/ 1e9 calls-per-second)))
  ;;        (define (nanoseconds-since-last-call)
  ;;          (- (current-time-in-nanoseconds)
  ;;             last-call-time))
  ;;        (lambda (param ...)
  ;;          (if (> (nanoseconds-since-last-call) nanoseconds-per-call)
  ;;              (begin
  ;;                (set! last-call-time (current-time-in-nanoseconds))
  ;;                (proc param ...))))))))

  (define-syntax limit-call-rate
    (syntax-rules ()
      ((limit-call-rate calls-per-second (proc param ...))
       (let ((last-call-time 0)
             (nanoseconds-per-call (lambda ()
                                     (/ 1e9 calls-per-second))))
         (define (nanoseconds-since-last-call)
           (- (current-time-in-nanoseconds)
              last-call-time))
         (lambda (param ...)
           (if (> (nanoseconds-since-last-call) (nanoseconds-per-call))
               (begin
                 (set! last-call-time (current-time-in-nanoseconds))
                 (proc param ...))))))))

  )

          