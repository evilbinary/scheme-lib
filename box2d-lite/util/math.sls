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

(library (box2d-lite util math)

  (export FLT-MAX pi sign clamp)

  (import (rnrs))

  (define FLT-MAX 3.40282e+38)

  (define pi 3.14159265358979323846264)

  (define (sign n)
    (if (< n 0) -1 1))

  (define (clamp n low high)
    (max low (min n high)))

  )