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

 (agave glamour frames-per-second)

 (export frames-per-second)

 (import (rnrs) (surfage s19 time) (glut))

 (define (current-time-in-nanoseconds)
   (let ((val (current-time)))
     (+ (* (time-second val) 1000000000)
        (time-nanosecond val))))

 (define (frames-per-second n)

   (let ( (window (glutGetWindow))
          (last-display-time 0) )

     (let ( (nanoseconds-per-frame
             (lambda ()
               (/ 1000000000.0 n)))

            (nanoseconds-since-last-display
             (lambda ()
               (- (current-time-in-nanoseconds)
                  last-display-time))) )

       (lambda ()
         (if (> (nanoseconds-since-last-display)
                (nanoseconds-per-frame))
             (begin
               (set! last-display-time (current-time-in-nanoseconds))
               (glutSetWindow window)
               (glutPostRedisplay))))))))