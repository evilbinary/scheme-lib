;"mwexpand.scm" macro expander
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

; The external entry points and kernel of the macro expander.
;
; Part of this code is snarfed from the Twobit macro expander.

(define mw:define-syntax-scope
  (let ((flag 'letrec))
    (lambda args
      (cond ((null? args) flag)
	    ((not (null? (cdr args)))
	     (apply mw:warn
		    "Too many arguments passed to define-syntax-scope"
		    args))
	    ((memq (car args) '(letrec letrec* let*))
	     (set! flag (car args)))
	    (else (mw:warn "Unrecognized argument to define-syntax-scope"
			  (car args)))))))

(define mw:quit             ; assigned by macwork:expand
  (lambda (v) v))
;@
(define (macwork:expand def-or-exp)
  (call-with-current-continuation
   (lambda (k)
     (set! mw:quit k)
     (set! mw:renaming-counter 0)
     (mw:desugar-definitions def-or-exp mw:global-syntax-environment))))

(define (mw:desugar-definitions exp env)
  (letrec
    ((define-loop
       (lambda (exp rest first)
	 (cond ((and (pair? exp)
		     (eq? (mw:syntax-lookup env (car exp))
			  mw:denote-of-begin)
		     (pair? (cdr exp)))
		(define-loop (cadr exp) (append (cddr exp) rest) first))
	       ((and (pair? exp)
		     (eq? (mw:syntax-lookup env (car exp))
			  mw:denote-of-define))
		(let ((exp (desugar-define exp env)))
		  (cond ((and (null? first) (null? rest))
			 exp)
			((null? rest)
			 (cons mw:begin1 (reverse (cons exp first))))
			(else (define-loop (car rest)
					   (cdr rest)
					   (cons exp first))))))
	       ((and (pair? exp)
		     (eq? (mw:syntax-lookup env (car exp))
			  mw:denote-of-define-syntax)
		     (null? first))
		(define-syntax-loop exp rest))
	       ((and (null? first) (null? rest))
		(mw:expand exp env))
	       ((null? rest)
		(cons mw:begin1 (reverse (cons (mw:expand exp env) first))))
	       (else (cons mw:begin1
			   (append (reverse first)
				   (map (lambda (exp) (mw:expand exp env))
					(cons exp rest))))))))

     (desugar-define
      (lambda (exp env)
	(cond
	 ((null? (cdr exp)) (mw:error "Malformed definition" exp))
	 ; (define foo) syntax is transformed into (define foo (undefined)).
	 ((null? (cddr exp))
	  (let ((id (cadr exp)))
	    (redefinition id)
	    (mw:syntax-bind-globally! id (mw:make-identifier-denotation id))
	    (list mw:define1 id mw:undefined)))
	 ((pair? (cadr exp))
	  ; mw:lambda0 is an unforgeable lambda, needed here because the
	  ; lambda expression will undergo further expansion.
	  (desugar-define `(,mw:define1 ,(car (cadr exp))
				     (,mw:lambda0 ,(cdr (cadr exp))
					       ,@(cddr exp)))
			  env))
	 ((> (length exp) 3) (mw:error "Malformed definition" exp))
	 (else (let ((id (cadr exp)))
		 (redefinition id)
		 (mw:syntax-bind-globally! id (mw:make-identifier-denotation id))
		 `(,mw:define1 ,id ,(mw:expand (caddr exp) env)))))))

     (define-syntax-loop
       (lambda (exp rest)
	 (cond ((and (pair? exp)
		     (eq? (mw:syntax-lookup env (car exp))
			  mw:denote-of-begin)
		     (pair? (cdr exp)))
		(define-syntax-loop (cadr exp) (append (cddr exp) rest)))
	       ((and (pair? exp)
		     (eq? (mw:syntax-lookup env (car exp))
			  mw:denote-of-define-syntax))
		(if (pair? (cdr exp))
		    (redefinition (cadr exp)))
		(if (null? rest)
		    (mw:define-syntax exp env)
		    (begin (mw:define-syntax exp env)
			   (define-syntax-loop (car rest) (cdr rest)))))
	       ((null? rest)
		(mw:expand exp env))
	       (else (cons mw:begin1
			   (map (lambda (exp) (mw:expand exp env))
					(cons exp rest)))))))

     (redefinition
      (lambda (id)
	(if (symbol? id)
	    (if (not (mw:identifier?
		      (mw:syntax-lookup mw:global-syntax-environment id)))
		(mw:warn "Redefining keyword" id))
	    (mw:error "Malformed variable or keyword" id)))))

    ; body of letrec

    (define-loop exp '() '())))

; Given an expression and a syntactic environment,
; returns an expression in core Scheme.

(define (mw:expand exp env)
  (if (not (pair? exp))
      (mw:atom exp env)
      (let ((keyword (mw:syntax-lookup env (car exp))))
	(case (mw:denote-class keyword)
	  ((special)
	   (cond
	    ((eq? keyword mw:denote-of-quote)         (mw:quote exp))
	    ((eq? keyword mw:denote-of-lambda)        (mw:lambda exp env))
	    ((eq? keyword mw:denote-of-if)            (mw:if exp env))
	    ((eq? keyword mw:denote-of-set!)          (mw:set exp env))
	    ((eq? keyword mw:denote-of-begin)         (mw:begin exp env))
	    ((eq? keyword mw:denote-of-let-syntax)    (mw:let-syntax exp env))
	    ((eq? keyword mw:denote-of-letrec-syntax)
	     (mw:letrec-syntax exp env))
     ; @@ case has a nontrivial syntax also -- wdc
     ((eq? keyword mw:denote-of-case)          (mw:case   exp env))
	    ; @@ let, let*, letrec, paint within quasiquotation -- kend
	    ((eq? keyword mw:denote-of-let)           (mw:let    exp env))
	    ((eq? keyword mw:denote-of-let*)          (mw:let*   exp env))
	    ((eq? keyword mw:denote-of-letrec)        (mw:letrec exp env))
	    ((eq? keyword mw:denote-of-quasiquote)    (mw:quasiquote exp env))
	    ((eq? keyword mw:denote-of-do)            (mw:do     exp env))
     ; @@ leave alone define-macro args specs -- stef
     ((eq? keyword mw:denote-of-define-macro)  exp)
     ((eq? keyword mw:denote-of-defmacro)      exp)
	    ((or (eq? keyword mw:denote-of-define)
		 (eq? keyword mw:denote-of-define-syntax))
	     ;; slight hack to allow expansion into defines -KenD
	     (if mw:in-define?
	       (mw:error "Definition out of context" exp)
	       (begin
		 (set! mw:in-define? #t)
		 (let ( (result (mw:desugar-definitions exp env)) )
		   (set! mw:in-define? #f)
		   result))
	    ))
	    (else (mw:bug "Bug detected in mw:expand" exp env))))
	  ((macro) (mw:macro exp env))
	  ((identifier) (mw:application exp env))
	  (else (mw:bug "Bug detected in mw:expand" exp env))
      ) )
) )

(define mw:in-define? #f)  ; should be fluid

(define (mw:atom exp env)
  (cond ((not (symbol? exp))
	 ; Here exp ought to be a boolean, number, character, or string,
	 ; but I'll allow for non-standard extensions by passing exp
	 ; to the underlying Scheme system without further checking.
	 exp)
	(else (let ((denotation (mw:syntax-lookup env exp)))
		(case (mw:denote-class denotation)
		  ((special macro)
		   (mw:error "Syntactic keyword used as a variable" exp env))
		  ((identifier) (mw:identifier-name denotation))
		  (else (mw:bug "Bug detected by mw:atom" exp env)))))))

(define (mw:quote exp)
  (if (= (mw:safe-length exp) 2)
      (list mw:quote1 (mw:strip (cadr exp)))
      (mw:error "Malformed quoted constant" exp)))

(define (mw:lambda exp env)
  (if (> (mw:safe-length exp) 2)
      (let* ((formals (cadr exp))
	     (alist (mw:rename-vars (mw:make-null-terminated formals)))
	     (env (mw:syntax-rename env alist))
	     (body (cddr exp)))
	(list mw:lambda1
	      (mw:rename-formals formals alist)
	      (mw:body body env)))
      (mw:error "Malformed lambda expression" exp)))

(define (mw:body body env)
  (define (loop body env defs)
    (if (null? body)
	(mw:error "Empty body"))
    (let ((exp (car body)))
      (if (and (pair? exp)
	       (symbol? (car exp)))
	  (let ((denotation (mw:syntax-lookup env (car exp))))
	    (case (mw:denote-class denotation)
	      ((special)
	       (cond ((eq? denotation mw:denote-of-begin)
		      (loop (append (cdr exp) (cdr body)) env defs))
		     ((eq? denotation mw:denote-of-define)
		      (loop (cdr body) env (cons exp defs)))
		     (else (mw:finalize-body body env defs))))
	      ((macro)
	       (mw:transcribe exp
			     env
			     (lambda (exp env)
			       (loop (cons exp (cdr body))
				     env
				     defs))))
	      ((identifier)
	       (mw:finalize-body body env defs))
	      (else (mw:bug "Bug detected in mw:body" body env))))
	  (mw:finalize-body body env defs))))
  (loop body env '()))

(define (mw:finalize-body body env defs)
  (if (null? defs)
      (let ((body (map (lambda (exp) (mw:expand exp env))
		       body)))
	(if (null? (cdr body))
	    (car body)
	    (cons mw:begin1 body)))
      (let* ((alist (mw:rename-vars '(quote lambda set!)))
	     (env (mw:syntax-alias env alist mw:standard-syntax-environment))
	     ;;(new-quote  (cdr (assq 'quote alist)))
	     (new-lambda (cdr (assq 'lambda alist)))
	     ;;(new-set!   (cdr (assq 'set!   alist)))
	     )
	(define (desugar-definition def)
	  (if (> (mw:safe-length def) 2)
	      (cond ((pair? (cadr def))
		     (desugar-definition
		      `(,(car def)
			,(car (cadr def))
			(,new-lambda
			  ,(cdr (cadr def))
			  ,@(cddr def)))))
		    ((= (length def) 3)
		     (cdr def))
		    (else (mw:error "Malformed definition" def env)))
	      (mw:error "Malformed definition" def env)))
	(mw:letrec
	 `(letrec ,(map desugar-definition (reverse defs)) ,@body)
	  env)))
  )

(define (mw:if exp env)
  (let ((n (mw:safe-length exp)))
    (if (or (= n 3) (= n 4))
	(cons mw:if1 (map (lambda (exp) (mw:expand exp env)) (cdr exp)))
	(mw:error "Malformed if expression" exp env))))

(define (mw:set exp env)
  (if (= (mw:safe-length exp) 3)
      `(,mw:set!1 ,(mw:expand (cadr exp) env) ,(mw:expand (caddr exp) env))
      (mw:error "Malformed assignment" exp env)))

(define (mw:begin exp env)
  (if (positive? (mw:safe-length exp))
      `(,mw:begin1 ,@(map (lambda (exp) (mw:expand exp env)) (cdr exp)))
      (mw:error "Malformed begin expression" exp env)))

(define (mw:application exp env)
  (if (> (mw:safe-length exp) 0)
      (map (lambda (exp) (mw:expand exp env))
	   exp)
      (mw:error "Malformed application")))

; I think the environment argument should always be global here.

(define (mw:define-syntax exp env)
  (cond ((and (= (mw:safe-length exp) 3)
	      (symbol? (cadr exp)))
	 (mw:define-syntax1 (cadr exp)
			   (caddr exp)
			   env
			   (mw:define-syntax-scope)))
	((and (= (mw:safe-length exp) 4)
	      (symbol? (cadr exp))
	      (memq (caddr exp) '(letrec letrec* let*)))
	 (mw:define-syntax1 (cadr exp)
			   (cadddr exp)
			   env
			   (caddr exp)))
	(else (mw:error "Malformed define-syntax" exp env))))

(define (mw:define-syntax1 keyword spec env scope)
  (case scope
    ((letrec)  (mw:define-syntax-letrec keyword spec env))
    ((letrec*) (mw:define-syntax-letrec* keyword spec env))
    ((let*)    (mw:define-syntax-let* keyword spec env))
    (else      (mw:bug "Weird scope" scope)))
  (list mw:quote1 keyword))

(define (mw:define-syntax-letrec keyword spec env)
  (mw:syntax-bind-globally!
   keyword
   (mw:compile-transformer-spec spec env)))

(define (mw:define-syntax-letrec* keyword spec env)
  (let* ((env (mw:syntax-extend (mw:syntax-copy env)
				(list keyword)
				'((fake denotation))))
	 (transformer (mw:compile-transformer-spec spec env)))
    (mw:syntax-assign! env keyword transformer)
    (mw:syntax-bind-globally! keyword transformer)))

(define (mw:define-syntax-let* keyword spec env)
  (mw:syntax-bind-globally!
   keyword
   (mw:compile-transformer-spec spec (mw:syntax-copy env))))

(define (mw:let-syntax exp env)
  (if (and (> (mw:safe-length exp) 2)
	   (mw:every (lambda (binding)
		       (and (pair? binding)
			    (symbol? (car binding))
			    (pair? (cdr binding))
			    (null? (cddr binding))))
		     (cadr exp)))
      (mw:body (cddr exp)
	       (mw:syntax-extend env
				 (map car (cadr exp))
				 (map (lambda (spec)
					(mw:compile-transformer-spec
					 spec
					 env))
				      (map cadr (cadr exp)))))
      (mw:error "Malformed let-syntax" exp env)))

(define (mw:letrec-syntax exp env)
  (if (and (> (mw:safe-length exp) 2)
	   (mw:every (lambda (binding)
		       (and (pair? binding)
			    (symbol? (car binding))
			    (pair? (cdr binding))
			    (null? (cddr binding))))
		     (cadr exp)))
      (let ((env (mw:syntax-extend env
				   (map car (cadr exp))
				   (map (lambda (id)
					  '(fake denotation))
					(cadr exp)))))
	(for-each (lambda (id spec)
		    (mw:syntax-assign!
		     env
		     id
		     (mw:compile-transformer-spec spec env)))
		  (map car (cadr exp))
		  (map cadr (cadr exp)))
	(mw:body (cddr exp) env))
      (mw:error "Malformed let-syntax" exp env)))

(define (mw:macro exp env)
  (mw:transcribe exp
		env
		(lambda (exp env)
		  (mw:expand exp env))))

; To do:
; Clean up alist hacking et cetera.

;;-----------------------------------------------------------------
;; The following was added to allow expansion without flattening
;; LETs to LAMBDAs so that the origianl structure of the program
;; is preserved by macro expansion.  I.e. so that usual.scm is not
;; required. -- added KenD

(define (mw:process-let-bindings alist binding-list env)  ;; helper proc
  (map (lambda (bind)
	 (list (cdr (assq (car bind) alist)) ; renamed name
	       (mw:body (cdr bind) env)))     ; alpha renamed value expression
       binding-list)
)

(define (mw:strip-begin exp) ;; helper proc: mw:body sometimes puts one in
  (if (and (pair? exp) (eq? (car exp) 'begin))
    (cdr exp)
    exp)
)

; CASE -- added by wdc
(define (mw:case exp env)
  (let ((expand (lambda (exp)
                  (mw:expand exp env))))
    (if (< (mw:safe-length exp) 3)
        (mw:error "Malformed case expression" exp env)
        `(case ,(expand (cadr exp))
               ,@(map (lambda (clause)
                        (if (< (mw:safe-length exp) 2)
                            (mw:error "Malformed case clause" exp env)
                            (cons (mw:strip (car clause))
                                  (map expand (cdr clause)))))
                      (cddr exp))))))


; LET
(define (mw:let exp env)
  (let* ( (name (if (or (pair? (cadr exp)) (null? (cadr exp)))
		    #f
		    (cadr exp)))  ; named let?
	  (binds (if name (caddr exp) (cadr exp)))
	  (body  (if name (cdddr exp) (cddr exp)))
	  (vars  (if (null? binds) #f (map car binds)))
	  (alist (if vars (mw:rename-vars vars) #f))
	  (newenv (if alist (mw:syntax-rename env alist) env))
	)
    (if name  ;; extend env with new name
	(let ( (rename (mw:rename-vars (list name))) )
	  (set! alist (append rename alist))
	  (set! newenv (mw:syntax-rename newenv rename))
    )   )
    `(let
	 ,@(if name (list (cdr (assq name alist))) '())
	 ,(mw:process-let-bindings alist binds env)
	 ,(mw:body body newenv))
) )


; LETREC differs from LET in that the binding values are processed in the
; new rather than the original environment.

(define (mw:letrec exp env)
  (let* ( (binds (cadr exp))
	  (body  (cddr exp))
	  (vars  (if (null? binds) #f (map car binds)))
	  (alist (if vars (mw:rename-vars vars) #f))
	  (newenv (if alist (mw:syntax-rename env alist) env))
	)
    `(letrec
	  ,(mw:process-let-bindings alist binds newenv)
	  ,(mw:body body newenv))
) )


; LET* adds to ENV for each new binding.

(define (mw:let* exp env)
  (let ( (binds (cadr exp))
	 (body  (cddr exp))
       )
    (let bind-loop ( (bindings binds) (newbinds '()) (newenv env) )
       (if (null? bindings)
	  `(let* ,(reverse newbinds) ,(mw:body body newenv))
	   (let* ( (bind (car bindings))
		   (var    (car bind))
		   (valexp (cdr bind))
		   (rename (mw:rename-vars (list var)))
		   (next-newenv (mw:syntax-rename newenv rename))
		 )
	     (bind-loop (cdr bindings)
			(cons (list (cdr (assq var rename))
				    (mw:body valexp newenv))
			      newbinds)
			next-newenv))
) ) ) )


; DO

(define (mw:process-do-bindings var-init-steps alist oldenv newenv)  ;; helper proc
  (map (lambda (vis)
	 (let ( (v (car vis))
		(i (cadr vis))
		(s (if (null? (cddr vis)) (car vis) (caddr vis))))
	   `( ,(cdr (assq v alist)) ; renamed name
	      ,(mw:body (list i) oldenv)     ; init in outer/old env
	      ,(mw:body (list s) newenv) ))) ; step in letrec/inner/new env
       var-init-steps)
)

(define (mw:do exp env)
  (let* ( (vis  (cadr exp))  ; (Var Init Step ...)
	  (ts   (caddr exp)) ; (Test Sequence ...)
	  (com  (cdddr exp)) ; (COMmand ...)
	  (vars (if (null? vis) #f (map car vis)))
	  (rename (if vars (mw:rename-vars vars) #f))
	  (newenv (if vars (mw:syntax-rename env rename) env))
	)
    `(do ,(if vars (mw:process-do-bindings vis rename env newenv) '())
	 ,(if  (null? ts)  '() (mw:strip-begin (mw:body (list ts) newenv)))
	 ,@(if (null? com) '() (list (mw:body com newenv))))
) )

;
; Quasiquotation (backquote)
;
; At level 0, unquoted forms are left painted (not mw:strip'ed).
; At higher levels, forms which are unquoted to level 0 are painted.
; This includes forms within quotes.  E.g.:
;   (lambda (a)
;     (quasiquote
;       (a (unquote a) b (quasiquote (a (unquote (unquote a)) b)))))
;or equivalently:
;  (lambda (a) `(a ,a b `(a ,,a b)))
;=>
;  (lambda (a|1) `(a ,a|1 b `(a ,,a|1 b)))

(define (mw:quasiquote exp env)

  (define (mw:atom exp env)
    (if (not (symbol? exp))
	exp
	(let ((denotation (mw:syntax-lookup env exp)))
	  (case (mw:denote-class denotation)
	    ((special macro identifier) (mw:identifier-name denotation))
	    (else (mw:bug "Bug detected by mw:atom" exp env))))
  ) )

  (define (quasi subexp level)
     (cond
	((null? subexp) subexp)
	((not (or (pair? subexp) (vector? subexp)))
	 (if (zero? level) (mw:atom subexp env) subexp) ; the work is here
	)
	((vector? subexp)
	 (let* ((l (vector-length subexp))
		(v (make-vector l)))
	   (do ((i 0 (+ i 1)))
	       ((= i l) v)
	     (vector-set! v i (quasi (vector-ref subexp i) level))
	     )
	   )
	 )
	(else
	  (let ( (keyword (mw:syntax-lookup env (car subexp))) )
	    (cond
	      ((eq? keyword mw:denote-of-unquote)
	       (cons 'unquote (quasi (cdr subexp) (- level 1)))
	      )
	      ((eq? keyword mw:denote-of-unquote-splicing)
	       (cons 'unquote-splicing (quasi (cdr subexp) (- level 1)))
	      )
	      ((eq? keyword mw:denote-of-quasiquote)
	       (cons 'quasiquote (quasi (cdr subexp) (+ level 1)))
	      )
	      (else
	       (cons (quasi (car subexp) level) (quasi (cdr subexp) level))
	      )
	    )
	) ) ; end else, let
     ) ; end cond
  )

  (quasi exp 0) ; need to unquote to level 0 to paint
)

;;                                      --- E O F ---
