;; "queue.scm"  Queues/Stacks for Scheme
;; Written by Andrew Wilcox (awilcox@astro.psu.edu) on April 1, 1992.
;;
;; This code is in the public domain.

(require 'record)

;;@code{(require 'queue)}
;;@ftindex queue
;;
;;A @dfn{queue} is a list where elements can be added to both the front
;;and rear, and removed from the front (i.e., they are what are often
;;called @dfn{dequeues}).  A queue may also be used like a stack.

;; Elements in a queue are stored in a list.  The last pair in the list
;; is stored in the queue type so that datums can be added in constant
;; time.

(define queue:record-type
  (make-record-type "queue" '(first-pair last-pair)))

;;@args
;;Returns a new, empty queue.
(define make-queue
  (let ((construct-queue (record-constructor queue:record-type '(first-pair last-pair))))
    (lambda ()
      (construct-queue '() '()))))

;;@args obj
;;Returns @code{#t} if @var{obj} is a queue.
(define queue? (record-predicate queue:record-type))

(define queue:first-pair (record-accessor queue:record-type
					  'first-pair))
(define queue:set-first-pair! (record-modifier queue:record-type
					       'first-pair))
(define queue:last-pair (record-accessor queue:record-type
					 'last-pair))
(define queue:set-last-pair! (record-modifier queue:record-type
					      'last-pair))

;;@body
;;Returns @code{#t} if the queue @var{q} is empty.
(define (queue-empty? q)
  (null? (queue:first-pair q)))

;;@body
;;Adds @var{datum} to the front of queue @var{q}.
(define (queue-push! q datum)
  (let* ((old-first-pair (queue:first-pair q))
	 (new-first-pair (cons datum old-first-pair)))
    (queue:set-first-pair! q new-first-pair)
    (if (null? old-first-pair)
	(queue:set-last-pair! q new-first-pair)))
  q)

;;@body
;;Adds @var{datum} to the rear of queue @var{q}.
(define (enqueue! q datum)
  (let ((new-pair (cons datum '())))
    (cond ((null? (queue:first-pair q))
	   (queue:set-first-pair! q new-pair))
	  (else
	   (set-cdr! (queue:last-pair q) new-pair)))
    (queue:set-last-pair! q new-pair))
  q)

;;@body
;;@deffnx {Procedure} queue-pop! q
;;Both of these procedures remove and return the datum at the front of
;;the queue.  @code{queue-pop!} is used to suggest that the queue is
;;being used like a stack.
(define (dequeue! q)
  (let ((first-pair (queue:first-pair q)))
    (if (null? first-pair)
	(slib:error "queue is empty" q))
    (let ((first-cdr (cdr first-pair)))
      (queue:set-first-pair! q first-cdr)
      (if (null? first-cdr)
	  (queue:set-last-pair! q '()))
      (car first-pair))))
(define queue-pop! dequeue!)

;;@ All of the following functions raise an error if the queue @var{q}
;;is empty.

;;@body
;;Removes and returns (the list) of all contents of queue @var{q}.
(define (dequeue-all! q)
  (let ((lst (queue:first-pair q)))
    (queue:set-first-pair! q '())
    (queue:set-last-pair!  q '())
    lst))

;;@body
;;Returns the datum at the front of the queue @var{q}.
(define (queue-front q)
  (let ((first-pair (queue:first-pair q)))
    (if (null? first-pair)
	(slib:error "queue is empty" q))
    (car first-pair)))

;;@body
;;Returns the datum at the rear of the queue @var{q}.
(define (queue-rear q)
  (let ((last-pair (queue:last-pair q)))
    (if (null? last-pair)
	(slib:error "queue is empty" q))
    (car last-pair)))
