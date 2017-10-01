(import  (scheme) (regex regex))

(define pattern "([^=&]+)=([^=&]*)")
(define str "a=b&c=d&=e&g=&1=2")

(printf 
    "match?: ~a \nmatch: ~a \nmatch-count?: ~a \nmatches: ~a \nsearch: ~a \nsplit: ~a \nreplace: ~a \nreplace-all: ~a \n"
    (regex-match? pattern str)
    (regex-match pattern str)
    (regex-match-count pattern str)
    (regex-matches pattern str)
    (regex-search pattern str)
    (regex-split "=" str)
    (regex-replace "=" str "~")
    (regex-replace-all "=" str "~")
)