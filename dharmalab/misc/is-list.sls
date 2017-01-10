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

(library (dharmalab misc is-list)

  (export is-list)

  (import (rnrs) (dharmalab misc gen-id))

  (define-syntax is-list

    (lambda (stx)

      (syntax-case stx ()

	((is-list name)

	 (with-syntax ( (name.ref      (gen-id #'name #'name ".ref"))
			(name.length   (gen-id #'name #'name ".length"))
			(name.map      (gen-id #'name #'name ".map"))
			(name.for-each (gen-id #'name #'name ".for-each"))
			(name.push!    (gen-id #'name #'name ".push!")) )

	   #'(begin

	       (define (name.ref i) (list-ref name i))

	       (define (name.length) (length name))

	       (define (name.map proc) (map proc name))

	       (define (name.for-each proc) (for-each proc name))

	       (define-syntax name.push!
		 (syntax-rules ()
		   ((name.push! val)
		    (begin
		      (set! name (cons val name))
		      name))))
	       
	       ))))))

  )