
;;; Test format import of implementation
;;; specific routine: pretty-print

#|
LARCENY USAGE:
==> larceny -r6rs -program print-ascii.ss

IKARUS USAGE
==> ikarus --r6rs-script print-ascii.ss

|#

(import (rnrs (6))
        (surfage s48 intermediate-format-strings))
        
(define pa
 '(define (print-ascii-chart . radix+port)  
  (let ( (radix (if (null? radix+port) 16 (car radix+port)))         
         (port  (if (or (null? radix+port) (null? (cdr radix+port)))
                  (current-output-port)
                  (cadr radix+port)))  
         (max-row    15)         
         (max-col     7)         
         (max-ascii 127)         
         (max-control 31)  ; [0..31] are control codes
       )   

    (define (printable? N) ; N.B.: integer input       
      (< max-control N max-ascii)) ; control or DEL  

    (define (print-a-char N) 
      (if (printable? N) 
        (begin        
          (display #\'               port)
          (display (integer->char N) port) 
          (display #\'               port) 
          )        
        (cond ; print a control character  
         ((= N max-ascii) (display "DEL" port))  
         (else            
          (display #\^   port)    
          (display (integer->char (+ (char->integer #\@) N)) port) 
          ) )     )      
      (display " = "                    port)  
      (display (number->string N radix) port) 
      (display #\space                  port)  
      (display #\space                  port) 
      (display #\space                  port)   
      )   

    ; output the chart...  
    (newline port)   
    (let row-loop ( (row 0) )  
      (if (> row max-row)        
        (newline port)  ; done          
        (let column-loop ( (col 0) )   
          (print-a-char (+ row (* col (+ max-row 1)))) 
          (if (< col max-col)        
            (column-loop (+ col 1))   
            (begin                  
              (newline  port)      
              (row-loop (+ row 1))  
              )   )          
          )   )    
      )) )
)

(format #t "~Y~%" pa)

;;		--- E O F ---		;;
