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

 (agave color hsva)

 (export <hsva> hsva hsva? hsva-clone hsva-assign! apply-hsva
           
         hsva-hue        hsva-hue-set!        hsva-hue-change!
         hsva-saturation hsva-saturation-set! hsva-saturation-change!
         hsva-value      hsva-value-set!      hsva-value-change!
         hsva-alpha      hsva-alpha-set!      hsva-alpha-change!)

 (import (rnrs) (agave misc define-record-type))

 (define-record-type++

   (<hsva> hsva hsva? hsva-clone hsva-assign! apply-hsva)
   
   (fields (mutable hue   hsva-hue   hsva-hue-set!   hsva-hue-change!)
           (mutable saturation
                    hsva-saturation
                    hsva-saturation-set!
                    hsva-saturation-change!)
           (mutable value  hsva-value  hsva-value-set!  hsva-value-change!)
           (mutable alpha hsva-alpha hsva-alpha-set! hsva-alpha-change!)))
 

 )