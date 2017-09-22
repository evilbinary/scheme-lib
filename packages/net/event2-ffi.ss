;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-09-10 12:06:07.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net event2-ffi ) 
  (export evutil-date-rfc1123
  evutil-monotonic-timer-new
  evutil-monotonic-timer-free
  evutil-configure-monotonic-time
  evutil-gettime-monotonic
  evutil-socketpair
  evutil-make-socket-nonblocking
  evutil-make-listen-socket-reuseable
  evutil-make-listen-socket-reuseable-port
  evutil-make-socket-closeonexec
  evutil-closesocket
  evutil-make-tcp-listen-socket-deferred
  evutil-strtoll
  evutil-snprintf
  evutil-vsnprintf
  evutil-inet-ntop
  evutil-inet-pton
  evutil-parse-sockaddr-port
  evutil-sockaddr-cmp
  evutil-ascii-strcasecmp
  evutil-ascii-strncasecmp
  evutil-getaddrinfo
  evutil-freeaddrinfo
  evutil-gai-strerror
  evutil-secure-rng-get-bytes
  evutil-secure-rng-init
  evutil-secure-rng-set-urandom-device-file
  evutil-secure-rng-add-bytes
  event-enable-debug-mode
  event-debug-unassign
  event-base-new
  event-reinit
  event-base-dispatch
  event-base-get-method
  event-get-supported-methods
  event-gettime-monotonic
  event-base-get-num-events
  event-base-get-max-events
  event-config-new
  event-config-free
  event-config-avoid-method
  event-base-get-features
  event-config-require-features
  event-config-set-flag
  event-config-set-num-cpus-hint
  event-config-set-max-dispatch-interval
  event-base-new-with-config
  event-base-free
  event-base-free-nofinalize
  event-set-log-callback
  event-set-fatal-callback
  event-enable-debug-logging
  event-base-set
  event-base-loop
  event-base-loopexit
  event-base-loopbreak
  event-base-loopcontinue
  event-base-got-exit
  event-base-got-break
  event-self-cbarg
  event-new
  event-assign
  event-free
  event-finalize
  event-free-finalize
  event-base-once
  event-add
  event-remove-timer
  event-del
  event-del-noblock
  event-del-block
  event-active
  event-pending
  event-base-get-running-event
  event-initialized
  event-get-fd
  event-get-base
  event-get-events
  event-get-callback
  event-get-callback-arg
  event-get-priority
  event-get-assignment
  event-get-struct-event-size
  event-get-version
  event-get-version-number
  event-base-priority-init
  event-base-get-npriorities
  event-priority-set
  event-base-init-common-timeout
  event-set-mem-functions
  event-base-dump-events
  event-base-active-by-fd
  event-base-active-by-signal
  event-base-foreach-event
  event-base-gettimeofday-cached
  event-base-update-cache-time
  libevent-global-shutdown
  evconnlistener-new
  evconnlistener-new-bind
  evconnlistener-free
  evconnlistener-enable
  evconnlistener-disable
  evconnlistener-get-base
  evconnlistener-get-fd
  evconnlistener-set-cb
  evconnlistener-set-error-cb

  bufferevent-socket-new
  bufferevent-socket-connect
  bufferevent-socket-connect-hostname
  bufferevent-socket-get-dns-error
  bufferevent-base-set
  bufferevent-get-base
  bufferevent-priority-set
  bufferevent-get-priority
  bufferevent-free
  bufferevent-setcb
  bufferevent-getcb
  bufferevent-setfd
  bufferevent-getfd
  bufferevent-get-underlying
  bufferevent-write
  bufferevent-write-buffer
  bufferevent-read
  bufferevent-read-buffer
  bufferevent-get-input
  bufferevent-get-output
  bufferevent-enable
  bufferevent-disable
  bufferevent-get-enabled
  bufferevent-set-timeouts
  bufferevent-setwatermark
  bufferevent-getwatermark
  bufferevent-lock
  bufferevent-unlock
  bufferevent-incref
  bufferevent-decref
  bufferevent-flush
  bufferevent-trigger
  bufferevent-trigger-event
  bufferevent-filter-new
  bufferevent-pair-new
  bufferevent-pair-get-partner
  ev-token-bucket-cfg-new
  ev-token-bucket-cfg-free
  bufferevent-set-rate-limit
  bufferevent-rate-limit-group-new
  bufferevent-rate-limit-group-set-cfg
  bufferevent-rate-limit-group-set-min-share
  bufferevent-rate-limit-group-free
  bufferevent-add-to-rate-limit-group
  bufferevent-remove-from-rate-limit-group
  bufferevent-set-max-single-read
  bufferevent-set-max-single-write
  bufferevent-get-max-single-read
  bufferevent-get-max-single-write
  bufferevent-get-read-limit
  bufferevent-get-write-limit
  bufferevent-get-max-to-read
  bufferevent-get-max-to-write
  bufferevent-get-token-bucket-cfg
  bufferevent-rate-limit-group-get-read-limit
  bufferevent-rate-limit-group-get-write-limit
  bufferevent-decrement-read-limit
  bufferevent-decrement-write-limit
  bufferevent-rate-limit-group-decrement-read
  bufferevent-rate-limit-group-decrement-write
  bufferevent-rate-limit-group-get-totals
  bufferevent-rate-limit-group-reset-totals
  evbuffer-readline
  evbuffer-setcb
  evbuffer-find

   evbuffer-new
  evbuffer-free
  evbuffer-enable-locking
  evbuffer-lock
  evbuffer-unlock
  evbuffer-set-flags
  evbuffer-clear-flags
  evbuffer-get-length
  evbuffer-get-contiguous-space
  evbuffer-expand
  evbuffer-reserve-space
  evbuffer-commit-space
  evbuffer-add
  evbuffer-remove
  evbuffer-copyout
  evbuffer-copyout-from
  evbuffer-remove-buffer
  evbuffer-readln
  evbuffer-add-buffer
  evbuffer-add-buffer-reference
  evbuffer-add-reference
  evbuffer-add-file
  evbuffer-file-segment-new
  evbuffer-file-segment-free
  evbuffer-file-segment-add-cleanup-cb
  evbuffer-add-file-segment
  evbuffer-add-printf
  evbuffer-add-vprintf
  evbuffer-drain
  evbuffer-write
  evbuffer-write-atmost
  evbuffer-read
  evbuffer-search
  evbuffer-search-range
  evbuffer-ptr-set
  evbuffer-search-eol
  evbuffer-peek
  evbuffer-add-cb
  evbuffer-remove-cb-entry
  evbuffer-remove-cb
  evbuffer-cb-set-flags
  evbuffer-cb-clear-flags
  evbuffer-pullup
  evbuffer-prepend
  evbuffer-prepend-buffer
  evbuffer-freeze
  evbuffer-unfreeze
  evbuffer-defer-callbacks
  evbuffer-add-iovec
  )

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libevent2.so")
   ((a6nt i3nt) "libevent2.dll")
   ((a6osx i3osx)  "libevent2.dylib")
   ((a6le i3le) "libevent2.so")))
 (define lib (load-librarys  lib-name ))

