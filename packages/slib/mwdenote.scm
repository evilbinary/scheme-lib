;"mwdenote.scm" Syntactic Environments
; Copyright 1992 William Clinger
;
; Permission to copy this software, in whole or in part, to use this
; software for any lawful purpose, and to redistribute this software
; is granted subject to the restriction that all copies made of this
; software must include this copyright notice in full.
;
; I also request that you send me a copy of any improvements that you
; make to this software so that they may be incorporated within it to
; the benefit of the Scheme community.

;;;; Syntactic environments.

; A syntactic environment maps identifiers to denotations,
; where a denotation is one of
;
;    (special <special>)
;    (macro <rules> <env>)
;    (identifier <id>)
;
; and where <special> is one of
;
;    quote
;    lambda
;    if
;    set!
;    begin
;    define
;    define-syntax
;    let-syntax
;    letrec-syntax
;    syntax-rules
;
; and where <rules> is a compiled <transformer spec> (see R4RS),
; <env> is a syntactic environment, and <id> is an identifier.

(define mw:standard-syntax-environment
  '((quote         . (special quote))
    (lambda        . (special lambda))
    (if            . (special if))
    (set!          . (special set!))
    (begin         . (special begin))
    (define        . (special define))
    (define-macro  . (special define-macro))       ;; @@ added stef
    (defmacro      . (special defmacro))           ;; @@ added stef
    (case          . (special case))               ;; @@ added wdc
    (let           . (special let))                ;; @@ added KAD
    (let*          . (special let*))               ;; @@    "
    (letrec        . (special letrec))             ;; @@    "
    (quasiquote    . (special quasiquote))         ;; @@    "
    (unquote       . (special unquote))            ;; @@    "
    (unquote-splicing . (special unquote-splicing)) ; @@    "
    (do            . (special do))                 ;; @@    "
    (define-syntax . (special define-syntax))
    (let-syntax    . (special let-syntax))
    (letrec-syntax . (special letrec-syntax))
    (syntax-rules  . (special syntax-rules))
    (...           . (identifier ...))
    (:::           . (identifier :::))))

; An unforgeable synonym for lambda, used to expand definitions.

(define mw:lambda0 (string->symbol " lambda "))

; The mw:global-syntax-environment will always be a nonempty
; association list since there is no way to remove the entry
; for mw:lambda0.  That entry is used as a header by destructive
; operations.

