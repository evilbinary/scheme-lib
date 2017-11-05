
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;Copyright 2016-2080 evilbinary.
					;作者:evilbinary on 12/24/16.
					;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme)  (glfw glfw)
	 (gui imgui)
	 (gles gles1)
	 (glut glut)
	 (cffi cffi)
	 (gui assimp)
	 (nanovg nanovg)
	 (utils libutil)
	 (utils macro) )




(define file "/Users/evil/dev/graphic/assimp/test/models/MD2/sydney.md2")

(if (> (length (command-line)) 1)
    (if (not (eq? "" (cadr (command-line))))
	(set! file  (cadr (command-line)))) )

;;(cffi-log #t)
(define scene 0)

(define (init-load)
  (set! scene (ai-import-file file  3645131))
  ;;(set! scene  (load-res))
  (printf " load ~x\n" scene)

  (let ((v (cffi-alloc 10)))
    (cffi-set-float v 0.111)
    (cffi-set-float (+ v 4) 0.222)
    (cffi-set-float (+ v 8) 0.333)
    (printf "1=>~f\n" (cffi-get-float v ))
    (printf "2=>~f\n" (cffi-get-float (+ v 4) ))
    (printf "3=>~f\n" (cffi-get-float (+ v  8)))
    ;;(test-array-float v)
    (cffi-free v)
    )
    
  
  )

(define (struct-ref addr offset)
  (cffi-get-pointer  (+ addr (* 8 offset))))

(define (struct-int addr offset)
  (cffi-get-int  (+ addr (* 8 offset))))

(define (struct-uint addr offset)
  (cffi-get-uint  (+ addr (* 8 offset))))

(define (mem-int addr)
  (cffi-get-int addr))


(define (get-nmesh scene)
  (struct-int  scene  2  ))

(define (get-meshs scene)
  (struct-ref scene 3))

(define (get-mesh-faces mesh)
  (struct-ref mesh 26))

(define (get-mesh-normals mesh)
  (struct-ref mesh 3))


(define (get-node scene)
  (struct-ref scene 1))

(define (get-mesh-nface mesh)
  (struct-int mesh 1))

(define (get-node-meshs node)
  (struct-ref node 141))

(define (get-node-nmesh node)
  (struct-int node 140 ))

(define (gl-render mesh face)
  (let ((v (cffi-alloc (* 9 32) ))
	(nv (cffi-alloc (* 9 32) ))
	(nindicaes (struct-int face 0))
	)
    ;;(printf "nindicaes=>~a\n" nindicaes)
    

    (let loop ((i 0) (count 0))
      (if (< i nindicaes)
	  (let* ((index (cffi-get-int
			 (+ (struct-ref face 1) (* i 4))
			 ) )
		 (normal (+ (get-mesh-normals mesh) (* index 12 )))
		 (nx (cffi-get-float normal))
		 (ny (cffi-get-float (+ normal 4)))
		 (nz (cffi-get-float (+ normal 8)))
		 
		 (vert (+ (struct-ref mesh 2) (* index 12) ))
		 (x (cffi-get-float vert) )
		 (y (cffi-get-float (+ vert 4)))
		 (z (cffi-get-float (+ vert 8))))
	    ;;(printf "index=>~a ~x\n" index   (struct-ref mesh 2) )
	    ;; (printf "x=~a y=~a z=~a\n"
	    ;; 	    x y z)
	    (cffi-set-float (+ nv (* count 4 )) nx)
	    (cffi-set-float (+ v (* count  4) ) x)
	    (set! count (+ count 1))
	    (cffi-set-float (+ nv (*  count 4) ) ny)
	    (cffi-set-float (+ v (*  count 4) ) y)
	    (set! count (+ count 1))
	    (cffi-set-float (+ nv (* count 4) ) nz)
	    (cffi-set-float (+ v (* count 4) ) z)
	    (set! count (+ count 1))
	    (loop (+ i 1) count)
	    )))
    ;;(test-array-float v)
    (glEnableClientState GL_NORMAL_ARRAY)
    (glNormalPointer GL_FLOAT  0 nv)
    (glEnableClientState GL_VERTEX_ARRAY)
    (glVertexPointer 3 GL_FLOAT 0 v)
    (glDrawArrays GL_TRIANGLES 0 9)
    (glDisableClientState GL_VERTEX_ARRAY)
    (cffi-free v)
    (cffi-free nv)
    ))


(define (render)
  (let 
       ((node (get-node scene))
       	(nmesh (get-nmesh scene))
       	(meshs (get-meshs scene))
	
	)
    ;;(printf "meshs=>~x\n"  meshs)
    ;;(printf " root node=~x node=~x\n" (cget-root-node  scene) node)
    ;;(printf "  number mesh->~a\n" nmesh)
    ;;(printf "nd->mNumMeshes ~a\n" (get-node-nmesh node))
    
    ;;(ctest scene  node)
    
    (glPushMatrix)
    (let loop ((i 0))
      (if (< i nmesh)
    	  (let* ((nd-meshs (get-node-meshs node))
    		 (mesh (struct-ref meshs (struct-int nd-meshs i ) ))
    		 (faces (get-mesh-faces mesh))
    		 (nface  (get-mesh-nface mesh)))
	    
    	    ;; (printf "  nd->meshs=>~x\n" nd-meshs )
	    ;; (printf "  nd->mMeshes[n]->~x\n"  (struct-int  nd-meshs i ))
	    ;; (printf "  mesh=>~x\n" mesh)
	    ;; (printf "  nd->mesh->mNumFaces->~a\n"  (get-mesh-nface mesh))
	    ;; (printf "  faces=>~x\n" faces)
	    ;; (printf "  face[0]=>~x\n" (cffi-get-int (+ faces (* 2 8) )))
	    
    	    (let l ((t 0))
    	      (if (< t nface)
    		  (let* ((face (+ faces (* 2 t 8) ))
    			 (nindex (struct-int face 0 )))
    		    ;;(printf "face->nindex=>~x\n" nindex)
    		    ;;(printf "face=>~x\n" face)
    		    ;; (if (< t 1)
    		    ;;(printf "face->mIndicate[0]=~x\n" (+ (struct-ref face  1 ) 4) ))
    		    ;;(printf "t=>~a\n" t)
		    ;;(test-gl mesh face)
		    (gl-render mesh face)
   
    		    (l (+ t 1))
    		    )))
	    
    	    (loop (+ i 1)))))
    (glPopMatrix)

    ;;(collect)
  ))

(init-load)



(define window '() )
(define res-dir 
  (case (machine-type)
    ((arm32le) "/data/data/org.evilbinary.chez/files/")
    (else "")
    ))

(define (opengl-test)
  (glfw-init)

  ;;(glfw-window-hint GLFW_DEPTH_BITS 16);
    ;;(glfw-window-hint GLFW_CLIENT_API  GLFW_OPENGL_ES_API);
    ;;(glfw-window-hint GLFW_CONTEXT_VERSION_MAJOR 2);
    ;;(glfw-window-hint GLFW_CONTEXT_VERSION_MINOR 0);
  (glfw-window-hint GLFW_SAMPLES 4)
  (set! window (glfw-create-window 640  480  "测试例子"   0  0) )
  (glfw-make-context-current window);

  (glad-load-gl-loader  (get-glfw-get-proc-address))
  (glad-load-gles1-loader  (get-glfw-get-proc-address))
  (glad-load-gles2-loader  (get-glfw-get-proc-address))

  (glfw-swap-interval 1);

  ;; (glfw-set-cursor-pos-callback
  ;;  window
  ;;  (lambda (w x y)
  ;;    (display (format "w=~x ~x ~a,~a\n" w window x y )) ))

  (glfw-set-key-callback
   window
   (lambda (w k s a m)
     (display (format "w=~x key=~a scancode=~a action=~a mods=~a\n" w k s a m))))
  
  (let (
	(rotation 2.0)
	)
    ;;(set! texture-id text-id)

    ;;(gluLookAt 0.0  0.0 3.0 0.0 0.0 -5.0  0.0  1.0 0.0)
    (glEnable GL_LIGHTING)
    (glEnable GL_LIGHT0)
    (glEnable GL_DEPTH_TEST)
    (glLightModelf GL_LIGHT_MODEL_TWO_SIDE 0.5)
    (glEnable GL_NORMALIZE);
    (glEnable GL_BLEND)
    ;;(glEnable GL_SMOOTH_POINT_SIZE_RANGE)
    (glEnable GL_FLAT )
    (glEnable GL_SMOOTH)
    ;;(glEnable GL_CULL_FACE)
    ;; (glEnable GL_POINT_SMOOTH);
    ;; (glHint GL_POINT_SMOOTH_HINT  GL_NICEST)
    ;; (glEnable GL_LINE_SMOOTH_HINT)
    ;; (glHint GL_LINE_SMOOTH_HINT  GL_NICEST)

    ;; (glBlendFunc GL_SRC_ALPHA 
    ;; 		 GL_ONE_MINUS_SRC_ALPHA)
    ;; (glShadeModel GL_SMOOTH )
    ;;(glColorMaterial GL_FRONT_AND_BACK GL_DIFFUSE)
    ;;(glMatrixMode GL_MODELVIEW)
    (glMatrixMode GL_PROJECTION)
    
    (while (= (glfw-window-should-close window) 0)
	   (glEnable GL_MULTISAMPLE)
	   (glClearColor 0.0  0.0  0.0  1.0 )
	   (glClear (+  GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT))

	   (glLoadIdentity)
	     
	   (glRotatef rotation 0.0 1.0 0.0)

	   
	   ;;(glScalef 0.3 0.3 0.3)
	   (glScalef 0.02 0.02 0.02)
	   (render)
	   

	  (set! rotation (+ rotation 0.2))

	   (glfw-swap-buffers window)
	   (glfw-poll-events)
	   ))
  (glfw-destroy-window window);
  (glfw-terminate)

  )

(opengl-test)