;;int evutil_date_rfc1123(char* date ,size_t datelen ,struct tm* tm)
(def-function evutil-date-rfc1123
             "evutil_date_rfc1123" (string int void*) int)

;;evutil_monotonic_timer* evutil_monotonic_timer_new(void )
(def-function evutil-monotonic-timer-new
             "evutil_monotonic_timer_new" (void) void*)

;;void evutil_monotonic_timer_free(struct evutil_monotonic_timer* timer)
(def-function evutil-monotonic-timer-free
             "evutil_monotonic_timer_free" (void*) void)

;;int evutil_configure_monotonic_time(struct evutil_monotonic_timer* timer ,int flags)
(def-function evutil-configure-monotonic-time
             "evutil_configure_monotonic_time" (void* int) int)

;;int evutil_gettime_monotonic(struct evutil_monotonic_timer* timer ,struct timeval* tp)
(def-function evutil-gettime-monotonic
             "evutil_gettime_monotonic" (void* void*) int)

;;int evutil_socketpair(int d ,int type ,int protocol ,int sv[])
(def-function evutil-socketpair
             "evutil_socketpair" (int int int void*) int)

;;int evutil_make_socket_nonblocking(int sock)
(def-function evutil-make-socket-nonblocking
             "evutil_make_socket_nonblocking" (int) int)

;;int evutil_make_listen_socket_reuseable(int sock)
(def-function evutil-make-listen-socket-reuseable
             "evutil_make_listen_socket_reuseable" (int) int)

;;int evutil_make_listen_socket_reuseable_port(int sock)
(def-function evutil-make-listen-socket-reuseable-port
             "evutil_make_listen_socket_reuseable_port" (int) int)

;;int evutil_make_socket_closeonexec(int sock)
(def-function evutil-make-socket-closeonexec
             "evutil_make_socket_closeonexec" (int) int)

;;int evutil_closesocket(int sock)
(def-function evutil-closesocket
             "evutil_closesocket" (int) int)

;;int evutil_make_tcp_listen_socket_deferred(int sock)
(def-function evutil-make-tcp-listen-socket-deferred
             "evutil_make_tcp_listen_socket_deferred" (int) int)

;;int64_t evutil_strtoll(char* s ,char endptr ,int base)
(def-function evutil-strtoll
             "evutil_strtoll" (string char int) int)

;;int evutil_snprintf(char* buf ,size_t buflen ,char* format)
(def-function evutil-snprintf
             "evutil_snprintf" (string int string) int)

;;int evutil_vsnprintf(char* buf ,size_t buflen ,char* format ,va_list ap)
(def-function evutil-vsnprintf
             "evutil_vsnprintf" (string int string va_list) int)

;;char* evutil_inet_ntop(int af ,void* src ,char* dst ,size_t len)
(def-function evutil-inet-ntop
             "evutil_inet_ntop" (int void* string int) string)

;;int evutil_inet_pton(int af ,char* src ,void* dst)
(def-function evutil-inet-pton
             "evutil_inet_pton" (int string void*) int)

;;int evutil_parse_sockaddr_port(char* str ,struct sockaddr* out ,int* outlen)
(def-function evutil-parse-sockaddr-port
             "evutil_parse_sockaddr_port" (string void* void*) int)

;;int evutil_sockaddr_cmp(struct sockaddr* sa1 ,struct sockaddr* sa2 ,int include_port)
(def-function evutil-sockaddr-cmp
             "evutil_sockaddr_cmp" (void* void* int) int)

;;int evutil_ascii_strcasecmp(char* str1 ,char* str2)
(def-function evutil-ascii-strcasecmp
             "evutil_ascii_strcasecmp" (string string) int)

;;int evutil_ascii_strncasecmp(char* str1 ,char* str2 ,size_t n)
(def-function evutil-ascii-strncasecmp
             "evutil_ascii_strncasecmp" (string string int) int)

;;int evutil_getaddrinfo(char* nodename ,char* servname ,struct addrinfo* hints_in)
(def-function evutil-getaddrinfo
             "evutil_getaddrinfo" (string string void*) int)

;;void evutil_freeaddrinfo(struct addrinfo* ai)
(def-function evutil-freeaddrinfo
             "evutil_freeaddrinfo" (void*) void)

;;char* evutil_gai_strerror(int err)
(def-function evutil-gai-strerror
             "evutil_gai_strerror" (int) string)

;;void evutil_secure_rng_get_bytes(void* buf ,size_t n)
(def-function evutil-secure-rng-get-bytes
             "evutil_secure_rng_get_bytes" (void* int) void)

;;int evutil_secure_rng_init(void )
(def-function evutil-secure-rng-init
             "evutil_secure_rng_init" (void) int)

