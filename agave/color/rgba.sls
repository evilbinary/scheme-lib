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

(library

 (agave color rgba)

 (export <rgba> rgba rgba? rgba-clone rgba-assign! apply-rgba
           
         rgba-red   rgba-red-set!   rgba-red-change!
         rgba-green rgba-green-set! rgba-green-change!
         rgba-blue  rgba-blue-set!  rgba-blue-change!
         rgba-alpha rgba-alpha-set! rgba-alpha-change!)

 (import (rnrs) (agave misc define-record-type))

 (define-record-type++

   (<rgba> rgba rgba? rgba-clone rgba-assign! apply-rgba)
   
   (fields (mutable red   rgba-red   rgba-red-set!   rgba-red-change!)
           (mutable green rgba-green rgba-green-set! rgba-green-change!)
           (mutable blue  rgba-blue  rgba-blue-set!  rgba-blue-change!)
           (mutable alpha rgba-alpha rgba-alpha-set! rgba-alpha-change!)))

 )