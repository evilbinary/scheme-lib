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

(library (dharmalab misc gen-id)

  (export gen-id)

  (import (rnrs))

  (define (gen-id template-id . args)
    (datum->syntax template-id
      (string->symbol
       (apply string-append
	      (map (lambda (x)
		     (if (string? x)
			 x
			 (symbol->string (syntax->datum x))))
		   args)))))

  )