(define mw:global-syntax-environment
  (cons (cons mw:lambda0
	      (cdr (assq 'lambda mw:standard-syntax-environment)))
	(mw:syntax-copy mw:standard-syntax-environment)))

(define (mw:global-syntax-environment-set! env)
  (set-cdr! mw:global-syntax-environment env))

(define (mw:syntax-bind-globally! id denotation)
  (if (and (mw:identifier? denotation)
	   (eq? id (mw:identifier-name denotation)))
      (letrec ((remove-bindings-for-id
		(lambda (bindings)
		  (cond ((null? bindings) '())
			((eq? (caar bindings) id)
			 (remove-bindings-for-id (cdr bindings)))
			(else (cons (car bindings)
				    (remove-bindings-for-id (cdr bindings))))))))
	(mw:global-syntax-environment-set!
	 (remove-bindings-for-id (cdr mw:global-syntax-environment))))
      (let ((x (assq id mw:global-syntax-environment)))
	(if x
	    (set-cdr! x denotation)
	    (mw:global-syntax-environment-set!
	     (cons (cons id denotation)
		   (cdr mw:global-syntax-environment)))))))

(define (mw:syntax-divert env1 env2)
  (append env2 env1))

(define (mw:syntax-extend env ids denotations)
  (mw:syntax-divert env (map cons ids denotations)))

(define (mw:syntax-lookup-raw env id)
  (let ((entry (assq id env)))
    (if entry
	(cdr entry)
	#f)))

(define (mw:syntax-lookup env id)
  (or (mw:syntax-lookup-raw env id)
      (mw:make-identifier-denotation id)))

(define (mw:syntax-assign! env id denotation)
  (let ((entry (assq id env)))
    (if entry
	(set-cdr! entry denotation)
	(mw:bug "Bug detected in mw:syntax-assign!" env id denotation))))

(define mw:denote-of-quote
  (mw:syntax-lookup mw:standard-syntax-environment 'quote))

(define mw:denote-of-lambda
  (mw:syntax-lookup mw:standard-syntax-environment 'lambda))

(define mw:denote-of-if
  (mw:syntax-lookup mw:standard-syntax-environment 'if))

(define mw:denote-of-set!
  (mw:syntax-lookup mw:standard-syntax-environment 'set!))

(define mw:denote-of-begin
  (mw:syntax-lookup mw:standard-syntax-environment 'begin))

(define mw:denote-of-define
  (mw:syntax-lookup mw:standard-syntax-environment 'define))

(define mw:denote-of-define-syntax
  (mw:syntax-lookup mw:standard-syntax-environment 'define-syntax))

(define mw:denote-of-define-macro
  (mw:syntax-lookup mw:standard-syntax-environment 'define-macro)) ;; @@ stef

(define mw:denote-of-defmacro
  (mw:syntax-lookup mw:standard-syntax-environment 'defmacro)) ;; @@ stef

(define mw:denote-of-let-syntax
  (mw:syntax-lookup mw:standard-syntax-environment 'let-syntax))

(define mw:denote-of-letrec-syntax
  (mw:syntax-lookup mw:standard-syntax-environment 'letrec-syntax))

(define mw:denote-of-syntax-rules
  (mw:syntax-lookup mw:standard-syntax-environment 'syntax-rules))

(define mw:denote-of-...
  (mw:syntax-lookup mw:standard-syntax-environment '...))

(define mw:denote-of-:::
  (mw:syntax-lookup mw:standard-syntax-environment ':::))

(define mw:denote-of-case
  (mw:syntax-lookup mw:standard-syntax-environment 'case))       ;; @@ wdc

(define mw:denote-of-let
  (mw:syntax-lookup mw:standard-syntax-environment 'let))        ;; @@ KenD

(define mw:denote-of-let*
  (mw:syntax-lookup mw:standard-syntax-environment 'let*))       ;; @@ KenD

(define mw:denote-of-letrec
  (mw:syntax-lookup mw:standard-syntax-environment 'letrec))     ;; @@ KenD

(define mw:denote-of-quasiquote
  (mw:syntax-lookup mw:standard-syntax-environment 'quasiquote)) ;; @@ KenD

(define mw:denote-of-unquote
  (mw:syntax-lookup mw:standard-syntax-environment 'unquote))    ;; @@ KenD

(define mw:denote-of-unquote-splicing
  (mw:syntax-lookup mw:standard-syntax-environment 'unquote-splicing)) ;@@ KenD

(define mw:denote-of-do
  (mw:syntax-lookup mw:standard-syntax-environment 'do))        ;; @@ KenD

(define mw:denote-class car)

;(define (mw:special? denotation)
;  (eq? (mw:denote-class denotation) 'special))

;(define (mw:macro? denotation)
;  (eq? (mw:denote-class denotation) 'macro))

(define (mw:identifier? denotation)
  (eq? (mw:denote-class denotation) 'identifier))

(define (mw:make-identifier-denotation id)
  (list 'identifier id))

(define macwork:rules cadr)
(define macwork:env caddr)
(define mw:identifier-name cadr)

(define (mw:same-denotation? d1 d2)
  (or (eq? d1 d2)
      (and (mw:identifier? d1)
	   (mw:identifier? d2)
	   (eq? (mw:identifier-name d1)
		(mw:identifier-name d2)))))

; Renaming of variables.

; Given a datum, strips the suffixes from any symbols that appear within
; the datum, trying not to copy any more of the datum than necessary.

; @@ rewrote to strip *all* suffixes -- wdc

(define mw:strip
  (letrec ((original-symbol
            (lambda (x)
              (let ((s (symbol->string x)))
                (loop x s 0 (string-length s)))))
           (loop
            (lambda (sym s i n)
              (cond ((= i n) sym)
                    ((char=? (string-ref s i)
                             mw:suffix-character)
                     (string->symbol (substring s 0 i)))
                    (else
                     (loop sym s (+ i 1) n))))))
    (lambda (x)
      (cond ((symbol? x)
             (original-symbol x))
            ((pair? x)
             (let ((y (mw:strip (car x)))
                   (z (mw:strip (cdr x))))
               (if (and (eq? y (car x))
                        (eq? z (cdr x)))
                   x
                   (cons y z))))
            ((vector? x)
             (list->vector (map mw:strip (vector->list x))))
            (else x)))))

; Given a list of identifiers, returns an alist that associates each
; identifier with a fresh identifier.

(define (mw:rename-vars vars)
  (set! mw:renaming-counter (+ mw:renaming-counter 1))
  (let ((suffix (string-append (string mw:suffix-character)
			       (number->string mw:renaming-counter))))
    (map (lambda (var)
	   (if (symbol? var)
	       (cons var
		     (string->symbol
		      (string-append (symbol->string var) suffix)))
	       (slib:error "Illegal variable" var)))
	 vars)))

; Given a syntactic environment env to be extended, an alist returned
; by mw:rename-vars, and a syntactic environment env2, extends env by
; binding the fresh identifiers to the denotations of the original
; identifiers in env2.

(define (mw:syntax-alias env alist env2)
  (mw:syntax-divert
   env
   (map (lambda (name-pair)
	  (let ((old-name (car name-pair))
		(new-name (cdr name-pair)))
	    (cons new-name
		  (mw:syntax-lookup env2 old-name))))
	alist)))

; Given a syntactic environment and an alist returned by mw:rename-vars,
; extends the environment by binding the old identifiers to the fresh
; identifiers.

(define (mw:syntax-rename env alist)
  (mw:syntax-divert env
		    (map (lambda (old new)
			   (cons old (mw:make-identifier-denotation new)))
			 (map car alist)
			 (map cdr alist))))

; Given a <formals> and an alist returned by mw:rename-vars that contains
; a new name for each formal identifier in <formals>, renames the
; formal identifiers.

(define (mw:rename-formals formals alist)
  (cond ((null? formals) '())
	((pair? formals)
	 (cons (cdr (assq (car formals) alist))
	       (mw:rename-formals (cdr formals) alist)))
	(else (cdr (assq formals alist)))))

(define mw:renaming-counter 0)