;;int evutil_secure_rng_set_urandom_device_file(char* fname)
(def-function evutil-secure-rng-set-urandom-device-file
             "evutil_secure_rng_set_urandom_device_file" (string) int)

;;void evutil_secure_rng_add_bytes(char* dat ,size_t datlen)
(def-function evutil-secure-rng-add-bytes
             "evutil_secure_rng_add_bytes" (string int) void)

;;void event_enable_debug_mode(void )
(def-function event-enable-debug-mode
             "event_enable_debug_mode" (void) void)

;;void event_debug_unassign(struct event* )
(def-function event-debug-unassign
             "event_debug_unassign" (void*) void)

;;event_base* event_base_new(void )
(def-function event-base-new
             "event_base_new" (void) void*)

;;int event_reinit(struct event_base* base)
(def-function event-reinit
             "event_reinit" (void*) int)

;;int event_base_dispatch(struct event_base* )
(def-function event-base-dispatch
             "event_base_dispatch" (void*) int)

;;char* event_base_get_method(struct event_base* )
(def-function event-base-get-method
             "event_base_get_method" (void*) string)

;;char event_get_supported_methods(void )
(def-function event-get-supported-methods
             "event_get_supported_methods" (void) char)

;;int event_gettime_monotonic(struct event_base* base ,struct timeval* tp)
(def-function event-gettime-monotonic
             "event_gettime_monotonic" (void* void*) int)

;;int event_base_get_num_events(struct event_base*  ,unsigned int )
(def-function event-base-get-num-events
             "event_base_get_num_events" (void* int) int)

;;int event_base_get_max_events(struct event_base*  ,unsigned int  ,int )
(def-function event-base-get-max-events
             "event_base_get_max_events" (void* int int) int)

;;event_config* event_config_new(void )
(def-function event-config-new
             "event_config_new" (void) void*)

;;void event_config_free(struct event_config* cfg)
(def-function event-config-free
             "event_config_free" (void*) void)

;;int event_config_avoid_method(struct event_config* cfg ,char* method)
(def-function event-config-avoid-method
             "event_config_avoid_method" (void* string) int)

;;int event_base_get_features(struct event_base* base)
(def-function event-base-get-features
             "event_base_get_features" (void*) int)

;;int event_config_require_features(struct event_config* cfg ,int feature)
(def-function event-config-require-features
             "event_config_require_features" (void* int) int)

;;int event_config_set_flag(struct event_config* cfg ,int flag)
(def-function event-config-set-flag
             "event_config_set_flag" (void* int) int)

;;int event_config_set_num_cpus_hint(struct event_config* cfg ,int cpus)
(def-function event-config-set-num-cpus-hint
             "event_config_set_num_cpus_hint" (void* int) int)

;;int event_config_set_max_dispatch_interval(struct event_config* cfg ,struct timeval* max_interval ,int max_callbacks ,int min_priority)
(def-function event-config-set-max-dispatch-interval
             "event_config_set_max_dispatch_interval" (void* void* int int) int)

;;event_base* event_base_new_with_config(struct event_config* )
(def-function event-base-new-with-config
             "event_base_new_with_config" (void*) void*)

;;void event_base_free(struct event_base* )
(def-function event-base-free
             "event_base_free" (void*) void)

;;void event_base_free_nofinalize(struct event_base* )
(def-function event-base-free-nofinalize
             "event_base_free_nofinalize" (void*) void)

;;void event_set_log_callback(event_log_cb cb)
(def-function event-set-log-callback
             "event_set_log_callback" (event_log_cb) void)

;;void event_set_fatal_callback(event_fatal_cb cb)
(def-function event-set-fatal-callback
             "event_set_fatal_callback" (void*) void)

;;void event_enable_debug_logging(uint32_t which)
(def-function event-enable-debug-logging
             "event_enable_debug_logging" (int) void)

;;int event_base_set(struct event_base*  ,struct event* )
(def-function event-base-set
             "event_base_set" (void* void*) int)

;;int event_base_loop(struct event_base*  ,int )
(def-function event-base-loop
             "event_base_loop" (void* int) int)

;;int event_base_loopexit(struct event_base*  ,struct timeval* )
(def-function event-base-loopexit
             "event_base_loopexit" (void* void*) int)

;;int event_base_loopbreak(struct event_base* )
(def-function event-base-loopbreak
             "event_base_loopbreak" (void*) int)

;;int event_base_loopcontinue(struct event_base* )
(def-function event-base-loopcontinue
             "event_base_loopcontinue" (void*) int)

;;int event_base_got_exit(struct event_base* )
(def-function event-base-got-exit
             "event_base_got_exit" (void*) int)

;;int event_base_got_break(struct event_base* )
(def-function event-base-got-break
             "event_base_got_break" (void*) int)

;;void* event_self_cbarg(void )
(def-function event-self-cbarg
             "event_self_cbarg" (void) void*)

;;event* event_new(struct event_base*  ,int  ,short  ,event_callback_fn  ,void* )
(def-function event-new
             "event_new" (void* int int void* void*) void*)

;;int event_assign(struct event*  ,struct event_base*  ,int  ,short  ,event_callback_fn  ,void* )
(def-function event-assign
             "event_assign" (void* void* int int void* void*) int)

;;void event_free(struct event* )
(def-function event-free
             "event_free" (void*) void)

;;int event_finalize(unsigned  ,struct event*  ,event_finalize_callback_fn )
(def-function event-finalize
             "event_finalize" (int void* void*) int)

;;int event_free_finalize(unsigned  ,struct event*  ,event_finalize_callback_fn )
(def-function event-free-finalize
             "event_free_finalize" (int void* void*) int)

;;int event_base_once(struct event_base*  ,int  ,short  ,event_callback_fn  ,void*  ,struct timeval* )
(def-function event-base-once
             "event_base_once" (void* int short void* void* void*) int)

