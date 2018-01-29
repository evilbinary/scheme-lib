;; Logger library for R7RS Scheme

;; The Logger library can be used to output messages to an output port.  
;; Each message is given a level, and only messages above a certain set 
;; level will be output to the port.  This allows the developer to control
;; the level of detail output by the program.  
;; This logger library uses the same levels as Ruby's Logger class.

;; Written by Peter Lane, 2017

;; # Open Works License
;; 
;; This is version 0.9.4 of the Open Works License
;; 
;; ## Terms
;; 
;; Permission is hereby granted by the holder(s) of copyright or other legal
;; privileges, author(s) or assembler(s), and contributor(s) of this work, to any
;; person who obtains a copy of this work in any form, to reproduce, modify,
;; distribute, publish, sell, sublicense, use, and/or otherwise deal in the
;; licensed material without restriction, provided the following conditions are
;; met:
;; 
;; Redistributions, modified or unmodified, in whole or in part, must retain
;; applicable copyright and other legal privilege notices, the above license
;; notice, these conditions, and the following disclaimer.
;; 
;; NO WARRANTY OF ANY KIND IS IMPLIED BY, OR SHOULD BE INFERRED FROM, THIS LICENSE
;; OR THE ACT OF DISTRIBUTION UNDER THE TERMS OF THIS LICENSE, INCLUDING BUT NOT
;; LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
;; AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS, ASSEMBLERS, OR HOLDERS OF
;; COPYRIGHT OR OTHER LEGAL PRIVILEGE BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
;; LIABILITY, WHETHER IN ACTION OF CONTRACT, TORT, OR OTHERWISE ARISING FROM, OUT
;; OF, OR IN CONNECTION WITH THE WORK OR THE USE OF OR OTHER DEALINGS IN THE WORK.

(library
  (logger logger)
  (export new-logger
          logger?
          log-close
          log-unknown
          log-fatal
          log-error
          log-warn
          log-info
          log-debug
          log-add
          log-level
          log-unknown?
          log-fatal?
          log-error?
          log-warn?
          log-info?
          log-debug?)
  (import (scheme))


  (define-record-type (logger make-logger logger?)
                      (fields 
                        (immutable port port-get)
                        (mutable level level-get level-set!)
                        (immutable flag created-file?)))

  (define *levels* (list (cons 'unknown 1) 
                          (cons 'fatal 2) 
                          (cons 'error 3) 
                          (cons 'warn 4)
                          (cons 'info 5)
                          (cons 'debug 6)))

  (define (valid-level? level)
    (memq level (map car *levels*)))

  (define (level<=? level1 level2)
    (let ((l1 (cdr (assq level1 *levels*)))
          (l2 (cdr (assq level2 *levels*))))
      (<= l1 l2)))

  ;; construct a logger object from an output port
  (define (new-logger out)
    (cond ((output-port? out)
            (make-logger out 'debug #f))
          ((string? out)
            (make-logger (open-output-file out) 'debug #t))
          (else
            (error #f "new-logger requires an output port or filename"))))

  ;; close logger if created a file
  (define (log-close logger)
    (when (created-file? logger)
      (close-output-port (port-get logger))))

  ;; change level of logger
  (define (log-level logger level)
    (if (valid-level? level)
      (level-set! logger level)
      (error #f "log-level given invalid level")))

  ;; if given level is not lower than logger's level
  ;; outputs message to logger's port
  (define (log-add logger msg level)
    (if (valid-level? level)
      (when (level<=? level (level-get logger))
        (let ((p (port-get logger)))
            (display level p)
            (display ": " p)
            (display msg p)
            (newline p)))
      (error #f "log-add given invalid level")))

  ;; log messages at a known level
  (define (log-unknown logger msg) (log-add logger msg 'unknown))
  (define (log-fatal logger msg) (log-add logger msg 'fatal))
  (define (log-error logger msg) (log-add logger msg 'error))
  (define (log-warn logger msg) (log-add logger msg 'warn))
  (define (log-info logger msg) (log-add logger msg 'info))
  (define (log-debug logger msg) (log-add logger msg 'debug))

  ;; check if level permits message at given level to be logged
  (define (log-unknown? logger) (level<=? 'unknown (level-get logger)))
  (define (log-fatal? logger) (level<=? 'fatal (level-get logger)))
  (define (log-error? logger) (level<=? 'error (level-get logger)))
  (define (log-warn? logger) (level<=? 'warn (level-get logger)))
  (define (log-info? logger) (level<=? 'info (level-get logger)))
  (define (log-debug? logger) (level<=? 'debug (level-get logger)))

)


