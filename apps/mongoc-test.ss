;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2016-2080 evilbinary.
;author:evilbinary on 12/24/16.
;email:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import  (scheme)  (cffi cffi)  (mongoc mongoc-ffi) (mongoc bson-ffi)  )

(define client '() )


(define query (cffi-alloc 1024) )
(define collection-name "test")
(define collection '() )
(define cursor '())
(define doc (cffi-alloc 1024 ))

(define insert (cffi-alloc 1024 ))
(define error (cffi-alloc 1024))
;;(cffi-set-pointer doc (cffi-alloc 1024))
;;(define len (cffi-alloc 1024 ))




(display "begin......\n")
(mongoc-init)

(set! client (mongoc-client-new "mongodb://127.0.0.1/?appname=client-example"))



;;(display client)
(mongoc-client-set-error-api client 2)

(set! query (cffi-alloc 1024) )

(bson-init query)

(set! collection (mongoc-client-get-collection client "test" collection-name))

(set! cursor (mongoc-collection-find-with-opts collection query 0 0))

(let loop ((t (mongoc-cursor-next cursor   doc )) )

  (if (not (= 0 t))
      (begin
	(display (format "next=~a doc=~a\n" t doc ))
	;;(bson-as-json (cffi-get-pointer doc) 0)
	(let ((str (bson-as-json (cffi-get-pointer doc) 0)))
	  (display (format "ddd=~a\n" str  ))
	  ;;(bson-free str)
	  (loop  (mongoc-cursor-next cursor  doc ) )
	  )
	)))
;;(cffi-log #t)
;;insert data
(set! json "{ \"_id\": 123, \"type\": \"misc\", \"item\":\"card\", \"qty\": 15 }")
(set! insert (bson-new-from-json json (string-length json) error))
(if (= 0 insert)
    (display "cannot parse\n"))

(mongoc-collection-insert  collection 0 insert 0 0)

(mongoc-cursor-destroy cursor)
(mongoc-collection-destroy collection)
(mongoc-client-destroy client)
(mongoc-cleanup)

(cffi-free query)
(cffi-free doc)


(display "end\n")

