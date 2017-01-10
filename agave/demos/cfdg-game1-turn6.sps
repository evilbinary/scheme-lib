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

;; Based on the original at:
;; 
;;     http://www.contextfreeart.org/gallery/view.php?id=118
;;
;; Ported to Scheme by Ed Cavazos

(import (rnrs)
        (agave demos cfdg)
        (agave demos cfdg-rule)
        (agave demos cfdg-abbreviations))

(rule start
      (1 (spiral)
         (spiral (r 120))
         (spiral (r 240))))

(rule spiral

      (1 (f-squares)
         (f-triangles (x 0.5) (y 0.5) (r 45))
         (spiral (y 1.0) (r 25) (s 0.9)))

      (0.022 (start (flip 90) (hue 50))))

(rule f-squares
      (1 (square (x 0.1) (y 0.1) (a -0.33) (hue 250) (sat 0.70) (b 0.80))
         (square (hue 220) (sat 0.90) (b 0.33))
         (square (s 0.9) (hue 220) (sat 0.25) (b 1.00))
         (f-squares (s 0.8) (r 5))))

(rule f-triangles
      (1 (triangle (x 0.1) (y 0.1) (a -0.33) (hue 20) (sat 0.7) (b 0.80))
         (triangle (hue 10) (sat 0.9) (b 0.33))
         (triangle (s 0.9) (hue 10) (sat 0.5) (b 1.00))
         (f-triangles (s 0.8) (r 5))))

(background (lambda () (hue 66) (sat 0.4) (b 0.5)))

(viewport '(-5 10 -5 10))

(threshold 0.001)

(start-shape start)

(run-model)