;;int event_add(struct event* ev ,struct timeval* timeout)
(def-function event-add
             "event_add" (void* void*) int)

;;int event_remove_timer(struct event* ev)
(def-function event-remove-timer
             "event_remove_timer" (void*) int)

;;int event_del(struct event* )
(def-function event-del
             "event_del" (void*) int)

;;int event_del_noblock(struct event* ev)
(def-function event-del-noblock
             "event_del_noblock" (void*) int)

;;int event_del_block(struct event* ev)
(def-function event-del-block
             "event_del_block" (void*) int)

;;void event_active(struct event* ev ,int res ,short ncalls)
(def-function event-active
             "event_active" (void* int short) void)

;;int event_pending(struct event* ev ,short events ,struct timeval* tv)
(def-function event-pending
             "event_pending" (void* short void*) int)

;;event* event_base_get_running_event(struct event_base* base)
(def-function event-base-get-running-event
             "event_base_get_running_event" (void*) void*)

;;int event_initialized(struct event* ev)
(def-function event-initialized
             "event_initialized" (void*) int)

;;int event_get_fd(struct event* ev)
(def-function event-get-fd
             "event_get_fd" (void*) int)

;;event_base* event_get_base(struct event* ev)
(def-function event-get-base
             "event_get_base" (void*) void*)

;;short event_get_events(struct event* ev)
(def-function event-get-events
             "event_get_events" (void*) short)

;;event_callback_fn event_get_callback(struct event* ev)
(def-function event-get-callback
             "event_get_callback" (void*) void*)

;;void* event_get_callback_arg(struct event* ev)
(def-function event-get-callback-arg
             "event_get_callback_arg" (void*) void*)

;;int event_get_priority(struct event* ev)
(def-function event-get-priority
             "event_get_priority" (void*) int)

;;void event_get_assignment(struct event* event ,int* fd_out ,short* events_out ,event_callback_fn* callback_out ,void arg_out)
(def-function event-get-assignment
             "event_get_assignment" (void* void* void* void* void) void)

;;size_t event_get_struct_event_size(void )
(def-function event-get-struct-event-size
             "event_get_struct_event_size" (void) int)

;;char* event_get_version(void )
(def-function event-get-version
             "event_get_version" (void) string)

;;uint32_t event_get_version_number(void )
(def-function event-get-version-number
             "event_get_version_number" (void) int)

;;int event_base_priority_init(struct event_base*  ,int )
(def-function event-base-priority-init
             "event_base_priority_init" (void* int) int)

;;int event_base_get_npriorities(struct event_base* eb)
(def-function event-base-get-npriorities
             "event_base_get_npriorities" (void*) int)

;;int event_priority_set(struct event*  ,int )
(def-function event-priority-set
             "event_priority_set" (void* int) int)

;;timeval* event_base_init_common_timeout(struct event_base* base ,struct timeval* duration)
(def-function event-base-init-common-timeout
             "event_base_init_common_timeout" (void* void*) void*)

;;void event_set_mem_functions()
(def-function event-set-mem-functions
             "event_set_mem_functions" () void)

;;void event_base_dump_events(struct event_base*  ,FILE* )
(def-function event-base-dump-events
             "event_base_dump_events" (void* void*) void)

;;void event_base_active_by_fd(struct event_base* base ,int fd ,short events)
(def-function event-base-active-by-fd
             "event_base_active_by_fd" (void* int short) void)

;;void event_base_active_by_signal(struct event_base* base ,int sig)
(def-function event-base-active-by-signal
             "event_base_active_by_signal" (void* int) void)

;;int event_base_foreach_event(struct event_base* base ,event_base_foreach_event_cb fn ,void* arg)
(def-function event-base-foreach-event
             "event_base_foreach_event" (void* void* void*) int)

;;int event_base_gettimeofday_cached(struct event_base* base ,struct timeval* tv)
(def-function event-base-gettimeofday-cached
             "event_base_gettimeofday_cached" (void* void*) int)

;;int event_base_update_cache_time(struct event_base* base)
(def-function event-base-update-cache-time
             "event_base_update_cache_time" (void*) int)

;;void libevent_global_shutdown(void )
(def-function libevent-global-shutdown
             "libevent_global_shutdown" (void) void)


;;evconnlistener* evconnlistener_new(struct event_base* base ,evconnlistener_cb cb ,void* ptr ,unsigned flags ,int backlog ,int fd)
(def-function evconnlistener-new
             "evconnlistener_new" (void* void* void* int int int) void*)

;;evconnlistener* evconnlistener_new_bind(struct event_base* base ,evconnlistener_cb cb ,void* ptr ,unsigned flags ,int backlog ,struct sockaddr* sa ,int socklen)
(def-function evconnlistener-new-bind
             "evconnlistener_new_bind" (void* void* void* int int void* int) void*)

;;void evconnlistener_free(struct evconnlistener* lev)
(def-function evconnlistener-free
             "evconnlistener_free" (void*) void)

;;int evconnlistener_enable(struct evconnlistener* lev)
(def-function evconnlistener-enable
             "evconnlistener_enable" (void*) int)

;;int evconnlistener_disable(struct evconnlistener* lev)
(def-function evconnlistener-disable
             "evconnlistener_disable" (void*) int)

;;event_base* evconnlistener_get_base(struct evconnlistener* lev)
(def-function evconnlistener-get-base
             "evconnlistener_get_base" (void*) void*)

;;int evconnlistener_get_fd(struct evconnlistener* lev)
(def-function evconnlistener-get-fd
             "evconnlistener_get_fd" (void*) int)

;;void evconnlistener_set_cb(struct evconnlistener* lev ,evconnlistener_cb cb ,void* arg)
(def-function evconnlistener-set-cb
             "evconnlistener_set_cb" (void* void* void*) void)

