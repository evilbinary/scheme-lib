#! /usr/bin/env scheme-script
;;; Copyright (c) 2012 Aaron W. Hsu <arcfide@sacrideo.us>
;;; 
;;; Permission to use, copy, modify, and distribute this software for
;;; any purpose with or without fee is hereby granted, provided that the
;;; above copyright notice and this permission notice appear in all
;;; copies.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;;; PERFORMANCE OF THIS SOFTWARE.

(import (chezscheme))

;;; Link all of the SRFIs to their normal directories like sane 
;;; people who use Chez Scheme prefer. :-)

(define (file-loop files)
  (cond
    [(null? files) (void)]
    [(should-link? (car files))
     (link-file (car files))
     (file-loop (cdr files))]
    [else (file-loop (cdr files))]))

(define (should-link? file)
  (and (< 3 (string-length file))
       (string=? "%3a" (substring file 0 3))))

(define (link-file file)
  (let ([clean (string-append ":" (substring file 3 (string-length file)))])
	(printf "Linking ~a~n" file)
	(system (format "ln -sf '~a' '~a'" file clean))))

(file-loop (directory-list "."))
