;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net event2-ffi)
  (export evutil-date-rfc1123 evutil-monotonic-timer-new
   evutil-monotonic-timer-free evutil-configure-monotonic-time
   evutil-gettime-monotonic evutil-socketpair
   evutil-make-socket-nonblocking
   evutil-make-listen-socket-reuseable
   evutil-make-listen-socket-reuseable-port
   evutil-make-socket-closeonexec evutil-closesocket
   evutil-make-tcp-listen-socket-deferred evutil-strtoll
   evutil-snprintf evutil-vsnprintf evutil-inet-ntop
   evutil-inet-pton evutil-parse-sockaddr-port
   evutil-sockaddr-cmp evutil-ascii-strcasecmp
   evutil-ascii-strncasecmp evutil-getaddrinfo
   evutil-freeaddrinfo evutil-gai-strerror
   evutil-secure-rng-get-bytes evutil-secure-rng-init
   evutil-secure-rng-set-urandom-device-file
   evutil-secure-rng-add-bytes event-enable-debug-mode
   event-debug-unassign event-base-new event-reinit
   event-base-dispatch event-base-get-method
   event-get-supported-methods event-gettime-monotonic
   event-base-get-num-events event-base-get-max-events
   event-config-new event-config-free event-config-avoid-method
   event-base-get-features event-config-require-features
   event-config-set-flag event-config-set-num-cpus-hint
   event-config-set-max-dispatch-interval
   event-base-new-with-config event-base-free
   event-base-free-nofinalize event-set-log-callback
   event-set-fatal-callback event-enable-debug-logging
   event-base-set event-base-loop event-base-loopexit
   event-base-loopbreak event-base-loopcontinue
   event-base-got-exit event-base-got-break event-self-cbarg
   event-new event-assign event-free event-finalize
   event-free-finalize event-base-once event-add
   event-remove-timer event-del event-del-noblock
   event-del-block event-active event-pending
   event-base-get-running-event event-initialized event-get-fd
   event-get-base event-get-events event-get-callback
   event-get-callback-arg event-get-priority
   event-get-assignment event-get-struct-event-size
   event-get-version event-get-version-number
   event-base-priority-init event-base-get-npriorities
   event-priority-set event-base-init-common-timeout
   event-set-mem-functions event-base-dump-events
   event-base-active-by-fd event-base-active-by-signal
   event-base-foreach-event event-base-gettimeofday-cached
   event-base-update-cache-time libevent-global-shutdown
   evconnlistener-new evconnlistener-new-bind
   evconnlistener-free evconnlistener-enable
   evconnlistener-disable evconnlistener-get-base
   evconnlistener-get-fd evconnlistener-set-cb
   evconnlistener-set-error-cb bufferevent-socket-new
   bufferevent-socket-connect
   bufferevent-socket-connect-hostname
   bufferevent-socket-get-dns-error bufferevent-base-set
   bufferevent-get-base bufferevent-priority-set
   bufferevent-get-priority bufferevent-free bufferevent-setcb
   bufferevent-getcb bufferevent-setfd bufferevent-getfd
   bufferevent-get-underlying bufferevent-write
   bufferevent-write-buffer bufferevent-read
   bufferevent-read-buffer bufferevent-get-input
   bufferevent-get-output bufferevent-enable
   bufferevent-disable bufferevent-get-enabled
   bufferevent-set-timeouts bufferevent-setwatermark
   bufferevent-getwatermark bufferevent-lock bufferevent-unlock
   bufferevent-incref bufferevent-decref bufferevent-flush
   bufferevent-trigger bufferevent-trigger-event
   bufferevent-filter-new bufferevent-pair-new
   bufferevent-pair-get-partner ev-token-bucket-cfg-new
   ev-token-bucket-cfg-free bufferevent-set-rate-limit
   bufferevent-rate-limit-group-new
   bufferevent-rate-limit-group-set-cfg
   bufferevent-rate-limit-group-set-min-share
   bufferevent-rate-limit-group-free
   bufferevent-add-to-rate-limit-group
   bufferevent-remove-from-rate-limit-group
   bufferevent-set-max-single-read
   bufferevent-set-max-single-write
   bufferevent-get-max-single-read
   bufferevent-get-max-single-write bufferevent-get-read-limit
   bufferevent-get-write-limit bufferevent-get-max-to-read
   bufferevent-get-max-to-write
   bufferevent-get-token-bucket-cfg
   bufferevent-rate-limit-group-get-read-limit
   bufferevent-rate-limit-group-get-write-limit
   bufferevent-decrement-read-limit
   bufferevent-decrement-write-limit
   bufferevent-rate-limit-group-decrement-read
   bufferevent-rate-limit-group-decrement-write
   bufferevent-rate-limit-group-get-totals
   bufferevent-rate-limit-group-reset-totals evbuffer-readline
   evbuffer-setcb evbuffer-find evbuffer-new evbuffer-free
   evbuffer-enable-locking evbuffer-lock evbuffer-unlock
   evbuffer-set-flags evbuffer-clear-flags evbuffer-get-length
   evbuffer-get-contiguous-space evbuffer-expand
   evbuffer-reserve-space evbuffer-commit-space evbuffer-add
   evbuffer-remove evbuffer-copyout evbuffer-copyout-from
   evbuffer-remove-buffer evbuffer-readln evbuffer-add-buffer
   evbuffer-add-buffer-reference evbuffer-add-reference
   evbuffer-add-file evbuffer-file-segment-new
   evbuffer-file-segment-free
   evbuffer-file-segment-add-cleanup-cb
   evbuffer-add-file-segment evbuffer-add-printf
   evbuffer-add-vprintf evbuffer-drain evbuffer-write
   evbuffer-write-atmost evbuffer-read evbuffer-search
   evbuffer-search-range evbuffer-ptr-set evbuffer-search-eol
   evbuffer-peek evbuffer-add-cb evbuffer-remove-cb-entry
   evbuffer-remove-cb evbuffer-cb-set-flags
   evbuffer-cb-clear-flags evbuffer-pullup evbuffer-prepend
   evbuffer-prepend-buffer evbuffer-freeze evbuffer-unfreeze
   evbuffer-defer-callbacks evbuffer-add-iovec)
  (import (scheme) (utils libutil) (cffi cffi))
  (load-librarys "libevent2")
  (def-function
    evutil-date-rfc1123
    "evutil_date_rfc1123"
    (string int void*)
    int)
  (def-function
    evutil-monotonic-timer-new
    "evutil_monotonic_timer_new"
    (void)
    void*)
  (def-function
    evutil-monotonic-timer-free
    "evutil_monotonic_timer_free"
    (void*)
    void)
  (def-function
    evutil-configure-monotonic-time
    "evutil_configure_monotonic_time"
    (void* int)
    int)
  (def-function
    evutil-gettime-monotonic
    "evutil_gettime_monotonic"
    (void* void*)
    int)
  (def-function
    evutil-socketpair
    "evutil_socketpair"
    (int int int void*)
    int)
  (def-function
    evutil-make-socket-nonblocking
    "evutil_make_socket_nonblocking"
    (int)
    int)
  (def-function
    evutil-make-listen-socket-reuseable
    "evutil_make_listen_socket_reuseable"
    (int)
    int)
  (def-function
    evutil-make-listen-socket-reuseable-port
    "evutil_make_listen_socket_reuseable_port"
    (int)
    int)
  (def-function
    evutil-make-socket-closeonexec
    "evutil_make_socket_closeonexec"
    (int)
    int)
  (def-function
    evutil-closesocket
    "evutil_closesocket"
    (int)
    int)
  (def-function
    evutil-make-tcp-listen-socket-deferred
    "evutil_make_tcp_listen_socket_deferred"
    (int)
    int)
  (def-function
    evutil-strtoll
    "evutil_strtoll"
    (string char int)
    int)
  (def-function
    evutil-snprintf
    "evutil_snprintf"
    (string int string)
    int)
  (def-function
    evutil-vsnprintf
    "evutil_vsnprintf"
    (string int string va_list)
    int)
  (def-function
    evutil-inet-ntop
    "evutil_inet_ntop"
    (int void* string int)
    string)
  (def-function
    evutil-inet-pton
    "evutil_inet_pton"
    (int string void*)
    int)
  (def-function
    evutil-parse-sockaddr-port
    "evutil_parse_sockaddr_port"
    (string void* void*)
    int)
  (def-function
    evutil-sockaddr-cmp
    "evutil_sockaddr_cmp"
    (void* void* int)
    int)
  (def-function
    evutil-ascii-strcasecmp
    "evutil_ascii_strcasecmp"
    (string string)
    int)
  (def-function
    evutil-ascii-strncasecmp
    "evutil_ascii_strncasecmp"
    (string string int)
    int)
  (def-function
    evutil-getaddrinfo
    "evutil_getaddrinfo"
    (string string void*)
    int)
  (def-function
    evutil-freeaddrinfo
    "evutil_freeaddrinfo"
    (void*)
    void)
  (def-function
    evutil-gai-strerror
    "evutil_gai_strerror"
    (int)
    string)
  (def-function
    evutil-secure-rng-get-bytes
    "evutil_secure_rng_get_bytes"
    (void* int)
    void)
  (def-function
    evutil-secure-rng-init
    "evutil_secure_rng_init"
    (void)
    int)
  (def-function
    evutil-secure-rng-set-urandom-device-file
    "evutil_secure_rng_set_urandom_device_file"
    (string)
    int)
  (def-function
    evutil-secure-rng-add-bytes
    "evutil_secure_rng_add_bytes"
    (string int)
    void)
  (def-function
    event-enable-debug-mode
    "event_enable_debug_mode"
    (void)
    void)
  (def-function
    event-debug-unassign
    "event_debug_unassign"
    (void*)
    void)
  (def-function event-base-new "event_base_new" (void) void*)
  (def-function event-reinit "event_reinit" (void*) int)
  (def-function
    event-base-dispatch
    "event_base_dispatch"
    (void*)
    int)
  (def-function
    event-base-get-method
    "event_base_get_method"
    (void*)
    string)
  (def-function
    event-get-supported-methods
    "event_get_supported_methods"
    (void)
    char)
  (def-function
    event-gettime-monotonic
    "event_gettime_monotonic"
    (void* void*)
    int)
  (def-function
    event-base-get-num-events
    "event_base_get_num_events"
    (void* int)
    int)
  (def-function
    event-base-get-max-events
    "event_base_get_max_events"
    (void* int int)
    int)
  (def-function
    event-config-new
    "event_config_new"
    (void)
    void*)
  (def-function
    event-config-free
    "event_config_free"
    (void*)
    void)
  (def-function
    event-config-avoid-method
    "event_config_avoid_method"
    (void* string)
    int)
  (def-function
    event-base-get-features
    "event_base_get_features"
    (void*)
    int)
  (def-function
    event-config-require-features
    "event_config_require_features"
    (void* int)
    int)
  (def-function
    event-config-set-flag
    "event_config_set_flag"
    (void* int)
    int)
  (def-function
    event-config-set-num-cpus-hint
    "event_config_set_num_cpus_hint"
    (void* int)
    int)
  (def-function
    event-config-set-max-dispatch-interval
    "event_config_set_max_dispatch_interval"
    (void* void* int int)
    int)
  (def-function
    event-base-new-with-config
    "event_base_new_with_config"
    (void*)
    void*)
  (def-function
    event-base-free
    "event_base_free"
    (void*)
    void)
  (def-function
    event-base-free-nofinalize
    "event_base_free_nofinalize"
    (void*)
    void)
  (def-function
    event-set-log-callback
    "event_set_log_callback"
    (event_log_cb)
    void)
  (def-function
    event-set-fatal-callback
    "event_set_fatal_callback"
    (void*)
    void)
  (def-function
    event-enable-debug-logging
    "event_enable_debug_logging"
    (int)
    void)
  (def-function
    event-base-set
    "event_base_set"
    (void* void*)
    int)
  (def-function
    event-base-loop
    "event_base_loop"
    (void* int)
    int)
  (def-function
    event-base-loopexit
    "event_base_loopexit"
    (void* void*)
    int)
  (def-function
    event-base-loopbreak
    "event_base_loopbreak"
    (void*)
    int)
  (def-function
    event-base-loopcontinue
    "event_base_loopcontinue"
    (void*)
    int)
  (def-function
    event-base-got-exit
    "event_base_got_exit"
    (void*)
    int)
  (def-function
    event-base-got-break
    "event_base_got_break"
    (void*)
    int)
  (def-function
    event-self-cbarg
    "event_self_cbarg"
    (void)
    void*)
  (def-function
    event-new
    "event_new"
    (void* int int void* void*)
    void*)
  (def-function
    event-assign
    "event_assign"
    (void* void* int int void* void*)
    int)
  (def-function event-free "event_free" (void*) void)
  (def-function
    event-finalize
    "event_finalize"
    (int void* void*)
    int)
  (def-function
    event-free-finalize
    "event_free_finalize"
    (int void* void*)
    int)
  (def-function
    event-base-once
    "event_base_once"
    (void* int short void* void* void*)
    int)
  (def-function event-add "event_add" (void* void*) int)
  (def-function
    event-remove-timer
    "event_remove_timer"
    (void*)
    int)
  (def-function event-del "event_del" (void*) int)
  (def-function
    event-del-noblock
    "event_del_noblock"
    (void*)
    int)
  (def-function event-del-block "event_del_block" (void*) int)
  (def-function
    event-active
    "event_active"
    (void* int short)
    void)
  (def-function
    event-pending
    "event_pending"
    (void* short void*)
    int)
  (def-function
    event-base-get-running-event
    "event_base_get_running_event"
    (void*)
    void*)
  (def-function
    event-initialized
    "event_initialized"
    (void*)
    int)
  (def-function event-get-fd "event_get_fd" (void*) int)
  (def-function event-get-base "event_get_base" (void*) void*)
  (def-function
    event-get-events
    "event_get_events"
    (void*)
    short)
  (def-function
    event-get-callback
    "event_get_callback"
    (void*)
    void*)
  (def-function
    event-get-callback-arg
    "event_get_callback_arg"
    (void*)
    void*)
  (def-function
    event-get-priority
    "event_get_priority"
    (void*)
    int)
  (def-function
    event-get-assignment
    "event_get_assignment"
    (void* void* void* void* void)
    void)
  (def-function
    event-get-struct-event-size
    "event_get_struct_event_size"
    (void)
    int)
  (def-function
    event-get-version
    "event_get_version"
    (void)
    string)
  (def-function
    event-get-version-number
    "event_get_version_number"
    (void)
    int)
  (def-function
    event-base-priority-init
    "event_base_priority_init"
    (void* int)
    int)
  (def-function
    event-base-get-npriorities
    "event_base_get_npriorities"
    (void*)
    int)
  (def-function
    event-priority-set
    "event_priority_set"
    (void* int)
    int)
  (def-function
    event-base-init-common-timeout
    "event_base_init_common_timeout"
    (void* void*)
    void*)
  (def-function
    event-set-mem-functions
    "event_set_mem_functions"
    ()
    void)
  (def-function
    event-base-dump-events
    "event_base_dump_events"
    (void* void*)
    void)
  (def-function
    event-base-active-by-fd
    "event_base_active_by_fd"
    (void* int short)
    void)
  (def-function
    event-base-active-by-signal
    "event_base_active_by_signal"
    (void* int)
    void)
  (def-function
    event-base-foreach-event
    "event_base_foreach_event"
    (void* void* void*)
    int)
  (def-function
    event-base-gettimeofday-cached
    "event_base_gettimeofday_cached"
    (void* void*)
    int)
  (def-function
    event-base-update-cache-time
    "event_base_update_cache_time"
    (void*)
    int)
  (def-function
    libevent-global-shutdown
    "libevent_global_shutdown"
    (void)
    void)
  (def-function
    evconnlistener-new
    "evconnlistener_new"
    (void* void* void* int int int)
    void*)
  (def-function
    evconnlistener-new-bind
    "evconnlistener_new_bind"
    (void* void* void* int int void* int)
    void*)
  (def-function
    evconnlistener-free
    "evconnlistener_free"
    (void*)
    void)
  (def-function
    evconnlistener-enable
    "evconnlistener_enable"
    (void*)
    int)
  (def-function
    evconnlistener-disable
    "evconnlistener_disable"
    (void*)
    int)
  (def-function
    evconnlistener-get-base
    "evconnlistener_get_base"
    (void*)
    void*)
  (def-function
    evconnlistener-get-fd
    "evconnlistener_get_fd"
    (void*)
    int)
  (def-function
    evconnlistener-set-cb
    "evconnlistener_set_cb"
    (void* void* void*)
    void)
  (def-function
    evconnlistener-set-error-cb
    "evconnlistener_set_error_cb"
    (void* void*)
    void)
  (def-function
    bufferevent-socket-new
    "bufferevent_socket_new"
    (void* int int)
    void*)
  (def-function
    bufferevent-socket-connect
    "bufferevent_socket_connect"
    (void* void* int)
    int)
  (def-function
    bufferevent-socket-connect-hostname
    "bufferevent_socket_connect_hostname"
    (void* void* int string int)
    int)
  (def-function
    bufferevent-socket-get-dns-error
    "bufferevent_socket_get_dns_error"
    (void*)
    int)
  (def-function
    bufferevent-base-set
    "bufferevent_base_set"
    (void* void*)
    int)
  (def-function
    bufferevent-get-base
    "bufferevent_get_base"
    (void*)
    void*)
  (def-function
    bufferevent-priority-set
    "bufferevent_priority_set"
    (void* int)
    int)
  (def-function
    bufferevent-get-priority
    "bufferevent_get_priority"
    (void*)
    int)
  (def-function
    bufferevent-free
    "bufferevent_free"
    (void*)
    void)
  (def-function
    bufferevent-setcb
    "bufferevent_setcb"
    (void* void* void* void* void*)
    void)
  (def-function
    bufferevent-getcb
    "bufferevent_getcb"
    (void* void* void* void* void)
    void)
  (def-function
    bufferevent-setfd
    "bufferevent_setfd"
    (void* int)
    int)
  (def-function
    bufferevent-getfd
    "bufferevent_getfd"
    (void*)
    int)
  (def-function
    bufferevent-get-underlying
    "bufferevent_get_underlying"
    (void*)
    void*)
  (def-function
    bufferevent-write
    "bufferevent_write"
    (void* void* int)
    int)
  (def-function
    bufferevent-write-buffer
    "bufferevent_write_buffer"
    (void* void*)
    int)
  (def-function
    bufferevent-read
    "bufferevent_read"
    (void* void* int)
    int)
  (def-function
    bufferevent-read-buffer
    "bufferevent_read_buffer"
    (void* void*)
    int)
  (def-function
    bufferevent-get-input
    "bufferevent_get_input"
    (void*)
    void*)
  (def-function
    bufferevent-get-output
    "bufferevent_get_output"
    (void*)
    void*)
  (def-function
    bufferevent-enable
    "bufferevent_enable"
    (void* int)
    int)
  (def-function
    bufferevent-disable
    "bufferevent_disable"
    (void* int)
    int)
  (def-function
    bufferevent-get-enabled
    "bufferevent_get_enabled"
    (void*)
    int)
  (def-function
    bufferevent-set-timeouts
    "bufferevent_set_timeouts"
    (void* void* void*)
    int)
  (def-function
    bufferevent-setwatermark
    "bufferevent_setwatermark"
    (void* int int int)
    void)
  (def-function
    bufferevent-getwatermark
    "bufferevent_getwatermark"
    (void* int void* void*)
    int)
  (def-function
    bufferevent-lock
    "bufferevent_lock"
    (void*)
    void)
  (def-function
    bufferevent-unlock
    "bufferevent_unlock"
    (void*)
    void)
  (def-function
    bufferevent-incref
    "bufferevent_incref"
    (void*)
    void)
  (def-function
    bufferevent-decref
    "bufferevent_decref"
    (void*)
    int)
  (def-function
    bufferevent-flush
    "bufferevent_flush"
    (void* short)
    int)
  (def-function
    bufferevent-trigger
    "bufferevent_trigger"
    (void* short int)
    void)
  (def-function
    bufferevent-trigger-event
    "bufferevent_trigger_event"
    (void* short int)
    void)
  (def-function
    bufferevent-filter-new
    "bufferevent_filter_new"
    (void*
      bufferevent_filter_cb
      bufferevent_filter_cb
      int
      void*)
    void*)
  (def-function
    bufferevent-pair-new
    "bufferevent_pair_new"
    (void* int)
    int)
  (def-function
    bufferevent-pair-get-partner
    "bufferevent_pair_get_partner"
    (void*)
    void*)
  (def-function
    ev-token-bucket-cfg-new
    "ev_token_bucket_cfg_new"
    (int int int int void*)
    void*)
  (def-function
    ev-token-bucket-cfg-free
    "ev_token_bucket_cfg_free"
    (void*)
    void)
  (def-function
    bufferevent-set-rate-limit
    "bufferevent_set_rate_limit"
    (void* void*)
    int)
  (def-function
    bufferevent-rate-limit-group-new
    "bufferevent_rate_limit_group_new"
    (void* void*)
    void*)
  (def-function
    bufferevent-rate-limit-group-set-cfg
    "bufferevent_rate_limit_group_set_cfg"
    (void* void*)
    int)
  (def-function
    bufferevent-rate-limit-group-set-min-share
    "bufferevent_rate_limit_group_set_min_share"
    (void* int)
    int)
  (def-function
    bufferevent-rate-limit-group-free
    "bufferevent_rate_limit_group_free"
    (void*)
    void)
  (def-function
    bufferevent-add-to-rate-limit-group
    "bufferevent_add_to_rate_limit_group"
    (void* void*)
    int)
  (def-function
    bufferevent-remove-from-rate-limit-group
    "bufferevent_remove_from_rate_limit_group"
    (void*)
    int)
  (def-function
    bufferevent-set-max-single-read
    "bufferevent_set_max_single_read"
    (void* int)
    int)
  (def-function
    bufferevent-set-max-single-write
    "bufferevent_set_max_single_write"
    (void* int)
    int)
  (def-function
    bufferevent-get-max-single-read
    "bufferevent_get_max_single_read"
    (void*)
    int)
  (def-function
    bufferevent-get-max-single-write
    "bufferevent_get_max_single_write"
    (void*)
    int)
  (def-function
    bufferevent-get-read-limit
    "bufferevent_get_read_limit"
    (void*)
    int)
  (def-function
    bufferevent-get-write-limit
    "bufferevent_get_write_limit"
    (void*)
    int)
  (def-function
    bufferevent-get-max-to-read
    "bufferevent_get_max_to_read"
    (void*)
    int)
  (def-function
    bufferevent-get-max-to-write
    "bufferevent_get_max_to_write"
    (void*)
    int)
  (def-function
    bufferevent-get-token-bucket-cfg
    "bufferevent_get_token_bucket_cfg"
    (void*)
    void*)
  (def-function
    bufferevent-rate-limit-group-get-read-limit
    "bufferevent_rate_limit_group_get_read_limit"
    (void*)
    int)
  (def-function
    bufferevent-rate-limit-group-get-write-limit
    "bufferevent_rate_limit_group_get_write_limit"
    (void*)
    int)
  (def-function
    bufferevent-decrement-read-limit
    "bufferevent_decrement_read_limit"
    (void* int)
    int)
  (def-function
    bufferevent-decrement-write-limit
    "bufferevent_decrement_write_limit"
    (void* int)
    int)
  (def-function
    bufferevent-rate-limit-group-decrement-read
    "bufferevent_rate_limit_group_decrement_read"
    (void* int)
    int)
  (def-function
    bufferevent-rate-limit-group-decrement-write
    "bufferevent_rate_limit_group_decrement_write"
    (void* int)
    int)
  (def-function
    bufferevent-rate-limit-group-get-totals
    "bufferevent_rate_limit_group_get_totals"
    (void* void* void*)
    void)
  (def-function
    bufferevent-rate-limit-group-reset-totals
    "bufferevent_rate_limit_group_reset_totals"
    (void*)
    void)
  (def-function
    evbuffer-readline
    "evbuffer_readline"
    (void*)
    string)
  (def-function
    evbuffer-setcb
    "evbuffer_setcb"
    (void* void*e void*)
    void)
  (def-function
    evbuffer-find
    "evbuffer_find"
    (void* void* int)
    void*)
  (def-function evbuffer-new "evbuffer_new" (void) void*)
  (def-function evbuffer-free "evbuffer_free" (void*) void)
  (def-function
    evbuffer-enable-locking
    "evbuffer_enable_locking"
    (void* void*)
    int)
  (def-function evbuffer-lock "evbuffer_lock" (void*) void)
  (def-function
    evbuffer-unlock
    "evbuffer_unlock"
    (void*)
    void)
  (def-function
    evbuffer-set-flags
    "evbuffer_set_flags"
    (void* int)
    int)
  (def-function
    evbuffer-clear-flags
    "evbuffer_clear_flags"
    (void* int)
    int)
  (def-function
    evbuffer-get-length
    "evbuffer_get_length"
    (void*)
    int)
  (def-function
    evbuffer-get-contiguous-space
    "evbuffer_get_contiguous_space"
    (void*)
    int)
  (def-function
    evbuffer-expand
    "evbuffer_expand"
    (void* int)
    int)
  (def-function
    evbuffer-reserve-space
    "evbuffer_reserve_space"
    (void* int void* int)
    int)
  (def-function
    evbuffer-commit-space
    "evbuffer_commit_space"
    (void* void* int)
    int)
  (def-function
    evbuffer-add
    "evbuffer_add"
    (void* void* int)
    int)
  (def-function
    evbuffer-remove
    "evbuffer_remove"
    (void* void* int)
    int)
  (def-function
    evbuffer-copyout
    "evbuffer_copyout"
    (void* void* int)
    int)
  (def-function
    evbuffer-copyout-from
    "evbuffer_copyout_from"
    (void* void* void* int)
    int)
  (def-function
    evbuffer-remove-buffer
    "evbuffer_remove_buffer"
    (void* void* int)
    int)
  (def-function
    evbuffer-readln
    "evbuffer_readln"
    (void* void*)
    string)
  (def-function
    evbuffer-add-buffer
    "evbuffer_add_buffer"
    (void* void*)
    int)
  (def-function
    evbuffer-add-buffer-reference
    "evbuffer_add_buffer_reference"
    (void* void*)
    int)
  (def-function
    evbuffer-add-reference
    "evbuffer_add_reference"
    (void* void* int evbuffer_ref_cleanup_cb void*)
    int)
  (def-function
    evbuffer-add-file
    "evbuffer_add_file"
    (void* int int int)
    int)
  (def-function
    evbuffer-file-segment-new
    "evbuffer_file_segment_new"
    (int int int int)
    void*)
  (def-function
    evbuffer-file-segment-free
    "evbuffer_file_segment_free"
    (void*)
    void)
  (def-function
    evbuffer-file-segment-add-cleanup-cb
    "evbuffer_file_segment_add_cleanup_cb"
    (void* evbuffer_file_segment_cleanup_cb void*)
    void)
  (def-function
    evbuffer-add-file-segment
    "evbuffer_add_file_segment"
    (void* void* int int)
    int)
  (def-function
    evbuffer-add-printf
    "evbuffer_add_printf"
    (void* string)
    int)
  (def-function
    evbuffer-add-vprintf
    "evbuffer_add_vprintf"
    (void* string va_list)
    int)
  (def-function
    evbuffer-drain
    "evbuffer_drain"
    (void* int)
    int)
  (def-function
    evbuffer-write
    "evbuffer_write"
    (void* int)
    int)
  (def-function
    evbuffer-write-atmost
    "evbuffer_write_atmost"
    (void* int int)
    int)
  (def-function
    evbuffer-read
    "evbuffer_read"
    (void* int int)
    int)
  (def-function
    evbuffer-search
    "evbuffer_search"
    (void* string int void*)
    void*)
  (def-function
    evbuffer-search-range
    "evbuffer_search_range"
    (void* string int void* void*)
    void*)
  (def-function
    evbuffer-ptr-set
    "evbuffer_ptr_set"
    (void* void* int)
    int)
  (def-function
    evbuffer-search-eol
    "evbuffer_search_eol"
    (void* void* void*)
    void*)
  (def-function
    evbuffer-peek
    "evbuffer_peek"
    (void* int void* void* int)
    int)
  (def-function
    evbuffer-add-cb
    "evbuffer_add_cb"
    (void* evbuffer_cb_func void*)
    void*)
  (def-function
    evbuffer-remove-cb-entry
    "evbuffer_remove_cb_entry"
    (void* void*)
    int)
  (def-function
    evbuffer-remove-cb
    "evbuffer_remove_cb"
    (void* evbuffer_cb_func void*)
    int)
  (def-function
    evbuffer-cb-set-flags
    "evbuffer_cb_set_flags"
    (void* void* int)
    int)
  (def-function
    evbuffer-cb-clear-flags
    "evbuffer_cb_clear_flags"
    (void* void* int)
    int)
  (def-function
    evbuffer-pullup
    "evbuffer_pullup"
    (void* int)
    void*)
  (def-function
    evbuffer-prepend
    "evbuffer_prepend"
    (void* void* int)
    int)
  (def-function
    evbuffer-prepend-buffer
    "evbuffer_prepend_buffer"
    (void* void*)
    int)
  (def-function
    evbuffer-freeze
    "evbuffer_freeze"
    (void* int)
    int)
  (def-function
    evbuffer-unfreeze
    "evbuffer_unfreeze"
    (void* int)
    int)
  (def-function
    evbuffer-defer-callbacks
    "evbuffer_defer_callbacks"
    (void* void*)
    int)
  (def-function
    evbuffer-add-iovec
    "evbuffer_add_iovec"
    (void* void* int)
    int))

