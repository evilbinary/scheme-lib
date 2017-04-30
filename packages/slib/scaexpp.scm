;;; "scaexpp.scm" syntax-case macros
;;; Copyright (C) 1992 R. Kent Dybvig
;;;
;;; Permission to copy this software, in whole or in part, to use this
;;; software for any lawful purpose, and to redistribute this software
;;; is granted subject to the restriction that all copies made of this
;;; software must include this copyright notice in full.  This software
;;; is provided AS IS, with NO WARRANTY, EITHER EXPRESS OR IMPLIED,
;;; INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY
;;; OR FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE
;;; AUTHORS BE LIABLE FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES OF ANY
;;; NATURE WHATSOEVER.

;;; Written by Robert Hieb & Kent Dybvig

;;; This file was munged by a simple minded sed script since it left
;;; its original authors' hands.  See syncase.sh for the horrid details.

(begin ((lambda ()
(letrec ((lambda-var-list (lambda (vars)
((letrec ((lvl (lambda (vars ls)
(if (pair? vars)
(lvl (cdr vars)
(cons (car vars)
ls))
(if (id? vars)
(cons vars
ls)
(if (null?
vars)
ls
(if (syntax-object?
vars)
(lvl (unwrap
vars)
ls)
(cons vars
ls))))))))
lvl)
vars
'())))
(gen-var (lambda (id) (gen-sym (id-sym-name id))))
(gen-sym (lambda (sym)
(syncase:new-symbol-hook (symbol->string sym))))
(strip (lambda (x)
(if (syntax-object? x)
(strip (syntax-object-expression x))
(if (pair? x)
((lambda (a d)
(if (if (eq? a (car x))
(eq? d (cdr x))
#f)
x
(cons a d)))
(strip (car x))
(strip (cdr x)))
(if (vector? x)
((lambda (old)
((lambda (new)
(if (syncase:andmap eq? old new)
x
(list->vector new)))
(map strip old)))
(vector->list x))
x)))))
(regen (lambda (x)
((lambda (g000139)
(if (memv g000139 '(ref))
(syncase:build-lexical-reference (cadr x))
(if (memv g000139 '(primitive))
(syncase:build-global-reference (cadr x))
(if (memv g000139 '(id))
(syncase:build-identifier (cadr x))
(if (memv g000139 '(quote))
(syncase:build-data (cadr x))
(if (memv
g000139
'(lambda))
(syncase:build-lambda
(cadr x)
(regen (caddr x)))
(begin g000139
(syncase:build-application
(syncase:build-global-reference
(car x))
(map regen
(cdr x))))))))))
(car x))))
(gen-vector (lambda (x)
(if (eq? (car x) 'list)
(syncase:list* 'vector (cdr x))
(if (eq? (car x) 'quote)
(list
'quote
(list->vector (cadr x)))
(list 'list->vector x)))))
(gen-append (lambda (x y)
(if (equal? y ''())
x
(list 'append x y))))
(gen-cons (lambda (x y)
(if (eq? (car y) 'list)
(syncase:list* 'list x (cdr y))
(if (if (eq? (car x) 'quote)
(eq? (car y) 'quote)
#f)
(list
'quote
(cons (cadr x) (cadr y)))
(if (equal? y ''())
(list 'list x)
(list 'cons x y))))))
(gen-map (lambda (e map-env)
((lambda (formals actuals)
(if (eq? (car e) 'ref)
(car actuals)
(if (syncase:andmap
(lambda (x)
(if (eq? (car x) 'ref)
(memq (cadr x)
formals)
#f))
(cdr e))
(syncase:list*
'map
(list 'primitive (car e))
(map ((lambda (r)
(lambda (x)
(cdr (assq (cadr x)
r))))
(map cons
formals
actuals))
(cdr e)))
(syncase:list*
'map
(list 'lambda formals e)
actuals))))
(map cdr map-env)
(map (lambda (x) (list 'ref (car x)))
map-env))))
(gen-ref (lambda (var level maps k)
(if (= level 0)
(k var maps)
(gen-ref
var
(- level 1)
(cdr maps)
(lambda (outer-var outer-maps)
((lambda (b)
(if b
(k (cdr b) maps)
((lambda (inner-var)
(k inner-var
(cons (cons (cons outer-var
inner-var)
(car maps))
outer-maps)))
(gen-sym var))))
(assq outer-var (car maps))))))))
(chi-syntax (lambda (src exp r w)
((letrec ((gen (lambda (e maps k)
(if (id? e)
((lambda (n)
((lambda (b)
(if (eq? (binding-type
b)
'syntax)
((lambda (level)
(if (< (length
maps)
level)
(syntax-error
src
"missing ellipsis in")
(gen-ref
n
level
maps
(lambda (x
maps)
(k (list
'ref
x)
maps)))))
(binding-value
b))
(if (ellipsis?
(wrap e
w))
(syntax-error
src
"invalid context for ... in")
(k (list
'id
(wrap e
w))
maps))))
(lookup
n
e
r)))
(id-var-name
e
w))
((lambda (g000141)
((lambda (g000142)
((lambda (g000140)
(if (not (eq? g000140
'no))
((lambda (_dots1
_dots2)
(if (if (ellipsis?
(wrap _dots1
w))
(ellipsis?
(wrap _dots2
w))
#f)
(k (list
'id
(wrap _dots1
w))
maps)
(g000142)))
(car g000140)
(cadr g000140))
(g000142)))
(syntax-dispatch
g000141
'(pair (any)
pair
(any)
atom)
(vector))))
(lambda ()
((lambda (g000144)
((lambda (g000145)
((lambda (g000143)
(if (not (eq? g000143
'no))
((lambda (_x
_dots
_y)
(if (ellipsis?
(wrap _dots
w))
(gen _y
maps
(lambda (y
maps)
(gen _x
(cons '()
maps)
(lambda (x
maps)
(if (null?
(car maps))
(syntax-error
src
"extra ellipsis in")
(k (gen-append
(gen-map
x
(car maps))
y)
(cdr maps)))))))
(g000145)))
(car g000143)
(cadr g000143)
(caddr
g000143))
(g000145)))
(syntax-dispatch
g000144
'(pair (any)
pair
(any)
any)
(vector))))
(lambda ()
((lambda (g000147)
((lambda (g000146)
(if (not (eq? g000146
'no))
((lambda (_x
_y)
(gen _x
maps
(lambda (x
maps)
(gen _y
maps
(lambda (y
maps)
(k (gen-cons
x
y)
maps))))))
(car g000146)
(cadr g000146))
((lambda (g000149)
((lambda (g000148)
(if (not (eq? g000148
'no))
((lambda (_e1
_e2)
(gen (cons _e1
_e2)
maps
(lambda (e
maps)
(k (gen-vector
e)
maps))))
(car g000148)
(cadr g000148))
((lambda (g000151)
((lambda (g000150)
(if (not (eq? g000150
'no))
((lambda (__)
(k (list
'quote
(wrap e
w))
maps))
(car g000150))
(syntax-error
g000151)))
(syntax-dispatch
g000151
'(any)
(vector))))
g000149)))
(syntax-dispatch
g000149
'(vector
pair
(any)
each
any)
(vector))))
g000147)))
(syntax-dispatch
g000147
'(pair (any)
any)
(vector))))
g000144))))
g000141))))
e)))))
gen)
exp
'()
(lambda (e maps) (regen e)))))
(ellipsis? (lambda (x)
;; I dont know what this is supposed to do, and removing it seemed harmless.
;; (if (if (top-level-bound? 'dp) dp #f)
;; (break)
;; (syncase:void))
(if (identifier? x)
(free-id=? x '...)
#f)))
(chi-syntax-definition (lambda (e w)
((lambda (g000153)
((lambda (g000154)
((lambda (g000152)
(if (not (eq? g000152
'no))
((lambda (__
_name
_val)
(if (id? _name)
(list _name
_val)
(g000154)))
(car g000152)
(cadr g000152)
(caddr
g000152))
(g000154)))
(syntax-dispatch
g000153
'(pair (any)
pair
(any)
pair
(any)
atom)
(vector))))
(lambda ()
(syntax-error
g000153))))
(wrap e w))))
(chi-definition (lambda (e w)
((lambda (g000156)
((lambda (g000157)
((lambda (g000155)
(if (not (eq? g000155
'no))
(apply
(lambda (__
_name
_args
_e1
_e2)
(if (if (id? _name)
(valid-bound-ids?
(lambda-var-list
_args))
#f)
(list _name
(cons '#(syntax-object
lambda
(top))
(cons _args
(cons _e1
_e2))))
(g000157)))
g000155)
(g000157)))
(syntax-dispatch
g000156
'(pair (any)
pair
(pair (any) any)
pair
(any)
each
any)
(vector))))
(lambda ()
((lambda (g000159)
((lambda (g000158)
(if (not (eq? g000158
'no))
((lambda (__
_name
_val)
(list _name
_val))
(car g000158)
(cadr g000158)
(caddr
g000158))
((lambda (g000161)
((lambda (g000162)
((lambda (g000160)
(if (not (eq? g000160
'no))
((lambda (__
_name)
(if (id? _name)
(list _name
(list '#(syntax-object
syncase:void
(top))))
(g000162)))
(car g000160)
(cadr g000160))
(g000162)))
(syntax-dispatch
g000161
'(pair (any)
pair
(any)
atom)
(vector))))
(lambda ()
(syntax-error
g000161))))
g000159)))
(syntax-dispatch
g000159
'(pair (any)
pair
(any)
pair
(any)
atom)
(vector))))
g000156))))
(wrap e w))))
(chi-sequence (lambda (e w)
((lambda (g000164)
((lambda (g000163)
(if (not (eq? g000163 'no))
((lambda (__ _e) _e)
(car g000163)
(cadr g000163))
(syntax-error g000164)))
(syntax-dispatch
g000164
'(pair (any) each any)
(vector))))
(wrap e w))))
(chi-macro-def (lambda (def r w)
(syncase:eval-hook (chi def null-env w))))
(chi-local-syntax (lambda (e r w)
((lambda (g000166)
((lambda (g000167)
((lambda (g000165)
(if (not (eq? g000165
'no))
(apply
(lambda (_who
_var
_val
_e1
_e2)
(if (valid-bound-ids?
_var)
((lambda (new-vars)
((lambda (new-w)
(chi-body
(cons _e1
_e2)
e
(extend-macro-env
new-vars
((lambda (w)
(map (lambda (x)
(chi-macro-def
x
r
w))
_val))
(if (free-id=?
_who
'#(syntax-object
letrec-syntax
(top)))
new-w
w))
r)
new-w))
(make-binding-wrap
_var
new-vars
w)))
(map gen-var
_var))
(g000167)))
g000165)
(g000167)))
(syntax-dispatch
g000166
'(pair (any)
pair
(each pair
(any)
pair
(any)
atom)
pair
(any)
each
any)
(vector))))
(lambda ()
((lambda (g000169)
((lambda (g000168)
(if (not (eq? g000168
'no))
((lambda (__)
(syntax-error
(wrap e
w)))
(car g000168))
(syntax-error
g000169)))
(syntax-dispatch
g000169
'(any)
(vector))))
g000166))))
e)))
(chi-body (lambda (body source r w)
(if (null? (cdr body))
(chi (car body) r w)
((letrec ((parse1 (lambda (body
var-ids
var-vals
macro-ids
macro-vals)
(if (null? body)
(syntax-error
(wrap source
w)
"no expressions in body")
((letrec ((parse2 (lambda (e)
((lambda (b)
((lambda (g000170)
(if (memv
g000170
'(macro))
(parse2
(chi-macro
(binding-value
b)
e
r
empty-wrap
(lambda (e
r
w)
(wrap e
w))))
(if (memv
g000170
'(definition))
(parse1
(cdr body)
(cons (cadr b)
var-ids)
(cons (caddr
b)
var-vals)
macro-ids
macro-vals)
(if (memv
g000170
'(syntax-definition))
(parse1
(cdr body)
var-ids
var-vals
(cons (cadr b)
macro-ids)
(cons (caddr
b)
macro-vals))
(if (memv
g000170
'(sequence))
(parse1
(append
(cdr b)
(cdr body))
var-ids
var-vals
macro-ids
macro-vals)
(begin g000170
(if (valid-bound-ids?
(append
var-ids
macro-ids))
((lambda (new-var-names
new-macro-names)
((lambda (w)
((lambda (r)
(syncase:build-letrec
new-var-names
(map (lambda (x)
(chi x
r
w))
var-vals)
(syncase:build-sequence
(map (lambda (x)
(chi x
r
w))
body))))
(extend-macro-env
new-macro-names
(map (lambda (x)
(chi-macro-def
x
r
w))
macro-vals)
(extend-var-env
new-var-names
r))))
(make-binding-wrap
(append
macro-ids
var-ids)
(append
new-macro-names
new-var-names)
empty-wrap)))
(map gen-var
var-ids)
(map gen-var
macro-ids))
(syntax-error
(wrap source
w)
"invalid identifier"))))))))
(car b)))
(syntax-type
e
r
empty-wrap)))))
parse2)
(car body))))))
parse1)
(map (lambda (x) (wrap x w)) body)
'()
'()
'()
'()))))
(syntax-type (lambda (e r w)
(if (syntax-object? e)
(syntax-type
(syntax-object-expression e)
r
(join-wraps
(syntax-object-wrap e)
w))
(if (if (pair? e)
(identifier? (car e))
#f)
((lambda (n)
((lambda (b)
((lambda (g000171)
(if (memv
g000171
'(special))
(if (memv
n
'(define))
(cons 'definition
(chi-definition
e
w))
(if (memv
n
'(define-syntax))
(cons 'syntax-definition
(chi-syntax-definition
e
w))
(if (memv
n
'(begin))
(cons 'sequence
(chi-sequence
e
w))
(begin n
(syncase:void)))))
(begin g000171
b)))
(binding-type b)))
(lookup n (car e) r)))
(id-var-name (car e) w))
'(other)))))
(chi-args (lambda (args r w source source-w)
(if (pair? args)
(cons (chi (car args) r w)
(chi-args
(cdr args)
r
w
source
source-w))
(if (null? args)
'()
(if (syntax-object? args)
(chi-args
(syntax-object-expression
args)
r
(join-wraps
w
(syntax-object-wrap
args))
source
source-w)
(syntax-error
(wrap source source-w)))))))
(chi-ref (lambda (e name binding w)
((lambda (g000172)
(if (memv g000172 '(lexical))
(syncase:build-lexical-reference name)
(if (memv
g000172
'(global global-unbound))
(syncase:build-global-reference name)
(begin g000172
(id-error
(wrap e w))))))
(binding-type binding))))
(chi-macro (letrec ((check-macro-output (lambda (x)
(if (pair?
x)
(begin (check-macro-output
(car x))
(check-macro-output
(cdr x)))
((lambda (g000173)
(if g000173
g000173
(if (vector?
x)
((lambda (n)
((letrec ((g000174 (lambda (i)
(if (= i
n)
(syncase:void)
(begin (check-macro-output
(vector-ref
x
i))
(g000174
(+ i
1)))))))
g000174)
0))
(vector-length
x))
(if (symbol?
x)
(syntax-error
x
"encountered raw symbol")
(syncase:void)))))
(syntax-object?
x))))))
(lambda (p e r w k)
((lambda (mw)
((lambda (x)
(check-macro-output x)
(k x r mw))
(p (wrap e (join-wraps mw w)))))
(new-mark-wrap)))))
(chi-pair (lambda (e r w k)
((lambda (first rest)
(if (id? first)
((lambda (n)
((lambda (b)
((lambda (g000175)
(if (memv
g000175
'(core))
((binding-value b)
e
r
w)
(if (memv
g000175
'(macro))
(chi-macro
(binding-value
b)
e
r
w
k)
(if (memv
g000175
'(special))
((binding-value
b)
e
r
w
k)
(begin g000175
(syncase:build-application
(chi-ref
first
n
b
w)
(chi-args
rest
r
w
e
w)))))))
(binding-type b)))
(lookup n first r)))
(id-var-name first w))
(syncase:build-application
(chi first r w)
(chi-args rest r w e w))))
(car e)
(cdr e))))
(chi (lambda (e r w)
(if (symbol? e)
((lambda (n)
(chi-ref e n (lookup n e r) w))
(id-var-name e w))
(if (pair? e)
(chi-pair e r w chi)
(if (syntax-object? e)
(chi (syntax-object-expression e)
r
(join-wraps
w
(syntax-object-wrap e)))
(if ((lambda (g000176)
(if g000176
g000176
((lambda (g000177)
(if g000177
g000177
((lambda (g000178)
(if g000178
g000178
(char?
e)))
(string? e))))
(number? e))))
(boolean? e))
(syncase:build-data e)
(syntax-error (wrap e w))))))))
(chi-top (lambda (e r w)
(if (pair? e)
(chi-pair e r w chi-top)
(if (syntax-object? e)
(chi-top
(syntax-object-expression e)
r
(join-wraps
w
(syntax-object-wrap e)))
(chi e r w)))))
(wrap (lambda (x w)
(if (null? w)
x
(if (syntax-object? x)
(make-syntax-object
(syntax-object-expression x)
(join-wraps
w
(syntax-object-wrap x)))
(if (null? x)
x
(make-syntax-object x w))))))
(unwrap (lambda (x)
(if (syntax-object? x)
((lambda (e w)
(if (pair? e)
(cons (wrap (car e) w)
(wrap (cdr e) w))
(if (vector? e)
(list->vector
(map (lambda (x)
(wrap x w))
(vector->list e)))
e)))
(syntax-object-expression x)
(syntax-object-wrap x))
x)))
(bound-id-member? (lambda (x list)
(if (not (null? list))
((lambda (g000179)
(if g000179
g000179
(bound-id-member?
x
(cdr list))))
(bound-id=? x (car list)))
#f)))
(valid-bound-ids? (lambda (ids)
(if ((letrec ((all-ids? (lambda (ids)
((lambda (g000181)
(if g000181
g000181
(if (id? (car ids))
(all-ids?
(cdr ids))
#f)))
(null?
ids)))))
all-ids?)
ids)
((letrec ((unique? (lambda (ids)
((lambda (g000180)
(if g000180
g000180
(if (not (bound-id-member?
(car ids)
(cdr ids)))
(unique?
(cdr ids))
#f)))
(null?
ids)))))
unique?)
ids)
#f)))
(bound-id=? (lambda (i j)
(if (eq? (id-sym-name i)
(id-sym-name j))
((lambda (i j)
(if (eq? (car i) (car j))
(same-marks?
(cdr i)
(cdr j))
#f))
(id-var-name&marks i empty-wrap)
(id-var-name&marks j empty-wrap))
#f)))
(free-id=? (lambda (i j)
(if (eq? (id-sym-name i) (id-sym-name j))
(eq? (id-var-name i empty-wrap)
(id-var-name j empty-wrap))
#f)))
(id-var-name&marks (lambda (id w)
(if (null? w)
(if (symbol? id)
(list id)
(id-var-name&marks
(syntax-object-expression
id)
(syntax-object-wrap
id)))
((lambda (n&m first)
(if (pair? first)
((lambda (n)
((letrec ((search (lambda (rib)
(if (null?
rib)
n&m
(if (if (eq? (caar rib)
n)
(same-marks?
(cdr n&m)
(cddar
rib))
#f)
(cdar rib)
(search
(cdr rib)))))))
search)
first))
(car n&m))
(cons (car n&m)
(if ((lambda (g000182)
(if g000182
g000182
(not (eqv? first
(cadr n&m)))))
(null?
(cdr n&m)))
(cons first
(cdr n&m))
(cddr n&m)))))
(id-var-name&marks
id
(cdr w))
(car w)))))
(id-var-name (lambda (id w)
(if (null? w)
(if (symbol? id)
id
(id-var-name
(syntax-object-expression
id)
(syntax-object-wrap id)))
(if (pair? (car w))
(car (id-var-name&marks id w))
(id-var-name id (cdr w))))))
(same-marks? (lambda (x y)
(if (null? x)
(null? y)
(if (not (null? y))
(if (eqv? (car x) (car y))
(same-marks?
(cdr x)
(cdr y))
#f)
#f))))
(join-wraps2 (lambda (w1 w2)
((lambda (x w1)
(if (null? w1)
(if (if (not (pair? x))
(eqv? x (car w2))
#f)
(cdr w2)
(cons x w2))
(cons x (join-wraps2 w1 w2))))
(car w1)
(cdr w1))))
(join-wraps1 (lambda (w1 w2)
(if (null? w1)
w2
(cons (car w1)
(join-wraps1 (cdr w1) w2)))))
(join-wraps (lambda (w1 w2)
(if (null? w2)
w1
(if (null? w1)
w2
(if (pair? (car w2))
(join-wraps1 w1 w2)
(join-wraps2 w1 w2))))))
(make-wrap-rib (lambda (ids new-names w)
(if (null? ids)
'()
(cons ((lambda (n&m)
(cons (car n&m)
(cons (car new-names)
(cdr n&m))))
(id-var-name&marks
(car ids)
w))
(make-wrap-rib
(cdr ids)
(cdr new-names)
w)))))
(make-binding-wrap (lambda (ids new-names w)
(if (null? ids)
w
(cons (make-wrap-rib
ids
new-names
w)
w))))
(new-mark-wrap (lambda ()
(set! current-mark
(+ current-mark 1))
(list current-mark)))
(current-mark 0)
(top-wrap '(top))
(empty-wrap '())
(id-sym-name (lambda (x)
(if (symbol? x)
x
(syntax-object-expression x))))
(id? (lambda (x)
((lambda (g000183)
(if g000183
g000183
(if (syntax-object? x)
(symbol?
(syntax-object-expression x))
#f)))
(symbol? x))))
(global-extend (lambda (type sym val)
(extend-global-env
sym
(cons type val))))
(lookup (lambda (name id r)
(if (eq? name (id-sym-name id))
(global-lookup name)
((letrec ((search (lambda (r name)
(if (null? r)
'(displaced-lexical)
(if (pair?
(car r))
(if (eq? (caar r)
name)
(cdar r)
(search
(cdr r)
name))
(if (eq? (car r)
name)
'(lexical)
(search
(cdr r)
name)))))))
search)
r
name))))
(extend-syntax-env (lambda (vars vals r)
(if (null? vars)
r
(cons (cons (car vars)
(cons 'syntax
(car vals)))
(extend-syntax-env
(cdr vars)
(cdr vals)
r)))))
(extend-var-env append)
(extend-macro-env (lambda (vars vals r)
(if (null? vars)
r
(cons (cons (car vars)
(cons 'macro
(car vals)))
(extend-macro-env
(cdr vars)
(cdr vals)
r)))))
(null-env '())
(global-lookup (lambda (sym)
((lambda (g000184)
(if g000184
g000184
'(global-unbound)))
(syncase:get-global-definition-hook sym))))
(extend-global-env (lambda (sym binding)
(syncase:put-global-definition-hook
sym
binding)))
(binding-value cdr)
(binding-type car)
(arg-check (lambda (pred? x who)
(if (not (pred? x))
(syncase:error-hook who "invalid argument" x)
(syncase:void))))
(id-error (lambda (x)
(syntax-error
x
"invalid context for identifier")))
(scope-error (lambda (id)
(syntax-error
id
"invalid context for bound identifier")))
(syntax-object-wrap (lambda (x) (vector-ref x 2)))
(syntax-object-expression (lambda (x) (vector-ref x 1)))
(make-syntax-object (lambda (expression wrap)
(vector
'syntax-object
expression
wrap)))
(syntax-object? (lambda (x)
(if (vector? x)
(if (= (vector-length x) 3)
(eq? (vector-ref x 0)
'syntax-object)
#f)
#f))))
(global-extend 'core 'letrec-syntax chi-local-syntax)
(global-extend 'core 'let-syntax chi-local-syntax)
(global-extend
'core
'quote
(lambda (e r w)
((lambda (g000136)
((lambda (g000135)
(if (not (eq? g000135 'no))
((lambda (__ _e) (syncase:build-data (strip _e)))
(car g000135)
(cadr g000135))
((lambda (g000138)
((lambda (g000137)
(if (not (eq? g000137 'no))
((lambda (__)
(syntax-error (wrap e w)))
(car g000137))
(syntax-error g000138)))
(syntax-dispatch
g000138
'(any)
(vector))))
g000136)))
(syntax-dispatch
g000136
'(pair (any) pair (any) atom)
(vector))))
e)))
(global-extend
'core
'syntax
(lambda (e r w)
((lambda (g000132)
((lambda (g000131)
(if (not (eq? g000131 'no))
((lambda (__ _x) (chi-syntax e _x r w))
(car g000131)
(cadr g000131))
((lambda (g000134)
((lambda (g000133)
(if (not (eq? g000133 'no))
((lambda (__)
(syntax-error (wrap e w)))
(car g000133))
(syntax-error g000134)))
(syntax-dispatch
g000134
'(any)
(vector))))
g000132)))
(syntax-dispatch
g000132
'(pair (any) pair (any) atom)
(vector))))
e)))
(global-extend
'core
'syntax-lambda
(lambda (e r w)
((lambda (g000127)
((lambda (g000128)
((lambda (g000126)
(if (not (eq? g000126 'no))
((lambda (__ _id _level _exp)
(if (if (valid-bound-ids? _id)
(map (lambda (x)
(if (integer? x)
(if (exact? x)
(not (negative?
x))
#f)
#f))
(map unwrap _level))
#f)
((lambda (new-vars)
(syncase:build-lambda
new-vars
(chi _exp
(extend-syntax-env
new-vars
(map unwrap
_level)
r)
(make-binding-wrap
_id
new-vars
w))))
(map gen-var _id))
(g000128)))
(car g000126)
(cadr g000126)
(caddr g000126)
(cadddr g000126))
(g000128)))
(syntax-dispatch
g000127
'(pair (any)
pair
(each pair (any) pair (any) atom)
pair
(any)
atom)
(vector))))
(lambda ()
((lambda (g000130)
((lambda (g000129)
(if (not (eq? g000129 'no))
((lambda (__)
(syntax-error (wrap e w)))
(car g000129))
(syntax-error g000130)))
(syntax-dispatch
g000130
'(any)
(vector))))
g000127))))
e)))
(global-extend
'core
'lambda
(lambda (e r w)
((lambda (g000121)
((lambda (g000120)
(if (not (eq? g000120 'no))
((lambda (__ _id _e1 _e2)
(if (not (valid-bound-ids? _id))
(syntax-error
(wrap e w)
"invalid parameter list")
((lambda (new-vars)
(syncase:build-lambda
new-vars
(chi-body
(cons _e1 _e2)
e
(extend-var-env
new-vars
r)
(make-binding-wrap
_id
new-vars
w))))
(map gen-var _id))))
(car g000120)
(cadr g000120)
(caddr g000120)
(cadddr g000120))
((lambda (g000123)
((lambda (g000122)
(if (not (eq? g000122 'no))
((lambda (__ _ids _e1 _e2)
((lambda (old-ids)
(if (not (valid-bound-ids?
(lambda-var-list
_ids)))
(syntax-error
(wrap e w)
"invalid parameter list")
((lambda (new-vars)
(syncase:build-improper-lambda
(reverse
(cdr new-vars))
(car new-vars)
(chi-body
(cons _e1
_e2)
e
(extend-var-env
new-vars
r)
(make-binding-wrap
old-ids
new-vars
w))))
(map gen-var
old-ids))))
(lambda-var-list _ids)))
(car g000122)
(cadr g000122)
(caddr g000122)
(cadddr g000122))
((lambda (g000125)
((lambda (g000124)
(if (not (eq? g000124
'no))
((lambda (__)
(syntax-error
(wrap e w)))
(car g000124))
(syntax-error
g000125)))
(syntax-dispatch
g000125
'(any)
(vector))))
g000123)))
(syntax-dispatch
g000123
'(pair (any)
pair
(any)
pair
(any)
each
any)
(vector))))
g000121)))
(syntax-dispatch
g000121
'(pair (any)
pair
(each any)
pair
(any)
each
any)
(vector))))
e)))
(global-extend
'core
'letrec
(lambda (e r w)
((lambda (g000116)
((lambda (g000117)
((lambda (g000115)
(if (not (eq? g000115 'no))
(apply
(lambda (__ _id _val _e1 _e2)
(if (valid-bound-ids? _id)
((lambda (new-vars)
((lambda (w r)
(syncase:build-letrec
new-vars
(map (lambda (x)
(chi x
r
w))
_val)
(chi-body
(cons _e1 _e2)
e
r
w)))
(make-binding-wrap
_id
new-vars
w)
(extend-var-env
new-vars
r)))
(map gen-var _id))
(g000117)))
g000115)
(g000117)))
(syntax-dispatch
g000116
'(pair (any)
pair
(each pair (any) pair (any) atom)
pair
(any)
each
any)
(vector))))
(lambda ()
((lambda (g000119)
((lambda (g000118)
(if (not (eq? g000118 'no))
((lambda (__)
(syntax-error (wrap e w)))
(car g000118))
(syntax-error g000119)))
(syntax-dispatch
g000119
'(any)
(vector))))
g000116))))
e)))
(global-extend
'core
'if
(lambda (e r w)
((lambda (g000110)
((lambda (g000109)
(if (not (eq? g000109 'no))
((lambda (__ _test _then)
(syncase:build-conditional
(chi _test r w)
(chi _then r w)
(chi (list '#(syntax-object
syncase:void
(top)))
r
empty-wrap)))
(car g000109)
(cadr g000109)
(caddr g000109))
((lambda (g000112)
((lambda (g000111)
(if (not (eq? g000111 'no))
((lambda (__ _test _then _else)
(syncase:build-conditional
(chi _test r w)
(chi _then r w)
(chi _else r w)))
(car g000111)
(cadr g000111)
(caddr g000111)
(cadddr g000111))
((lambda (g000114)
((lambda (g000113)
(if (not (eq? g000113
'no))
((lambda (__)
(syntax-error
(wrap e w)))
(car g000113))
(syntax-error
g000114)))
(syntax-dispatch
g000114
'(any)
(vector))))
g000112)))
(syntax-dispatch
g000112
'(pair (any)
pair
(any)
pair
(any)
pair
(any)
atom)
(vector))))
g000110)))
(syntax-dispatch
g000110
'(pair (any) pair (any) pair (any) atom)
(vector))))
e)))
(global-extend
'core
'set!
(lambda (e r w)
((lambda (g000104)
((lambda (g000105)
((lambda (g000103)
(if (not (eq? g000103 'no))
((lambda (__ _id _val)
(if (id? _id)
((lambda (val n)
((lambda (g000108)
(if (memv
g000108
'(lexical))
(syncase:build-lexical-assignment
n
val)
(if (memv
g000108
'(global
global-unbound))
(syncase:build-global-assignment
n
val)
(begin g000108
(id-error
(wrap _id
w))))))
(binding-type
(lookup n _id r))))
(chi _val r w)
(id-var-name _id w))
(g000105)))
(car g000103)
(cadr g000103)
(caddr g000103))
(g000105)))
(syntax-dispatch
g000104
'(pair (any) pair (any) pair (any) atom)
(vector))))
(lambda ()
((lambda (g000107)
((lambda (g000106)
(if (not (eq? g000106 'no))
((lambda (__)
(syntax-error (wrap e w)))
(car g000106))
(syntax-error g000107)))
(syntax-dispatch
g000107
'(any)
(vector))))
g000104))))
e)))
(global-extend
'special
'begin
(lambda (e r w k)
((lambda (body)
(if (null? body)
(if (eqv? k chi-top)
(chi (list '#(syntax-object syncase:void (top)))
r
empty-wrap)
(syntax-error
(wrap e w)
"no expressions in body of"))
(syncase:build-sequence
((letrec ((dobody (lambda (body)
(if (null? body)
'()
((lambda (first)
(cons first
(dobody
(cdr body))))
(k (car body)
r
empty-wrap))))))
dobody)
body))))
(chi-sequence e w))))
(global-extend
'special
'define
(lambda (e r w k)
(if (eqv? k chi-top)
((lambda (n&v)
((lambda (n)
(global-extend 'global n '())
(syncase:build-global-definition
n
(chi (cadr n&v) r empty-wrap)))
(id-var-name (car n&v) empty-wrap)))
(chi-definition e w))
(syntax-error
(wrap e w)
"invalid context for definition"))))
(global-extend
'special
'define-syntax
(lambda (e r w k)
(if (eqv? k chi-top)
((lambda (n&v)
(global-extend
'macro
(id-var-name (car n&v) empty-wrap)
(chi-macro-def (cadr n&v) r empty-wrap))
(chi (list '#(syntax-object syncase:void (top)))
r
empty-wrap))
(chi-syntax-definition e w))
(syntax-error
(wrap e w)
"invalid context for definition"))))
(set! expand-syntax
(lambda (x) (chi-top x null-env top-wrap)))
(set! implicit-identifier
(lambda (id sym)
(arg-check id? id 'implicit-identifier)
(arg-check symbol? sym 'implicit-identifier)
(if (syntax-object? id)
(wrap sym (syntax-object-wrap id))
sym)))
(set! syntax-object->datum (lambda (x) (strip x)))
(set! generate-temporaries
(lambda (ls)
(arg-check list? ls 'generate-temporaries)
(map (lambda (x) (wrap (syncase:new-symbol-hook "g") top-wrap)) ls)))
(set! free-identifier=?
(lambda (x y)
(arg-check id? x 'free-identifier=?)
(arg-check id? y 'free-identifier=?)
(free-id=? x y)))
(set! bound-identifier=?
(lambda (x y)
(arg-check id? x 'bound-identifier=?)
(arg-check id? y 'bound-identifier=?)
(bound-id=? x y)))
(set! identifier? (lambda (x) (id? x)))
(set! syntax-error
(lambda (object . messages)
(for-each
(lambda (x) (arg-check string? x 'syntax-error))
messages)
((lambda (message)
(syncase:error-hook 'expand-syntax message (strip object)))
(if (null? messages)
"invalid syntax"
(apply string-append messages)))))
(set! syncase:install-global-transformer
(lambda (sym p) (global-extend 'macro sym p)))
((lambda ()
(letrec ((match (lambda (e p k w r)
(if (eq? r 'no)
r
((lambda (g000100)
(if (memv g000100 '(any))
(cons (wrap e w) r)
(if (memv
g000100
'(free-id))
(if (if (identifier?
e)
(free-id=?
(wrap e w)
(vector-ref
k
(cdr p)))
#f)
r
'no)
(begin g000100
(if (syntax-object?
e)
(match*
(syntax-object-expression
e)
p
k
(join-wraps
w
(syntax-object-wrap
e))
r)
(match*
e
p
k
w
r))))))
(car p)))))
(match* (lambda (e p k w r)
((lambda (g000101)
(if (memv g000101 '(pair))
(if (pair? e)
(match
(car e)
(cadr p)
k
w
(match
(cdr e)
(cddr p)
k
w
r))
'no)
(if (memv g000101 '(each))
(if (eq? (cadr p) 'any)
((lambda (l)
(if (eq? l 'no)
l
(cons l r)))
(match-each-any
e
w))
(if (null? e)
(match-empty
(cdr p)
r)
((lambda (l)
(if (eq? l
'no)
l
((letrec ((collect (lambda (l)
(if (null?
(car l))
r
(cons (map car
l)
(collect
(map cdr
l)))))))
collect)
l)))
(match-each
e
(cdr p)
k
w))))
(if (memv
g000101
'(atom))
(if (equal?
(cdr p)
e)
r
'no)
(if (memv
g000101
'(vector))
(if (vector? e)
(match
(vector->list
e)
(cdr p)
k
w
r)
'no)
(begin g000101
(syncase:void)))))))
(car p))))
(match-empty (lambda (p r)
((lambda (g000102)
(if (memv g000102 '(any))
(cons '() r)
(if (memv
g000102
'(each))
(match-empty
(cdr p)
r)
(if (memv
g000102
'(pair))
(match-empty
(cadr p)
(match-empty
(cddr p)
r))
(if (memv
g000102
'(free-id
atom))
r
(if (memv
g000102
'(vector))
(match-empty
(cdr p)
r)
(begin g000102
(syncase:void))))))))
(car p))))
(match-each-any (lambda (e w)
(if (pair? e)
((lambda (l)
(if (eq? l 'no)
l
(cons (wrap (car e)
w)
l)))
(match-each-any
(cdr e)
w))
(if (null? e)
'()
(if (syntax-object?
e)
(match-each-any
(syntax-object-expression
e)
(join-wraps
w
(syntax-object-wrap
e)))
'no)))))
(match-each (lambda (e p k w)
(if (pair? e)
((lambda (first)
(if (eq? first 'no)
first
((lambda (rest)
(if (eq? rest
'no)
rest
(cons first
rest)))
(match-each
(cdr e)
p
k
w))))
(match (car e) p k w '()))
(if (null? e)
'()
(if (syntax-object? e)
(match-each
(syntax-object-expression
e)
p
k
(join-wraps
w
(syntax-object-wrap
e)))
'no))))))
(set! syntax-dispatch
(lambda (expression pattern keys)
(match
expression
pattern
keys
empty-wrap
'())))))))))
(syncase:install-global-transformer
'let
(lambda (x)
((lambda (g00095)
((lambda (g00096)
((lambda (g00094)
(if (not (eq? g00094 'no))
(apply
(lambda (__ _x _v _e1 _e2)
(if (syncase:andmap identifier? _x)
(cons (cons '#(syntax-object
lambda
(top))
(cons _x
(cons _e1 _e2)))
_v)
(g00096)))
g00094)
(g00096)))
(syntax-dispatch
g00095
'(pair (any)
pair
(each pair (any) pair (any) atom)
pair
(any)
each
any)
(vector))))
(lambda ()
((lambda (g00098)
((lambda (g00099)
((lambda (g00097)
(if (not (eq? g00097 'no))
(apply
(lambda (__ _f _x _v _e1 _e2)
(if (syncase:andmap
identifier?
(cons _f _x))
(cons (list '#(syntax-object
letrec
(top))
(list (list _f
(cons '#(syntax-object
lambda
(top))
(cons _x
(cons _e1
_e2)))))
_f)
_v)
(g00099)))
g00097)
(g00099)))
(syntax-dispatch
g00098
'(pair (any)
pair
(any)
pair
(each pair (any) pair (any) atom)
pair
(any)
each
any)
(vector))))
(lambda () (syntax-error g00098))))
g00095))))
x)))
(syncase:install-global-transformer
'syntax-case
((lambda ()
(letrec ((syncase:build-dispatch-call (lambda (args body val)
((lambda (g00046)
((lambda (g00045)
(if (not (eq? g00045
'no))
body
((lambda (g00048)
((lambda (g00047)
(if (not (eq? g00047
'no))
((lambda (_arg1)
((lambda (g00066)
((lambda (g00065)
(if (not (eq? g00065
'no))
((lambda (_body
_val)
(list (list '#(syntax-object
syntax-lambda
(top))
(list _arg1)
_body)
(list '#(syntax-object
car
(top))
_val)))
(car g00065)
(cadr g00065))
(syntax-error
g00066)))
(syntax-dispatch
g00066
'(pair (any)
pair
(any)
atom)
(vector))))
(list body
val)))
(car g00047))
((lambda (g00050)
((lambda (g00049)
(if (not (eq? g00049
'no))
((lambda (_arg1
_arg2)
((lambda (g00064)
((lambda (g00063)
(if (not (eq? g00063
'no))
((lambda (_body
_val)
(list (list '#(syntax-object
syntax-lambda
(top))
(list _arg1
_arg2)
_body)
(list '#(syntax-object
car
(top))
_val)
(list '#(syntax-object
cadr
(top))
_val)))
(car g00063)
(cadr g00063))
(syntax-error
g00064)))
(syntax-dispatch
g00064
'(pair (any)
pair
(any)
atom)
(vector))))
(list body
val)))
(car g00049)
(cadr g00049))
((lambda (g00052)
((lambda (g00051)
(if (not (eq? g00051
'no))
((lambda (_arg1
_arg2
_arg3)
((lambda (g00062)
((lambda (g00061)
(if (not (eq? g00061
'no))
((lambda (_body
_val)
(list (list '#(syntax-object
syntax-lambda
(top))
(list _arg1
_arg2
_arg3)
_body)
(list '#(syntax-object
car
(top))
_val)
(list '#(syntax-object
cadr
(top))
_val)
(list '#(syntax-object
caddr
(top))
_val)))
(car g00061)
(cadr g00061))
(syntax-error
g00062)))
(syntax-dispatch
g00062
'(pair (any)
pair
(any)
atom)
(vector))))
(list body
val)))
(car g00051)
(cadr g00051)
(caddr
g00051))
((lambda (g00054)
((lambda (g00053)
(if (not (eq? g00053
'no))
((lambda (_arg1
_arg2
_arg3
_arg4)
((lambda (g00060)
((lambda (g00059)
(if (not (eq? g00059
'no))
((lambda (_body
_val)
(list (list '#(syntax-object
syntax-lambda
(top))
(list _arg1
_arg2
_arg3
_arg4)
_body)
(list '#(syntax-object
car
(top))
_val)
(list '#(syntax-object
cadr
(top))
_val)
(list '#(syntax-object
caddr
(top))
_val)
(list '#(syntax-object
cadddr
(top))
_val)))
(car g00059)
(cadr g00059))
(syntax-error
g00060)))
(syntax-dispatch
g00060
'(pair (any)
pair
(any)
atom)
(vector))))
(list body
val)))
(car g00053)
(cadr g00053)
(caddr
g00053)
(cadddr
g00053))
((lambda (g00056)
((lambda (g00055)
(if (not (eq? g00055
'no))
((lambda (_arg)
((lambda (g00058)
((lambda (g00057)
(if (not (eq? g00057
'no))
((lambda (_body
_val)
(list '#(syntax-object
apply
(top))
(list '#(syntax-object
syntax-lambda
(top))
_arg
_body)
_val))
(car g00057)
(cadr g00057))
(syntax-error
g00058)))
(syntax-dispatch
g00058
'(pair (any)
pair
(any)
atom)
(vector))))
(list body
val)))
(car g00055))
(syntax-error
g00056)))
(syntax-dispatch
g00056
'(each any)
(vector))))
g00054)))
(syntax-dispatch
g00054
'(pair (any)
pair
(any)
pair
(any)
pair
(any)
atom)
(vector))))
g00052)))
(syntax-dispatch
g00052
'(pair (any)
pair
(any)
pair
(any)
atom)
(vector))))
g00050)))
(syntax-dispatch
g00050
'(pair (any)
pair
(any)
atom)
(vector))))
g00048)))
(syntax-dispatch
g00048
'(pair (any)
atom)
(vector))))
g00046)))
(syntax-dispatch
g00046
'(atom)
(vector))))
args)))
(extract-bound-syntax-ids (lambda (pattern keys)
((letrec ((gen (lambda (p
n
ids)
(if (identifier?
p)
(if (key? p
keys)
ids
(cons (list p
n)
ids))
((lambda (g00068)
((lambda (g00069)
((lambda (g00067)
(if (not (eq? g00067
'no))
((lambda (_x
_dots)
(if (ellipsis?
_dots)
(gen _x
(+ n
1)
ids)
(g00069)))
(car g00067)
(cadr g00067))
(g00069)))
(syntax-dispatch
g00068
'(pair (any)
pair
(any)
atom)
(vector))))
(lambda ()
((lambda (g00071)
((lambda (g00070)
(if (not (eq? g00070
'no))
((lambda (_x
_y)
(gen _x
n
(gen _y
n
ids)))
(car g00070)
(cadr g00070))
((lambda (g00073)
((lambda (g00072)
(if (not (eq? g00072
'no))
((lambda (_x)
(gen _x
n
ids))
(car g00072))
((lambda (g00075)
((lambda (g00074)
(if (not (eq? g00074
'no))
((lambda (_x)
ids)
(car g00074))
(syntax-error
g00075)))
(syntax-dispatch
g00075
'(any)
(vector))))
g00073)))
(syntax-dispatch
g00073
'(vector
each
any)
(vector))))
g00071)))
(syntax-dispatch
g00071
'(pair (any)
any)
(vector))))
g00068))))
p)))))
gen)
pattern
0
'())))
(valid-syntax-pattern? (lambda (pattern keys)
(letrec ((check? (lambda (p
ids)
(if (identifier?
p)
(if (eq? ids
'no)
ids
(if (key? p
keys)
ids
(if (if (not (ellipsis?
p))
(not (memid
p
ids))
#f)
(cons p
ids)
'no)))
((lambda (g00077)
((lambda (g00078)
((lambda (g00076)
(if (not (eq? g00076
'no))
((lambda (_x
_dots)
(if (ellipsis?
_dots)
(check?
_x
ids)
(g00078)))
(car g00076)
(cadr g00076))
(g00078)))
(syntax-dispatch
g00077
'(pair (any)
pair
(any)
atom)
(vector))))
(lambda ()
((lambda (g00080)
((lambda (g00079)
(if (not (eq? g00079
'no))
((lambda (_x
_y)
(check?
_x
(check?
_y
ids)))
(car g00079)
(cadr g00079))
((lambda (g00082)
((lambda (g00081)
(if (not (eq? g00081
'no))
((lambda (_x)
(check?
_x
ids))
(car g00081))
((lambda (g00084)
((lambda (g00083)
(if (not (eq? g00083
'no))
((lambda (_x)
ids)
(car g00083))
(syntax-error
g00084)))
(syntax-dispatch
g00084
'(any)
(vector))))
g00082)))
(syntax-dispatch
g00082
'(vector
each
any)
(vector))))
g00080)))
(syntax-dispatch
g00080
'(pair (any)
any)
(vector))))
g00077))))
p)))))
(not (eq? (check?
pattern
'())
'no)))))
(valid-keyword? (lambda (k)
(if (identifier? k)
(not (free-identifier=?
k
'...))
#f)))
(convert-syntax-dispatch-pattern (lambda (pattern
keys)
((letrec ((gen (lambda (p)
(if (identifier?
p)
(if (key? p
keys)
(cons '#(syntax-object
free-id
(top))
(key-index
p
keys))
(list '#(syntax-object
any
(top))))
((lambda (g00086)
((lambda (g00087)
((lambda (g00085)
(if (not (eq? g00085
'no))
((lambda (_x
_dots)
(if (ellipsis?
_dots)
(cons '#(syntax-object
each
(top))
(gen _x))
(g00087)))
(car g00085)
(cadr g00085))
(g00087)))
(syntax-dispatch
g00086
'(pair (any)
pair
(any)
atom)
(vector))))
(lambda ()
((lambda (g00089)
((lambda (g00088)
(if (not (eq? g00088
'no))
((lambda (_x
_y)
(cons '#(syntax-object
pair
(top))
(cons (gen _x)
(gen _y))))
(car g00088)
(cadr g00088))
((lambda (g00091)
((lambda (g00090)
(if (not (eq? g00090
'no))
((lambda (_x)
(cons '#(syntax-object
vector
(top))
(gen _x)))
(car g00090))
((lambda (g00093)
((lambda (g00092)
(if (not (eq? g00092
'no))
((lambda (_x)
(cons '#(syntax-object
atom
(top))
p))
(car g00092))
(syntax-error
g00093)))
(syntax-dispatch
g00093
'(any)
(vector))))
g00091)))
(syntax-dispatch
g00091
'(vector
each
any)
(vector))))
g00089)))
(syntax-dispatch
g00089
'(pair (any)
any)
(vector))))
g00086))))
p)))))
gen)
pattern)))
(key-index (lambda (p keys)
(- (length keys)
(length (memid p keys)))))
(key? (lambda (p keys)
(if (identifier? p) (memid p keys) #f)))
(memid (lambda (i ids)
(if (not (null? ids))
(if (bound-identifier=? i (car ids))
ids
(memid i (cdr ids)))
#f)))
(ellipsis? (lambda (x)
(if (identifier? x)
(free-identifier=? x '...)
#f))))
(lambda (x)
((lambda (g00030)
((lambda (g00031)
((lambda (g00029)
(if (not (eq? g00029 'no))
((lambda (__ _val _key)
(if (syncase:andmap valid-keyword? _key)
(list '#(syntax-object
syntax-error
(top))
_val)
(g00031)))
(car g00029)
(cadr g00029)
(caddr g00029))
(g00031)))
(syntax-dispatch
g00030
'(pair (any)
pair
(any)
pair
(each any)
atom)
(vector))))
(lambda ()
((lambda (g00033)
((lambda (g00034)
((lambda (g00032)
(if (not (eq? g00032 'no))
(apply
(lambda (__
_val
_key
_pat
_exp)
(if (if (identifier?
_pat)
(if (syncase:andmap
valid-keyword?
_key)
(syncase:andmap
(lambda (x)
(not (free-identifier=?
_pat
x)))
(cons '...
_key))
#f)
#f)
(list (list '#(syntax-object
syntax-lambda
(top))
(list (list _pat
0))
_exp)
_val)
(g00034)))
g00032)
(g00034)))
(syntax-dispatch
g00033
'(pair (any)
pair
(any)
pair
(each any)
pair
(pair (any) pair (any) atom)
atom)
(vector))))
(lambda ()
((lambda (g00036)
((lambda (g00037)
((lambda (g00035)
(if (not (eq? g00035 'no))
(apply
(lambda (__
_val
_key
_pat
_exp
_e1
_e2
_e3)
(if (if (syncase:andmap
valid-keyword?
_key)
(valid-syntax-pattern?
_pat
_key)
#f)
((lambda (g00044)
((lambda (g00043)
(if (not (eq? g00043
'no))
((lambda (_pattern
_y
_call)
(list '#(syntax-object
let
(top))
(list (list '#(syntax-object
x
(top))
_val))
(list '#(syntax-object
let
(top))
(list (list _y
(list '#(syntax-object
syntax-dispatch
(top))
'#(syntax-object
x
(top))
(list '#(syntax-object
quote
(top))
_pattern)
(list '#(syntax-object
syntax
(top))
(list->vector
_key)))))
(list '#(syntax-object
if
(top))
(list '#(syntax-object
not
(top))
(list '#(syntax-object
eq?
(top))
_y
(list '#(syntax-object
quote
(top))
'#(syntax-object
no
(top)))))
_call
(cons '#(syntax-object
syntax-case
(top))
(cons '#(syntax-object
x
(top))
(cons _key
(map (lambda (__e1
__e2
__e3)
(cons __e1
(cons __e2
__e3)))
_e1
_e2
_e3))))))))
(car g00043)
(cadr g00043)
(caddr
g00043))
(syntax-error
g00044)))
(syntax-dispatch
g00044
'(pair (any)
pair
(any)
pair
(any)
atom)
(vector))))
(list (convert-syntax-dispatch-pattern
_pat
_key)
'#(syntax-object
y
(top))
(syncase:build-dispatch-call
(extract-bound-syntax-ids
_pat
_key)
_exp
'#(syntax-object
y
(top)))))
(g00037)))
g00035)
(g00037)))
(syntax-dispatch
g00036
'(pair (any)
pair
(any)
pair
(each any)
pair
(pair (any)
pair
(any)
atom)
each
pair
(any)
pair
(any)
each
any)
(vector))))
(lambda ()
((lambda (g00039)
((lambda (g00040)
((lambda (g00038)
(if (not (eq? g00038
'no))
(apply
(lambda (__
_val
_key
_pat
_fender
_exp
_e1
_e2
_e3)
(if (if (syncase:andmap
valid-keyword?
_key)
(valid-syntax-pattern?
_pat
_key)
#f)
((lambda (g00042)
((lambda (g00041)
(if (not (eq? g00041
'no))
((lambda (_pattern
_y
_dorest
_call)
(list '#(syntax-object
let
(top))
(list (list '#(syntax-object
x
(top))
_val))
(list '#(syntax-object
let
(top))
(list (list _dorest
(list '#(syntax-object
lambda
(top))
'()
(cons '#(syntax-object
syntax-case
(top))
(cons '#(syntax-object
x
(top))
(cons _key
(map (lambda (__e1
__e2
__e3)
(cons __e1
(cons __e2
__e3)))
_e1
_e2
_e3)))))))
(list '#(syntax-object
let
(top))
(list (list _y
(list '#(syntax-object
syntax-dispatch
(top))
'#(syntax-object
x
(top))
(list '#(syntax-object
quote
(top))
_pattern)
(list '#(syntax-object
syntax
(top))
(list->vector
_key)))))
(list '#(syntax-object
if
(top))
(list '#(syntax-object
not
(top))
(list '#(syntax-object
eq?
(top))
_y
(list '#(syntax-object
quote
(top))
'#(syntax-object
no
(top)))))
_call
(list _dorest))))))
(car g00041)
(cadr g00041)
(caddr
g00041)
(cadddr
g00041))
(syntax-error
g00042)))
(syntax-dispatch
g00042
'(pair (any)
pair
(any)
pair
(any)
pair
(any)
atom)
(vector))))
(list (convert-syntax-dispatch-pattern
_pat
_key)
'#(syntax-object
y
(top))
'#(syntax-object
dorest
(top))
(syncase:build-dispatch-call
(extract-bound-syntax-ids
_pat
_key)
(list '#(syntax-object
if
(top))
_fender
_exp
(list '#(syntax-object
dorest
(top))))
'#(syntax-object
y
(top)))))
(g00040)))
g00038)
(g00040)))
(syntax-dispatch
g00039
'(pair (any)
pair
(any)
pair
(each any)
pair
(pair (any)
pair
(any)
pair
(any)
atom)
each
pair
(any)
pair
(any)
each
any)
(vector))))
(lambda ()
(syntax-error
g00039))))
g00036))))
g00033))))
g00030))))
x)))))))
