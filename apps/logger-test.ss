;; Example of using the logger

(import (logger logger))

(define log (new-logger "log1.txt"))
(log-level log 'info)
(log-info log "some information logged")
(log-debug log "this will be ignored")
(log-level log 'debug)
(log-debug log "but this included")
(log-close log)

