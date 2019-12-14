;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui keys)
  (export
    default-key-maps
    get-default-key-map
    set-default-key-map)
  (import (scheme))
  (define default-key-map (make-hashtable equal-hash equal?))
  (define default-key-maps
    (list '(ctl 2) '(shift 1) '(alt 4) '(super 8) '(caps-lock 16)
      '(num-lock 32) '(a 65) '(b 66) '(c 67) '(d 68) '(v 86)
      '(x 88) '(up 265) '(down 264) '(left 263) '(right 262)
      '(tab 258)))
  (define (set-default-key-map key val)
    (hashtable-set! default-key-map key val))
  (define (get-default-key-map key)
    (hashtable-ref default-key-map key '())))

