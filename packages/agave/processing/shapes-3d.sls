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

 (agave processing shapes-3d)

 (export stroke
         fill
         polygon
         triangle
         )

 (import (rnrs)
         (agave geometry pt-3d)
         (agave color rgba)
         (gles gles1)
         (agave glamour misc)
         )

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define stroke-color (rgba 0.0 0.0 0.0 1.0))

 (define fill-color   (rgba 1.0 1.0 1.0 1.0))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define stroke

   (case-lambda

    ((r g b a) (set! stroke-color (rgba r g b a)))
    ((r g b)   (set! stroke-color (rgba r g b 1.0)))
    ((g a)     (set! stroke-color (rgba g g g a)))
    ((g)       (set! stroke-color (rgba g g g 1.0)))))

 (define fill

   (case-lambda

    ((r g b a) (set! fill-color (rgba r g b a)))
    ((r g b)   (set! fill-color (rgba r g b 1.0)))
    ((g a)     (set! fill-color (rgba g g g a)))
    ((g)       (set! fill-color (rgba g g g 1.0)))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (gl-pt-vertex p)
   (glVertex3d (pt-x p)
               (pt-y p)
               (pt-z p)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define (polygon . vertices)

   (gl-color-rgba fill-color)

   (gl-begin GL_POLYGON (for-each gl-pt-vertex vertices))

   (gl-color-rgba stroke-color)

   (gl-begin GL_LINE_LOOP (for-each gl-pt-vertex vertices)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (define triangle

   (case-lambda

    ( (a b c) (polygon a b c) )

    ( (x0 y0 z0 x1 y1 z1 x2 y2 z2)

      (triangle (pt x0 y0 z0)
                (pt x1 y1 z1)
                (pt x2 y2 z2)) )))
 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 )
