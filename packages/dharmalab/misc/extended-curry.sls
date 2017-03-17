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
(library (dharmalab misc extended-curry)

 (export curry)

 (import (rnrs)
         (for (dharmalab misc symbols) (meta 1)))

 (define-syntax curry-helper

   (syntax-rules ()

     ( (curry-helper (original ...) procedure parameter rest ...)

       (lambda (parameter)

         (curry-helper (original ...) procedure rest ...)) )

     ( (curry-helper (original ...) procedure)

       (procedure original ...) )))

 (define-syntax curry

   (lambda (x)

     (syntax-case x ()

       ( (curry procedure parameter ...)

         (with-syntax ( ((sorted ...)

                         (datum->syntax
                          (syntax procedure)
                          (list-sort symbol<?
                                     (syntax->datum
                                      (syntax (parameter ...)))))) )

                      (syntax

                       (curry-helper (parameter ...) ;; original
                                     procedure
                                     sorted ...))) ))))
 )