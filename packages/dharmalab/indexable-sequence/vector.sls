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

(library (dharmalab indexable-sequence vector)

  (export vector-fold-left
          vector-fold-right
          vector-for-each
          vector-for-each-with-index
          vector-copy
          vector-map!
          vector-map
          vector-subseq
          vector-take
          vector-drop
          vector-filter-to-reverse-list
          vector-filter
          vector-index
          vector-find
          vector-swap!
          vector-reverse!
          vector-reverse)

  (import (except (rnrs) vector-for-each vector-map)
          (dharmalab indexable-sequence indexable-functors)
          (dharmalab indexable-sequence define-indexable-sequence-procedures))

  (define-indexable-sequence-procedures
    vector
    vector-length
    vector-ref
    vector-set!
    make-vector)

  )