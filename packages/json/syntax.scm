;;; (json syntax) --- Guile JSON implementation.

;; Copyright (C) 2013 Aleix Conchillo Flaque <aconchillo@gmail.com>
;;
;; This file is part of guile-json.
;;
;; guile-json is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;;
;; guile-json is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with guile-json; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301 USA

;;; Commentary:

;; JSON module for Guile

;;; Code:

(library (json syntax)
  (export json)
  (import (chezscheme))

  (define (list->hash-table lst)
    (let loop ((table (make-hash-table))
               (lst lst))
      (if (not (null? lst))
          (let* ([pair (car list)]
                 [key (car pair)]
                 [value (cdr pair)])
            (hashtable-set! table key value)
            (loop table (cdr list)))
          table)))

  (define-syntax json
    (syntax-rules (unquote unquote-splicing array object)
      ((_ (unquote val))
       val)
      ((_ ((unquote-splicing val) . rest))
       (append val (json rest)))
      ((_ (array val . rest))
       (cons (json val) (json rest)))
      ((_ (object key+val ...))
       (list->hash-table
        (json (array key+val ...))))
      ((_ (val . rest))
       (cons (json val) (json rest)))
      ((_ val)
       (quote val))))
  )

;;; (json syntax) ends here
