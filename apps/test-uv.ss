;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 11/19/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(import  (scheme) (net uv-ffi) (cffi cffi) )

(define loop (uv-default-loop))
(define server (cffi-alloc 10))
(define addr (cffi-alloc 10))

(define ret 0)

(def-function-callback
  make-on-new-connection
  (void* int ) void)

(def-function-callback
  make-after-read
  (void* int void*) void)

(def-function-callback
  make-echo-alloc
  (void* int void*) void)


(def-function-callback
  make-after-shutdown
  (void* int) void)

(def-function-callback
  make-on-close
  (void*) void)

(define on-close
  (make-on-close
   (lambda (peer)
     (cffi-free peer))))

(define after-shutdown
  (make-after-shutdown
   (lambda (req status)
     (printf "after-shutdown\n")
     ;;(uv-close req->handle on-close )
     (cffi-free req))))

(define echo-alloc
  (make-echo-alloc
   (lambda (handle size buf)
     (printf "echo-alloc ~a\n" size)
     ;;(set-buf-base buf (cffi-alloc size))
     ;;(set-buf-len buf size)
     (let ((b (make-uv-buf-t
	      (cffi-alloc size) size)))
       (lisp2struct b buf)
       (printf "alloc b ~a\n" b)
       )
     
     )))


(def-struct uv-buf-t
  (base void*)
  (len int))


(define after-read
  (make-after-read
   (lambda (handle nread buf)
     (let ((a (make-uv-buf-t 0 0)))
       (printf "buf=>~a\n" (struct2lisp buf a))
       (printf "buf base ~a len=~a\n" (uv-buf-t-base a) (uv-buf-t-len a) )
       (printf "after-read nread=~a buf=~s\n" nread  (cffi-string (uv-buf-t-base a)))
       )
     (if (<  nread 0)
	 (begin
	   (if (not (= -1 nread))
	       (printf "reqd error ~a\n" (uv-err-name nread)))
	   (printf "free buf->base and shutdown\n")
	   ;;(cffi-free (get-buf-len buf))
	   (uv-close handle 0)
	   ))
     (if (= 0 nread)
	 (begin
	   (printf "free buf->base\n")
	   ;;(cffi-free (get-buf-base buf))
	   )))))

(uv-tcp-init loop server)
(uv-ip4-addr "0.0.0.0" 7000 addr)

(uv-tcp-bind server addr 0)
(set! ret (uv-listen server 128
	   (make-on-new-connection
	    (lambda (data status)
	      (printf "status=~a\n" status)
	      (let ((client (cffi-alloc 10)))
		(uv-tcp-init loop client)
		(if (= 0 (uv-accept server client))
		    (uv-read-start client echo-alloc after-read)
		    (uv-close client 0)))

	      ))))

(printf "ret=~a ~a\n" ret (uv-err-name ret) )
(uv-run loop 0)

