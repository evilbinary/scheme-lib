;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;作者:evilbinary on 2017-09-06 00:24:18.
					;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net curl-ffi ) 
  (export curl-strequal
	  curl-strnequal
	  curl-formadd
	  curl-formget
	  curl-formfree
	  curl-getenv
	  curl-version
	  curl-easy-escape
	  curl-escape
	  curl-easy-unescape
	  curl-unescape
	  curl-free
	  curl-global-init
	  curl-global-init-mem
	  curl-global-cleanup
	  curl-slist-append
	  curl-slist-free-all
	  curl-getdate
	  curl-share-init
	  curl-share-setopt
	  curl-share-cleanup
	  curl-version-info
	  curl-easy-strerror
	  curl-share-strerror
	  curl-easy-pause
	  curl-easy-init
	  curl-easy-setopt
	  curl-easy-perform
	  curl-easy-cleanup
	  curl-easy-getinfo
	  curl-easy-duphandle
	  curl-easy-reset
	  curl-easy-recv
	  curl-easy-send
	  curl-multi-init
	  curl-multi-add-handle
	  curl-multi-remove-handle
	  curl-multi-fdset
	  curl-multi-wait
	  curl-multi-perform
	  curl-multi-cleanup
	  curl-multi-info-read
	  curl-multi-strerror
	  curl-multi-socket
	  curl-multi-socket-action
	  curl-multi-socket-all
	  curl-multi-timeout
	  curl-multi-setopt
	  curl-multi-assign
	  curl-pushheader-bynum
	  curl-pushheader-byname

	  CURLOPT_WRITEDATA 
	  CURLOPT_URL 
	  CURLOPT_PORT 
	  CURLOPT_PROXY 
	  CURLOPT_USERPWD 
	  CURLOPT_PROXYUSERPWD 
	  CURLOPT_RANGE 

	  
	  CURLOPT_READDATA 
	  
	  CURLOPT_ERRORBUFFER 
	  
	  CURLOPT_WRITEFUNCTION 
	  
	  CURLOPT_READFUNCTION 
	  CURLOPT_TIMEOUT 
	  
	  
	  
	  
	  
	  
	  
	  
	  CURLOPT_INFILESIZE 
	  CURLOPT_POSTFIELDS 
	  CURLOPT_REFERER 
	  
	  CURLOPT_FTPPORT 
	  CURLOPT_USERAGENT 
	  
	  
	  
	  
	  CURLOPT_LOW_SPEED_LIMIT 
	  CURLOPT_LOW_SPEED_TIME 
	  
	  
	  
	  
	  
	  CURLOPT_RESUME_FROM 
	  CURLOPT_COOKIE 
	  
	  CURLOPT_HTTPHEADER 
	  CURLOPT_HTTPPOST 
	  CURLOPT_SSLCERT 
	  CURLOPT_KEYPASSWD 
	  CURLOPT_CRLF 
	  CURLOPT_QUOTE 
	  
	  CURLOPT_HEADERDATA 
	  
	  CURLOPT_COOKIEFILE 
	  
	  CURLOPT_SSLVERSION 
	  CURLOPT_TIMECONDITION 
	  
	  CURLOPT_TIMEVALUE 

	  
	  
	  
	  
	  CURLOPT_CUSTOMREQUEST 
	  CURLOPT_STDERR 

	  
	  CURLOPT_POSTQUOTE 

	  CURLOPT_OBSOLETE40 

	  CURLOPT_VERBOSE 
	  CURLOPT_HEADER 
	  CURLOPT_NOPROGRESS 
	  CURLOPT_NOBODY 
	  CURLOPT_FAILONERROR 
	  CURLOPT_UPLOAD 
	  CURLOPT_POST 
	  CURLOPT_DIRLISTONLY 

	  CURLOPT_APPEND 
	  
	  CURLOPT_NETRC 

	  CURLOPT_FOLLOWLOCATION 

	  CURLOPT_TRANSFERTEXT 
	  CURLOPT_PUT 

	  
	  
	  
	  
	  CURLOPT_PROGRESSFUNCTION 
	  
	  CURLOPT_PROGRESSDATA 
	  CURLOPT_AUTOREFERER 
	  
	  CURLOPT_PROXYPORT 
	  CURLOPT_POSTFIELDSIZE 
	  CURLOPT_HTTPPROXYTUNNEL 
	  CURLOPT_INTERFACE 
	  
	  
	  CURLOPT_KRBLEVEL 
	  CURLOPT_SSL_VERIFYPEER 
	  
	  CURLOPT_CAINFO 

	  CURLOPT_MAXREDIRS 
	  
	  CURLOPT_FILETIME 
	  CURLOPT_TELNETOPTIONS 
	  CURLOPT_MAXCONNECTS 

	  CURLOPT_OBSOLETE72 

	  
	  
	  
	  CURLOPT_FRESH_CONNECT 
	  
	  
	  CURLOPT_FORBID_REUSE 
	  
	  CURLOPT_RANDOM_FILE 
	  CURLOPT_EGDSOCKET 
	  
	  CURLOPT_CONNECTTIMEOUT 
	  
	  CURLOPT_HEADERFUNCTION 
	  
	  
	  CURLOPT_HTTPGET 
	  
	  
	  CURLOPT_SSL_VERIFYHOST 
	  
	  CURLOPT_COOKIEJAR 
	  CURLOPT_SSL_CIPHER_LIST 
	  
	  CURLOPT_HTTP_VERSION 
	  
	  
	  CURLOPT_FTP_USE_EPSV 
	  CURLOPT_SSLCERTTYPE 
	  CURLOPT_SSLKEY 
	  CURLOPT_SSLKEYTYPE 
	  CURLOPT_SSLENGINE 
	  
	  
	  CURLOPT_SSLENGINE_DEFAULT 
	  CURLOPT_DNS_USE_GLOBAL_CACHE 
	  CURLOPT_DNS_CACHE_TIMEOUT 
	  CURLOPT_PREQUOTE 
	  CURLOPT_DEBUGFUNCTION 
	  CURLOPT_DEBUGDATA 
	  CURLOPT_COOKIESESSION 
	  
	  CURLOPT_CAPATH 
	  CURLOPT_BUFFERSIZE 
	  
	  
	  CURLOPT_NOSIGNAL 
	  CURLOPT_SHARE 
	  
	  
	  CURLOPT_PROXYTYPE 
	  
	  
	  CURLOPT_ACCEPT_ENCODING 
	  CURLOPT_PRIVATE 
	  CURLOPT_HTTP200ALIASES 
	  
	  
	  CURLOPT_UNRESTRICTED_AUTH 
	  
	  
	  CURLOPT_FTP_USE_EPRT 
	  
	  
	  CURLOPT_HTTPAUTH 
	  
	  
	  CURLOPT_SSL_CTX_FUNCTION 
	  
	  CURLOPT_SSL_CTX_DATA 
	  
	  CURLOPT_FTP_CREATE_MISSING_DIRS 
	  
	  
	  CURLOPT_PROXYAUTH 
	  
	  
	  
	  CURLOPT_FTP_RESPONSE_TIMEOUT 
	  
	  

	  CURLOPT_IPRESOLVE 
	  

	  
	  
	  CURLOPT_MAXFILESIZE 
	  
	  
	  CURLOPT_INFILESIZE_LARGE 
	  
	  
	  CURLOPT_RESUME_FROM_LARGE 
	  
	  
	  CURLOPT_MAXFILESIZE_LARGE 
	  
	  
	  
	  CURLOPT_NETRC_FILE 
	  
	  
	  CURLOPT_USE_SSL 
	  CURLOPT_POSTFIELDSIZE_LARGE 
	  CURLOPT_TCP_NODELAY 

	  
	  
	  
	  

	  
	  
	  
	  CURLOPT_FTPSSLAUTH 

	  CURLOPT_IOCTLFUNCTION 
	  CURLOPT_IOCTLDATA 

	  
	  CURLOPT_FTP_ACCOUNT 
	  CURLOPT_COOKIELIST 
	  CURLOPT_IGNORE_CONTENT_LENGTH 
	  
	  
	  
	  CURLOPT_FTP_SKIP_PASV_IP 
	  
	  CURLOPT_FTP_FILEMETHOD 
	  CURLOPT_LOCALPORT 
	  CURLOPT_LOCALPORTRANGE 
	  
	  CURLOPT_CONNECT_ONLY 
	  
	  CURLOPT_CONV_FROM_NETWORK_FUNCTION 
	  
	  CURLOPT_CONV_TO_NETWORK_FUNCTION 
	  
	  
	  CURLOPT_CONV_FROM_UTF8_FUNCTION 

	  CURLOPT_MAX_SEND_SPEED_LARGE 
	  CURLOPT_MAX_RECV_SPEED_LARGE 
	  CURLOPT_FTP_ALTERNATIVE_TO_USER 
	  CURLOPT_SOCKOPTFUNCTION 
	  CURLOPT_SOCKOPTDATA 
	  
	  CURLOPT_SSL_SESSIONID_CACHE 
	  CURLOPT_SSH_AUTH_TYPES 
	  CURLOPT_SSH_PUBLIC_KEYFILE 
	  CURLOPT_SSH_PRIVATE_KEYFILE 
	  CURLOPT_FTP_SSL_CCC 
	  CURLOPT_TIMEOUT_MS 
	  CURLOPT_CONNECTTIMEOUT_MS 
	  
	  CURLOPT_HTTP_TRANSFER_DECODING 
	  CURLOPT_HTTP_CONTENT_DECODING 
	  
	  CURLOPT_NEW_FILE_PERMS 
	  CURLOPT_NEW_DIRECTORY_PERMS 
	  
	  CURLOPT_POSTREDIR 
	  CURLOPT_SSH_HOST_PUBLIC_KEY_MD5 
	  
	  
	  
	  CURLOPT_OPENSOCKETFUNCTION 
	  CURLOPT_OPENSOCKETDATA 
	  CURLOPT_COPYPOSTFIELDS 
	  CURLOPT_PROXY_TRANSFER_MODE 
	  CURLOPT_SEEKFUNCTION 
	  CURLOPT_SEEKDATA 
	  CURLOPT_CRLFILE 
	  CURLOPT_ISSUERCERT 
	  CURLOPT_ADDRESS_SCOPE 
	  
	  CURLOPT_CERTINFO 
	  CURLOPT_USERNAME 
	  CURLOPT_PASSWORD 

	  
	  CURLOPT_PROXYUSERNAME 
	  CURLOPT_PROXYPASSWORD 
	  
	  
	  
	  
	  
	  
	  CURLOPT_NOPROXY 
	  CURLOPT_TFTP_BLKSIZE 
	  CURLOPT_SOCKS5_GSSAPI_SERVICE 
	  CURLOPT_SOCKS5_GSSAPI_NEC 
	  
	  
	  
	  CURLOPT_PROTOCOLS 
	  
	  
	  
	  CURLOPT_REDIR_PROTOCOLS 
	  CURLOPT_SSH_KNOWNHOSTS 
	  
	  CURLOPT_SSH_KEYFUNCTION 
	  CURLOPT_SSH_KEYDATA 
	  CURLOPT_MAIL_FROM 
	  CURLOPT_MAIL_RCPT 
	  CURLOPT_FTP_USE_PRET 
	  CURLOPT_RTSP_REQUEST 
	  CURLOPT_RTSP_SESSION_ID 
	  CURLOPT_RTSP_STREAM_URI 
	  CURLOPT_RTSP_TRANSPORT 
	  CURLOPT_RTSP_CLIENT_CSEQ 
	  CURLOPT_RTSP_SERVER_CSEQ 
	  CURLOPT_INTERLEAVEDATA 
	  CURLOPT_INTERLEAVEFUNCTION 
	  CURLOPT_WILDCARDMATCH 
	  
	  CURLOPT_CHUNK_BGN_FUNCTION 
	  
	  CURLOPT_CHUNK_END_FUNCTION 
	  CURLOPT_FNMATCH_FUNCTION 
	  CURLOPT_CHUNK_DATA 
	  CURLOPT_FNMATCH_DATA 
	  CURLOPT_RESOLVE 
	  CURLOPT_TLSAUTH_USERNAME 
	  CURLOPT_TLSAUTH_PASSWORD 
	  CURLOPT_TLSAUTH_TYPE 
	  
	  
	  

	  
	  
	  
	  CURLOPT_TRANSFER_ENCODING 
	  
	  CURLOPT_CLOSESOCKETFUNCTION 
	  CURLOPT_CLOSESOCKETDATA 
	  CURLOPT_GSSAPI_DELEGATION 
	  CURLOPT_DNS_SERVERS 

	  CURLOPT_ACCEPTTIMEOUT_MS 
	  CURLOPT_TCP_KEEPALIVE 
	  CURLOPT_TCP_KEEPIDLE 
	  CURLOPT_TCP_KEEPINTVL 
	  CURLOPT_SSL_OPTIONS 
	  CURLOPT_MAIL_AUTH 
	  CURLOPT_SASL_IR 
	  
	  
	  CURLOPT_XFERINFOFUNCTION 
	  CURLOPT_XOAUTH2_BEARER 
	  
	  
	  CURLOPT_DNS_INTERFACE 
	  
	  CURLOPT_DNS_LOCAL_IP4 
	  
	  CURLOPT_DNS_LOCAL_IP6 
	  CURLOPT_LOGIN_OPTIONS 
	  CURLOPT_SSL_ENABLE_NPN 
	  CURLOPT_SSL_ENABLE_ALPN 
	  
	  CURLOPT_EXPECT_100_TIMEOUT_MS 
	  
	  CURLOPT_PROXYHEADER 
	  CURLOPT_HEADEROPT 
	  
	  CURLOPT_PINNEDPUBLICKEY 
	  CURLOPT_UNIX_SOCKET_PATH 
	  CURLOPT_SSL_VERIFYSTATUS 
	  CURLOPT_SSL_FALSESTART 
	  CURLOPT_PATH_AS_IS 
	  CURLOPT_PROXY_SERVICE_NAME 
	  CURLOPT_SERVICE_NAME 
	  CURLOPT_PIPEWAIT 
	  CURLOPT_DEFAULT_PROTOCOL 
	  CURLOPT_STREAM_WEIGHT 
	  CURLOPT_STREAM_DEPENDS 
	  CURLOPT_STREAM_DEPENDS_E 
	  CURLOPT_TFTP_NO_OPTIONS 
	  
	  CURLOPT_CONNECT_TO 
	  CURLOPT_TCP_FASTOPEN 
	  
	  CURLOPT_KEEP_SENDING_ON_ERROR 
	  
	  CURLOPT_PROXY_CAINFO 
	  
	  CURLOPT_PROXY_CAPATH 
	  
	  CURLOPT_PROXY_SSL_VERIFYPEER 
	  
	  
	  CURLOPT_PROXY_SSL_VERIFYHOST 
	  
	  CURLOPT_PROXY_SSLVERSION 
	  CURLOPT_PROXY_TLSAUTH_USERNAME 
	  CURLOPT_PROXY_TLSAUTH_PASSWORD 
	  CURLOPT_PROXY_TLSAUTH_TYPE 
	  CURLOPT_PROXY_SSLCERT 
	  
	  CURLOPT_PROXY_SSLCERTTYPE 
	  CURLOPT_PROXY_SSLKEY 
	  
	  CURLOPT_PROXY_SSLKEYTYPE 
	  CURLOPT_PROXY_KEYPASSWD 
	  CURLOPT_PROXY_SSL_CIPHER_LIST 
	  CURLOPT_PROXY_CRLFILE 
	  
	  CURLOPT_PROXY_SSL_OPTIONS 
	  CURLOPT_PRE_PROXY 

	  CURLOPT_PROXY_PINNEDPUBLICKEY 
	  CURLOPT_ABSTRACT_UNIX_SOCKET 
	  CURLOPT_SUPPRESS_CONNECT_HEADERS 
	  CURLOPT_REQUEST_TARGET 
	  CURLOPT_SOCKS5_AUTH


	  CURL_GLOBAL_SSL 
	  CURL_GLOBAL_WIN32
	  CURL_GLOBAL_ALL
	  CURL_GLOBAL_NOTHING
	  CURL_GLOBAL_DEFAULT 
	  CURL_GLOBAL_ACK_EINTR
	  )

  (import (scheme) (utils libutil) (cffi cffi) )

  (define lib-name
    (case (machine-type)
      ((arm32le) "libcurl.so")
      ((a6nt i3nt ta6nt ti3nt) "libcurl.dll")
      ((a6osx i3osx ta6osx ti3osx)  "libcurl.dylib")
      ((a6le i3le ta6le ti3le) "libcurl.so")))
  (define lib (load-librarys  lib-name ))

  (define OBJECTPOINT 10000)
  (define LONG 0)
  (define STRINGPOINT 10000)
  (define FUNCTIONPOINT 20000)
  (define OFF_T 30000)

  (define CURL_GLOBAL_SSL 1)
  (define CURL_GLOBAL_WIN32 2)
  (define CURL_GLOBAL_ALL (+ CURL_GLOBAL_SSL CURL_GLOBAL_WIN32))
  (define CURL_GLOBAL_NOTHING 0)
  (define CURL_GLOBAL_DEFAULT CURL_GLOBAL_ALL)
  (define CURL_GLOBAL_ACK_EINTR 2)
  
  (define-syntax def-cinit
    (lambda (x)
      (define (make-prefix-id prefix kw)
        (datum->syntax
	 kw
	 (string->symbol
	  (string-append prefix (symbol->string (syntax->datum kw))))))
      (syntax-case x ()
   	((_ name type offset)
	 (with-syntax ([nname (make-prefix-id "CURLOPT_" #'name)])
		      #'(define nname
			  (+ type offset ))))  ) ))

  ;; This is the FILE ;; or void ;; the regular output should be written to. 
  (def-cinit WRITEDATA OBJECTPOINT 1)

  ;; The full URL to get/put 
  (def-cinit URL STRINGPOINT 2)

  ;; Port number to connect to if other than default. 
  (def-cinit PORT LONG 3)

  ;; Name of proxy to use. 
  (def-cinit PROXY STRINGPOINT 4)

  ;; "user:password;options" to use when fetching. 
  (def-cinit USERPWD STRINGPOINT 5)

  ;; "user:password" to use with proxy. 
  (def-cinit PROXYUSERPWD STRINGPOINT 6)

  ;; Range to get specified as an ASCII string. 
  (def-cinit RANGE STRINGPOINT 7)

  ;; not used 

  ;; Specified file stream to upload from (use as input): 
  (def-cinit READDATA OBJECTPOINT 9)

  ;; Buffer to receive error messages in must be at least CURL_ERROR_SIZE
  ;; bytes big. If this is not used error messages go to stderr instead: 
  (def-cinit ERRORBUFFER OBJECTPOINT 10)

  ;; Function that will be called to store the output (instead of fwrite). The
  ;; parameters will use fwrite() syntax make sure to follow them. 
  (def-cinit WRITEFUNCTION FUNCTIONPOINT 11)

  ;; Function that will be called to read the input (instead of fread). The
  ;; parameters will use fread() syntax make sure to follow them. 
  (def-cinit READFUNCTION FUNCTIONPOINT 12)

  ;; Time-out the read operation after this amount of seconds 
  (def-cinit TIMEOUT LONG 13)

  ;; If the CURLOPT_INFILE is used this can be used to inform libcurl about
  ;; how large the file being sent really is. That allows better error
  ;; checking and better verifies that the upload was successful. -1 means
  ;; unknown size.
  ;;
  ;; For large file support there is also a _LARGE version of the key
  ;; which takes an off_t type allowing platforms with larger off_t
  ;; sizes to handle larger files.  See below for INFILESIZE_LARGE.
  
  (def-cinit INFILESIZE LONG 14)

  ;; POST static input fields. 
  (def-cinit POSTFIELDS OBJECTPOINT 15)

  ;; Set the referrer page (needed by some CGIs) 
  (def-cinit REFERER STRINGPOINT 16)

  ;; Set the FTP PORT string (interface name named or numerical IP address)
  ;; Use i.e '-' to use default address. 
  (def-cinit FTPPORT STRINGPOINT 17)

  ;; Set the User-Agent string (examined by some CGIs) 
  (def-cinit USERAGENT STRINGPOINT 18)

  ;; If the download receives less than "low speed limit" bytes/second
  ;; during "low speed time" seconds the operations is aborted.
  ;; You could i.e if you have a pretty high speed connection abort if
  ;; it is less than 2000 bytes/sec during 20 seconds.
  

  ;; Set the "low speed limit" 
  (def-cinit LOW_SPEED_LIMIT LONG 19)

  ;; Set the "low speed time" 
  (def-cinit LOW_SPEED_TIME LONG 20)

  ;; Set the continuation offset.
  ;;
  ;; Note there is also a _LARGE version of this key which uses
  ;; off_t types allowing for large file offsets on platforms which
  ;; use larger-than-32-bit off_t's.  Look below for RESUME_FROM_LARGE.
  
  (def-cinit RESUME_FROM LONG 21)

  ;; Set cookie in request: 
  (def-cinit COOKIE STRINGPOINT 22)

  ;; This points to a linked list of headers struct curl_slist kind. This
  ;;list is also used for RTSP (in spite of its name) 
  (def-cinit HTTPHEADER OBJECTPOINT 23)

  ;; This points to a linked list of post entries struct curl_httppost 
  (def-cinit HTTPPOST OBJECTPOINT 24)

  ;; name of the file keeping your private SSL-certificate 
  (def-cinit SSLCERT STRINGPOINT 25)

  ;; password for the SSL or SSH private key 
  (def-cinit KEYPASSWD STRINGPOINT 26)

  ;; send TYPE parameter? 
  (def-cinit CRLF LONG 27)

  ;; send linked-list of QUOTE commands 
  (def-cinit QUOTE OBJECTPOINT 28)

  ;; send FILE ;; or void ;; to store headers to if you use a callback it
  ;; is simply passed to the callback unmodified 
  (def-cinit HEADERDATA OBJECTPOINT 29)

  ;; point to a file to read the initial cookies from also enables
  ;; "cookie awareness" 
  (def-cinit COOKIEFILE STRINGPOINT 31)

  ;; What version to specifically try to use.
  ;;See CURL_SSLVERSION defines below. 
  (def-cinit SSLVERSION LONG 32)

  ;; What kind of HTTP time condition to use see defines 
  (def-cinit TIMECONDITION LONG 33)

  ;; Time to use with the above condition. Specified in number of seconds
  ;; since 1 Jan 1970 
  (def-cinit TIMEVALUE LONG 34)

  ;; 35 = OBSOLETE 

  ;; Custom request for customizing the get command like
  ;; HTTP: DELETE TRACE and others
  ;; FTP: to use a different list command
  
  (def-cinit CUSTOMREQUEST STRINGPOINT 36)

  ;; FILE handle to use instead of stderr 
  (def-cinit STDERR OBJECTPOINT 37)

  ;; 38 is not used 

  ;; send linked-list of post-transfer QUOTE commands 
  (def-cinit POSTQUOTE OBJECTPOINT 39)

  (def-cinit OBSOLETE40 OBJECTPOINT 40) ;; OBSOLETE do not use! 

  (def-cinit VERBOSE LONG 41)      ;; talk a lot 
  (def-cinit HEADER LONG 42)       ;; throw the header out too 
  (def-cinit NOPROGRESS LONG 43)   ;; shut off the progress meter 
  (def-cinit NOBODY LONG 44)       ;; use HEAD to get http document 
  (def-cinit FAILONERROR LONG 45)  ;; no output on http error codes >= 400 
  (def-cinit UPLOAD LONG 46)       ;; this is an upload 
  (def-cinit POST LONG 47)         ;; HTTP POST method 
  (def-cinit DIRLISTONLY LONG 48)  ;; bare names when listing directories 

  (def-cinit APPEND LONG 50)       ;; Append instead of overwrite on upload! 

  ;; Specify whether to read the user+password from the .netrc or the URL.
  ;; This must be one of the CURL_NETRC_;; enums below. 
  (def-cinit NETRC LONG 51)

  (def-cinit FOLLOWLOCATION LONG 52)  ;; use Location: Luke! 

  (def-cinit TRANSFERTEXT LONG 53) ;; transfer data in text/ASCII format 
  (def-cinit PUT LONG 54)          ;; HTTP PUT 

  ;; 55 = OBSOLETE 

  ;; DEPRECATED
  ;; Function that will be called instead of the internal progress display
  ;; function. This function should be defined as the curl_progress_callback
  ;; prototype defines. 
  (def-cinit PROGRESSFUNCTION FUNCTIONPOINT 56)

  ;; Data passed to the CURLOPT_PROGRESSFUNCTION and CURLOPT_XFERINFOFUNCTION
  ;;  callbacks 
  (def-cinit PROGRESSDATA OBJECTPOINT 57)

  ;; We want the referrer field set automatically when following locations 
  (def-cinit AUTOREFERER LONG 58)

  ;; Port of the proxy can be set in the proxy string as well with:
  ;; "[host]:[port]" 
  (def-cinit PROXYPORT LONG 59)

  ;; size of the POST input data if strlen() is not good to use 
  (def-cinit POSTFIELDSIZE LONG 60)

  ;; tunnel non-http operations through a HTTP proxy 
  (def-cinit HTTPPROXYTUNNEL LONG 61)

  ;; Set the interface string to use as outgoing network interface 
  (def-cinit INTERFACE STRINGPOINT 62)

  ;; Set the krb4/5 security level this also enables krb4/5 awareness.  This
  ;; is a string 'clear' 'safe' 'confidential' or 'private'.  If the string
  ;; is set but doesn't match one of these 'private' will be used.  
  (def-cinit KRBLEVEL STRINGPOINT 63)

  ;; Set if we should verify the peer in ssl handshake set 1 to verify. 
  (def-cinit SSL_VERIFYPEER LONG 64)

  ;; The CApath or CAfile used to validate the peer certificate
  ;;this option is used only if SSL_VERIFYPEER is true 
  (def-cinit CAINFO STRINGPOINT 65)

  ;; 66 = OBSOLETE 
  ;; 67 = OBSOLETE 

  ;; Maximum number of http redirects to follow 
  (def-cinit MAXREDIRS LONG 68)

  ;; Pass a long set to 1 to get the date of the requested document (if
  ;;possible)! Pass a zero to shut it off. 
  (def-cinit FILETIME LONG 69)

  ;; This points to a linked list of telnet options 
  (def-cinit TELNETOPTIONS OBJECTPOINT 70)

  ;; Max amount of cached alive connections 
  (def-cinit MAXCONNECTS LONG 71)

  (def-cinit OBSOLETE72 LONG 72) ;; OBSOLETE do not use! 

  ;; 73 = OBSOLETE 

  ;; Set to explicitly use a new connection for the upcoming transfer.
  ;;Do not use this unless you're absolutely sure of this as it makes the
  ;;operation slower and is less friendly for the network. 
  (def-cinit FRESH_CONNECT LONG 74)

  ;; Set to explicitly forbid the upcoming transfer's connection to be re-used
  ;; when done. Do not use this unless you're absolutely sure of this as it
  ;;makes the operation slower and is less friendly for the network. 
  (def-cinit FORBID_REUSE LONG 75)

  ;; Set to a file name that contains random data for libcurl to use to
  ;;seed the random engine when doing SSL connects. 
  (def-cinit RANDOM_FILE STRINGPOINT 76)

  ;; Set to the Entropy Gathering Daemon socket pathname 
  (def-cinit EGDSOCKET STRINGPOINT 77)

  ;; Time-out connect operations after this amount of seconds if connects are
  ;;OK within this time then fine... This only aborts the connect phase. 
  (def-cinit CONNECTTIMEOUT LONG 78)

  ;; Function that will be called to store headers (instead of fwrite). The
  ;; parameters will use fwrite() syntax make sure to follow them. 
  (def-cinit HEADERFUNCTION FUNCTIONPOINT 79)

  ;; Set this to force the HTTP request to get back to GET. Only really usable
  ;;if POST PUT or a custom request have been used first.
  
  (def-cinit HTTPGET LONG 80)

  ;; Set if we should verify the Common name from the peer certificate in ssl
  ;; handshake set 1 to check existence 2 to ensure that it matches the
  ;; provided hostname. 
  (def-cinit SSL_VERIFYHOST LONG 81)

  ;; Specify which file name to write all known cookies in after completed
  ;;operation. Set file name to "-" (dash) to make it go to stdout. 
  (def-cinit COOKIEJAR STRINGPOINT 82)

  ;; Specify which SSL ciphers to use 
  (def-cinit SSL_CIPHER_LIST STRINGPOINT 83)

  ;; Specify which HTTP version to use! This must be set to one of the
  ;;CURL_HTTP_VERSION;; enums set below. 
  (def-cinit HTTP_VERSION LONG 84)

  ;; Specifically switch on or off the FTP engine's use of the EPSV command. By
  ;;default that one will always be attempted before the more traditional
  ;;PASV command. 
  (def-cinit FTP_USE_EPSV LONG 85)

  ;; type of the file keeping your SSL-certificate ("DER" "PEM" "ENG") 
  (def-cinit SSLCERTTYPE STRINGPOINT 86)

  ;; name of the file keeping your private SSL-key 
  (def-cinit SSLKEY STRINGPOINT 87)

  ;; type of the file keeping your private SSL-key ("DER" "PEM" "ENG") 
  (def-cinit SSLKEYTYPE STRINGPOINT 88)

  ;; crypto engine for the SSL-sub system 
  (def-cinit SSLENGINE STRINGPOINT 89)

  ;; set the crypto engine for the SSL-sub system as default
  ;;the param has no meaning...
  
  (def-cinit SSLENGINE_DEFAULT LONG 90)

  ;; Non-zero value means to use the global dns cache 
  (def-cinit DNS_USE_GLOBAL_CACHE LONG 91) ;; DEPRECATED do not use! 

  ;; DNS cache timeout 
  (def-cinit DNS_CACHE_TIMEOUT LONG 92)

  ;; send linked-list of pre-transfer QUOTE commands 
  (def-cinit PREQUOTE OBJECTPOINT 93)

  ;; set the debug function 
  (def-cinit DEBUGFUNCTION FUNCTIONPOINT 94)

  ;; set the data for the debug function 
  (def-cinit DEBUGDATA OBJECTPOINT 95)

  ;; mark this as start of a cookie session 
  (def-cinit COOKIESESSION LONG 96)

  ;; The CApath directory used to validate the peer certificate
  ;;this option is used only if SSL_VERIFYPEER is true 
  (def-cinit CAPATH STRINGPOINT 97)

  ;; Instruct libcurl to use a smaller receive buffer 
  (def-cinit BUFFERSIZE LONG 98)

  ;; Instruct libcurl to not use any signal/alarm handlers even when using
  ;; timeouts. This option is useful for multi-threaded applications.
  ;;See libcurl-the-guide for more background information. 
  (def-cinit NOSIGNAL LONG 99)

  ;; Provide a CURLShare for mutexing non-ts data 
  (def-cinit SHARE OBJECTPOINT 100)

  ;; indicates type of proxy. accepted values are CURLPROXY_HTTP (default)
  ;;CURLPROXY_HTTPS CURLPROXY_SOCKS4 CURLPROXY_SOCKS4A and
  ;;CURLPROXY_SOCKS5. 
  (def-cinit PROXYTYPE LONG 101)

  ;; Set the Accept-Encoding string. Use this to tell a server you would like
  ;; the response to be compressed. Before 7.21.6 this was known as
  ;; CURLOPT_ENCODING 
  (def-cinit ACCEPT_ENCODING STRINGPOINT 102)

  ;; Set pointer to private data 
  (def-cinit PRIVATE OBJECTPOINT 103)

  ;; Set aliases for HTTP 200 in the HTTP Response header 
  (def-cinit HTTP200ALIASES OBJECTPOINT 104)

  ;; Continue to send authentication (user+password) when following locations
  ;;even when hostname changed. This can potentially send off the name
  ;;and password to whatever host the server decides. 
  (def-cinit UNRESTRICTED_AUTH LONG 105)

  ;; Specifically switch on or off the FTP engine's use of the EPRT command (
  ;;it also disables the LPRT attempt). By default those ones will always be
  ;;attempted before the good old traditional PORT command. 
  (def-cinit FTP_USE_EPRT LONG 106)

  ;; Set this to a bitmask value to enable the particular authentications
  ;;methods you like. Use this in combination with CURLOPT_USERPWD.
  ;;Note that setting multiple bits may cause extra network round-trips. 
  (def-cinit HTTPAUTH LONG 107)

  ;; Set the ssl context callback function currently only for OpenSSL ssl_ctx
  ;;in second argument. The function must be matching the
  ;;curl_ssl_ctx_callback proto. 
  (def-cinit SSL_CTX_FUNCTION FUNCTIONPOINT 108)

  ;; Set the userdata for the ssl context callback function's third
  ;;argument 
  (def-cinit SSL_CTX_DATA OBJECTPOINT 109)

  ;; FTP Option that causes missing dirs to be created on the remote server.
  ;; In 7.19.4 we introduced the convenience enums for this option using the
  ;;CURLFTP_CREATE_DIR prefix.
  
  (def-cinit FTP_CREATE_MISSING_DIRS LONG 110)

  ;; Set this to a bitmask value to enable the particular authentications
  ;; methods you like. Use this in combination with CURLOPT_PROXYUSERPWD.
  ;; Note that setting multiple bits may cause extra network round-trips. 
  (def-cinit PROXYAUTH LONG 111)

  ;; FTP option that changes the timeout in seconds associated with
  ;; getting a response.  This is different from transfer timeout time and
  ;; essentially places a demand on the FTP server to acknowledge commands
  ;; in a timely manner. 
  (def-cinit FTP_RESPONSE_TIMEOUT LONG 112)

  ;; Set this option to one of the CURL_IPRESOLVE_;; defines (see below) to
  ;; tell libcurl to resolve names to those IP versions only. This only has
  ;; affect on systems with support for more than one i.e IPv4 _and_ IPv6.

  (def-cinit IPRESOLVE LONG 113)

  ;; Set this option to limit the size of a file that will be downloaded from
  ;; an HTTP or FTP server.

  ;; Note there is also _LARGE version which adds large file support for
  ;; platforms which have larger off_t sizes.  See MAXFILESIZE_LARGE below. 
  (def-cinit MAXFILESIZE LONG 114)

  ;; See the comment for INFILESIZE above but in short specifies
  ;; the size of the file being uploaded.  -1 means unknown.
  
  (def-cinit INFILESIZE_LARGE OFF_T 115)

  ;; Sets the continuation offset.  There is also a LONG version of this;
  ;; look above for RESUME_FROM.
  
  (def-cinit RESUME_FROM_LARGE OFF_T 116)

  ;; Sets the maximum size of data that will be downloaded from
  ;; an HTTP or FTP server.  See MAXFILESIZE above for the LONG version.
  
  (def-cinit MAXFILESIZE_LARGE OFF_T 117)

  ;; Set this option to the file name of your .netrc file you want libcurl
  ;;to parse (using the CURLOPT_NETRC option). If not set libcurl will do
  ;;a poor attempt to find the user's home directory and check for a .netrc
  ;;file in there. 
  (def-cinit NETRC_FILE STRINGPOINT 118)

  ;; Enable SSL/TLS for FTP pick one of:
  ;;CURLUSESSL_TRY     - try using SSL proceed anyway otherwise
  ;;CURLUSESSL_CONTROL - SSL for the control connection or fail
  ;;CURLUSESSL_ALL     - SSL for all communication or fail
  
  (def-cinit USE_SSL LONG 119)

  ;; The _LARGE version of the standard POSTFIELDSIZE option 
  (def-cinit POSTFIELDSIZE_LARGE OFF_T 120)

  ;; Enable/disable the TCP Nagle algorithm 
  (def-cinit TCP_NODELAY LONG 121)

  ;; 122 OBSOLETE used in 7.12.3. Gone in 7.13.0 
  ;; 123 OBSOLETE. Gone in 7.16.0 
  ;; 124 OBSOLETE used in 7.12.3. Gone in 7.13.0 
  ;; 125 OBSOLETE used in 7.12.3. Gone in 7.13.0 
  ;; 126 OBSOLETE used in 7.12.3. Gone in 7.13.0 
  ;; 127 OBSOLETE. Gone in 7.16.0 
  ;; 128 OBSOLETE. Gone in 7.16.0 

  ;; When FTP over SSL/TLS is selected (with CURLOPT_USE_SSL) this option
  ;;can be used to change libcurl's default action which is to first try
  ;; "AUTH SSL" and then "AUTH TLS" in this order and proceed when a OK
  ;; response has been received.

  ;; Available parameters are:
  ;; CURLFTPAUTH_DEFAULT - let libcurl decide
  ;; CURLFTPAUTH_SSL     - try "AUTH SSL" first then TLS
  ;; CURLFTPAUTH_TLS     - try "AUTH TLS" first then SSL
  
  (def-cinit FTPSSLAUTH LONG 129)

  (def-cinit IOCTLFUNCTION FUNCTIONPOINT 130)
  (def-cinit IOCTLDATA OBJECTPOINT 131)

  ;; 132 OBSOLETE. Gone in 7.16.0 
  ;; 133 OBSOLETE. Gone in 7.16.0 

  ;; zero terminated string for pass on to the FTP server when asked for
  ;;  "account" info 
  (def-cinit FTP_ACCOUNT STRINGPOINT 134)

  ;; feed cookie into cookie engine 
  (def-cinit COOKIELIST STRINGPOINT 135)

  ;; ignore Content-Length 
  (def-cinit IGNORE_CONTENT_LENGTH LONG 136)

  ;; Set to non-zero to skip the IP address received in a 227 PASV FTP server
  ;;response. Typically used for FTP-SSL purposes but is not restricted to
  ;;that. libcurl will then instead use the same IP address it used for the
  ;;control connection. 
  (def-cinit FTP_SKIP_PASV_IP LONG 137)

  ;; Select "file method" to use when doing FTP see the curl_ftpmethod
  ;; above. 
  (def-cinit FTP_FILEMETHOD LONG 138)

  ;; Local port number to bind the socket to 
  (def-cinit LOCALPORT LONG 139)

  ;; Number of ports to try including the first one set with LOCALPORT.
  ;;Thus setting it to 1 will make no additional attempts but the first.
  
  (def-cinit LOCALPORTRANGE LONG 140)

  ;; no transfer set up connection and let application use the socket by
  ;;extracting it with CURLINFO_LASTSOCKET 
  (def-cinit CONNECT_ONLY LONG 141)

  ;; Function that will be called to convert from the
  ;;network encoding (instead of using the iconv calls in libcurl) 
  (def-cinit CONV_FROM_NETWORK_FUNCTION FUNCTIONPOINT 142)

  ;; Function that will be called to convert to the
  ;;network encoding (instead of using the iconv calls in libcurl) 
  (def-cinit CONV_TO_NETWORK_FUNCTION FUNCTIONPOINT 143)

  ;; Function that will be called to convert from UTF8
  ;;(instead of using the iconv calls in libcurl)
  ;;Note that this is used only for SSL certificate processing 
  (def-cinit CONV_FROM_UTF8_FUNCTION FUNCTIONPOINT 144)

  ;; if the connection proceeds too quickly then need to slow it down 
  ;; limit-rate: maximum number of bytes per second to send or receive 
  (def-cinit MAX_SEND_SPEED_LARGE OFF_T 145)
  (def-cinit MAX_RECV_SPEED_LARGE OFF_T 146)

  ;; Pointer to command string to send if USER/PASS fails. 
  (def-cinit FTP_ALTERNATIVE_TO_USER STRINGPOINT 147)

  ;; callback function for setting socket options 
  (def-cinit SOCKOPTFUNCTION FUNCTIONPOINT 148)
  (def-cinit SOCKOPTDATA OBJECTPOINT 149)

  ;; set to 0 to disable session ID re-use for this transfer default is
  ;; enabled (== 1) 
  (def-cinit SSL_SESSIONID_CACHE LONG 150)

  ;; allowed SSH authentication methods 
  (def-cinit SSH_AUTH_TYPES LONG 151)

  ;; Used by scp/sftp to do public/private key authentication 
  (def-cinit SSH_PUBLIC_KEYFILE STRINGPOINT 152)
  (def-cinit SSH_PRIVATE_KEYFILE STRINGPOINT 153)

  ;; Send CCC (Clear Command Channel) after authentication 
  (def-cinit FTP_SSL_CCC LONG 154)

  ;; Same as TIMEOUT and CONNECTTIMEOUT but with ms resolution 
  (def-cinit TIMEOUT_MS LONG 155)
  (def-cinit CONNECTTIMEOUT_MS LONG 156)

  ;; set to zero to disable the libcurl's decoding and thus pass the raw body
  ;; data to the application even when it is encoded/compressed 
  (def-cinit HTTP_TRANSFER_DECODING LONG 157)
  (def-cinit HTTP_CONTENT_DECODING LONG 158)

  ;; Permission used when creating new files and directories on the remote
  ;; server for protocols that support it SFTP/SCP/FILE 
  (def-cinit NEW_FILE_PERMS LONG 159)
  (def-cinit NEW_DIRECTORY_PERMS LONG 160)

  ;; Set the behaviour of POST when redirecting. Values must be set to one
  ;;of CURL_REDIR;; defines below. This used to be called CURLOPT_POST301 
  (def-cinit POSTREDIR LONG 161)

  ;; used by scp/sftp to verify the host's public key 
  (def-cinit SSH_HOST_PUBLIC_KEY_MD5 STRINGPOINT 162)

  ;; Callback function for opening socket (instead of socket(2)). Optionally
  ;;callback is able change the address or refuse to connect returning
  ;; CURL_SOCKET_BAD.  The callback should have type
  ;; curl_opensocket_callback 
  (def-cinit OPENSOCKETFUNCTION FUNCTIONPOINT 163)
  (def-cinit OPENSOCKETDATA OBJECTPOINT 164)

  ;; POST volatile input fields. 
  (def-cinit COPYPOSTFIELDS OBJECTPOINT 165)

  ;; set transfer mode (;type=<a|i>) when doing FTP via an HTTP proxy 
  (def-cinit PROXY_TRANSFER_MODE LONG 166)

  ;; Callback function for seeking in the input stream 
  (def-cinit SEEKFUNCTION FUNCTIONPOINT 167)
  (def-cinit SEEKDATA OBJECTPOINT 168)

  ;; CRL file 
  (def-cinit CRLFILE STRINGPOINT 169)

  ;; Issuer certificate 
  (def-cinit ISSUERCERT STRINGPOINT 170)

  ;; (IPv6) Address scope 
  (def-cinit ADDRESS_SCOPE LONG 171)

  ;; Collect certificate chain info and allow it to get retrievable with
  ;;CURLINFO_CERTINFO after the transfer is complete. 
  (def-cinit CERTINFO LONG 172)

  ;; "name" and "pwd" to use when fetching. 
  (def-cinit USERNAME STRINGPOINT 173)
  (def-cinit PASSWORD STRINGPOINT 174)

  ;; "name" and "pwd" to use with Proxy when fetching. 
  (def-cinit PROXYUSERNAME STRINGPOINT 175)
  (def-cinit PROXYPASSWORD STRINGPOINT 176)

  ;; Comma separated list of hostnames defining no-proxy zones. These should
  ;; match both hostnames directly and hostnames within a domain. For
  ;; example local.com will match local.com and www.local.com but NOT
  ;; notlocal.com or www.notlocal.com. For compatibility with other
  ;; implementations of this .local.com will be considered to be the same as
  ;; local.com. A single ;; is the only valid wildcard and effectively
  ;; disables the use of proxy. ;
  (def-cinit NOPROXY STRINGPOINT 177)

  ;; block size for TFTP transfers 
  (def-cinit TFTP_BLKSIZE LONG 178)

  ;; Socks Service 
  (def-cinit SOCKS5_GSSAPI_SERVICE STRINGPOINT 179) ;; DEPRECATED do not use! 

  ;; Socks Service 
  (def-cinit SOCKS5_GSSAPI_NEC LONG 180)

  ;; set the bitmask for the protocols that are allowed to be used for the
  ;; transfer which thus helps the app which takes URLs from users or other
  ;; external inputs and want to restrict what protocol(s) to deal
  ;; with. Defaults to CURLPROTO_ALL. 
  (def-cinit PROTOCOLS LONG 181)

  ;; set the bitmask for the protocols that libcurl is allowed to follow to
  ;; as a subset of the CURLOPT_PROTOCOLS ones. That means the protocol needs
  ;; to be set in both bitmasks to be allowed to get redirected to. Defaults
  ;; to all protocols except FILE and SCP. 
  (def-cinit REDIR_PROTOCOLS LONG 182)

  ;; set the SSH knownhost file name to use 
  (def-cinit SSH_KNOWNHOSTS STRINGPOINT 183)

  ;; set the SSH host key callback must point to a curl_sshkeycallback
  ;;function 				;
  (def-cinit SSH_KEYFUNCTION FUNCTIONPOINT 184)

  ;; set the SSH host key callback custom pointer 
  (def-cinit SSH_KEYDATA OBJECTPOINT 185)

  ;; set the SMTP mail originator 
  (def-cinit MAIL_FROM STRINGPOINT 186)

  ;; set the list of SMTP mail receiver(s) 
  (def-cinit MAIL_RCPT OBJECTPOINT 187)

  ;; FTP: send PRET before PASV 
  (def-cinit FTP_USE_PRET LONG 188)

  ;; RTSP request method (OPTIONS SETUP PLAY etc...) 
  (def-cinit RTSP_REQUEST LONG 189)

  ;; The RTSP session identifier 
  (def-cinit RTSP_SESSION_ID STRINGPOINT 190)

  ;; The RTSP stream URI 
  (def-cinit RTSP_STREAM_URI STRINGPOINT 191)

  ;; The Transport: header to use in RTSP requests 
  (def-cinit RTSP_TRANSPORT STRINGPOINT 192)

  ;; Manually initialize the client RTSP CSeq for this handle 
  (def-cinit RTSP_CLIENT_CSEQ LONG 193)

  ;; Manually initialize the server RTSP CSeq for this handle 
  (def-cinit RTSP_SERVER_CSEQ LONG 194)

  ;; The stream to pass to INTERLEAVEFUNCTION. 
  (def-cinit INTERLEAVEDATA OBJECTPOINT 195)

  ;; Let the application define a custom write method for RTP data 
  (def-cinit INTERLEAVEFUNCTION FUNCTIONPOINT 196)

  ;; Turn on wildcard matching 
  (def-cinit WILDCARDMATCH LONG 197)

  ;; Directory matching callback called before downloading of an
  ;;individual file (chunk) started 
  (def-cinit CHUNK_BGN_FUNCTION FUNCTIONPOINT 198)

  ;; Directory matching callback called after the file (chunk)
  ;;was downloaded or skipped 
  (def-cinit CHUNK_END_FUNCTION FUNCTIONPOINT 199)

  ;; Change match (fnmatch-like) callback for wildcard matching 
  (def-cinit FNMATCH_FUNCTION FUNCTIONPOINT 200)

  ;; Let the application define custom chunk data pointer 
  (def-cinit CHUNK_DATA OBJECTPOINT 201)

  ;; FNMATCH_FUNCTION user pointer 
  (def-cinit FNMATCH_DATA OBJECTPOINT 202)

  ;; send linked-list of name:port:address sets 
  (def-cinit RESOLVE OBJECTPOINT 203)

  ;; Set a username for authenticated TLS 
  (def-cinit TLSAUTH_USERNAME STRINGPOINT 204)

  ;; Set a password for authenticated TLS 
  (def-cinit TLSAUTH_PASSWORD STRINGPOINT 205)

  ;; Set authentication type for authenticated TLS 
  (def-cinit TLSAUTH_TYPE STRINGPOINT 206)

  ;; Set to 1 to enable the "TE:" header in HTTP requests to ask for
  ;; compressed transfer-encoded responses. Set to 0 to disable the use of TE:
  ;; in outgoing requests. The current default is 0 but it might change in a
  ;; future libcurl release.

  ;; libcurl will ask for the compressed methods it knows of and if that
  ;; isn't any it will not ask for transfer-encoding at all even if this
  ;; option is set to 1.

  
  (def-cinit TRANSFER_ENCODING LONG 207)

  ;; Callback function for closing socket (instead of close(2)). The callback
  ;;should have type curl_closesocket_callback 
  (def-cinit CLOSESOCKETFUNCTION FUNCTIONPOINT 208)
  (def-cinit CLOSESOCKETDATA OBJECTPOINT 209)

  ;; allow GSSAPI credential delegation 
  (def-cinit GSSAPI_DELEGATION LONG 210)

  ;; Set the name servers to use for DNS resolution 
  (def-cinit DNS_SERVERS STRINGPOINT 211)

  ;; Time-out accept operations (currently for FTP only) after this amount
  ;;of milliseconds. 
  (def-cinit ACCEPTTIMEOUT_MS LONG 212)

  ;; Set TCP keepalive 
  (def-cinit TCP_KEEPALIVE LONG 213)

  ;; non-universal keepalive knobs (Linux AIX HP-UX more) 
  (def-cinit TCP_KEEPIDLE LONG 214)
  (def-cinit TCP_KEEPINTVL LONG 215)

  ;; Enable/disable specific SSL features with a bitmask see CURLSSLOPT_;; 
  (def-cinit SSL_OPTIONS LONG 216)

  ;; Set the SMTP auth originator 
  (def-cinit MAIL_AUTH STRINGPOINT 217)

  ;; Enable/disable SASL initial response 
  (def-cinit SASL_IR LONG 218)

  ;; Function that will be called instead of the internal progress display
  ;; function. This function should be defined as the curl_xferinfo_callback
  ;; prototype defines. (Deprecates CURLOPT_PROGRESSFUNCTION) 
  (def-cinit XFERINFOFUNCTION FUNCTIONPOINT 219)

  ;; The XOAUTH2 bearer token 
  (def-cinit XOAUTH2_BEARER STRINGPOINT 220)

  ;; Set the interface string to use as outgoing network
  ;; interface for DNS requests.
  ;; Only supported by the c-ares DNS backend 
  (def-cinit DNS_INTERFACE STRINGPOINT 221)

  ;; Set the local IPv4 address to use for outgoing DNS requests.
  ;; Only supported by the c-ares DNS backend 
  (def-cinit DNS_LOCAL_IP4 STRINGPOINT 222)

  ;; Set the local IPv4 address to use for outgoing DNS requests.
  ;; Only supported by the c-ares DNS backend 
  (def-cinit DNS_LOCAL_IP6 STRINGPOINT 223)

  ;; Set authentication options directly 
  (def-cinit LOGIN_OPTIONS STRINGPOINT 224)

  ;; Enable/disable TLS NPN extension (http2 over ssl might fail without) 
  (def-cinit SSL_ENABLE_NPN LONG 225)

  ;; Enable/disable TLS ALPN extension (http2 over ssl might fail without) 
  (def-cinit SSL_ENABLE_ALPN LONG 226)

  ;; Time to wait for a response to a HTTP request containing an
  ;; Expect: 100-continue header before sending the data anyway. 
  (def-cinit EXPECT_100_TIMEOUT_MS LONG 227)

  ;; This points to a linked list of headers used for proxy requests only
  ;;struct curl_slist kind 
  (def-cinit PROXYHEADER OBJECTPOINT 228)

  ;; Pass in a bitmask of "header options" 
  (def-cinit HEADEROPT LONG 229)

  ;; The public key in DER form used to validate the peer public key
  ;;this option is used only if SSL_VERIFYPEER is true 
  (def-cinit PINNEDPUBLICKEY STRINGPOINT 230)

  ;; Path to Unix domain socket 
  (def-cinit UNIX_SOCKET_PATH STRINGPOINT 231)

  ;; Set if we should verify the certificate status. 
  (def-cinit SSL_VERIFYSTATUS LONG 232)

  ;; Set if we should enable TLS false start. 
  (def-cinit SSL_FALSESTART LONG 233)

  ;; Do not squash dot-dot sequences 
  (def-cinit PATH_AS_IS LONG 234)

  ;; Proxy Service Name 
  (def-cinit PROXY_SERVICE_NAME STRINGPOINT 235)

  ;; Service Name 
  (def-cinit SERVICE_NAME STRINGPOINT 236)

  ;; Wait/don't wait for pipe/mutex to clarify 
  (def-cinit PIPEWAIT LONG 237)

  ;; Set the protocol used when curl is given a URL without a protocol 
  (def-cinit DEFAULT_PROTOCOL STRINGPOINT 238)

  ;; Set stream weight 1 - 256 (default is 16) 
  (def-cinit STREAM_WEIGHT LONG 239)

  ;; Set stream dependency on another CURL handle 
  (def-cinit STREAM_DEPENDS OBJECTPOINT 240)

  ;; Set E-xclusive stream dependency on another CURL handle 
  (def-cinit STREAM_DEPENDS_E OBJECTPOINT 241)

  ;; Do not send any tftp option requests to the server 
  (def-cinit TFTP_NO_OPTIONS LONG 242)

  ;; Linked-list of host:port:connect-to-host:connect-to-port
  ;;overrides the URL's host:port (only for the network layer) 
  (def-cinit CONNECT_TO OBJECTPOINT 243)

  ;; Set TCP Fast Open 
  (def-cinit TCP_FASTOPEN LONG 244)

  ;; Continue to send data if the server responds early with an
  ;; HTTP status code >= 300 
  (def-cinit KEEP_SENDING_ON_ERROR LONG 245)

  ;; The CApath or CAfile used to validate the proxy certificate
  ;;this option is used only if PROXY_SSL_VERIFYPEER is true 
  (def-cinit PROXY_CAINFO STRINGPOINT 246)

  ;; The CApath directory used to validate the proxy certificate
  ;; this option is used only if PROXY_SSL_VERIFYPEER is true 
  (def-cinit PROXY_CAPATH STRINGPOINT 247)

  ;; Set if we should verify the proxy in ssl handshake
  ;; set 1 to verify. 
  (def-cinit PROXY_SSL_VERIFYPEER LONG 248)

  ;; Set if we should verify the Common name from the proxy certificate in ssl
  ;; handshake set 1 to check existence 2 to ensure that it matches
  ;; the provided hostname. 
  (def-cinit PROXY_SSL_VERIFYHOST LONG 249)

  ;; What version to specifically try to use for proxy.
  ;;See CURL_SSLVERSION defines below. 
  (def-cinit PROXY_SSLVERSION LONG 250)

  ;; Set a username for authenticated TLS for proxy 
  (def-cinit PROXY_TLSAUTH_USERNAME STRINGPOINT 251)

  ;; Set a password for authenticated TLS for proxy 
  (def-cinit PROXY_TLSAUTH_PASSWORD STRINGPOINT 252)

  ;; Set authentication type for authenticated TLS for proxy 
  (def-cinit PROXY_TLSAUTH_TYPE STRINGPOINT 253)

  ;; name of the file keeping your private SSL-certificate for proxy 
  (def-cinit PROXY_SSLCERT STRINGPOINT 254)

  ;; type of the file keeping your SSL-certificate ("DER" "PEM" "ENG") for
  ;; proxy 
  (def-cinit PROXY_SSLCERTTYPE STRINGPOINT 255)

  ;; name of the file keeping your private SSL-key for proxy 
  (def-cinit PROXY_SSLKEY STRINGPOINT 256)

  ;; type of the file keeping your private SSL-key ("DER" "PEM" "ENG") for
  ;; proxy 
  (def-cinit PROXY_SSLKEYTYPE STRINGPOINT 257)

  ;; password for the SSL private key for proxy 
  (def-cinit PROXY_KEYPASSWD STRINGPOINT 258)

  ;; Specify which SSL ciphers to use for proxy 
  (def-cinit PROXY_SSL_CIPHER_LIST STRINGPOINT 259)

  ;; CRL file for proxy 
  (def-cinit PROXY_CRLFILE STRINGPOINT 260)

  ;; Enable/disable specific SSL features with a bitmask for proxy see
  ;;CURLSSLOPT_;; 
  (def-cinit PROXY_SSL_OPTIONS LONG 261)

  ;; Name of pre proxy to use. 
  (def-cinit PRE_PROXY STRINGPOINT 262)

  ;; The public key in DER form used to validate the proxy public key
  ;;this option is used only if PROXY_SSL_VERIFYPEER is true 
  (def-cinit PROXY_PINNEDPUBLICKEY STRINGPOINT 263)

  ;; Path to an abstract Unix domain socket 
  (def-cinit ABSTRACT_UNIX_SOCKET STRINGPOINT 264)

  ;; Suppress proxy CONNECT response headers from user callbacks 
  (def-cinit SUPPRESS_CONNECT_HEADERS LONG 265)

  ;; The request target instead of extracted from the URL 
  (def-cinit REQUEST_TARGET STRINGPOINT 266)

  ;; bitmask of allowed auth methods for connections to SOCKS5 proxies 
  (def-cinit SOCKS5_AUTH LONG 267)
  
  
  ;;int curl_strequal(char* s1 ,char* s2)
  (def-function curl-strequal
    "curl_strequal" (string string) int)

  ;;int curl_strnequal(char* s1 ,char* s2 ,size_t n)
  (def-function curl-strnequal
    "curl_strnequal" (string string int) int)

  ;;CURLFORMcode curl_formadd()
  (def-function curl-formadd
    "curl_formadd" () int)

  ;;int curl_formget(struct curl_httppost* form ,void* arg ,curl_formget_callback append)
  (def-function curl-formget
    "curl_formget" (void* void* curl_formget_callback) int)

  ;;void curl_formfree(struct curl_httppost* form)
  (def-function curl-formfree
    "curl_formfree" (void*) void)

  ;;char* curl_getenv(char* variable)
  (def-function curl-getenv
    "curl_getenv" (string) string)

  ;;char* curl_version(void )
  (def-function curl-version
    "curl_version" (void) string)

  ;;char* curl_easy_escape(CURL* handle ,char* string ,int length)
  (def-function curl-easy-escape
    "curl_easy_escape" (void* string int) string)

  ;;char* curl_escape(char* string ,int length)
  (def-function curl-escape
    "curl_escape" (string int) string)

  ;;char* curl_easy_unescape(CURL* handle ,char* string ,int length ,int* outlength)
  (def-function curl-easy-unescape
    "curl_easy_unescape" (void* string int void*) string)

  ;;char* curl_unescape(char* string ,int length)
  (def-function curl-unescape
    "curl_unescape" (string int) string)

  ;;void curl_free(void* p)
  (def-function curl-free
    "curl_free" (void*) void)

  ;;CURLcode curl_global_init(long flags)
  (def-function curl-global-init
    "curl_global_init" (long) int)

  ;;CURLcode curl_global_init_mem(long flags ,curl_malloc_callback m ,curl_free_callback f ,curl_realloc_callback r ,curl_strdup_callback s ,curl_calloc_callback c)
  (def-function curl-global-init-mem
    "curl_global_init_mem" (long void* void* void* void* void*) int)

  ;;void curl_global_cleanup(void )
  (def-function curl-global-cleanup
    "curl_global_cleanup" (void) void)

  ;; curl_slist_append(struct curl_slist*  ,char* )
  (def-function curl-slist-append
    "curl_slist_append" (void* string) void*)

  ;;void curl_slist_free_all(struct curl_slist* )
  (def-function curl-slist-free-all
    "curl_slist_free_all" (void*) void)

  ;;time_t curl_getdate(char* p ,time_t* unused)
  (def-function curl-getdate
    "curl_getdate" (string void*) time_t)

  ;;CURLSH* curl_share_init(void )
  (def-function curl-share-init
    "curl_share_init" (void) void*)

  ;;CURLSHcode curl_share_setopt(CURLSH*  ,CURLSHoption option)
  (def-function curl-share-setopt
    "curl_share_setopt" (void* int) int)

  ;;CURLSHcode curl_share_cleanup(CURLSH* )
  (def-function curl-share-cleanup
    "curl_share_cleanup" (void*) int)

  ;;curl_version_info_data* curl_version_info(CURLversion )
  (def-function curl-version-info
    "curl_version_info" (int) void*)

  ;;char* curl_easy_strerror(CURLcode )
  (def-function curl-easy-strerror
    "curl_easy_strerror" (int) string)

  ;;char* curl_share_strerror(CURLSHcode )
  (def-function curl-share-strerror
    "curl_share_strerror" (int) string)

  ;;CURLcode curl_easy_pause(CURL* handle ,int bitmask)
  (def-function curl-easy-pause
    "curl_easy_pause" (void* int) int)

  ;;CURL* curl_easy_init(void )
  (def-function curl-easy-init
    "curl_easy_init" (void) void*)

  ;;CURLcode curl_easy_setopt(CURL* curl ,CURLoption option ...)
  (def-function curl-easy-setopt
    "curl_easy_setopt" (void* int void* ) int)

  ;;CURLcode curl_easy_perform(CURL* curl)
  (def-function curl-easy-perform
    "curl_easy_perform" (void*) int)

  ;;void curl_easy_cleanup(CURL* curl)
  (def-function curl-easy-cleanup
    "curl_easy_cleanup" (void*) void)

  ;;CURLcode curl_easy_getinfo(CURL* curl ,CURLINFO info)
  (def-function curl-easy-getinfo
    "curl_easy_getinfo" (void* int) int)

  ;;CURL* curl_easy_duphandle(CURL* curl)
  (def-function curl-easy-duphandle
    "curl_easy_duphandle" (void*) void*)

  ;;void curl_easy_reset(CURL* curl)
  (def-function curl-easy-reset
    "curl_easy_reset" (void*) void)

  ;;CURLcode curl_easy_recv(CURL* curl ,void* buffer ,size_t buflen ,size_t* n)
  (def-function curl-easy-recv
    "curl_easy_recv" (void* void* int void*) int)

  ;;CURLcode curl_easy_send(CURL* curl ,void* buffer ,size_t buflen ,size_t* n)
  (def-function curl-easy-send
    "curl_easy_send" (void* void* int void*) int)

  ;;CURLM* curl_multi_init(void )
  (def-function curl-multi-init
    "curl_multi_init" (void) void*)

  ;;CURLMcode curl_multi_add_handle(CURLM* multi_handle ,CURL* curl_handle)
  (def-function curl-multi-add-handle
    "curl_multi_add_handle" (void* void*) int)

  ;;CURLMcode curl_multi_remove_handle(CURLM* multi_handle ,CURL* curl_handle)
  (def-function curl-multi-remove-handle
    "curl_multi_remove_handle" (void* void*) int)

  ;;CURLMcode curl_multi_fdset(CURLM* multi_handle ,void* read_fd_set ,void* write_fd_set ,void* exc_fd_set ,int* max_fd)
  (def-function curl-multi-fdset
    "curl_multi_fdset" (void* void* void* void* void*) int)

  ;;CURLMcode curl_multi_wait(CURLM* multi_handle ,void* extra_fds[] ,unsigned int extra_nfds ,int timeout_ms ,int* ret)
  (def-function curl-multi-wait
    "curl_multi_wait" (void* void* int int void*) int)

  ;;CURLMcode curl_multi_perform(CURLM* multi_handle ,int* running_handles)
  (def-function curl-multi-perform
    "curl_multi_perform" (void* void*) int)

  ;;CURLMcode curl_multi_cleanup(CURLM* multi_handle)
  (def-function curl-multi-cleanup
    "curl_multi_cleanup" (void*) int)

  ;;CURLMsg* curl_multi_info_read(CURLM* multi_handle ,int* msgs_in_queue)
  (def-function curl-multi-info-read
    "curl_multi_info_read" (void* void*) void*)

  ;;char* curl_multi_strerror(CURLMcode )
  (def-function curl-multi-strerror
    "curl_multi_strerror" (int) string)

  ;;CURLMcode curl_multi_socket(CURLM* multi_handle ,curl_socket_t s ,int* running_handles)
  (def-function curl-multi-socket
    "curl_multi_socket" (void* int void*) int)

  ;;CURLMcode curl_multi_socket_action(CURLM* multi_handle ,curl_socket_t s ,int ev_bitmask ,int* running_handles)
  (def-function curl-multi-socket-action
    "curl_multi_socket_action" (void* int int void*) int)

  ;;CURLMcode curl_multi_socket_all(CURLM* multi_handle ,int* running_handles)
  (def-function curl-multi-socket-all
    "curl_multi_socket_all" (void* void*) int)

  ;;CURLMcode curl_multi_timeout(CURLM* multi_handle ,long* milliseconds)
  (def-function curl-multi-timeout
    "curl_multi_timeout" (void* void*) int)

  ;;CURLMcode curl_multi_setopt(CURLM* multi_handle ,CURLMoption option)
  (def-function curl-multi-setopt
    "curl_multi_setopt" (void* CURLMoption) int)

  ;;CURLMcode curl_multi_assign(CURLM* multi_handle ,curl_socket_t sockfd ,void* sockp)
  (def-function curl-multi-assign
    "curl_multi_assign" (void* int void*) int)

  ;;char* curl_pushheader_bynum(struct curl_pushheaders* h ,size_t num)
  (def-function curl-pushheader-bynum
    "curl_pushheader_bynum" (void* int) string)

  ;;char* curl_pushheader_byname(struct curl_pushheaders* h ,char* name)
  (def-function curl-pushheader-byname
    "curl_pushheader_byname" (void* string) string)


  )
