;;;;"xml-parse.scm" XML parsing and conversion to SXML (Scheme-XML)
;;; Copyright (C) 2007 Aubrey Jaffer
;;; 2007-04 jaffer: demacrofied from public-domain SSAX 5.1
;
;Permission to copy this software, to modify it, to redistribute it,
;to distribute modified versions, and to use it for any purpose is
;granted, subject to the following restrictions and understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warranty or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

;;@code{(require 'xml-parse)} or @code{(require 'ssax)}
;;
;;@noindent
;;The XML standard document referred to in this module is@*
;;@url{http://www.w3.org/TR/1998/REC-xml-19980210.html}.
;;
;;@noindent
;;The present frameworks fully supports the XML Namespaces
;;Recommendation@*
;;@url{http://www.w3.org/TR/REC-xml-names}.

(require 'rev2-procedures)		; for substring-move-left!
(require 'string-search)
(require 'let-values)
(require 'values)
(require 'srfi-1)			; for fold-right, fold, cons*

;;@subsection String Glue

;;;; Three functions from SRFI-13
; procedure string-concatenate-reverse STRINGS [FINAL END]
(define (ssax:string-concatenate-reverse strs final end)
  (if (null? strs) (substring final 0 end)
      (let*
	  ((total-len
	    (let loop ((len end) (lst strs))
	      (if (null? lst) len
		  (loop (+ len (string-length (car lst))) (cdr lst)))))
	   (result (make-string total-len)))
	(let loop ((len end) (j total-len) (str final) (lst strs))
	  (substring-move-left! str 0 len result (- j len))
	  (if (null? lst) result
	      (loop (string-length (car lst)) (- j len)
		    (car lst) (cdr lst)))))))
; string-concatenate/shared STRING-LIST -> STRING
(define (ssax:string-concatenate/shared strs)
  (cond ((null? strs) "")		; Test for the fast path first
	((null? (cdr strs)) (car strs))
	(else
	 (let*
	     ((total-len
	       (let loop ((len (string-length (car strs))) (lst (cdr strs)))
		 (if (null? lst) len
		     (loop (+ len (string-length (car lst))) (cdr lst)))))
	      (result (make-string total-len)))
	   (let loop ((j 0) (str (car strs)) (lst (cdr strs)))
	     (substring-move-left! str 0 (string-length str) result j)
	     (if (null? lst) result
		 (loop (+ j (string-length str))
		       (car lst) (cdr lst))))))))
; string-concatenate-reverse/shared STRING-LIST [FINAL-STRING END] -> STRING
; We do not use the optional arguments of this procedure.  Therefore,
; we do not implement them.  See SRFI-13 for the complete
; implementation.
(define (ssax:string-concatenate-reverse/shared strs)
  (cond ((null? strs) "")		; Test for the fast path first
	((null? (cdr strs)) (car strs))
	(else
	 (ssax:string-concatenate-reverse (cdr strs)
					  (car strs)
					  (string-length (car strs))))))


;;@args list-of-frags
;;
;;Given the list of fragments (some of which are text strings),
;;reverse the list and concatenate adjacent text strings.  If
;;LIST-OF-FRAGS has zero or one element, the result of the procedure
;;is @code{equal?} to its argument.
(define (ssax:reverse-collect-str fragments)
  (cond
   ((null? fragments) '())		; a shortcut
   ((null? (cdr fragments)) fragments)	; see the comment above
   (else
    (let loop ((fragments fragments) (result '()) (strs '()))
      (cond
       ((null? fragments)
	(if (null? strs)
	    result
	    (cons (ssax:string-concatenate/shared strs) result)))
       ((string? (car fragments))
	(loop (cdr fragments) result (cons (car fragments) strs)))
       (else
	(loop (cdr fragments)
	      (cons (car fragments)
		    (if (null? strs)
			result
			(cons (ssax:string-concatenate/shared strs) result)))
	      '())))))))

;;@args list-of-frags
;;
;;Given the list of fragments (some of which are text strings),
;;reverse the list and concatenate adjacent text strings while
;;dropping "unsignificant" whitespace, that is, whitespace in front,
;;behind and between elements.  The whitespace that is included in
;;character data is not affected.
;;
;;Use this procedure to "intelligently" drop "insignificant"
;;whitespace in the parsed SXML.  If the strict compliance with the
;;XML Recommendation regarding the whitespace is desired, use the
;;@code{ssax:reverse-collect-str} procedure instead.
(define (ssax:reverse-collect-str-drop-ws fragments)
  ;; Test if a string is made of only whitespace.
  ;; An empty string is considered made of whitespace as well
  (define (string-whitespace? str)
    (let ((len (string-length str)))
      (cond ((zero? len) #t)
	    ((= 1 len) (char-whitespace? (string-ref str 0)))
	    (else
	     (let loop ((i 0))
	       (or (>= i len)
		   (and (char-whitespace? (string-ref str i))
			(loop (+ 1 i)))))))))
  (cond
   ((null? fragments) '())		; a shortcut
   ((null? (cdr fragments))		; another shortcut
    (if (and (string? (car fragments)) (string-whitespace? (car fragments)))
	'()				; remove trailing ws
	fragments))
   (else
    (let loop ((fragments fragments) (result '()) (strs '())
	       (all-whitespace? #t))
      (cond
       ((null? fragments)
	(if all-whitespace?
	    result			; remove leading ws
	    (cons (ssax:string-concatenate/shared strs) result)))
       ((string? (car fragments))
	(loop (cdr fragments)
	      result
	      (cons (car fragments) strs)
	      (and all-whitespace? (string-whitespace? (car fragments)))))
       (else
	(loop (cdr fragments)
	      (cons (car fragments)
		    (if all-whitespace?
			result
			(cons (ssax:string-concatenate/shared strs) result)))
	      '()
	      #t)))))))

;;@subsection Character and Token Functions
;;
;;The following functions either skip, or build and return tokens,
;;according to inclusion or delimiting semantics.  The list of
;;characters to expect, include, or to break at may vary from one
;;invocation of a function to another.  This allows the functions to
;;easily parse even context-sensitive languages.
;;
;;Exceptions are mentioned specifically.  The list of expected
;;characters (characters to skip until, or break-characters) may
;;include an EOF "character", which is coded as symbol *eof*
;;
;;The input stream to parse is specified as a PORT, which is the last
;;argument.

;;@args char-list string port
;;
;;Reads a character from the @3 and looks it up in the
;;@1 of expected characters.  If the read character was
;;found among expected, it is returned.  Otherwise, the
;;procedure writes a message using @2 as a comment
;;and quits.
(define (ssax:assert-current-char expected-chars comment port)
  (let ((c (read-char port)))
    (if (memv c expected-chars) c
	(slib:error port "Wrong character " c
		    " (0x" (if (eof-object? c)
			       "*eof*"
			       (number->string (char->integer c) 16)) ") "
		    comment ". " expected-chars " expected"))))

;;@args char-list port
;;
;;Reads characters from the @2 and disregards them, as long as they
;;are mentioned in the @1.  The first character (which may be EOF)
;;peeked from the stream that is @emph{not} a member of the @1 is
;;returned.
(define (ssax:skip-while skip-chars port)
  (do ((c (peek-char port) (peek-char port)))
      ((not (memv c skip-chars)) c)
    (read-char port)))

;;;				Stream tokenizers
;;
;;Note: since we can't tell offhand how large the token being read is
;;going to be, we make a guess, pre-allocate a string, and grow it by
;;quanta if necessary.  The quantum is always the length of the string
;;before it was extended the last time.  Thus the algorithm does a
;;Fibonacci-type extension, which has been proven optimal.
;;
;;Size 32 turns out to be fairly good, on average.  That policy is
;;good only when a Scheme system is multi-threaded with preemptive
;;scheduling, or when a Scheme system supports shared substrings.  In
;;all the other cases, it's better for ssax:init-buffer to return the
;;same static buffer.  ssax:next-token* functions return a copy (a
;;substring) of accumulated data, so the same buffer can be reused.
;;We shouldn't worry about an incoming token being too large:
;;ssax:next-token will use another chunk automatically.  Still, the
;;best size for the static buffer is to allow most of the tokens to
;;fit in.  Using a static buffer _dramatically_ reduces the amount of
;;produced garbage (e.g., during XML parsing).

;;@body
;;
;;Returns an initial buffer for @code{ssax:next-token*} procedures.
;;@0 may allocate a new buffer at each invocation.
(define (ssax:init-buffer) (make-string 32))

;;;(define ssax:init-buffer
;;;  (let ((buffer (make-string 512)))
;;;    (lambda () buffer)))

;;@args prefix-char-list break-char-list comment-string port
;;
;;Skips any number of the prefix characters (members of the @1), if
;;any, and reads the sequence of characters up to (but not including)
;;a break character, one of the @2.
;;
;;The string of characters thus read is returned.  The break character
;;is left on the input stream.  @2 may include the symbol @code{*eof*};
;;otherwise, EOF is fatal, generating an error message including a
;;specified @3.
(define (ssax:next-token prefix-skipped-chars break-chars comment port)
  (let outer ((buffer (ssax:init-buffer)) (filled-buffer-l '())
	      (c (ssax:skip-while prefix-skipped-chars port)))
    (let ((curr-buf-len (string-length buffer)))
      (let loop ((i 0) (c c))
	(cond
	 ((memv c break-chars)
	  (if (null? filled-buffer-l) (substring buffer 0 i)
	      (ssax:string-concatenate-reverse filled-buffer-l buffer i)))
	 ((eof-object? c)
	  (if (memq '*eof* break-chars)	; was EOF expected?
	      (if (null? filled-buffer-l) (substring buffer 0 i)
		  (ssax:string-concatenate-reverse filled-buffer-l buffer i))
	      (slib:error port "EOF while reading a token " comment)))
	 ((>= i curr-buf-len)
	  (outer (make-string curr-buf-len)
		 (cons buffer filled-buffer-l) c))
	 (else
	  (string-set! buffer i c)
	  (read-char port)		; move to the next char
	  (loop (+ 1 i) (peek-char port))))))))

;;@noindent
;;@code{ssax:next-token-of} is similar to @code{ssax:next-token}
;;except that it implements an inclusion rather than delimiting
;;semantics.

;;@args inc-charset port
;;
;;Reads characters from the @2 that belong to the list of characters
;;@1.  The reading stops at the first character which is not a member
;;of the set.  This character is left on the stream.  All the read
;;characters are returned in a string.
;;
;;@args pred port
;;
;;Reads characters from the @2 for which @var{pred} (a procedure of
;;one argument) returns non-#f.  The reading stops at the first
;;character for which @var{pred} returns #f.  That character is left
;;on the stream.  All the results of evaluating of @var{pred} up to #f
;;are returned in a string.
;;
;;@var{pred} is a procedure that takes one argument (a character or
;;the EOF object) and returns a character or #f.  The returned
;;character does not have to be the same as the input argument to the
;;@var{pred}.  For example,
;;
;;@example
;;(ssax:next-token-of (lambda (c)
;;                      (cond ((eof-object? c) #f)
;;                            ((char-alphabetic? c) (char-downcase c))
;;                            (else #f)))
;;                    (current-input-port))
;;@end example
;;
;;will try to read an alphabetic token from the current input port,
;;and return it in lower case.
(define (ssax:next-token-of incl-list/pred port)
  (let* ((buffer (ssax:init-buffer))
	 (curr-buf-len (string-length buffer)))
    (if (procedure? incl-list/pred)
	(let outer ((buffer buffer) (filled-buffer-l '()))
	  (let loop ((i 0))
	    (if (>= i curr-buf-len)	; make sure we have space
		(outer (make-string curr-buf-len) (cons buffer filled-buffer-l))
		(let ((c (incl-list/pred (peek-char port))))
		  (if c
		      (begin
			(string-set! buffer i c)
			(read-char port) ; move to the next char
			(loop (+ 1 i)))
		      ;; incl-list/pred decided it had had enough
		      (if (null? filled-buffer-l) (substring buffer 0 i)
			  (ssax:string-concatenate-reverse filled-buffer-l buffer i)))))))

	;; incl-list/pred is a list of allowed characters
	(let outer ((buffer buffer) (filled-buffer-l '()))
	  (let loop ((i 0))
	    (if (>= i curr-buf-len)	; make sure we have space
		(outer (make-string curr-buf-len) (cons buffer filled-buffer-l))
		(let ((c (peek-char port)))
		  (cond
		   ((not (memv c incl-list/pred))
		    (if (null? filled-buffer-l) (substring buffer 0 i)
			(ssax:string-concatenate-reverse filled-buffer-l buffer i)))
		   (else
		    (string-set! buffer i c)
		    (read-char port)	; move to the next char
		    (loop (+ 1 i))))))))
	)))

;;@body
;;
;;Reads @1 characters from the @2, and returns them in a string.  If
;;EOF is encountered before @1 characters are read, a shorter string
;;will be returned.
(define (ssax:read-string len port)
  (define buffer (make-string len))
  (do ((idx 0 (+ 1 idx)))
      ((>= idx len) idx)
    (let ((chr (read-char port)))
      (cond ((eof-object? chr)
	     (set! idx (+ -1 idx))
	     (set! len idx))
	    (else (string-set! buffer idx chr))))))

;;@subsection Data Types
;;
;;@table @code
;;
;;@item TAG-KIND
;;
;;A symbol @samp{START}, @samp{END}, @samp{PI}, @samp{DECL},
;;@samp{COMMENT}, @samp{CDSECT}, or @samp{ENTITY-REF} that identifies
;;a markup token
;;
;;@item UNRES-NAME
;;
;;a name (called GI in the XML Recommendation) as given in an XML
;;document for a markup token: start-tag, PI target, attribute name.
;;If a GI is an NCName, UNRES-NAME is this NCName converted into a
;;Scheme symbol.  If a GI is a QName, @samp{UNRES-NAME} is a pair of
;;symbols: @code{(@var{PREFIX} . @var{LOCALPART})}.
;;
;;@item RES-NAME
;;
;;An expanded name, a resolved version of an @samp{UNRES-NAME}.  For
;;an element or an attribute name with a non-empty namespace URI,
;;@samp{RES-NAME} is a pair of symbols,
;;@code{(@var{URI-SYMB} . @var{LOCALPART})}.
;;Otherwise, it's a single symbol.
;;
;;@item ELEM-CONTENT-MODEL
;;
;;A symbol:
;;@table @samp
;;@item ANY
;;anything goes, expect an END tag.
;;@item EMPTY-TAG
;;no content, and no END-tag is coming
;;@item EMPTY
;;no content, expect the END-tag as the next token
;;@item PCDATA
;;expect character data only, and no children elements
;;@item MIXED
;;@item ELEM-CONTENT
;;@end table
;;
;;@item URI-SYMB
;;
;;A symbol representing a namespace URI -- or other symbol chosen by
;;the user to represent URI.  In the former case, @code{URI-SYMB} is
;;created by %-quoting of bad URI characters and converting the
;;resulting string into a symbol.
;;
;;@item NAMESPACES
;;
;;A list representing namespaces in effect.  An element of the list
;;has one of the following forms:
;;
;;@table @code
;;
;;@item (@var{prefix} @var{uri-symb} . @var{uri-symb}) or
;;
;;@item (@var{prefix} @var{user-prefix} . @var{uri-symb})
;;@var{user-prefix} is a symbol chosen by the user to represent the URI.
;;
;;@item (#f @var{user-prefix} . @var{uri-symb})
;;Specification of the user-chosen prefix and a URI-SYMBOL.
;;
;;@item (*DEFAULT* @var{user-prefix} . @var{uri-symb})
;;Declaration of the default namespace
;;
;;@item (*DEFAULT* #f . #f)
;;Un-declaration of the default namespace.  This notation
;;represents overriding of the previous declaration
;;
;;@end table
;;
;;A NAMESPACES list may contain several elements for the same @var{prefix}.
;;The one closest to the beginning of the list takes effect.
;;
;;@item ATTLIST
;;
;;An ordered collection of (@var{NAME} . @var{VALUE}) pairs, where
;;@var{NAME} is a RES-NAME or an UNRES-NAME.  The collection is an ADT.
;;
;;@item STR-HANDLER
;;
;;A procedure of three arguments: @var{string1} @var{string2}
;;@var{seed} returning a new @var{seed}.  The procedure is supposed to
;;handle a chunk of character data @var{string1} followed by a chunk
;;of character data @var{string2}.  @var{string2} is a short string,
;;often @samp{"\n"} and even @samp{""}.
;;
;;@item ENTITIES
;;An assoc list of pairs:
;;@lisp
;;   (@var{named-entity-name} . @var{named-entity-body})
;;@end lisp
;;
;;where @var{named-entity-name} is a symbol under which the entity was
;;declared, @var{named-entity-body} is either a string, or (for an
;;external entity) a thunk that will return an input port (from which
;;the entity can be read).  @var{named-entity-body} may also be #f.
;;This is an indication that a @var{named-entity-name} is currently
;;being expanded.  A reference to this @var{named-entity-name} will be
;;an error: violation of the WFC nonrecursion.
;;
;;@item XML-TOKEN
;;
;;This record represents a markup, which is, according to the XML
;;Recommendation, "takes the form of start-tags, end-tags,
;;empty-element tags, entity references, character references,
;;comments, CDATA section delimiters, document type declarations, and
;;processing instructions."
;;
;;@table @asis
;;@item kind
;;a TAG-KIND
;;@item head
;;an UNRES-NAME.  For XML-TOKENs of kinds 'COMMENT and 'CDSECT, the
;;head is #f.
;;@end table
;;
;;For example,
;;@example
;;<P>                   => kind=START,      head=P
;;</P>                  => kind=END,        head=P
;;<BR/>                 => kind=EMPTY-EL,   head=BR
;;<!DOCTYPE OMF ...>    => kind=DECL,       head=DOCTYPE
;;<?xml version="1.0"?> => kind=PI,         head=xml
;;&my-ent;              => kind=ENTITY-REF, head=my-ent
;;@end example
;;
;;Character references are not represented by xml-tokens as these
;;references are transparently resolved into the corresponding
;;characters.
;;
;;@item XML-DECL
;;
;;The record represents a datatype of an XML document: the list of
;;declared elements and their attributes, declared notations, list of
;;replacement strings or loading procedures for parsed general
;;entities, etc.  Normally an XML-DECL record is created from a DTD or
;;an XML Schema, although it can be created and filled in in many
;;other ways (e.g., loaded from a file).
;;
;;@table @var
;;@item elems
;;an (assoc) list of decl-elem or #f.  The latter instructs
;;the parser to do no validation of elements and attributes.
;;
;;@item decl-elem
;;declaration of one element:
;;
;;@code{(@var{elem-name} @var{elem-content} @var{decl-attrs})}
;;
;;@var{elem-name} is an UNRES-NAME for the element.
;;
;;@var{elem-content} is an ELEM-CONTENT-MODEL.
;;
;;@var{decl-attrs} is an @code{ATTLIST}, of
;;@code{(@var{attr-name} . @var{value})} associations.
;;
;;This element can declare a user procedure to handle parsing of an
;;element (e.g., to do a custom validation, or to build a hash of IDs
;;as they're encountered).
;;
;;@item decl-attr
;;an element of an @code{ATTLIST}, declaration of one attribute:
;;
;;@code{(@var{attr-name} @var{content-type} @var{use-type} @var{default-value})}
;;
;;@var{attr-name} is an UNRES-NAME for the declared attribute.
;;
;;@var{content-type} is a symbol: @code{CDATA}, @code{NMTOKEN},
;;@code{NMTOKENS}, @dots{} or a list of strings for the enumerated
;;type.
;;
;;@var{use-type} is a symbol: @code{REQUIRED}, @code{IMPLIED}, or
;;@code{FIXED}.
;;
;;@var{default-value} is a string for the default value, or #f if not
;;given.
;;
;;@end table
;;
;;@end table

;;see a function make-empty-xml-decl to make a XML declaration entry
;;suitable for a non-validating parsing.

;;We define xml-token simply as a pair.
(define (make-xml-token kind head) (cons kind head))
(define xml-token? pair?)
(define xml-token-kind car)
(define xml-token-head cdr)

;;@subsection Low-Level Parsers and Scanners
;;
;;@noindent
;;These procedures deal with primitive lexical units (Names,
;;whitespaces, tags) and with pieces of more generic productions.
;;Most of these parsers must be called in appropriate context.  For
;;example, @code{ssax:complete-start-tag} must be called only when the
;;start-tag has been detected and its GI has been read.

(define char-return (integer->char 13))
(define ssax:S-chars (map integer->char '(32 10 9 13)))

;;@body
;;
;;Skip the S (whitespace) production as defined by
;;@example
;;[3] S ::= (#x20 | #x09 | #x0D | #x0A)
;;@end example
;;
;;@0 returns the first not-whitespace character it encounters while
;;scanning the @1.  This character is left on the input stream.
(define (ssax:skip-S port)
  (ssax:skip-while ssax:S-chars port))

;;Check to see if a-char may start a NCName
(define (ssax:ncname-starting-char? a-char)
  (and (char? a-char)
       (or (char-alphabetic? a-char)
	   (char=? #\_ a-char))))

;;@body
;;
;;Read a NCName starting from the current position in the @1 and
;;return it as a symbol.
;;
;;@example
;;[4] NameChar ::= Letter | Digit | '.' | '-' | '_' | ':'
;;                 | CombiningChar | Extender
;;[5] Name ::= (Letter | '_' | ':') (NameChar)*
;;@end example
;;
;;This code supports the XML Namespace Recommendation REC-xml-names,
;;which modifies the above productions as follows:
;;
;;@example
;;[4] NCNameChar ::= Letter | Digit | '.' | '-' | '_'
;;                      | CombiningChar | Extender
;;[5] NCName ::= (Letter | '_') (NCNameChar)*
;;@end example
;;
;;As the Rec-xml-names says,
;;
;;@quotation
;;"An XML document conforms to this specification if all other tokens
;;[other than element types and attribute names] in the document which
;;are required, for XML conformance, to match the XML production for
;;Name, match this specification's production for NCName."
;;@end quotation
;;
;;Element types and attribute names must match the production QName,
;;defined below.
(define (ssax:read-NCName port)
  (let ((first-char (peek-char port)))
    (or (ssax:ncname-starting-char? first-char)
	(slib:error port "XMLNS [4] for '" first-char "'")))
  (string->symbol (ssax:next-token-of (lambda (c)
					(cond
					 ((eof-object? c) #f)
					 ((char-alphabetic? c) c)
					 ((string-index "0123456789.-_" c) c)
					 (else #f)))
				      port)))

;;@body
;;
;;Read a (namespace-) Qualified Name, QName, from the current position
;;in @1; and return an UNRES-NAME.
;;
;;From REC-xml-names:
;;@example
;;[6] QName ::= (Prefix ':')? LocalPart
;;[7] Prefix ::= NCName
;;[8] LocalPart ::= NCName
;;@end example
(define (ssax:read-QName port)
  (let ((prefix-or-localpart (ssax:read-NCName port)))
    (case (peek-char port)
      ((#\:)				; prefix was given after all
       (read-char port)			; consume the colon
       (cons prefix-or-localpart (ssax:read-NCName port)))
      (else prefix-or-localpart)	; Prefix was omitted
      )))

;;The prefix of the pre-defined XML namespace
(define ssax:Prefix-XML (string->symbol "xml"))

;;An UNRES-NAME that is postulated to be larger than anything that can
;;occur in a well-formed XML document.  ssax:name-compare enforces
;;this postulate.
(define ssax:largest-unres-name (cons (string->symbol "#LARGEST-SYMBOL")
				      (string->symbol "#LARGEST-SYMBOL")))

;;Compare one RES-NAME or an UNRES-NAME with the other.
;;Return a symbol '<, '>, or '= depending on the result of
;;the comparison.
;;Names without @var{prefix} are always smaller than those with the @var{prefix}.
(define ssax:name-compare
  (letrec ((symbol-compare
	    (lambda (symb1 symb2)
	      (cond
	       ((eq? symb1 symb2) '=)
	       ((string<? (symbol->string symb1) (symbol->string symb2))
		'<)
	       (else '>)))))
    (lambda (name1 name2)
      (cond
       ((symbol? name1) (if (symbol? name2) (symbol-compare name1 name2)
			    '<))
       ((symbol? name2) '>)
       ((eq? name2 ssax:largest-unres-name) '<)
       ((eq? name1 ssax:largest-unres-name) '>)
       ((eq? (car name1) (car name2))	; prefixes the same
	(symbol-compare (cdr name1) (cdr name2)))
       (else (symbol-compare (car name1) (car name2)))))))

;;@args port
;;
;;This procedure starts parsing of a markup token.  The current
;;position in the stream must be @samp{<}.  This procedure scans
;;enough of the input stream to figure out what kind of a markup token
;;it is seeing.  The procedure returns an XML-TOKEN structure
;;describing the token.  Note, generally reading of the current markup
;;is not finished!  In particular, no attributes of the start-tag
;;token are scanned.
;;
;;Here's a detailed break out of the return values and the position in
;;the PORT when that particular value is returned:
;;
;;@table @asis
;;
;;@item PI-token
;;
;;only PI-target is read.  To finish the Processing-Instruction and
;;disregard it, call @code{ssax:skip-pi}.  @code{ssax:read-attributes}
;;may be useful as well (for PIs whose content is attribute-value
;;pairs).
;;
;;@item END-token
;;
;;The end tag is read completely; the current position is right after
;;the terminating @samp{>} character.
;;
;;@item COMMENT
;;
;;is read and skipped completely.  The current position is right after
;;@samp{-->} that terminates the comment.
;;
;;@item CDSECT
;;
;;The current position is right after @samp{<!CDATA[}.  Use
;;@code{ssax:read-cdata-body} to read the rest.
;;
;;@item DECL
;;
;;We have read the keyword (the one that follows @samp{<!})
;;identifying this declaration markup.  The current position is after
;;the keyword (usually a whitespace character)
;;
;;@item START-token
;;
;;We have read the keyword (GI) of this start tag.  No attributes are
;;scanned yet.  We don't know if this tag has an empty content either.
;;Use @code{ssax:complete-start-tag} to finish parsing of the token.
;;
;;@end table
(define ssax:read-markup-token ; procedure ssax:read-markup-token port
  (let ()
    ;; we have read "<!-".  Skip through the rest of the comment
    ;; Return the 'COMMENT token as an indication we saw a comment
    ;; and skipped it.
    (define (skip-comment port)
      (ssax:assert-current-char '(#\-) "XML [15], second dash" port)
      (if (not (find-string-from-port? "-->" port))
	  (slib:error port "XML [15], no -->"))
      (make-xml-token 'COMMENT #f))
    ;; we have read "<![" that must begin a CDATA section
    (define (read-cdata port)
      (define cdstr (ssax:read-string 6 port))
      (if (not (string=? "CDATA[" cdstr))
	  (slib:error "expected 'CDATA[' but read " cdstr))
      (make-xml-token 'CDSECT #f))

    (lambda (port)
      (ssax:assert-current-char '(#\<) "start of the token" port)
      (case (peek-char port)
	((#\/) (read-char port)
	 (let ((val (make-xml-token 'END (ssax:read-QName port))))
	   (ssax:skip-S port)
	   (ssax:assert-current-char '(#\>) "XML [42]" port)
	   val))
	((#\?) (read-char port) (make-xml-token 'PI (ssax:read-NCName port)))
	((#\!)
	 (read-char port)
	 (case (peek-char port)
	   ((#\-) (read-char port) (skip-comment port))
	   ((#\[) (read-char port) (read-cdata port))
	   (else (make-xml-token 'DECL (ssax:read-NCName port)))))
	(else (make-xml-token 'START (ssax:read-QName port)))))))

;;@body
;;
;;The current position is inside a PI.  Skip till the rest of the PI
(define (ssax:skip-pi port)
  (if (not (find-string-from-port? "?>" port))
      (slib:error port "Failed to find ?> terminating the PI")))

;;@body
;;
;;The current position is right after reading the PITarget.  We read
;;the body of PI and return is as a string.  The port will point to
;;the character right after @samp{?>} combination that terminates PI.
;;
;;@example
;;[16] PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
;;@end example
(define (ssax:read-pi-body-as-string port)
  (ssax:skip-S port)		    ; skip WS after the PI target name
  (ssax:string-concatenate/shared
   (let loop ()
     (let ((pi-fragment
	    (ssax:next-token '() '(#\?) "reading PI content" port)))
       (read-char port)
       (if (eqv? #\> (peek-char port))
	   (begin
	     (read-char port)
	     (cons pi-fragment '()))
	   (cons* pi-fragment "?" (loop)))))))

;;@body
;;
;;The current pos in the port is inside an internal DTD subset (e.g.,
;;after reading @samp{#\[} that begins an internal DTD subset) Skip
;;until the @samp{]>} combination that terminates this DTD.
(define (ssax:skip-internal-dtd port)
  (slib:warn port "Internal DTD subset is not currently handled ")
  (if (not (find-string-from-port? "]>" port))
      (slib:error port
		  "Failed to find ]> terminating the internal DTD subset")))

;;@args port str-handler seed
;;
;;This procedure must be called after we have read a string
;;@samp{<![CDATA[} that begins a CDATA section.  The current position
;;must be the first position of the CDATA body.  This function reads
;;@emph{lines} of the CDATA body and passes them to a @2, a character
;;data consumer.
;;
;;@2 is a procedure taking arguments: @var{string1}, @var{string2},
;;and @var{seed}.  The first @var{string1} argument to @2 never
;;contains a newline; the second @var{string2} argument often will.
;;On the first invocation of @2, @3 is the one passed to @0 as the
;;third argument.  The result of this first invocation will be passed
;;as the @var{seed} argument to the second invocation of the line
;;consumer, and so on.  The result of the last invocation of the @2 is
;;returned by the @0.  Note a similarity to the fundamental @dfn{fold}
;;iterator.
;;
;;Within a CDATA section all characters are taken at their face value,
;;with three exceptions:
;;@itemize @bullet
;;@item
;;CR, LF, and CRLF are treated as line delimiters, and passed
;;as a single @samp{#\newline} to @2
;;
;;@item
;;@samp{]]>} combination is the end of the CDATA section.
;;@samp{&gt;} is treated as an embedded @samp{>} character.
;;
;;@item
;;@samp{&lt;} and @samp{&amp;} are not specially recognized (and are
;;not expanded)!
;;
;;@end itemize
(define ssax:read-cdata-body
  (let ((cdata-delimiters (list char-return #\newline #\] #\&)))
    (lambda (port str-handler seed)
      (let loop ((seed seed))
	(let ((fragment (ssax:next-token '() cdata-delimiters "reading CDATA" port)))
	  ;; that is, we're reading the char after the 'fragment'
	  (case (read-char port)
	    ((#\newline) (loop (str-handler fragment #\newline seed)))
	    ((#\])
	     (if (not (eqv? (peek-char port) #\]))
		 (loop (str-handler fragment "]" seed))
		 (let check-after-second-braket
		     ((seed (if (string-null? fragment) seed
				(str-handler fragment "" seed))))
		   (read-char port)
		   (case (peek-char port) ; after the second bracket
		     ((#\>) (read-char port) seed) ; we have read "]]>"
		     ((#\]) (check-after-second-braket
			     (str-handler "]" "" seed)))
		     (else (loop (str-handler "]]" "" seed)))))))
	    ((#\&)   ; Note that #\& within CDATA may stand for itself
	     (let ((ent-ref  ; it does not have to start an entity ref
		    (ssax:next-token-of
		     (lambda (c)
		       (and (not (eof-object? c)) (char-alphabetic? c) c))
		     port)))
	       (cond		   ; replace "&gt;" with #\>
		((and (string=? "gt" ent-ref) (eqv? (peek-char port) #\;))
		 (read-char port)
		 (loop (str-handler fragment ">" seed)))
		(else
		 (loop
		  (str-handler ent-ref ""
			       (str-handler fragment "&" seed)))))))
	    (else ; Must be CR: if the next char is #\newline, skip it
	     (if (eqv? (peek-char port) #\newline) (read-char port))
	     (loop (str-handler fragment #\newline seed)))
	    ))))))

;;@body
;;
;;@example
;;[66]  CharRef ::=  '&#' [0-9]+ ';'
;;                 | '&#x' [0-9a-fA-F]+ ';'
;;@end example
;;
;;This procedure must be called after we we have read @samp{&#} that
;;introduces a char reference.  The procedure reads this reference and
;;returns the corresponding char.  The current position in PORT will
;;be after the @samp{;} that terminates the char reference.
;;
;;Faults detected:@*
;;WFC: XML-Spec.html#wf-Legalchar
;;
;;According to Section @cite{4.1 Character and Entity References}
;;of the XML Recommendation:
;;
;;@quotation
;;"[Definition: A character reference refers to a specific character
;;in the ISO/IEC 10646 character set, for example one not directly
;;accessible from available input devices.]"
;;@end quotation
;;
;;@c Therefore, we use a @code{ucscode->char} function to convert a
;;@c character code into the character -- *regardless* of the current
;;@c character encoding of the input stream.
(define (ssax:read-char-ref port)
  (let* ((base (cond ((eqv? (peek-char port) #\x) (read-char port) 16)
		     (else 10)))
         (name (ssax:next-token '() '(#\;) "XML [66]" port))
         (char-code (string->number name base)))
    (read-char port)		       ; read the terminating #\; char
    (if (integer? char-code) (integer->char char-code)
	(slib:error port "[wf-Legalchar] broken for '" name "'"))))

(define ssax:predefined-parsed-entities
  `(
    (,(string->symbol "amp") . "&")
    (,(string->symbol "lt") . "<")
    (,(string->symbol "gt") . ">")
    (,(string->symbol "apos") . "'")
    (,(string->symbol "quot") . "\"")
    ))

;;@body
;;
;;Expands and handles a parsed-entity reference.
;;
;;@2 is a symbol, the name of the parsed entity to expand.
;;@c entities - see ENTITIES
;;@4 is a procedure of arguments @var{port}, @var{entities}, and
;;@var{seed} that returns a seed.
;;@5 is called if the entity in question is a pre-declared entity.
;;
;;@0 returns the result returned by @4 or @5.
;;
;;Faults detected:@*
;;WFC: XML-Spec.html#wf-entdeclared@*
;;WFC: XML-Spec.html#norecursion
(define (ssax:handle-parsed-entity port name entities content-handler str-handler seed)
  (cond		    ; First we check the list of the declared entities
   ((assq name entities) =>
    (lambda (decl-entity)
      (let ((ent-body (cdr decl-entity)) ; mark the list to prevent recursion
	    (new-entities (cons (cons name #f) entities)))
	(cond
	 ((string? ent-body)
	  (call-with-input-string ent-body
	    (lambda (port) (content-handler port new-entities seed))))
	 ((procedure? ent-body)
	  (let ((port (ent-body)))
	    (define val (content-handler port new-entities seed))
	    (close-input-port port)
	    val))
	 (else
	  (slib:error port "[norecursion] broken for " name))))))
   ((assq name ssax:predefined-parsed-entities)
    => (lambda (decl-entity)
	 (str-handler (cdr decl-entity) "" seed)))
   (else (slib:error port "[wf-entdeclared] broken for " name))))

;;;; The ATTLIST Abstract Data Type

;;; Currently is implemented as an assoc list sorted in the ascending
;;; order of NAMES.

(define attlist-fold fold)
(define attlist-null? null?)
(define attlist->alist identity)
(define (make-empty-attlist) '())

;;@body
;;
;;Add a @2 pair to the existing @1, preserving its sorted ascending
;;order; and return the new list.  Return #f if a pair with the same
;;name already exists in @1
(define (attlist-add attlist name-value)
  (if (null? attlist) (cons name-value attlist)
      (case (ssax:name-compare (car name-value) (caar attlist))
	((=) #f)
	((<) (cons name-value attlist))
	(else (cons (car attlist) (attlist-add (cdr attlist) name-value)))
	)))

;;@body
;;
;;Given an non-null @1, return a pair of values: the top and the rest.
(define (attlist-remove-top attlist)
  (values (car attlist) (cdr attlist)))

;;@args port entities
;;
;;This procedure reads and parses a production @dfn{Attribute}.
;;
;;@example
;;[41] Attribute ::= Name Eq AttValue
;;[10] AttValue ::=  '"' ([^<&"] | Reference)* '"'
;;                | "'" ([^<&'] | Reference)* "'"
;;[25] Eq ::= S? '=' S?
;;@end example
;;
;;The procedure returns an ATTLIST, of Name (as UNRES-NAME), Value (as
;;string) pairs.  The current character on the @1 is a non-whitespace
;;character that is not an NCName-starting character.
;;
;;Note the following rules to keep in mind when reading an
;;@dfn{AttValue}:
;;@quotation
;;Before the value of an attribute is passed to the application or
;;checked for validity, the XML processor must normalize it as
;;follows:
;;
;;@itemize @bullet
;;@item
;;A character reference is processed by appending the referenced
;;character to the attribute value.
;;
;;@item
;;An entity reference is processed by recursively processing the
;;replacement text of the entity.  The named entities @samp{amp},
;;@samp{lt}, @samp{gt}, @samp{quot}, and @samp{apos} are pre-declared.
;;
;;@item
;;A whitespace character (#x20, #x0D, #x0A, #x09) is processed by
;;appending #x20 to the normalized value, except that only a single
;;#x20 is appended for a "#x0D#x0A" sequence that is part of an
;;external parsed entity or the literal entity value of an internal
;;parsed entity.
;;
;;@item
;;Other characters are processed by appending them to the normalized
;;value.
;;
;;@end itemize
;;
;;@end quotation
;;
;;Faults detected:@*
;;WFC: XML-Spec.html#CleanAttrVals@*
;;WFC: XML-Spec.html#uniqattspec
(define ssax:read-attributes	  ; ssax:read-attributes port entities
  (let ((value-delimeters (append '(#\< #\&) ssax:S-chars)))
    ;; Read the AttValue from the PORT up to the delimiter (which can
    ;; be a single or double-quote character, or even a symbol *eof*).
    ;; 'prev-fragments' is the list of string fragments, accumulated
    ;; so far, in reverse order.  Return the list of fragments with
    ;; newly read fragments prepended.
    (define (read-attrib-value delimiter port entities prev-fragments)
      (let* ((new-fragments
	      (cons (ssax:next-token '() (cons delimiter value-delimeters)
				     "XML [10]" port)
		    prev-fragments))
	     (cterm (read-char port)))
	(cond
	 ((or (eof-object? cterm) (eqv? cterm delimiter))
	  new-fragments)
	 ((eqv? cterm char-return)	; treat a CR and CRLF as a LF
	  (if (eqv? (peek-char port) #\newline) (read-char port))
	  (read-attrib-value delimiter port entities
	                     (cons " " new-fragments)))
	 ((memv cterm ssax:S-chars)
	  (read-attrib-value delimiter port entities
	                     (cons " " new-fragments)))
	 ((eqv? cterm #\&)
	  (cond
	   ((eqv? (peek-char port) #\#)
	    (read-char port)
	    (read-attrib-value delimiter port entities
			       (cons (string (ssax:read-char-ref port)) new-fragments)))
	   (else
	    (read-attrib-value delimiter port entities
			       (read-named-entity port entities new-fragments)))))
	 (else (slib:error port "[CleanAttrVals] broken")))))

    ;; we have read "&" that introduces a named entity reference.
    ;; read this reference and return the result of normalizing of the
    ;; corresponding string (that is, read-attrib-value is applied to
    ;; the replacement text of the entity).  The current position will
    ;; be after ";" that terminates the entity reference
    (define (read-named-entity port entities fragments)
      (let ((name (ssax:read-NCName port)))
	(ssax:assert-current-char '(#\;) "XML [68]" port)
	(ssax:handle-parsed-entity port name entities
				   (lambda (port entities fragments)
				     (read-attrib-value '*eof* port entities fragments))
				   (lambda (str1 str2 fragments)
				     (if (equal? "" str2) (cons str1 fragments)
					 (cons* str2 str1 fragments)))
				   fragments)))

    (lambda (port entities)
      (let loop ((attr-list (make-empty-attlist)))
	(if (not (ssax:ncname-starting-char? (ssax:skip-S port))) attr-list
	    (let ((name (ssax:read-QName port)))
	      (ssax:skip-S port)
	      (ssax:assert-current-char '(#\=) "XML [25]" port)
	      (ssax:skip-S port)
	      (let ((delimiter
		     (ssax:assert-current-char '(#\' #\" ) "XML [10]" port)))
		(loop
		 (or (attlist-add attr-list
				  (cons name
					(ssax:string-concatenate-reverse/shared
					 (read-attrib-value delimiter port entities
							    '()))))
		     (slib:error port "[uniqattspec] broken for " name))))))))
    ))

;;@body
;;
;;Convert an @2 to a RES-NAME, given the appropriate @3 declarations.
;;The last parameter, @4, determines if the default namespace applies
;;(for instance, it does not for attribute names).
;;
;;Per REC-xml-names/#nsc-NSDeclared, the "xml" prefix is considered
;;pre-declared and bound to the namespace name
;;"http://www.w3.org/XML/1998/namespace".
;;
;;@0 tests for the namespace constraints:@*
;;@url{http://www.w3.org/TR/REC-xml-names/#nsc-NSDeclared}
(define (ssax:resolve-name port unres-name namespaces apply-default-ns?)
  (cond
   ((pair? unres-name)			; it's a QNAME
    (cons
     (cond
      ((assq (car unres-name) namespaces) => cadr)
      ((eq? (car unres-name) ssax:Prefix-XML) ssax:Prefix-XML)
      (else
       (slib:error port "[nsc-NSDeclared] broken; prefix " (car unres-name))))
     (cdr unres-name)))
   (apply-default-ns?	      ; Do apply the default namespace, if any
    (let ((default-ns (assq '*DEFAULT* namespaces)))
      (if (and default-ns (cadr default-ns))
	  (cons (cadr default-ns) unres-name)
	  unres-name)))		       ; no default namespace declared
   (else unres-name)))	       ; no prefix, don't apply the default-ns


;;Procedure: ssax:uri-string->symbol URI-STR
;;Convert a URI-STR to an appropriate symbol
(define ssax:uri-string->symbol string->symbol)


;;@args tag port elems entities namespaces
;;
;;Complete parsing of a start-tag markup.  @0 must be called after the
;;start tag token has been read.  @1 is an UNRES-NAME.  @3 is an
;;instance of the ELEMS slot of XML-DECL; it can be #f to tell the
;;function to do @emph{no} validation of elements and their
;;attributes.
;;
;;@0 returns several values:
;;@itemize @bullet
;;@item ELEM-GI:
;;a RES-NAME.
;;@item ATTRIBUTES:
;;element's attributes, an ATTLIST of (RES-NAME . STRING) pairs.
;;The list does NOT include xmlns attributes.
;;@item NAMESPACES:
;;the input list of namespaces amended with namespace
;;(re-)declarations contained within the start-tag under parsing
;;@item ELEM-CONTENT-MODEL
;;@end itemize
;;
;;On exit, the current position in @2 will be the first character
;;after @samp{>} that terminates the start-tag markup.
;;
;;Faults detected:@*
;;VC: XML-Spec.html#enum@*
;;VC: XML-Spec.html#RequiredAttr@*
;;VC: XML-Spec.html#FixedAttr@*
;;VC: XML-Spec.html#ValueType@*
;;WFC: XML-Spec.html#uniqattspec (after namespaces prefixes are resolved)@*
;;VC: XML-Spec.html#elementvalid@*
;;WFC: REC-xml-names/#dt-NSName
;;
;;@emph{Note}: although XML Recommendation does not explicitly say it,
;;xmlns and xmlns: attributes don't have to be declared (although they
;;can be declared, to specify their default value).
(define ssax:complete-start-tag

  (let ((xmlns (string->symbol "xmlns"))
	(largest-dummy-decl-attr (list ssax:largest-unres-name #f #f #f)))

    ;; Scan through the attlist and validate it, against decl-attrs
    ;; Return an assoc list with added fixed or implied attrs.
    ;; Note that both attlist and decl-attrs are ATTLISTs, and therefore,
    ;; sorted
    (define (validate-attrs port attlist decl-attrs)

      ;; Check to see decl-attr is not of use type REQUIRED.  Add
      ;; the association with the default value, if any declared
      (define (add-default-decl decl-attr result)
	(let*-values
	 (((attr-name content-type use-type default-value)
	   (apply values decl-attr)))
	 (and (eq? use-type 'REQUIRED)
	      (slib:error port "[RequiredAttr] broken for" attr-name))
	 (if default-value
	     (cons (cons attr-name default-value) result)
	     result)))

      (let loop ((attlist attlist) (decl-attrs decl-attrs) (result '()))
	(if (attlist-null? attlist)
	    (attlist-fold add-default-decl result decl-attrs)
	    (let*-values
	     (((attr attr-others)
	       (attlist-remove-top attlist))
	      ((decl-attr other-decls)
	       (if (attlist-null? decl-attrs)
		   (values largest-dummy-decl-attr decl-attrs)
		   (attlist-remove-top decl-attrs)))
	      )
	     (case (ssax:name-compare (car attr) (car decl-attr))
	       ((<)
		(if (or (eq? xmlns (car attr))
			(and (pair? (car attr)) (eq? xmlns (caar attr))))
		    (loop attr-others decl-attrs (cons attr result))
		    (slib:error port "[ValueType] broken for " attr)))
	       ((>)
		(loop attlist other-decls
		      (add-default-decl decl-attr result)))
	       (else ; matched occurrence of an attr with its declaration
		(let*-values
		 (((attr-name content-type use-type default-value)
		   (apply values decl-attr)))
		 ;; Run some tests on the content of the attribute
		 (cond
		  ((eq? use-type 'FIXED)
		   (or (equal? (cdr attr) default-value)
		       (slib:error port "[FixedAttr] broken for " attr-name)))
		  ((eq? content-type 'CDATA) #t) ; everything goes
		  ((pair? content-type)
		   (or (member (cdr attr) content-type)
		       (slib:error port "[enum] broken for " attr-name "="
				   (cdr attr))))
		  (else
		   (slib:warn port "declared content type " content-type
			      " not verified yet")))
		 (loop attr-others other-decls (cons attr result)))))
	     ))))


    ;; Add a new namespace declaration to namespaces.
    ;; First we convert the uri-str to a uri-symbol and search namespaces for
    ;; an association (_ user-prefix . uri-symbol).
    ;; If found, we return the argument namespaces with an association
    ;; (prefix user-prefix . uri-symbol) prepended.
    ;; Otherwise, we prepend (prefix uri-symbol . uri-symbol)
    (define (add-ns port prefix uri-str namespaces)
      (and (equal? "" uri-str)
	   (slib:error port "[dt-NSName] broken for " prefix))
      (let ((uri-symbol (ssax:uri-string->symbol uri-str)))
	(let loop ((nss namespaces))
	  (cond
	   ((null? nss)
	    (cons (cons* prefix uri-symbol uri-symbol) namespaces))
	   ((eq? uri-symbol (cddar nss))
	    (cons (cons* prefix (cadar nss) uri-symbol) namespaces))
	   (else (loop (cdr nss)))))))

    ;; partition attrs into proper attrs and new namespace declarations
    ;; return two values: proper attrs and the updated namespace declarations
    (define (adjust-namespace-decl port attrs namespaces)
      (let loop ((attrs attrs) (proper-attrs '()) (namespaces namespaces))
	(cond
	 ((null? attrs) (values proper-attrs namespaces))
	 ((eq? xmlns (caar attrs))  ; re-decl of the default namespace
	  (loop (cdr attrs) proper-attrs
		(if (equal? "" (cdar attrs)) ; un-decl of the default ns
		    (cons (cons* '*DEFAULT* #f #f) namespaces)
		    (add-ns port '*DEFAULT* (cdar attrs) namespaces))))
	 ((and (pair? (caar attrs)) (eq? xmlns (caaar attrs)))
	  (loop (cdr attrs) proper-attrs
		(add-ns port (cdaar attrs) (cdar attrs) namespaces)))
	 (else
	  (loop (cdr attrs) (cons (car attrs) proper-attrs) namespaces)))))

    ;; The body of the function
    (lambda (tag-head port elems entities namespaces)
      (let*-values
       (((attlist) (ssax:read-attributes port entities))
	((empty-el-tag?)
	 (begin
	   (ssax:skip-S port)
	   (and
	    (eqv? #\/
		  (ssax:assert-current-char '(#\> #\/) "XML [40], XML [44], no '>'" port))
	    (ssax:assert-current-char '(#\>) "XML [44], no '>'" port))))
	((elem-content decl-attrs)	; see xml-decl for their type
	 (if elems			; elements declared: validate!
	     (cond
	      ((assoc tag-head elems) =>
	       (lambda (decl-elem)	; of type xml-decl::decl-elem
		 (values
		  (if empty-el-tag? 'EMPTY-TAG (cadr decl-elem))
		  (caddr decl-elem))))
	      (else
	       (slib:error port "[elementvalid] broken, no decl for " tag-head)))
	     (values			; non-validating parsing
	      (if empty-el-tag? 'EMPTY-TAG 'ANY)
	      #f)			; no attributes declared
	     ))
	((merged-attrs) (if decl-attrs (validate-attrs port attlist decl-attrs)
			    (attlist->alist attlist)))
	((proper-attrs namespaces)
	 (adjust-namespace-decl port merged-attrs namespaces))
	)
       ;; build the return value
       (values
	(ssax:resolve-name port tag-head namespaces #t)
	(fold-right
	 (lambda (name-value attlist)
	   (or
	    (attlist-add attlist
			 (cons (ssax:resolve-name port (car name-value) namespaces #f)
			       (cdr name-value)))
	    (slib:error port "[uniqattspec] after NS expansion broken for "
			name-value)))
	 (make-empty-attlist)
	 proper-attrs)
	namespaces
	elem-content)))))

;;@body
;;
;;Parses an ExternalID production:
;;
;;@example
;;[75] ExternalID ::= 'SYSTEM' S SystemLiteral
;;                  | 'PUBLIC' S PubidLiteral S SystemLiteral
;;[11] SystemLiteral ::= ('"' [^"]* '"') | ("'" [^']* "'")
;;[12] PubidLiteral ::=  '"' PubidChar* '"'
;;                     | "'" (PubidChar - "'")* "'"
;;[13] PubidChar ::=  #x20 | #x0D | #x0A | [a-zA-Z0-9]
;;                         | [-'()+,./:=?;!*#@@$_%]
;;@end example
;;
;;Call @0 when an ExternalID is expected; that is, the current
;;character must be either #\S or #\P that starts correspondingly a
;;SYSTEM or PUBLIC token.  @0 returns the @var{SystemLiteral} as a
;;string.  A @var{PubidLiteral} is disregarded if present.
(define (ssax:read-external-id port)
  (let ((discriminator (ssax:read-NCName port)))
    (ssax:assert-current-char ssax:S-chars "space after SYSTEM or PUBLIC" port)
    (ssax:skip-S port)
    (let ((delimiter
	   (ssax:assert-current-char '(#\' #\" ) "XML [11], XML [12]" port)))
      (cond
       ((eq? discriminator (string->symbol "SYSTEM"))
	(let ((val (ssax:next-token '() (list delimiter) "XML [11]" port)))
	  (read-char port)		; reading the closing delim
	  val))
       ((eq? discriminator (string->symbol "PUBLIC"))
	(let loop ((c (read-char port)))
	  (cond
	   ((eqv? c delimiter) c)
	   ((eof-object? c)
	    (slib:error port "Unexpected EOF while skipping until " delimiter))
	   (else (loop (read-char port)))))
	(ssax:assert-current-char ssax:S-chars "space after PubidLiteral" port)
	(ssax:skip-S port)
	(let* ((delimiter
		(ssax:assert-current-char '(#\' #\" ) "XML [11]" port))
	       (systemid
		(ssax:next-token '() (list delimiter) "XML [11]" port)))
	  (read-char port)		; reading the closing delim
	  systemid))
       (else
	(slib:error port "XML [75], " discriminator
		    " rather than SYSTEM or PUBLIC"))))))


;;@subsection Mid-Level Parsers and Scanners
;;
;;@noindent
;;These procedures parse productions corresponding to the whole
;;(document) entity or its higher-level pieces (prolog, root element,
;;etc).

;;@body
;;
;;Scan the Misc production in the context:
;;
;;@example
;;[1]  document ::=  prolog element Misc*
;;[22] prolog ::= XMLDecl? Misc* (doctypedec l Misc*)?
;;[27] Misc ::= Comment | PI |  S
;;@end example
;;
;;Call @0 in the prolog or epilog contexts.  In these contexts,
;;whitespaces are completely ignored.  The return value from @0 is
;;either a PI-token, a DECL-token, a START token, or *EOF*.  Comments
;;are ignored and not reported.
(define (ssax:scan-misc port)
  (let loop ((c (ssax:skip-S port)))
    (cond
     ((eof-object? c) c)
     ((not (char=? c #\<))
      (slib:error port "XML [22], char '" c "' unexpected"))
     (else
      (let ((token (ssax:read-markup-token port)))
	(case (xml-token-kind token)
	  ((COMMENT) (loop (ssax:skip-S port)))
	  ((PI DECL START) token)
	  (else
	   (slib:error port "XML [22], unexpected token of kind "
		       (xml-token-kind token)
		       ))))))))

;;@args port expect-eof? str-handler iseed
;;
;;Read the character content of an XML document or an XML element.
;;
;;@example
;;[43] content ::=
;;(element | CharData | Reference | CDSect | PI | Comment)*
;;@end example
;;
;;To be more precise, @0 reads CharData, expands CDSect and character
;;entities, and skips comments.  @0 stops at a named reference, EOF,
;;at the beginning of a PI, or a start/end tag.
;;
;;@2 is a boolean indicating if EOF is normal; i.e., the character
;;data may be terminated by the EOF.  EOF is normal while processing a
;;parsed entity.
;;
;;@4 is an argument passed to the first invocation of @3.
;;
;;@0 returns two results: @var{seed} and @var{token}.  The @var{seed}
;;is the result of the last invocation of @3, or the original @4 if @3
;;was never called.
;;
;;@var{token} can be either an eof-object (this can happen only if @2
;;was #t), or:
;;@itemize @bullet
;;
;;@item
;;an xml-token describing a START tag or an END-tag;
;;For a start token, the caller has to finish reading it.
;;
;;@item
;;an xml-token describing the beginning of a PI.  It's up to an
;;application to read or skip through the rest of this PI;
;;
;;@item
;;an xml-token describing a named entity reference.
;;
;;@end itemize
;;
;;CDATA sections and character references are expanded inline and
;;never returned.  Comments are silently disregarded.
;;
;;As the XML Recommendation requires, all whitespace in character data
;;must be preserved.  However, a CR character (#x0D) must be
;;disregarded if it appears before a LF character (#x0A), or replaced
;;by a #x0A character otherwise.  See Secs. 2.10 and 2.11 of the XML
;;Recommendation.  See also the canonical XML Recommendation.
(define ssax:read-char-data
  (let ((terminators-usual (list #\< #\& char-return))
	(terminators-usual-eof (list #\< '*eof* #\& char-return))
	(handle-fragment
	 (lambda (fragment str-handler seed)
	   (if (string-null? fragment) seed
	       (str-handler fragment "" seed)))))
    (lambda (port expect-eof? str-handler seed)
      ;; Very often, the first character we encounter is #\<
      ;; Therefore, we handle this case in a special, fast path
      (if (eqv? #\< (peek-char port))
	  ;; The fast path
	  (let ((token (ssax:read-markup-token port)))
	    (case (xml-token-kind token)
	      ((START END)		; The most common case
	       (values seed token))
	      ((CDSECT)
	       (let ((seed (ssax:read-cdata-body port str-handler seed)))
		 (ssax:read-char-data port expect-eof? str-handler seed)))
	      ((COMMENT)
	       (ssax:read-char-data port expect-eof? str-handler seed))
	      (else
	       (values seed token))))
	  ;; The slow path
	  (let ((char-data-terminators
		 (if expect-eof? terminators-usual-eof terminators-usual)))
	    (let loop ((seed seed))
	      (let* ((fragment
		      (ssax:next-token '() char-data-terminators
				       "reading char data" port))
		     (term-char (peek-char port)) ; one of char-data-terminators
		     )
		(if (eof-object? term-char)
		    (values
		     (handle-fragment fragment str-handler seed)
		     term-char)
		    (case term-char
		      ((#\<)
		       (let ((token (ssax:read-markup-token port)))
			 (case (xml-token-kind token)
			   ((CDSECT)
			    (loop
			     (ssax:read-cdata-body port str-handler
						   (handle-fragment fragment str-handler seed))))
			   ((COMMENT)
			    (loop (handle-fragment fragment str-handler seed)))
			   (else
			    (values
			     (handle-fragment fragment str-handler seed)
			     token)))))
		      ((#\&)
		       (read-char port)
		       (case (peek-char port)
			 ((#\#) (read-char port)
			  (loop (str-handler fragment
					     (string (ssax:read-char-ref port))
					     seed)))
			 (else
			  (let ((name (ssax:read-NCName port)))
			    (ssax:assert-current-char '(#\;) "XML [68]" port)
			    (values
			     (handle-fragment fragment str-handler seed)
			     (make-xml-token 'ENTITY-REF name))))))
		      (else		; This must be a CR character
		       (read-char port)
		       (if (eqv? (peek-char port) #\newline)
			   (read-char port))
		       (loop (str-handler fragment (string #\newline) seed))))
		    ))))))))

;;@body
;;
;;Make sure that @1 is of anticipated @2 and has anticipated @3.  Note
;;that the @3 argument may actually be a pair of two symbols,
;;Namespace-URI or the prefix, and of the localname.  If the assertion
;;fails, @4 is evaluated by passing it three arguments: @1 @2 @3.  The
;;result of @4 is returned.
(define (ssax:assert-token token kind gi error-cont)
  (or (and (xml-token? token)
	   (eq? kind (xml-token-kind token))
	   (equal? gi (xml-token-head token)))
      (error-cont token kind gi)))

;;@subsection High-level Parsers
;;
;;These procedures are to instantiate a SSAX parser.  A user can
;;instantiate the parser to do the full validation, or no validation,
;;or any particular validation.  The user specifies which PI he wants
;;to be notified about.  The user tells what to do with the parsed
;;character and element data.  The latter handlers determine if the
;;parsing follows a SAX or a DOM model.

;;@args my-pi-handlers
;;
;;Create a parser to parse and process one Processing Element (PI).
;;
;;@1 is an association list of pairs
;;@code{(@var{pi-tag} . @var{pi-handler})} where @var{pi-tag} is an
;;NCName symbol, the PI target; and @var{pi-handler} is a procedure
;;taking arguments @var{port}, @var{pi-tag}, and @var{seed}.
;;
;;@var{pi-handler} should read the rest of the PI up to and including
;;the combination @samp{?>} that terminates the PI.  The handler
;;should return a new seed.  One of the @var{pi-tag}s may be the
;;symbol @code{*DEFAULT*}.  The corresponding handler will handle PIs
;;that no other handler will.  If the *DEFAULT* @var{pi-tag} is not
;;specified, @0 will assume the default handler that skips the body of
;;the PI.
;;
;;@0 returns a procedure of arguments @var{port}, @var{pi-tag}, and
;;@var{seed}; that will parse the current PI according to @1.
(define (ssax:make-pi-parser handlers)
  (lambda (port target seed)
    (define pair (assv target handlers))
    (or pair (set! pair (assv '*DEFAULT* handlers)))
    (cond ((not pair)
	   (slib:warn port "Skipping PI: " target #\newline)
	   (ssax:skip-pi port)
	   seed)
	  (else ((cdr pair) port target seed)))))

;;syntax: ssax:make-elem-parser
;;   my-new-level-seed my-finish-element my-char-data-handler my-pi-handlers

;;@body
;;
;;Create a parser to parse and process one element, including its
;;character content or children elements.  The parser is typically
;;applied to the root element of a document.
;;
;;@table @asis
;;
;;@item @1
;;is a procedure taking arguments:
;;
;;@var{elem-gi} @var{attributes} @var{namespaces} @var{expected-content} @var{seed}
;;
;;where @var{elem-gi} is a RES-NAME of the element about to be
;;processed.
;;
;;@1 is to generate the seed to be passed to handlers that process the
;;content of the element.
;;
;;@item @2
;;is a procedure taking arguments:
;;
;;@var{elem-gi} @var{attributes} @var{namespaces} @var{parent-seed} @var{seed}
;;
;;@2 is called when parsing of @var{elem-gi} is finished.
;;The @var{seed} is the result from the last content parser (or
;;from @1 if the element has the empty content).
;;@var{parent-seed} is the same seed as was passed to @1.
;;@2 is to generate a seed that will be the result
;;of the element parser.
;;
;;@item @3
;;is a STR-HANDLER as described in Data Types above.
;;
;;@item @4
;;is as described for @code{ssax:make-pi-handler} above.
;;
;;@end table
;;
;;The generated parser is a procedure taking arguments:
;;
;;@var{start-tag-head} @var{port} @var{elems} @var{entities} @var{namespaces} @var{preserve-ws?} @var{seed}
;;
;;The procedure must be called after the start tag token has been
;;read.  @var{start-tag-head} is an UNRES-NAME from the start-element
;;tag.  ELEMS is an instance of ELEMS slot of XML-DECL.
;;
;;Faults detected:@*
;;VC: XML-Spec.html#elementvalid@*
;;WFC: XML-Spec.html#GIMatch
(define (ssax:make-elem-parser my-new-level-seed my-finish-element
			       my-char-data-handler my-pi-handlers)
  (lambda (start-tag-head port elems entities namespaces preserve-ws? seed)
    (define xml-space-gi (cons ssax:Prefix-XML
			       (string->symbol "space")))
    (let handle-start-tag ((start-tag-head start-tag-head)
			   (port port) (entities entities)
			   (namespaces namespaces)
			   (preserve-ws? preserve-ws?) (parent-seed seed))
      (let*-values
       (((elem-gi attributes namespaces expected-content)
	 (ssax:complete-start-tag start-tag-head port elems
				  entities namespaces))
	((seed)
	 (my-new-level-seed elem-gi attributes
			    namespaces expected-content parent-seed)))
       (case expected-content
	 ((EMPTY-TAG)
	  (my-finish-element
	   elem-gi attributes namespaces parent-seed seed))
	 ((EMPTY)		 ; The end tag must immediately follow
	  (ssax:assert-token (and (eqv? #\< (ssax:skip-S port))
				  (ssax:read-markup-token port))
			     'END
			     start-tag-head
			     (lambda (token exp-kind exp-head)
			       (slib:error port "[elementvalid] broken for " token
					   " while expecting "
					   exp-kind exp-head)))
	  (my-finish-element
	   elem-gi attributes namespaces parent-seed seed))
	 (else				; reading the content...
	  (let ((preserve-ws?	; inherit or set the preserve-ws? flag
		 (cond ((assoc xml-space-gi attributes) =>
			(lambda (name-value)
			  (equal? "preserve" (cdr name-value))))
		       (else preserve-ws?))))
	    (let loop ((port port) (entities entities)
		       (expect-eof? #f) (seed seed))
	      (let*-values
	       (((seed term-token)
		 (ssax:read-char-data port expect-eof?
				      my-char-data-handler seed)))
	       (if (eof-object? term-token)
		   seed
		   (case (xml-token-kind term-token)
		     ((END)
		      (ssax:assert-token term-token 'END  start-tag-head
					 (lambda (token exp-kind exp-head)
					   (slib:error port "[GIMatch] broken for "
						       term-token " while expecting "
						       exp-kind exp-head)))
		      (my-finish-element
		       elem-gi attributes namespaces parent-seed seed))
		     ((PI)
		      (let ((seed
			     ((ssax:make-pi-parser my-pi-handlers)
			      port (xml-token-head term-token) seed)))
			(loop port entities expect-eof? seed)))
		     ((ENTITY-REF)
		      (let ((seed
			     (ssax:handle-parsed-entity
			      port (xml-token-head term-token)
			      entities
			      (lambda (port entities seed)
				(loop port entities #t seed))
			      my-char-data-handler
			      seed))) ; keep on reading the content after ent
			(loop port entities expect-eof? seed)))
		     ((START)		; Start of a child element
		      (if (eq? expected-content 'PCDATA)
			  (slib:error port "[elementvalid] broken for "
				      elem-gi
				      " with char content only; unexpected token "
				      term-token))
		      ;; Do other validation of the element content
		      (let ((seed
			     (handle-start-tag
			      (xml-token-head term-token)
			      port entities namespaces
			      preserve-ws? seed)))
			(loop port entities expect-eof? seed)))
		     (else
		      (slib:error port "XML [43] broken for "
				  term-token))))))))
	 )))
    ))


;;This is ssax:make-parser with all the (specialization) handlers given
;;as positional arguments.  It is called by ssax:make-parser, see below
(define (ssax:make-parser/positional-args
	 *handler-DOCTYPE
	 *handler-UNDECL-ROOT
	 *handler-DECL-ROOT
	 *handler-NEW-LEVEL-SEED
	 *handler-FINISH-ELEMENT
	 *handler-CHAR-DATA-HANDLER
	 *handler-PROCESSING-INSTRUCTIONS)
  (lambda (port seed)
    ;; We must've just scanned the DOCTYPE token.  Handle the
    ;; doctype declaration and exit to
    ;; scan-for-significant-prolog-token-2, and eventually, to the
    ;; element parser.
    (define (handle-decl port token-head seed)
      (or (eq? (string->symbol "DOCTYPE") token-head)
	  (slib:error port "XML [22], expected DOCTYPE declaration, found "
		      token-head))
      (ssax:assert-current-char ssax:S-chars "XML [28], space after DOCTYPE" port)
      (ssax:skip-S port)
      (let*-values
       (((docname) (ssax:read-QName port))
	((systemid)
	 (and (ssax:ncname-starting-char? (ssax:skip-S port))
	      (ssax:read-external-id port)))
	((internal-subset?)
	 (begin
	   (ssax:skip-S port)
	   (eqv? #\[
		 (ssax:assert-current-char '(#\> #\[)
					"XML [28], end-of-DOCTYPE" port))))
	((elems entities namespaces seed)
	 (*handler-DOCTYPE port docname systemid internal-subset? seed)))
       (scan-for-significant-prolog-token-2 port elems entities namespaces
					    seed)))
    ;; Scan the leading PIs until we encounter either a doctype
    ;; declaration or a start token (of the root element).  In the
    ;; latter two cases, we exit to the appropriate continuation
    (define (scan-for-significant-prolog-token-1 port seed)
      (let ((token (ssax:scan-misc port)))
	(if (eof-object? token)
	    (slib:error port "XML [22], unexpected EOF")
	    (case (xml-token-kind token)
	      ((PI)
	       (let ((seed
		      ((ssax:make-pi-parser *handler-PROCESSING-INSTRUCTIONS)
		       port (xml-token-head token) seed)))
		 (scan-for-significant-prolog-token-1 port seed)))
	      ((DECL) (handle-decl port (xml-token-head token) seed))
	      ((START)
	       (let*-values
		(((elems entities namespaces seed)
		  (*handler-UNDECL-ROOT (xml-token-head token) seed)))
		(element-parser (xml-token-head token) port elems
				entities namespaces #f seed)))
	      (else (slib:error port "XML [22], unexpected markup "
				token))))))
    ;; Scan PIs after the doctype declaration, till we encounter
    ;; the start tag of the root element.  After that we exit
    ;; to the element parser
    (define (scan-for-significant-prolog-token-2 port elems entities namespaces seed)
      (let ((token (ssax:scan-misc port)))
	(if (eof-object? token)
	    (slib:error port "XML [22], unexpected EOF")
	    (case (xml-token-kind token)
	      ((PI)
	       (let ((seed ((ssax:make-pi-parser *handler-PROCESSING-INSTRUCTIONS)
			    port (xml-token-head token) seed)))
		 (scan-for-significant-prolog-token-2 port elems entities
						      namespaces seed)))
	      ((START)
	       (element-parser (xml-token-head token) port elems
			       entities namespaces #f
			       (*handler-DECL-ROOT (xml-token-head token) seed)))
	      (else (slib:error port "XML [22], unexpected markup "
				token))))))
    ;; A procedure start-tag-head port elems entities namespaces
    ;;		 preserve-ws? seed
    (define element-parser
      (ssax:make-elem-parser *handler-NEW-LEVEL-SEED
			     *handler-FINISH-ELEMENT
			     *handler-CHAR-DATA-HANDLER
			     *handler-PROCESSING-INSTRUCTIONS))

    ;; Get the ball rolling ...
    (scan-for-significant-prolog-token-1 port seed)
    ))

(define DOCTYPE 'DOCTYPE)
(define UNDECL-ROOT 'UNDECL-ROOT)
(define DECL-ROOT 'DECL-ROOT)
(define NEW-LEVEL-SEED 'NEW-LEVEL-SEED)
(define FINISH-ELEMENT 'FINISH-ELEMENT)
(define CHAR-DATA-HANDLER 'CHAR-DATA-HANDLER)
(define PROCESSING-INSTRUCTIONS 'PROCESSING-INSTRUCTIONS)

;;@args user-handler-tag user-handler ...
;;
;;Create an XML parser, an instance of the XML parsing framework.
;;This will be a SAX, a DOM, or a specialized parser depending on the
;;supplied user-handlers.
;;
;;@0 takes an even number of arguments; @1 is a symbol that identifies
;;a procedure (or association list for @code{PROCESSING-INSTRUCTIONS})
;;(@2) that follows the tag.  Given below are tags and signatures of
;;the corresponding procedures.  Not all tags have to be specified.
;;If some are omitted, reasonable defaults will apply.
;;
;;@table @samp
;;
;;@item DOCTYPE
;;handler-procedure: @var{port} @var{docname} @var{systemid} @var{internal-subset?} @var{seed}
;;
;;If @var{internal-subset?} is #t, the current position in the port is
;;right after we have read @samp{[} that begins the internal DTD
;;subset.  We must finish reading of this subset before we return (or
;;must call @code{skip-internal-dtd} if we aren't interested in
;;reading it).  @var{port} at exit must be at the first symbol after
;;the whole DOCTYPE declaration.
;;
;;The handler-procedure must generate four values:
;;@quotation
;;@var{elems} @var{entities} @var{namespaces} @var{seed}
;;@end quotation
;;
;;@var{elems} is as defined for the ELEMS slot of XML-DECL.  It may be
;;#f to switch off validation.  @var{namespaces} will typically
;;contain @var{user-prefix}es for selected @var{uri-symb}s.  The
;;default handler-procedure skips the internal subset, if any, and
;;returns @code{(values #f '() '() seed)}.
;;
;;@item UNDECL-ROOT
;;procedure: @var{elem-gi} @var{seed}
;;
;;where @var{elem-gi} is an UNRES-NAME of the root element.  This
;;procedure is called when an XML document under parsing contains
;;@emph{no} DOCTYPE declaration.
;;
;;The handler-procedure, as a DOCTYPE handler procedure above,
;;must generate four values:
;;@quotation
;;@var{elems} @var{entities} @var{namespaces} @var{seed}
;;@end quotation
;;
;;The default handler-procedure returns (values #f '() '() seed)
;;
;;@item DECL-ROOT
;;procedure: @var{elem-gi} @var{seed}
;;
;;where @var{elem-gi} is an UNRES-NAME of the root element.  This
;;procedure is called when an XML document under parsing does contains
;;the DOCTYPE declaration.  The handler-procedure must generate a new
;;@var{seed} (and verify that the name of the root element matches the
;;doctype, if the handler so wishes).  The default handler-procedure
;;is the identity function.
;;
;;@item NEW-LEVEL-SEED
;;procedure: see ssax:make-elem-parser, my-new-level-seed
;;
;;@item FINISH-ELEMENT
;;procedure: see ssax:make-elem-parser, my-finish-element
;;
;;@item CHAR-DATA-HANDLER
;;procedure: see ssax:make-elem-parser, my-char-data-handler
;;
;;@item PROCESSING-INSTRUCTIONS
;;association list as is passed to @code{ssax:make-pi-parser}.
;;The default value is '()
;;
;;@end table
;;
;;The generated parser is a procedure of arguments @var{port} and
;;@var{seed}.
;;
;;This procedure parses the document prolog and then exits to an
;;element parser (created by @code{ssax:make-elem-parser}) to handle
;;the rest.
;;
;;@example
;;[1]  document ::=  prolog element Misc*
;;[22] prolog ::= XMLDecl? Misc* (doctypedec | Misc*)?
;;[27] Misc ::= Comment | PI |  S
;;[28] doctypedecl ::=  '<!DOCTYPE' S Name (S ExternalID)? S?
;;              ('[' (markupdecl | PEReference | S)* ']' S?)? '>'
;;[29] markupdecl ::= elementdecl | AttlistDecl
;;                     | EntityDecl
;;                     | NotationDecl | PI
;;                     | Comment
;;@end example
(define ssax:make-parser
  (let ((descriptors
	 `((DOCTYPE
	    ,(lambda (port docname systemid internal-subset? seed)
	       (cond (internal-subset?
		      (ssax:skip-internal-dtd port)))
	       (slib:warn port "DOCTYPE DECL " docname " "
			  systemid " found and skipped")
	       (values #f '() '() seed)
	       ))
	   (UNDECL-ROOT
	    ,(lambda (elem-gi seed) (values #f '() '() seed)))
	   (DECL-ROOT
	    ,(lambda (elem-gi seed) seed))
	   (NEW-LEVEL-SEED)		; required
	   (FINISH-ELEMENT)		; required
	   (CHAR-DATA-HANDLER)		; required
	   (PROCESSING-INSTRUCTIONS ())
	   )))
    (lambda proplist
      (define count 0)
      (if (odd? (length proplist))
	  (slib:error 'ssax:make-parser "takes even number of arguments"
		      proplist))
      (let ((posititional-args
	     (map (lambda (spec)
		    (define ptail (member (car spec) proplist))
		    (cond ((and ptail (odd? (length ptail)))
			   (slib:error 'ssax:make-parser 'bad 'argument ptail))
			  (ptail
			   (set! count (+ 1 count))
			   (cadr ptail))
			  ((not (null? (cdr spec)))
			   (cadr spec))
			  (else
			   (slib:error
			    'ssax:make-parser 'missing (car spec) 'property))))
		  descriptors)))
	(if (= count (quotient (length proplist) 2))
	    (apply ssax:make-parser/positional-args posititional-args)
	    (slib:error 'ssax:make-parser 'extra 'arguments proplist))))))

;;@subsection Parsing XML to SXML

;;@body
;;
;;This is an instance of the SSAX parser that returns an SXML
;;representation of the XML document to be read from @1.  @2 is a list
;;of @code{(@var{user-prefix} . @var{uri-string})} that assigns
;;@var{user-prefix}es to certain namespaces identified by particular
;;@var{uri-string}s.  It may be an empty list.  @0 returns an SXML
;;tree.  The port points out to the first character after the root
;;element.
(define (ssax:xml->sxml port namespace-prefix-assig)
  (define namespaces
    (map (lambda (el) (cons* #f (car el) (ssax:uri-string->symbol (cdr el))))
	 namespace-prefix-assig))
  (define (RES-NAME->SXML res-name)
    (string->symbol
     (string-append
      (symbol->string (car res-name))
      ":"
      (symbol->string (cdr res-name)))))
  (let ((result
	 (reverse
	  ((ssax:make-parser

	    'DOCTYPE
	    (lambda (port docname systemid internal-subset? seed)
	      (cond (internal-subset?
		     (ssax:skip-internal-dtd port)))
	      (slib:warn port "DOCTYPE DECL " docname " "
			 systemid " found and skipped")
	      (values #f '() namespaces seed))

	    'NEW-LEVEL-SEED
	    (lambda (elem-gi attributes namespaces expected-content seed)
	      '())

	    'FINISH-ELEMENT
	    (lambda (elem-gi attributes namespaces parent-seed seed)
	      (define nseed (ssax:reverse-collect-str-drop-ws seed))
	      (define attrs
		(attlist-fold
		 (lambda (attr accum)
		   (cons (list (if (symbol? (car attr))
				   (car attr)
				   (RES-NAME->SXML (car attr)))
			       (cdr attr))
			 accum))
		 '() attributes))
	      (cons (cons (if (symbol? elem-gi)
			      elem-gi
			      (RES-NAME->SXML elem-gi))
			  (if (null? attrs)
			      nseed
			      (cons (cons '@ attrs) nseed)))
		    parent-seed))

	    'CHAR-DATA-HANDLER
	    (lambda (string1 string2 seed)
	      (if (string-null? string2)
		  (cons string1 seed)
		  (cons* string2 string1 seed)))

	    'UNDECL-ROOT
	    (lambda (elem-gi seed)
	      (values #f '() namespaces seed))

	    'PROCESSING-INSTRUCTIONS
	    (list
	     (cons '*DEFAULT*
		   (lambda (port pi-tag seed)
		     (cons (list '*PROCESSING-INSTRUCTIONS*
				 pi-tag
				 (ssax:read-pi-body-as-string port))
			   seed))))
	    )
	   port
	   '()))))
    (cons '*TOP*
	  (if (null? namespace-prefix-assig)
	      result
	      (cons
	       (list '@ (cons '*NAMESPACES*
			      (map (lambda (ns) (list (car ns) (cdr ns)))
				   namespace-prefix-assig)))
	       result)))))
