;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; R6RS library for Alex Shinn's Irregex
;;; 
;;; Copyright (c) 2009 Aaron W. Hsu <arcfide@sacrideo.us>
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

(library (irregex irregex)
  (export 
    irregex 
    string->irregex 
    sre->irregex 
    irregex?
    irregex-search
    irregex-match
    irregex-match-data?
    irregex-match-substring irregex-match-start-index
    irregex-match-end-index 
    irregex-match-subchunk
    irregex-replace irregex-replace/all
    irregex-fold
    irregex-fold/chunked
    make-irregex-chunker
    irregex-search/chunked irregex-match/chunked)
  (import 
    (except (rnrs base) error)
    (rnrs control)
    (except (rnrs lists) find filter remove) ;for r5rs
    (rnrs r5rs)
    (rnrs mutable-pairs)
    (rnrs mutable-strings)
    (rnrs unicode)
    (surfage private include)
    (surfage s23 error)
    )
    (include/resolve ("irregex") "irregex.scm")
)