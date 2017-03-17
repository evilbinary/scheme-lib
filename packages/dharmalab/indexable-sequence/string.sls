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

(library (dharmalab indexable-sequence string)

  (export string-fold-left
          string-fold-right
          string-for-each
          string-for-each-with-index
          string-copy
          string-map!
          string-map
          string-subseq
          string-take
          string-drop
          string-filter-to-reverse-list
          string-filter
          string-index
          string-find
          string-swap!
          string-reverse!
          string-reverse)

  (import (except (rnrs) string-for-each string-copy)
          (rnrs mutable-strings)
          (dharmalab indexable-sequence indexable-functors)
          (dharmalab indexable-sequence define-indexable-sequence-procedures))

  (define-indexable-sequence-procedures
    string
    string-length
    string-ref
    string-set!
    make-string))
