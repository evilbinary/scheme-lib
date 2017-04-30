;;; "dbsyn.scm" -- Syntactic extensions for RDMS  -*- scheme -*-
;; Features: within-database

;;; Copyright (C) 2002, 2003 Ivan Shmakov <ivan@theory.dcn-asu.ru>
;;
;; Permission to copy this software, to modify it, to redistribute it,
;; to distribute modified versions, and to use it for any purpose is
;; granted, subject to the following restrictions and understandings.
;;
;; 1.  Any copy made of this software must include this copyright notice
;; in full.
;;
;; 2.  I have made no warranty or representation that the operation of
;; this software will be error-free, and I am under no obligation to
;; provide any services, by way of maintenance, update, or otherwise.
;;
;; 3.  In conjunction with products arising from the use of this
;; material, there shall be no use of my name in any advertising,
;; promotional, or sales literature without prior written consent in
;; each case.

;;; History:

;; 2002-08-01: I've tired of tracking database description elements
;; (such as `(define-tables ...)'); so I decided to use `etags'.  But
;; its hard (if possible) to create regexp to match against RDMS' table
;; specs.  So I wrote `within-database' syntax extension and now I can
;; simply use something like:

;; $ etags -l scheme \
;;         -r '/ *(define-\(command\|table\) (\([^; \t]+\)/\2/' \
;;         source1.scm ...

;; ... and get TAGS table with all of my database commands and tables.

;;; Code:
(require 'database-commands)
(require 'databases)
(require 'relational-database)

;@
(define-syntax within-database
  (syntax-rules (define-table define-command define-macro)
                                        ;
    ((within-database database)
     database)
                                        ; define-table
    ((within-database database
		      (define-table (name primary columns) row ...)
		      rest ...)
     (begin (define-tables database '(name primary columns (row ...)))
            (within-database database rest ...)))
                                        ; define-command
    ((within-database database
		      (define-command template arg-1 arg-2 ...)
		      rest ...)
     (begin (define-*commands* database '(template arg-1 arg-2 ...))
            (within-database database rest ...)))
                                        ;
    ((within-database database
		      (command arg-1 ...)
		      rest ...)
     (begin (cond ((let ((p (database '*macro*)))
                     (and p (slib:eval (p 'command))))
                   => (lambda (proc)
                        (slib:eval
                         (apply proc (cons database '(arg-1 ...))))))
                  (else
                   ((database 'command) arg-1 ...)))
            (within-database database rest ...)))))

(define (define-*macros* rdb . specs)
  (define defmac
    (((rdb 'open-table) '*macros* #t) 'row:update))
  (for-each (lambda (spec)
              (let* ((procname (caar spec))
                     (args     (cdar spec))
                     (body-1   (cdr  spec))
                     (comment  (and (string? (car body-1))
                                    (car body-1)))
                     (body     (if comment (cdr body-1) body-1)))
                (defmac (list procname
                              `(lambda ,args . ,body)
                              (or comment "")))))
            specs))

;@
(define (add-macro-support rdb)
  (define-tables rdb
    '(*macros*
      ((name symbol))
      ((procedure expression)
       (documentation string))
      ((define-macro (lambda (db . args)
                       (define-*macros* db args)
                       #t) ""))))
  (define-*commands* rdb
    '((*macro* rdb)
      (((rdb 'open-table) '*macros* #f) 'get 'procedure)))
  rdb)
