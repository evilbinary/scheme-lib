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
  curl-pushheader-byname)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libcurl.so")
   ((a6nt i3nt) "libcurl.dll")
   ((a6osx i3osx)  "libcurl.dylib")
   ((a6le i3le) "libcurl.so")))
 (define lib (load-librarys  lib-name ))

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