;;void evconnlistener_set_error_cb(struct evconnlistener* lev ,evconnlistener_errorcb errorcb)
(def-function evconnlistener-set-error-cb
             "evconnlistener_set_error_cb" (void* void*) void)




;;bufferevent* bufferevent_socket_new(struct event_base* base ,int fd ,int options)
(def-function bufferevent-socket-new
             "bufferevent_socket_new" (void* int int) void*)

;;int bufferevent_socket_connect(struct bufferevent*  ,struct sockaddr*  ,int )
(def-function bufferevent-socket-connect
             "bufferevent_socket_connect" (void* void* int) int)

;;int bufferevent_socket_connect_hostname(struct bufferevent*  ,struct evdns_base*  ,int  ,char*  ,int )
(def-function bufferevent-socket-connect-hostname
             "bufferevent_socket_connect_hostname" (void* void* int string int) int)

;;int bufferevent_socket_get_dns_error(struct bufferevent* bev)
(def-function bufferevent-socket-get-dns-error
             "bufferevent_socket_get_dns_error" (void*) int)

;;int bufferevent_base_set(struct event_base* base ,struct bufferevent* bufev)
(def-function bufferevent-base-set
             "bufferevent_base_set" (void* void*) int)

;;event_base* bufferevent_get_base(struct bufferevent* bev)
(def-function bufferevent-get-base
             "bufferevent_get_base" (void*) void*)

;;int bufferevent_priority_set(struct bufferevent* bufev ,int pri)
(def-function bufferevent-priority-set
             "bufferevent_priority_set" (void* int) int)

;;int bufferevent_get_priority(struct bufferevent* bufev)
(def-function bufferevent-get-priority
             "bufferevent_get_priority" (void*) int)

;;void bufferevent_free(struct bufferevent* bufev)
(def-function bufferevent-free
             "bufferevent_free" (void*) void)

;;void bufferevent_setcb(struct bufferevent* bufev ,bufferevent_data_cb readcb ,bufferevent_data_cb writecb ,bufferevent_event_cb eventcb ,void* cbarg)
(def-function bufferevent-setcb
             "bufferevent_setcb" (void* void* void* void* void*) void)

;;void bufferevent_getcb(struct bufferevent* bufev ,bufferevent_data_cb* readcb_ptr ,bufferevent_data_cb* writecb_ptr ,bufferevent_event_cb* eventcb_ptr ,void cbarg_ptr)
(def-function bufferevent-getcb
             "bufferevent_getcb" (void* void* void* void* void) void)

;;int bufferevent_setfd(struct bufferevent* bufev ,int fd)
(def-function bufferevent-setfd
             "bufferevent_setfd" (void* int) int)

;;int bufferevent_getfd(struct bufferevent* bufev)
(def-function bufferevent-getfd
             "bufferevent_getfd" (void*) int)

;;bufferevent* bufferevent_get_underlying(struct bufferevent* bufev)
(def-function bufferevent-get-underlying
             "bufferevent_get_underlying" (void*) void*)

;;int bufferevent_write(struct bufferevent* bufev ,void* data ,size_t size)
(def-function bufferevent-write
             "bufferevent_write" (void* void* int) int)

;;int bufferevent_write_buffer(struct bufferevent* bufev ,struct evbuffer* buf)
(def-function bufferevent-write-buffer
             "bufferevent_write_buffer" (void* void*) int)

;;size_t bufferevent_read(struct bufferevent* bufev ,void* data ,size_t size)
(def-function bufferevent-read
             "bufferevent_read" (void* void* int) int)

;;int bufferevent_read_buffer(struct bufferevent* bufev ,struct evbuffer* buf)
(def-function bufferevent-read-buffer
             "bufferevent_read_buffer" (void* void*) int)

;;evbuffer* bufferevent_get_input(struct bufferevent* bufev)
(def-function bufferevent-get-input
             "bufferevent_get_input" (void*) void*)

;;evbuffer* bufferevent_get_output(struct bufferevent* bufev)
(def-function bufferevent-get-output
             "bufferevent_get_output" (void*) void*)

;;int bufferevent_enable(struct bufferevent* bufev ,short event)
(def-function bufferevent-enable
             "bufferevent_enable" (void* int) int)

;;int bufferevent_disable(struct bufferevent* bufev ,short event)
(def-function bufferevent-disable
             "bufferevent_disable" (void* int) int)

;;short bufferevent_get_enabled(struct bufferevent* bufev)
(def-function bufferevent-get-enabled
             "bufferevent_get_enabled" (void*) int)

;;int bufferevent_set_timeouts(struct bufferevent* bufev ,struct timeval* timeout_read ,struct timeval* timeout_write)
(def-function bufferevent-set-timeouts
             "bufferevent_set_timeouts" (void* void* void*) int)

;;void bufferevent_setwatermark(struct bufferevent* bufev ,short events ,size_t lowmark ,size_t highmark)
(def-function bufferevent-setwatermark
             "bufferevent_setwatermark" (void* int int int) void)

;;int bufferevent_getwatermark(struct bufferevent* bufev ,short events ,size_t* lowmark ,size_t* highmark)
(def-function bufferevent-getwatermark
             "bufferevent_getwatermark" (void* int void* void*) int)

;;void bufferevent_lock(struct bufferevent* bufev)
(def-function bufferevent-lock
             "bufferevent_lock" (void*) void)

;;void bufferevent_unlock(struct bufferevent* bufev)
(def-function bufferevent-unlock
             "bufferevent_unlock" (void*) void)

;;void bufferevent_incref(struct bufferevent* bufev)
(def-function bufferevent-incref
             "bufferevent_incref" (void*) void)

;;int bufferevent_decref(struct bufferevent* bufev)
(def-function bufferevent-decref
             "bufferevent_decref" (void*) int)

;;int bufferevent_flush(struct bufferevent* bufev ,short iotype)
(def-function bufferevent-flush
             "bufferevent_flush" (void* short) int)

