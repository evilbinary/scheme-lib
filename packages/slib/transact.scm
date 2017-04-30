;;; "transact.scm" Interface to programs.
; Copyright 1997, 1998, 2002, 2008 Aubrey Jaffer
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

(require 'string-search)
(require 'filename)
(require 'line-i/o)
(require 'system)
(require 'printf)
(require 'scanf)
(require 'byte)
(require-if 'compiling 'directory)

;;@subsubheading File Locking
;;
;;@noindent
;;Unix file-locking is focussed on write permissions for segments of a
;;existing file.  While this might be employed for (binary) database
;;access, it is not used for everyday contention (between users) for
;;text files.
;;
;;@noindent
;;Microsoft has several file-locking protocols.  Their model denies
;;write access to a file if any reader has it open.  This is too
;;restrictive.  Write access is denied even when the reader has
;;reached end-of-file.  And tracking read access (which is much more
;;common than write access) causes havoc when remote hosts crash or
;;disconnect.
;;
;;@noindent
;;It is bizarre that the concept of multi-user contention for
;;modifying files has not been adequately addressed by either of the
;;large operating system development efforts.  There is further irony
;;that both camps support contention detection and resolution only
;;through weak conventions of some their document editing programs.
;;
;;@noindent
;;@cindex file-lock
;;The @dfn{file-lock} procedures implement a transaction method for file
;;replacement compatible with the methods used by the GNU @dfn{emacs}
;;text editor on Unix systems and the Microsoft @dfn{Word} editor.
;;@cindex emacs
;;
;;@noindent
;;@cindex certificate
;;Both protocols employ what I term a @dfn{certificate} containing the
;;user, hostname, time, and (on Unix) process-id.
;;Intent to replace @var{file} is indicated by adding to @var{file}'s
;;directory a certificate object whose name is derived from
;;@var{file}.
;;
;;@noindent
;;The Microsoft Word certificate is contained in a 162 byte file named
;;for the visited @var{file} with a @samp{~$} prefix.
;;Emacs/Unix creates a symbolic link to a certificate named for the
;;visited @var{file} prefixed with @samp{.#}.
;;Because Unix systems can import Microsoft file systems, these
;;routines maintain and check both Emacs and Word certificates.

;;Returns a string naming the path of the emacs-style file-lock symbolic
;;link associated with @1.
(define (emacs-lock:path path)
  (let* ((dir (pathname->vicinity path))
	 (file (substring path (string-length dir) (string-length path))))
    (in-vicinity dir (string-append ".#" file))))

;;Returns a string naming the path of the ms-word style lock file
;;associated with @1.
(define (word-lock:path path)
  (let* ((dir (pathname->vicinity path))
	 (file (substring path (string-length dir) (string-length path)))
	 (filen (string-length file)))
    (in-vicinity
     dir (string-append
	  "~$" (substring file (min 2 (max 0 (- filen 10))) filen)))))

(define (word-lock:certificate lockpath)
  (define iport (open-file lockpath 'rb))
  (and
   iport
   (call-with-open-ports
    (lambda (iport)
      (define len (read-byte iport))
      (define pos 1)
      (and (number? len)
	   (let ((name (make-string len)))
	     (define (discard cnt)
	       (do ((cnt (+ -1 cnt) (+ -1 cnt)))
		   ((or (eof-object? (peek-char iport)) (negative? cnt))
		    (negative? cnt))
		 (or (eof-object? (read-byte iport)) (set! pos (+ 1 pos)))))
	     (define (read-field)
	       (define len (read-byte iport))
	       (set! pos (+ 1 pos))
	       (or (eof-object? (read-byte iport)) (set! pos (+ 1 pos)))
	       (and (number? len)
		    (let ((str (make-string len)))
		      (do ((idx 0 (+ 1 idx)))
			  ((or (eof-object? (peek-char iport)) (>= idx len))
			   (and (>= idx len) str))
			(string-set! str idx (read-char iport))
			(or (eof-object? (read-char iport)) (set! pos (+ 2 pos)))))))
;;; read compact name
	     (do ((idx 0 (+ 1 idx)))
		 ((or (eof-object? (peek-char iport)) (>= idx len)))
	       (string-set! name idx (read-char iport))
	       (set! pos (+ 1 pos)))
;;; read expanded names (interleaved with nul)
;;; I think this is probably UTF-16.
	     (let* ((name2 (and (discard (- 54 pos)) (read-field)))
		    (company (and (discard 6) (read-field)))
		    (name3 (and (discard 8) (read-field))))
	       (define (check field fieldname)
		 (cond ((not field) (slib:warn 'missing fieldname))
		       ((equal? name field))
		       (else (slib:warn fieldname 'mismatch name field))))
	       (check name2 'name2)
	       (check name3 'name3)
	       (or (and (eof-object? (peek-char iport)) (= pos 162))
		   (and (not (and (discard (- 162 pos))
				  (eof-object? (peek-char iport))))
			(slib:error lockpath 'length pos '(not = 162))))
	       (and name company (sprintf #f "%s@%s" name company))))))
    iport)))

(define (emacs-lock:certificate lockpath)
  (define conflict
    (system->line (sprintf #f "ls -ld %#a 2>/dev/null" lockpath)))
  (cond ((and conflict (substring? "-> " conflict))
	 => (lambda (idx)
	      (substring conflict (+ 3 idx) (string-length conflict))))
	((and conflict (not (equal? conflict ""))) (slib:error 'bad 'emacs 'lock lockpath conflict))
	(else #f)))

(define (file-lock:certificate path)
  (or (case (software-type)
	((unix coherent plan9)
	 (emacs-lock:certificate (emacs-lock:path path)))
	(else #f))
      (word-lock:certificate (word-lock:path path))))

;;@body
;;Returns the string @samp{@var{user}@@@var{hostname}} associated with
;;the lock owner of file @1 if locked; and #f otherwise.
(define (file-lock-owner path)
  (or (emacs-lock:certificate (emacs-lock:path path))
      (word-lock:certificate (word-lock:path path))))

(define (word:lock! path email)
  (define lockpath (word-lock:path path))
  (define at (substring? "@" email))
  (define (trim str len) (substring str 0 (min len (string-length str))))
  (let ((user
	 (trim (substring email 0 at) 15))
	(hostname
	 (trim (substring email (+ 1 at) (string-length email)) 14))
	(oport (open-file lockpath 'wb)))
    (define userlen (string-length user))
    (and oport
	 (call-with-open-ports
	  oport (lambda (oport)
		  (define pos 1)
		  (define (nulls cnt)
		    (write-bytes (make-bytes cnt 0) cnt oport)
		    (set! pos (+ cnt pos)))
		  (define (write-field field)
		    (define len (string-length field))
		    (write-byte len oport)
		    (write-byte 0 oport)
		    (set! pos (+ 2 pos))
		    (do ((idx 0 (+ 1 idx)))
			((>= idx len))
		      (write-char (string-ref field idx) oport)
		      (write-byte 0 oport)
		      (set! pos (+ 2 pos))))
		  (write-byte userlen oport)
		  (display user oport) (set! pos (+ userlen pos))
;;; write expanded names (interleaved with nul)
		  (nulls (- 54 pos))
		  (write-field user)
		  (nulls 6)
		  (write-field hostname)
		  (nulls 8)
		  (write-field user)
		  (nulls (- 162 pos))
		  (if (not (eqv? 162 pos))
		      (slib:error lockpath 'length pos '(not = 162)))
		  #t))
	 (let ((certificate (word-lock:certificate lockpath)))
	   (and (equal? certificate (string-append user "@" hostname))
		 certificate)))))

(define (emacs:lock! path email)
  (define lockpath (emacs-lock:path path))
  (define certificate (sprintf #f "%s.%s:%d"
			       email
			       (or (system->line "echo $PPID") "")
			       (current-time)))
  (and (eqv? 0 (system (sprintf #f "ln -s %#a %#a" certificate lockpath)))
       (let ((e-cert (emacs-lock:certificate lockpath)))
	 (and (equal? certificate e-cert)
	      certificate))))

;;@args path email
;;@args path
;;
;;@1 must be a string naming the file to be locked.  If supplied, @2
;;must be a string formatted as @samp{@var{user}@@@var{hostname}}.  If
;;absent, @2 defaults to the value returned by @code{user-email-address}.
;;
;;If @1 is already locked, then @0 returns @samp{#f}.  If @1 is
;;unlocked, then @0 returns the certificate string associated with the
;;new lock for file @1.
(define (file-lock! path . email)
  (set! email (if (null? email) (user-email-address) (car email)))
  (and (string? email)
       (not (file-lock:certificate path))
       (let ((wl (word:lock! path email)))
	 (case (software-type)
	   ((unix coherent plan9)
	    ;; file-system may not support symbolic links.
	    (or (and (provided? 'current-time) (emacs:lock! path email))
		wl))
	   (else wl)))))

;;@body
;;@1 must be a string naming the file to be unlocked.  @2 must be the
;;string returned by @code{file-lock!} for @1.
;;
;;If @1 is locked with @2, then @0 removes the locks and returns
;;@samp{#t}.  Otherwise, @0 leaves the file system unaltered and returns
;;@samp{#f}.
(define (file-unlock! path certificate)
  (define w-path (word-lock:path path))
  (let ((w-cert (word-lock:certificate w-path)))
    (cond ((not w-cert) #f)
	  ((not certificate) #f)
	  ((equal? w-cert certificate)	; word certificate only
					; (emacs certificate is longer)
	   (delete-file w-path))
	  ((not (eqv? 0 (substring? w-cert certificate)))
	   ;; word certificate doesn't match emacs certificate
	   (slib:warn 'file-unlock! w-path 'mismatch certificate) #f)
	  (else
	   (let ((e-path (emacs-lock:path path)))
	     (define e-cert (emacs-lock:certificate e-path))
	     (case (software-type)
	       ((unix coherent plan9)
		(cond ((not (equal? e-cert certificate))
		       (slib:warn 'file-unlock! e-path 'mismatch certificate)
		       #f)
		      (else (and (delete-file e-path)
				 (delete-file w-path)))))
	       (else (delete-file w-path))))))))

;;@args path prefix
;;@args path
;;@1 must be a string naming a file.  Optional argument @2 is a string
;;printed before each line of the message.  @0 prints to
;;@code{(current-error-port)} that @1 is locked for writing and lists
;;its lock-files.
;;
;;@example
;;(describe-file-lock "my.txt" ">> ")
;;@print{}
;;>> "my.txt" is locked for writing by 'luser@@no.com.4829:1200536423'
;;>> (lock files are "~$my.txt" and ".#my.txt")
;;@end example
(define (describe-file-lock path . prefix)
  (define cep (current-error-port))
  (define w-path (word-lock:path path))
  (define e-path (emacs-lock:path path))
  (set! prefix (if (null? prefix) "" (car prefix)))
  (let ((w-cert (word-lock:certificate w-path))
	(e-cert (emacs-lock:certificate e-path)))
    (cond ((or (file-exists? w-path) (file-exists? e-path))
	   (fprintf cep
		    "%s\"%s\" is locked for writing by '%s'\\n"
		    prefix
		    path
		    (or e-cert w-cert '??)))
	  (else
	   (fprintf cep
		    "%s\"%s\" is not locked for writing\\n"
		    prefix
		    path)))
    (if e-cert
	(fprintf cep "%s(lock files are \"%s\" and \"%s\")\\n"
		 prefix w-path e-path)
	(fprintf cep "%s(lock file is \"%s\")\\n"
		 prefix w-path))
    (force-output cep)))

;;;@subsubheading File Transactions

(define (emacs:backup-number path)
  (let* ((dir (pathname->vicinity path))
	 (file (substring path (string-length dir) (string-length path)))
	 (largest #f))
    (require 'directory)
    (if (equal? "" dir) (set! dir "./"))
    (directory-for-each
     (lambda (str)
       (define left.~ (substring? ".~" str))
       (cond ((not left.~))
	     ((not (equal? file (substring str 0 left.~))))
	     ((string->number (substring str
					 (+ 2 left.~)
					 (string-reverse-index str #\~)))
	      => (lambda (number)
		   (set! largest (max number (or largest number)))))))
     dir (string-append file "*~*[0-9]~"))
    largest))

;;@body
;;@1 must be a string.  @2 must be a symbol.  Depending on @2, @0
;;returns:
;;@table @r
;;@item none
;;#f
;;@item simple
;;the string "@1~"
;;@item numbered
;;the string "@1.~@var{n}~", where @var{n} is one greater than the
;;highest number appearing in a filename matching "@1.~*~".  @var{n}
;;defauls to 1 when no filename matches.
;;@item existing
;;the string "@1.~@var{n}~" if a numbered backup already exists in
;;this directory; otherwise. "@1~"
;;@item orig
;;the string "@1.orig"
;;@item bak
;;the string "@1.bak"
;;@end table
(define (emacs:backup-name path backup-style)
  (define (numbered bn) (sprintf #f "%s.~%d~" path (+ 1 (or bn 0))))
  (define (simple) (string-append path "~"))
  (case backup-style
    ((none #f) #f)
    ((simple) (simple))
    ((numbered) (numbered (emacs:backup-number path)))
    ((existing) (let ((bn (emacs:backup-number path)))
		  (if bn (numbered bn) (simple))))
    ((orig bak) (sprintf #f "%s.%s" path backup-style))
    (else
     (slib:error 'emacs:backup-name 'unknown 'backup-style backup-style))))

;;@args proc path backup-style certificate
;;@args proc path backup-style
;;@args proc path
;;
;;@2 must be a string naming an existing file.  @3 is one of the
;;symbols @r{none}, @r{simple}, @r{numbered}, @r{existing}, @r{orig},
;;@r{bak} or @r{#f}; with meanings described above; or a string naming
;;the location of a backup file.  @3 defaults to @r{#f}.  If supplied,
;;@4 is the certificate with which @2 is locked.
;;
;;@1 must be a procedure taking two string arguments:
;;@itemize @bullet
;;@item
;;@2, the original filename (to be read); and
;;@item
;;a temporary file-name.
;;@end itemize
;;
;;If @2 is locked by other than @4, or if @4 is supplied and @2 is not
;;locked, then @0 returns #f.  If @4 is not supplied, then, @0 creates
;;temporary (Emacs and Word) locks for @2 during the transaction.  The
;;lock status of @2 will be restored before @0 returns.
;;
;;@0 calls @1 with @2 (which should not be modified) and a temporary
;;file path to be written.
;;If @1 returns any value other than @r{#t}, then the file named by @2
;;is not altered and @0 returns @r{#f}.
;;Otherwise, @code{emacs:backup-name} is called with @2 and @3.  If it
;;returns a string, then @2 is renamed to it.
;;
;;Finally, the temporary file is renamed @2.
;;@0 returns #t if @2 was successfully replaced; and #f otherwise.
(define (transact-file-replacement proc path . args)
  (define certificate (case (length args)
			((2) (cadr args))
			((1 0) #f)
			(else (slib:error 'transact-file-replacement
					  (+ 2 (length args)) 'args))))
  (define backup-style (if (null? args) #f (car args)))
  (define move (case (software-type)
		 ((unix coherent plan9) "mv -f")
		 ((ms-dos windows os/2 atarist) "MOVE /Y")
		 (else (slib:error (software-type) 'move?))))
  (define (move? tmpfn path)
    (eqv? 0 (system (sprintf #f "%s %#a %#a" move tmpfn path))))
  (let* ((dir (pathname->vicinity path))
	 (file (substring path (string-length dir) (string-length path)))
	 (tmpfn (in-vicinity dir (string-append "#" file "#"))))
    (cond ((not (file-exists? path)) (slib:warn 'file path 'missing) #f)
	  (else
	   (let ((f-cert (file-lock:certificate path)))
	     (cond ((and f-cert (not (equal? certificate f-cert)))
		    (slib:warn 'file path 'locked 'by f-cert) #f)
		   ((and (file-exists? tmpfn)
			 (slib:warn 'file tmpfn 'exists)
			 (not (delete-file tmpfn)))
		    #f)
		   ((or certificate (file-lock! path))
		    => (lambda (cert)
			 (define result (proc path tmpfn))
			 (cond
			  ((not (eqv? #t result))
			   (delete-file tmpfn)
			   (or f-cert (file-unlock! path cert)) #f)
			  (else
			   (let ((bakf
				  (if (symbol? backup-style)
				      (emacs:backup-name path backup-style)
				      backup-style)))
			     (cond
			      ((and bakf (not (move? path bakf)))
			       (or f-cert (file-unlock! path cert)) #f)
			      ((not (move? tmpfn path))
			       (or f-cert (file-unlock! path cert)) #f)
			      (else
			       (or f-cert (file-unlock! path cert)) #t)))))))
		   (else (slib:warn 'could 'not 'lock path) #f)))))))

(define (windows:user-email-address user hostname)
  (define compname (getenv "COMPUTERNAME")) ;without domain
  (define workgroup #f)
  (call-with-tmpnam
   (lambda (tmp)
     (and (zero? (system (string-append "net config workstation >" tmp)))
	  (file-exists? tmp)
	  (not (eof-object? (call-with-input-file tmp read-char)))
	  (call-with-input-file tmp
	    (lambda (port)
	      (do ((line (read-line port) (read-line port)))
		  ((eof-object? line))
		(sscanf line " User name %s" user)
		(sscanf line " Computer name \\\\%s" compname)
		;; Don't want "DNS" from "Workstation Domain DNS Name"
		(sscanf line " Workstation domain %s" workgroup)))))))
  (string-append (or user "John_Doe") "@"
		 (if (and compname (not hostname))
		     (string-append compname "." (or workgroup "localnet"))
		     (or hostname "localhost"))))

;;@subsubheading Identification

;;@args
;;@0 returns a string of the form @samp{username@r{@@}hostname}.  If
;;this e-mail address cannot be obtained, #f is returned.
(define (user-email-address)
  (define user (or (getenv "USER") (getenv "USERNAME")))
  (define hostname (getenv "HOSTNAME")) ;with domain
  (cond ((and user hostname) (string-append user "@" hostname))
	(else (case (software-type)
		;;((amiga)				)
		;;((macos thinkc)			)
		((ms-dos windows os/2 atarist)
		 (windows:user-email-address user hostname))
		;;((nosve)				)
		;;((vms)				)
		((unix coherent plan9)
		 (call-with-tmpnam
		  (lambda (tmp)
		    (if (not user) (set! user (system->line "whoami" tmp)))
		    (if (not hostname) (set! hostname (system->line "hostname" tmp)))
		    (if (not user) (set! user "John_Doe"))
		    (if (not hostname) (set! hostname "localhost"))))
		 (string-append user "@" hostname))))))
