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
;;     http://www.contextfreeart.org/gallery/view.php?id=541
;;
;; Ported to Scheme by Ed Cavazos

(import (rnrs)
        (agave demos cfdg)
        (agave demos cfdg-rule)
        (agave demos cfdg-abbreviations))

(rule black
      
      (60 (circle (s 0.6))
          (black (x 0.1) (r 5) (s 0.99) (b -0.01) (a -0.01)))
      
      (1  (white)
          (black)))

(rule white

      (60 (circle (s 0.6))
          (white (x 0.1) (r -5) (s 0.99) (b 0.01) (a -0.01)))

      (1  (black)
          (white)))

(rule chiaroscuro
      (1 (black (b 0.5))))

(background (lambda () (b -0.5)))

(viewport '(-3 6 -2 6))

(threshold 0.03)

(start-shape chiaroscuro)

(run-model)