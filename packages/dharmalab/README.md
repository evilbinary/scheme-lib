
# Setup #

    $ cd ~/scheme # Where '~/scheme' is the path to your Scheme libraries
    $ git clone git://github.com/dharmatech/surfage.git

# (dharmalab math basic) #

Constant: `pi`

    (square <number>)

Curried versions of various procedures:

    (add <number>)

    (multiply-by <number>)

    (subtract-from <number>)

    (subtract <number>)

    (divide <number>)

    (divide-by <number>)

    (greater-than  <number>)
    (greater-than= <number>)

    (less-than  <number>)
    (less-than= <number>)

# (dharmalab misc curry) #

Macro: `(curry (proc param ...))`

Create a curried version of 'vector-set!':

    > (define put (curry (vector-set! a b c)))
    > (define v0 '#(a b c d e))
    > (((put v0) 0) 'x)
    > v0
    #(x b c d e)

# (dharmalab records define-record-type) #

Macro: `define-record-type++`

Example:

<pre>
(define-record-type++ point
  (fields x y))

(define p (make-point 10 20))

(is-point p)

(list p.x p.y) ;; ---> (10 20)

(define (distance-from-origin p)
  (import-point p)
  (sqrt (+ (* x x) (* y y))))

</pre>

# (dharmalab misc time entry) #

The standard `time` macro is provided by many implementations, but
exported from different libraries. This is a common interface to it.

    (time <expression>)

# (dharmalab misc gen-id) #

    (gen-id <identifier> <string-or-syntax> ...)

As seen in <i>The Scheme Programming Lanaugage</i>.

# (dharmalab misc queue) #

Purely functional queue.

# (dharmalab misc is-list) #

    > (import (dharmalab misc is-list))
    > (define numbers '(1 2 3 4 5))
    > (is-list numbers)
    > (numbers.ref 0)
    1
    > (numbers.length)
    5
    > (numbers.map (lambda (x) (* x x)))
    (1 4 9 16 25)

# (dharmalab misc is-vector) #

Similar to `is-list`.