;;void bufferevent_trigger(struct bufferevent* bufev ,short iotype ,int options)
(def-function bufferevent-trigger
             "bufferevent_trigger" (void* short int) void)

;;void bufferevent_trigger_event(struct bufferevent* bufev ,short what ,int options)
(def-function bufferevent-trigger-event
             "bufferevent_trigger_event" (void* short int) void)

;;bufferevent* bufferevent_filter_new(struct bufferevent* underlying ,bufferevent_filter_cb input_filter ,bufferevent_filter_cb output_filter ,int options ,void* ctx)
(def-function bufferevent-filter-new
             "bufferevent_filter_new" (void* bufferevent_filter_cb bufferevent_filter_cb int void*) void*)

;;int bufferevent_pair_new(struct event_base* base ,int options)
(def-function bufferevent-pair-new
             "bufferevent_pair_new" (void* int) int)

;;bufferevent* bufferevent_pair_get_partner(struct bufferevent* bev)
(def-function bufferevent-pair-get-partner
             "bufferevent_pair_get_partner" (void*) void*)

;;ev_token_bucket_cfg* ev_token_bucket_cfg_new(size_t read_rate ,size_t read_burst ,size_t write_rate ,size_t write_burst ,struct timeval* tick_len)
(def-function ev-token-bucket-cfg-new
             "ev_token_bucket_cfg_new" (int int int int void*) void*)

;;void ev_token_bucket_cfg_free(struct ev_token_bucket_cfg* cfg)
(def-function ev-token-bucket-cfg-free
             "ev_token_bucket_cfg_free" (void*) void)

;;int bufferevent_set_rate_limit(struct bufferevent* bev ,struct ev_token_bucket_cfg* cfg)
(def-function bufferevent-set-rate-limit
             "bufferevent_set_rate_limit" (void* void*) int)

;;bufferevent_rate_limit_group* bufferevent_rate_limit_group_new(struct event_base* base ,struct ev_token_bucket_cfg* cfg)
(def-function bufferevent-rate-limit-group-new
             "bufferevent_rate_limit_group_new" (void* void*) void*)

;;int bufferevent_rate_limit_group_set_cfg(struct bufferevent_rate_limit_group*  ,struct ev_token_bucket_cfg* )
(def-function bufferevent-rate-limit-group-set-cfg
             "bufferevent_rate_limit_group_set_cfg" (void* void*) int)

;;int bufferevent_rate_limit_group_set_min_share(struct bufferevent_rate_limit_group*  ,size_t )
(def-function bufferevent-rate-limit-group-set-min-share
             "bufferevent_rate_limit_group_set_min_share" (void* int) int)

;;void bufferevent_rate_limit_group_free(struct bufferevent_rate_limit_group* )
(def-function bufferevent-rate-limit-group-free
             "bufferevent_rate_limit_group_free" (void*) void)

;;int bufferevent_add_to_rate_limit_group(struct bufferevent* bev ,struct bufferevent_rate_limit_group* g)
(def-function bufferevent-add-to-rate-limit-group
             "bufferevent_add_to_rate_limit_group" (void* void*) int)

;;int bufferevent_remove_from_rate_limit_group(struct bufferevent* bev)
(def-function bufferevent-remove-from-rate-limit-group
             "bufferevent_remove_from_rate_limit_group" (void*) int)

;;int bufferevent_set_max_single_read(struct bufferevent* bev ,size_t size)
(def-function bufferevent-set-max-single-read
             "bufferevent_set_max_single_read" (void* int) int)

;;int bufferevent_set_max_single_write(struct bufferevent* bev ,size_t size)
(def-function bufferevent-set-max-single-write
             "bufferevent_set_max_single_write" (void* int) int)

;;ssize_t bufferevent_get_max_single_read(struct bufferevent* bev)
(def-function bufferevent-get-max-single-read
             "bufferevent_get_max_single_read" (void*) int)

;;ssize_t bufferevent_get_max_single_write(struct bufferevent* bev)
(def-function bufferevent-get-max-single-write
             "bufferevent_get_max_single_write" (void*) int)

;;ssize_t bufferevent_get_read_limit(struct bufferevent* bev)
(def-function bufferevent-get-read-limit
             "bufferevent_get_read_limit" (void*) int)

;;ssize_t bufferevent_get_write_limit(struct bufferevent* bev)
(def-function bufferevent-get-write-limit
             "bufferevent_get_write_limit" (void*) int)

;;ssize_t bufferevent_get_max_to_read(struct bufferevent* bev)
(def-function bufferevent-get-max-to-read
             "bufferevent_get_max_to_read" (void*) int)

;;ssize_t bufferevent_get_max_to_write(struct bufferevent* bev)
(def-function bufferevent-get-max-to-write
             "bufferevent_get_max_to_write" (void*) int)

;;ev_token_bucket_cfg* bufferevent_get_token_bucket_cfg(struct bufferevent* bev)
(def-function bufferevent-get-token-bucket-cfg
             "bufferevent_get_token_bucket_cfg" (void*) void*)

;;ssize_t bufferevent_rate_limit_group_get_read_limit(struct bufferevent_rate_limit_group* )
(def-function bufferevent-rate-limit-group-get-read-limit
             "bufferevent_rate_limit_group_get_read_limit" (void*) int)

;;ssize_t bufferevent_rate_limit_group_get_write_limit(struct bufferevent_rate_limit_group* )
(def-function bufferevent-rate-limit-group-get-write-limit
             "bufferevent_rate_limit_group_get_write_limit" (void*) int)

;;int bufferevent_decrement_read_limit(struct bufferevent* bev ,ssize_t decr)
(def-function bufferevent-decrement-read-limit
             "bufferevent_decrement_read_limit" (void* int) int)

;;int bufferevent_decrement_write_limit(struct bufferevent* bev ,ssize_t decr)
(def-function bufferevent-decrement-write-limit
             "bufferevent_decrement_write_limit" (void* int) int)

