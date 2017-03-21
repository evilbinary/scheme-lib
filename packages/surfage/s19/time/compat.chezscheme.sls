
(library (surfage s19 time compat)

  (export format
          host:time-resolution
          host:current-time 
          host:time-nanosecond 
          host:time-second 
          host:time-gmt-offset)

  (import (chezscheme)
          (prefix (only (chezscheme)
                        current-time
                        time-nanosecond
                        time-second)
                  host:))

  (define host:time-resolution 1000)

  ;; (define (host:time-gmt-offset t)
  ;;   (date-zone-offset t))

  (define (host:time-gmt-offset t)
    (date-zone-offset (time-utc->date t)))
    
  )
