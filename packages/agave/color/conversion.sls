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

 (agave color conversion)

 (export hsva->rgba)

 (import (rnrs)
         (agave color rgba)
         (agave color hsva))

 (define (hsva->rgba color)

   (let ((hue        (inexact (hsva-hue        color)))
         (saturation (inexact (hsva-saturation color)))
         (value      (inexact (hsva-value      color)))
         (alpha      (inexact (hsva-alpha      color))))

     (let ((Hi (mod (floor (/ hue 60.0)) 6.0)))

       (let ((f (- (/ hue 60.0) Hi))
             (p (* (- 1.0 saturation) value)))

         (let ((q (* (- 1.0 (*      f  saturation)) value))
               (t (* (- 1.0 (* (- 1.0 f) saturation)) value)))
           
           (case (exact Hi)
             ((0) (rgba value t   p   alpha))
             ((1) (rgba q   value p   alpha))
             ((2) (rgba p   value t   alpha))
             ((3) (rgba p   q   value alpha))
             ((4) (rgba t   p   value alpha))
             ((5) (rgba value p   q   alpha))))))))
 )