;;int bufferevent_rate_limit_group_decrement_read(struct bufferevent_rate_limit_group*  ,ssize_t )
(def-function bufferevent-rate-limit-group-decrement-read
             "bufferevent_rate_limit_group_decrement_read" (void* int) int)

;;int bufferevent_rate_limit_group_decrement_write(struct bufferevent_rate_limit_group*  ,ssize_t )
(def-function bufferevent-rate-limit-group-decrement-write
             "bufferevent_rate_limit_group_decrement_write" (void* int) int)

;;void bufferevent_rate_limit_group_get_totals(struct bufferevent_rate_limit_group* grp ,uint64_t* total_read_out ,uint64_t* total_written_out)
(def-function bufferevent-rate-limit-group-get-totals
             "bufferevent_rate_limit_group_get_totals" (void* void* void*) void)

;;void bufferevent_rate_limit_group_reset_totals(struct bufferevent_rate_limit_group* grp)
(def-function bufferevent-rate-limit-group-reset-totals
  "bufferevent_rate_limit_group_reset_totals" (void*) void)


;;char* evbuffer_readline(struct evbuffer* buffer)
(def-function evbuffer-readline
             "evbuffer_readline" (void*) string)

;;void evbuffer_setcb(struct evbuffer* buffer ,evbuffer_cb cb ,void* cbarg)
(def-function evbuffer-setcb
             "evbuffer_setcb" (void* void*e void*) void)

;;unsigned* evbuffer_find(struct evbuffer* buffer ,unsigned* what ,int len)
(def-function evbuffer-find
  "evbuffer_find" (void* void* int) void*)



;;evbuffer* evbuffer_new(void )
(def-function evbuffer-new
             "evbuffer_new" (void) void*)

;;void evbuffer_free(struct evbuffer* buf)
(def-function evbuffer-free
             "evbuffer_free" (void*) void)

;;int evbuffer_enable_locking(struct evbuffer* buf ,void* lock)
(def-function evbuffer-enable-locking
             "evbuffer_enable_locking" (void* void*) int)

;;void evbuffer_lock(struct evbuffer* buf)
(def-function evbuffer-lock
             "evbuffer_lock" (void*) void)

;;void evbuffer_unlock(struct evbuffer* buf)
(def-function evbuffer-unlock
             "evbuffer_unlock" (void*) void)

;;int evbuffer_set_flags(struct evbuffer* buf ,uint64_t flags)
(def-function evbuffer-set-flags
             "evbuffer_set_flags" (void* int) int)

;;int evbuffer_clear_flags(struct evbuffer* buf ,uint64_t flags)
(def-function evbuffer-clear-flags
             "evbuffer_clear_flags" (void* int) int)

;;size_t evbuffer_get_length(struct evbuffer* buf)
(def-function evbuffer-get-length
             "evbuffer_get_length" (void*) int)

;;size_t evbuffer_get_contiguous_space(struct evbuffer* buf)
(def-function evbuffer-get-contiguous-space
             "evbuffer_get_contiguous_space" (void*) int)

;;int evbuffer_expand(struct evbuffer* buf ,size_t datlen)
(def-function evbuffer-expand
             "evbuffer_expand" (void* int) int)

;;int evbuffer_reserve_space(struct evbuffer* buf ,ssize_t size ,struct iovec* vec ,int n_vec)
(def-function evbuffer-reserve-space
             "evbuffer_reserve_space" (void* int void* int) int)

;;int evbuffer_commit_space(struct evbuffer* buf ,struct iovec* vec ,int n_vecs)
(def-function evbuffer-commit-space
             "evbuffer_commit_space" (void* void* int) int)

;;int evbuffer_add(struct evbuffer* buf ,void* data ,size_t datlen)
(def-function evbuffer-add
             "evbuffer_add" (void* void* int) int)

;;int evbuffer_remove(struct evbuffer* buf ,void* data ,size_t datlen)
(def-function evbuffer-remove
             "evbuffer_remove" (void* void* int) int)

;;ssize_t evbuffer_copyout(struct evbuffer* buf ,void* data_out ,size_t datlen)
(def-function evbuffer-copyout
             "evbuffer_copyout" (void* void* int) int)

;;ssize_t evbuffer_copyout_from(struct evbuffer* buf ,struct evbuffer_ptr* pos ,void* data_out ,size_t datlen)
(def-function evbuffer-copyout-from
             "evbuffer_copyout_from" (void* void* void* int) int)

;;int evbuffer_remove_buffer(struct evbuffer* src ,struct evbuffer* dst ,size_t datlen)
(def-function evbuffer-remove-buffer
             "evbuffer_remove_buffer" (void* void* int) int)

;;char* evbuffer_readln(struct evbuffer* buffer ,size_t* n_read_out)
(def-function evbuffer-readln
             "evbuffer_readln" (void* void*) string)

;;int evbuffer_add_buffer(struct evbuffer* outbuf ,struct evbuffer* inbuf)
(def-function evbuffer-add-buffer
             "evbuffer_add_buffer" (void* void*) int)

;;int evbuffer_add_buffer_reference(struct evbuffer* outbuf ,struct evbuffer* inbuf)
(def-function evbuffer-add-buffer-reference
             "evbuffer_add_buffer_reference" (void* void*) int)

;;int evbuffer_add_reference(struct evbuffer* outbuf ,void* data ,size_t datlen ,evbuffer_ref_cleanup_cb cleanupfn ,void* cleanupfn_arg)
(def-function evbuffer-add-reference
             "evbuffer_add_reference" (void* void* int evbuffer_ref_cleanup_cb void*) int)

;;int evbuffer_add_file(struct evbuffer* outbuf ,int fd ,int64_t offset ,int64_t length)
(def-function evbuffer-add-file
             "evbuffer_add_file" (void* int int int) int)

