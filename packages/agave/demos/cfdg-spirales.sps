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
;;     http://www.contextfreeart.org/gallery/view.php?id=1182
;;
;; Ported to Scheme by Ed Cavazos

(import (rnrs)
        (agave demos cfdg)
        (agave demos cfdg-rule)
        (agave demos cfdg-abbreviations))

(rule line
      (1 (a1)
         (a1 (r 120))
         (a1 (r 240))))

(rule a1
      (1 (a1 (s 0.95) (x 2.0) (r 12) (b 0.5) (hue 10.0) (sat 1.5))
         (chunk)))

(rule chunk
      (1 (circle)
         (line (a -0.3) (s 0.3) (flip 60.0))))

(rule start
      (1 (line (a -0.3))))

(background (lambda () (b -1)))

(viewport '(-20 40 -20 40))

(start-shape start)

(threshold 0.05)

(run-model)
