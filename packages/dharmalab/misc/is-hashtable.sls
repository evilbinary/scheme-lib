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

(library (dharmalab misc is-hashtable)

  (export is-hashtable)

  (import (rnrs)
          (for (dharmalab misc gen-id) (meta 1)))

  (define-syntax is-hashtable

    (lambda (stx)

      (syntax-case stx ()

        ((is-hashtable name)

         (with-syntax ( (name.size      (gen-id #'name #'name ".size"))
                        (name.ref       (gen-id #'name #'name ".ref"))
                        (name.get       (gen-id #'name #'name ".get"))
                        (name.set!      (gen-id #'name #'name ".set!"))
                        (name.delete!   (gen-id #'name #'name ".delete!"))
                        (name.contains? (gen-id #'name #'name ".contains?"))
                        (name.update!   (gen-id #'name #'name ".update!"))
                        (name.copy      (gen-id #'name #'name ".copy"))
                        (name.clear!    (gen-id #'name #'name ".clear!"))
                        (name.keys      (gen-id #'name #'name ".keys"))
                        (name.entries   (gen-id #'name #'name ".entries")) )

           (syntax

            (begin

              (define (name.size)                     (hashtable-size name))
              (define (name.ref key default)          (hashtable-ref name key default))
              (define (name.get key)                  (hashtable-ref name key #f))
              (define (name.set! key obj)             (hashtable-set! name key obj))
              (define (name.delete! key)              (hashtable-delete! name key))
              (define (name.contains? key)            (hashtable-contains? name key))
              (define (name.update! key proc default) (hashtable-update! name key proc default))
              (define (name.copy)                     (hashtable-copy name))
              (define (name.clear!)                   (hashtable-clear! name))
              (define (name.keys)                     (hashtable-keys name))
              (define (name.entries)                  (hashtable-entries name))))))))))