;;evbuffer_file_segment* evbuffer_file_segment_new(int fd ,int64_t offset ,int64_t length ,unsigned flags)
(def-function evbuffer-file-segment-new
             "evbuffer_file_segment_new" (int int int int) void*)

;;void evbuffer_file_segment_free(struct evbuffer_file_segment* seg)
(def-function evbuffer-file-segment-free
             "evbuffer_file_segment_free" (void*) void)

;;void evbuffer_file_segment_add_cleanup_cb(struct evbuffer_file_segment* seg ,evbuffer_file_segment_cleanup_cb cb ,void* arg)
(def-function evbuffer-file-segment-add-cleanup-cb
             "evbuffer_file_segment_add_cleanup_cb" (void* evbuffer_file_segment_cleanup_cb void*) void)

;;int evbuffer_add_file_segment(struct evbuffer* buf ,struct evbuffer_file_segment* seg ,int64_t offset ,int64_t length)
(def-function evbuffer-add-file-segment
             "evbuffer_add_file_segment" (void* void* int int) int)

;;int evbuffer_add_printf(struct evbuffer* buf ,char* fmt)
(def-function evbuffer-add-printf
             "evbuffer_add_printf" (void* string) int)

;;int evbuffer_add_vprintf(struct evbuffer* buf ,char* fmt ,va_list ap)
(def-function evbuffer-add-vprintf
             "evbuffer_add_vprintf" (void* string va_list) int)

;;int evbuffer_drain(struct evbuffer* buf ,size_t len)
(def-function evbuffer-drain
             "evbuffer_drain" (void* int) int)

;;int evbuffer_write(struct evbuffer* buffer ,int fd)
(def-function evbuffer-write
             "evbuffer_write" (void* int) int)

;;int evbuffer_write_atmost(struct evbuffer* buffer ,int fd ,ssize_t howmuch)
(def-function evbuffer-write-atmost
             "evbuffer_write_atmost" (void* int int) int)

;;int evbuffer_read(struct evbuffer* buffer ,int fd ,int howmuch)
(def-function evbuffer-read
             "evbuffer_read" (void* int int) int)

;;evbuffer_ptr evbuffer_search(struct evbuffer* buffer ,char* what ,size_t len ,struct evbuffer_ptr* start)
(def-function evbuffer-search
             "evbuffer_search" (void* string int void*) void*)

;;evbuffer_ptr evbuffer_search_range(struct evbuffer* buffer ,char* what ,size_t len ,struct evbuffer_ptr* start ,struct evbuffer_ptr* end)
(def-function evbuffer-search-range
             "evbuffer_search_range" (void* string int void* void*) void*)

;;int evbuffer_ptr_set(struct evbuffer* buffer ,struct evbuffer_ptr* ptr ,size_t position)
(def-function evbuffer-ptr-set
             "evbuffer_ptr_set" (void* void* int) int)

;;evbuffer_ptr evbuffer_search_eol(struct evbuffer* buffer ,struct evbuffer_ptr* start ,size_t* eol_len_out)
(def-function evbuffer-search-eol
             "evbuffer_search_eol" (void* void* void*) void*)

;;int evbuffer_peek(struct evbuffer* buffer ,ssize_t len ,struct evbuffer_ptr* start_at ,struct iovec* vec_out ,int n_vec)
(def-function evbuffer-peek
             "evbuffer_peek" (void* int void* void* int) int)

;;evbuffer_cb_entry* evbuffer_add_cb(struct evbuffer* buffer ,evbuffer_cb_func cb ,void* cbarg)
(def-function evbuffer-add-cb
             "evbuffer_add_cb" (void* evbuffer_cb_func void*) void*)

;;int evbuffer_remove_cb_entry(struct evbuffer* buffer ,struct evbuffer_cb_entry* ent)
(def-function evbuffer-remove-cb-entry
             "evbuffer_remove_cb_entry" (void* void*) int)

;;int evbuffer_remove_cb(struct evbuffer* buffer ,evbuffer_cb_func cb ,void* cbarg)
(def-function evbuffer-remove-cb
             "evbuffer_remove_cb" (void* evbuffer_cb_func void*) int)

;;int evbuffer_cb_set_flags(struct evbuffer* buffer ,struct evbuffer_cb_entry* cb ,uint32_t flags)
(def-function evbuffer-cb-set-flags
             "evbuffer_cb_set_flags" (void* void* int) int)

;;int evbuffer_cb_clear_flags(struct evbuffer* buffer ,struct evbuffer_cb_entry* cb ,uint32_t flags)
(def-function evbuffer-cb-clear-flags
             "evbuffer_cb_clear_flags" (void* void* int) int)

;;unsigned* evbuffer_pullup(struct evbuffer* buf ,ssize_t size)
(def-function evbuffer-pullup
             "evbuffer_pullup" (void* int) void*)

;;int evbuffer_prepend(struct evbuffer* buf ,void* data ,size_t size)
(def-function evbuffer-prepend
             "evbuffer_prepend" (void* void* int) int)

;;int evbuffer_prepend_buffer(struct evbuffer* dst ,struct evbuffer* src)
(def-function evbuffer-prepend-buffer
             "evbuffer_prepend_buffer" (void* void*) int)

;;int evbuffer_freeze(struct evbuffer* buf ,int at_front)
(def-function evbuffer-freeze
             "evbuffer_freeze" (void* int) int)

;;int evbuffer_unfreeze(struct evbuffer* buf ,int at_front)
(def-function evbuffer-unfreeze
             "evbuffer_unfreeze" (void* int) int)

;;int evbuffer_defer_callbacks(struct evbuffer* buffer ,struct event_base* base)
(def-function evbuffer-defer-callbacks
             "evbuffer_defer_callbacks" (void* void*) int)

;;size_t evbuffer_add_iovec(struct evbuffer* buffer ,struct iovec* vec ,int n_vec)
(def-function evbuffer-add-iovec
  "evbuffer_add_iovec" (void* void* int) int)

)
