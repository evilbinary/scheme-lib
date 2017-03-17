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
#!r6rs
(library (dharmalab math basic)

  (export pi
          square
          add
          multiply-by
          subtract-from
          subtract
          divide
          divide-by
          greater-than
          greater-than=
          less-than
          less-than=)

  (import (rnrs)
          (dharmalab misc extended-curry))

  (define pi  3.14159265358979323846)

  (define (square n) (* n n))

  (define add           (curry + a b))

  (define multiply-by   (curry * a b))

  (define subtract-from (curry - a b))

  (define subtract      (curry - b a))

  (define divide        (curry / a b))

  (define divide-by     (curry / b a))

  (define greater-than  (curry >  b a))
  (define greater-than= (curry >= b a))

  (define less-than     (curry <  b a))
  (define less-than=    (curry <= b a))

  (define =to (curry = a b))

  )