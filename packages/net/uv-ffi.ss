;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (net uv-ffi)
  (export pthread-barrier-init pthread-barrier-wait
   pthread-barrier-destroy uv-version uv-version-string
   uv-replace-allocator uv-default-loop uv-loop-init
   uv-loop-close uv-loop-new uv-loop-delete uv-loop-size
   uv-loop-alive uv-loop-configure uv-loop-fork uv-run uv-stop
   uv-ref uv-unref uv-has-ref uv-update-time uv-now
   uv-backend-fd uv-backend-timeout uv-translate-sys-error
   uv-strerror uv-err-name uv-shutdown uv-handle-size
   uv-handle-get-type uv-handle-type-name uv-handle-get-data
   uv-handle-get-loop uv-handle-set-data uv-req-size
   uv-req-get-data uv-req-set-data uv-req-get-type
   uv-req-type-name uv-is-active uv-walk uv-print-all-handles
   uv-print-active-handles uv-close uv-send-buffer-size
   uv-recv-buffer-size uv-fileno uv-buf-init
   uv-stream-get-write-queue-size uv-listen uv-accept
   uv-read-start uv-read-stop uv-write uv-write2 uv-try-write
   uv-is-readable uv-is-writable uv-stream-set-blocking
   uv-is-closing uv-tcp-init uv-tcp-init-ex uv-tcp-open
   uv-tcp-nodelay uv-tcp-keepalive uv-tcp-simultaneous-accepts
   uv-tcp-bind uv-tcp-getsockname uv-tcp-getpeername
   uv-tcp-connect uv-udp-init uv-udp-init-ex uv-udp-open
   uv-udp-bind uv-udp-getsockname uv-udp-set-membership
   uv-udp-set-multicast-loop uv-udp-set-multicast-ttl
   uv-udp-set-multicast-interface uv-udp-set-broadcast
   uv-udp-set-ttl uv-udp-send uv-udp-try-send uv-udp-recv-start
   uv-udp-recv-stop uv-udp-get-send-queue-size
   uv-udp-get-send-queue-count uv-tty-init uv-tty-set-mode
   uv-tty-reset-mode uv-tty-get-winsize uv-guess-handle
   uv-pipe-init uv-pipe-open uv-pipe-bind uv-pipe-connect
   uv-pipe-getsockname uv-pipe-getpeername
   uv-pipe-pending-instances uv-pipe-pending-count
   uv-pipe-pending-type uv-pipe-chmod uv-poll-init
   uv-poll-init-socket uv-poll-start uv-poll-stop
   uv-prepare-init uv-prepare-start uv-prepare-stop
   uv-check-init uv-check-start uv-check-stop uv-idle-init
   uv-idle-start uv-idle-stop uv-async-init uv-async-send
   uv-timer-init uv-timer-start uv-timer-stop uv-timer-again
   uv-timer-set-repeat uv-timer-get-repeat uv-getaddrinfo
   uv-freeaddrinfo uv-getnameinfo uv-spawn uv-process-kill
   uv-kill uv-process-get-pid uv-queue-work uv-cancel
   uv-setup-args uv-get-process-title uv-set-process-title
   uv-resident-set-memory uv-uptime uv-get-osfhandle
   uv-getrusage uv-os-homedir uv-os-tmpdir uv-os-get-passwd
   uv-os-free-passwd uv-os-getpid uv-os-getppid uv-cpu-info
   uv-free-cpu-info uv-interface-addresses
   uv-free-interface-addresses uv-os-getenv uv-os-setenv
   uv-os-unsetenv uv-os-gethostname uv-fs-get-type
   uv-fs-get-result uv-fs-get-ptr uv-fs-get-path
   uv-fs-get-statbuf uv-fs-req-cleanup uv-fs-close uv-fs-open
   uv-fs-read uv-fs-unlink uv-fs-write uv-fs-copyfile
   uv-fs-mkdir uv-fs-mkdtemp uv-fs-rmdir uv-fs-scandir
   uv-fs-scandir-next uv-fs-stat uv-fs-fstat uv-fs-rename
   uv-fs-fsync uv-fs-fdatasync uv-fs-ftruncate uv-fs-sendfile
   uv-fs-access uv-fs-chmod uv-fs-utime uv-fs-futime
   uv-fs-lstat uv-fs-link uv-fs-symlink uv-fs-readlink
   uv-fs-realpath uv-fs-fchmod uv-fs-chown uv-fs-fchown
   uv-fs-poll-init uv-fs-poll-start uv-fs-poll-stop
   uv-fs-poll-getpath uv-signal-init uv-signal-start
   uv-signal-start-oneshot uv-signal-stop uv-loadavg
   uv-fs-event-init uv-fs-event-start uv-fs-event-stop
   uv-fs-event-getpath uv-ip4-addr uv-ip6-addr uv-ip4-name
   uv-ip6-name uv-inet-ntop uv-inet-pton uv-if-indextoname
   uv-if-indextoiid uv-exepath uv-cwd uv-chdir
   uv-get-free-memory uv-get-total-memory uv-hrtime
   uv-disable-stdio-inheritance uv-dlopen uv-dlclose uv-dlsym
   uv-dlerror uv-mutex-init uv-mutex-init-recursive
   uv-mutex-destroy uv-mutex-lock uv-mutex-trylock
   uv-mutex-unlock uv-rwlock-init uv-rwlock-destroy
   uv-rwlock-rdlock uv-rwlock-tryrdlock uv-rwlock-rdunlock
   uv-rwlock-wrlock uv-rwlock-trywrlock uv-rwlock-wrunlock
   uv-sem-init uv-sem-destroy uv-sem-post uv-sem-wait
   uv-sem-trywait uv-cond-init uv-cond-destroy uv-cond-signal
   uv-cond-broadcast uv-barrier-init uv-barrier-destroy
   uv-barrier-wait uv-cond-wait uv-cond-timedwait uv-once
   uv-key-create uv-key-delete uv-key-get uv-key-set
   uv-thread-create uv-thread-self uv-thread-join
   uv-thread-equal uv-loop-get-data uv-loop-set-data)
  (import (scheme) (utils libutil) (cffi cffi))
  (load-librarys "libuv")
  (def-function
    pthread-barrier-init
    "pthread_barrier_init"
    (void* void* int)
    int)
  (def-function
    pthread-barrier-wait
    "pthread_barrier_wait"
    (void*)
    int)
  (def-function
    pthread-barrier-destroy
    "pthread_barrier_destroy"
    (void*)
    int)
  (def-function uv-version "uv_version" (void) int)
  (def-function
    uv-version-string
    "uv_version_string"
    (void)
    string)
  (def-function
    uv-replace-allocator
    "uv_replace_allocator"
    (uv_malloc_func uv_realloc_func uv_calloc_func uv_free_func)
    int)
  (def-function
    uv-default-loop
    "uv_default_loop"
    (void)
    void*)
  (def-function uv-loop-init "uv_loop_init" (void*) int)
  (def-function uv-loop-close "uv_loop_close" (void*) int)
  (def-function uv-loop-new "uv_loop_new" (void) void*)
  (def-function uv-loop-delete "uv_loop_delete" (void*) void)
  (def-function uv-loop-size "uv_loop_size" (void) int)
  (def-function uv-loop-alive "uv_loop_alive" (void*) int)
  (def-function
    uv-loop-configure
    "uv_loop_configure"
    (void* uv_loop_option)
    int)
  (def-function uv-loop-fork "uv_loop_fork" (void*) int)
  (def-function uv-run "uv_run" (void* int) int)
  (def-function uv-stop "uv_stop" (void*) void)
  (def-function uv-ref "uv_ref" (void*) void)
  (def-function uv-unref "uv_unref" (void*) void)
  (def-function uv-has-ref "uv_has_ref" (void*) int)
  (def-function uv-update-time "uv_update_time" (void*) void)
  (def-function uv-now "uv_now" (void*) int)
  (def-function uv-backend-fd "uv_backend_fd" (void*) int)
  (def-function
    uv-backend-timeout
    "uv_backend_timeout"
    (void*)
    int)
  (def-function
    uv-translate-sys-error
    "uv_translate_sys_error"
    (int)
    int)
  (def-function uv-strerror "uv_strerror" (int) string)
  (def-function uv-err-name "uv_err_name" (int) string)
  (def-function
    uv-shutdown
    "uv_shutdown"
    (void* void* uv_shutdown_cb)
    int)
  (def-function
    uv-handle-size
    "uv_handle_size"
    (uv_handle_type)
    int)
  (def-function
    uv-handle-get-type
    "uv_handle_get_type"
    (void*)
    uv_handle_type)
  (def-function
    uv-handle-type-name
    "uv_handle_type_name"
    (uv_handle_type)
    string)
  (def-function
    uv-handle-get-data
    "uv_handle_get_data"
    (void*)
    void*)
  (def-function
    uv-handle-get-loop
    "uv_handle_get_loop"
    (void*)
    void*)
  (def-function
    uv-handle-set-data
    "uv_handle_set_data"
    (void* void*)
    void)
  (def-function uv-req-size "uv_req_size" (uv_req_type) int)
  (def-function
    uv-req-get-data
    "uv_req_get_data"
    (void*)
    void*)
  (def-function
    uv-req-set-data
    "uv_req_set_data"
    (void* void*)
    void)
  (def-function
    uv-req-get-type
    "uv_req_get_type"
    (void*)
    uv_req_type)
  (def-function
    uv-req-type-name
    "uv_req_type_name"
    (uv_req_type)
    string)
  (def-function uv-is-active "uv_is_active" (void*) int)
  (def-function
    uv-walk
    "uv_walk"
    (void* uv_walk_cb void*)
    void)
  (def-function
    uv-print-all-handles
    "uv_print_all_handles"
    (void* void*)
    void)
  (def-function
    uv-print-active-handles
    "uv_print_active_handles"
    (void* void*)
    void)
  (def-function uv-close "uv_close" (void* void*) void)
  (def-function
    uv-send-buffer-size
    "uv_send_buffer_size"
    (void* void*)
    int)
  (def-function
    uv-recv-buffer-size
    "uv_recv_buffer_size"
    (void* void*)
    int)
  (def-function uv-fileno "uv_fileno" (void* void*) int)
  (def-function
    uv-buf-init
    "uv_buf_init"
    (string int)
    uv_buf_t)
  (def-function
    uv-stream-get-write-queue-size
    "uv_stream_get_write_queue_size"
    (void*)
    int)
  (def-function uv-listen "uv_listen" (void* int void*) int)
  (def-function uv-accept "uv_accept" (void* void*) int)
  (def-function
    uv-read-start
    "uv_read_start"
    (void* void* void*)
    int)
  (def-function uv-read-stop "uv_read_stop" (void*) int)
  (def-function
    uv-write
    "uv_write"
    (void* void* void* int void*)
    int)
  (def-function
    uv-write2
    "uv_write2"
    (void* void* void* int void* void*)
    int)
  (def-function
    uv-try-write
    "uv_try_write"
    (void* void* int)
    int)
  (def-function uv-is-readable "uv_is_readable" (void*) int)
  (def-function uv-is-writable "uv_is_writable" (void*) int)
  (def-function
    uv-stream-set-blocking
    "uv_stream_set_blocking"
    (void* int)
    int)
  (def-function uv-is-closing "uv_is_closing" (void*) int)
  (def-function uv-tcp-init "uv_tcp_init" (void* void*) int)
  (def-function
    uv-tcp-init-ex
    "uv_tcp_init_ex"
    (void* void* int)
    int)
  (def-function
    uv-tcp-open
    "uv_tcp_open"
    (void* uv_os_sock_t)
    int)
  (def-function
    uv-tcp-nodelay
    "uv_tcp_nodelay"
    (void* int)
    int)
  (def-function
    uv-tcp-keepalive
    "uv_tcp_keepalive"
    (void* int int)
    int)
  (def-function
    uv-tcp-simultaneous-accepts
    "uv_tcp_simultaneous_accepts"
    (void* int)
    int)
  (def-function
    uv-tcp-bind
    "uv_tcp_bind"
    (void* void* int)
    int)
  (def-function
    uv-tcp-getsockname
    "uv_tcp_getsockname"
    (void* void* void*)
    int)
  (def-function
    uv-tcp-getpeername
    "uv_tcp_getpeername"
    (void* void* void*)
    int)
  (def-function
    uv-tcp-connect
    "uv_tcp_connect"
    (void* void* void* uv_connect_cb)
    int)
  (def-function uv-udp-init "uv_udp_init" (void* void*) int)
  (def-function
    uv-udp-init-ex
    "uv_udp_init_ex"
    (void* void* int)
    int)
  (def-function
    uv-udp-open
    "uv_udp_open"
    (void* uv_os_sock_t)
    int)
  (def-function
    uv-udp-bind
    "uv_udp_bind"
    (void* void* int)
    int)
  (def-function
    uv-udp-getsockname
    "uv_udp_getsockname"
    (void* void* void*)
    int)
  (def-function
    uv-udp-set-membership
    "uv_udp_set_membership"
    (void* string string uv_membership)
    int)
  (def-function
    uv-udp-set-multicast-loop
    "uv_udp_set_multicast_loop"
    (void* int)
    int)
  (def-function
    uv-udp-set-multicast-ttl
    "uv_udp_set_multicast_ttl"
    (void* int)
    int)
  (def-function
    uv-udp-set-multicast-interface
    "uv_udp_set_multicast_interface"
    (void* string)
    int)
  (def-function
    uv-udp-set-broadcast
    "uv_udp_set_broadcast"
    (void* int)
    int)
  (def-function
    uv-udp-set-ttl
    "uv_udp_set_ttl"
    (void* int)
    int)
  (def-function
    uv-udp-send
    "uv_udp_send"
    (void* void* void* int void* uv_udp_send_cb)
    int)
  (def-function
    uv-udp-try-send
    "uv_udp_try_send"
    (void* void* int void*)
    int)
  (def-function
    uv-udp-recv-start
    "uv_udp_recv_start"
    (void* uv_alloc_cb uv_udp_recv_cb)
    int)
  (def-function
    uv-udp-recv-stop
    "uv_udp_recv_stop"
    (void*)
    int)
  (def-function
    uv-udp-get-send-queue-size
    "uv_udp_get_send_queue_size"
    (void*)
    int)
  (def-function
    uv-udp-get-send-queue-count
    "uv_udp_get_send_queue_count"
    (void*)
    int)
  (def-function
    uv-tty-init
    "uv_tty_init"
    (void* void* uv_file int)
    int)
  (def-function
    uv-tty-set-mode
    "uv_tty_set_mode"
    (void* uv_tty_mode_t)
    int)
  (def-function
    uv-tty-reset-mode
    "uv_tty_reset_mode"
    (void)
    int)
  (def-function
    uv-tty-get-winsize
    "uv_tty_get_winsize"
    (void* void* void*)
    int)
  (def-function
    uv-guess-handle
    "uv_guess_handle"
    (uv_file)
    uv_handle_type)
  (def-function
    uv-pipe-init
    "uv_pipe_init"
    (void* void* int)
    int)
  (def-function
    uv-pipe-open
    "uv_pipe_open"
    (void* uv_file)
    int)
  (def-function
    uv-pipe-bind
    "uv_pipe_bind"
    (void* string)
    int)
  (def-function
    uv-pipe-connect
    "uv_pipe_connect"
    (void* void* string uv_connect_cb)
    void)
  (def-function
    uv-pipe-getsockname
    "uv_pipe_getsockname"
    (void* string void*)
    int)
  (def-function
    uv-pipe-getpeername
    "uv_pipe_getpeername"
    (void* string void*)
    int)
  (def-function
    uv-pipe-pending-instances
    "uv_pipe_pending_instances"
    (void* int)
    void)
  (def-function
    uv-pipe-pending-count
    "uv_pipe_pending_count"
    (void*)
    int)
  (def-function
    uv-pipe-pending-type
    "uv_pipe_pending_type"
    (void*)
    uv_handle_type)
  (def-function uv-pipe-chmod "uv_pipe_chmod" (void* int) int)
  (def-function
    uv-poll-init
    "uv_poll_init"
    (void* void* int)
    int)
  (def-function
    uv-poll-init-socket
    "uv_poll_init_socket"
    (void* void* uv_os_sock_t)
    int)
  (def-function
    uv-poll-start
    "uv_poll_start"
    (void* int uv_poll_cb)
    int)
  (def-function uv-poll-stop "uv_poll_stop" (void*) int)
  (def-function
    uv-prepare-init
    "uv_prepare_init"
    (void* void*)
    int)
  (def-function
    uv-prepare-start
    "uv_prepare_start"
    (void* uv_prepare_cb)
    int)
  (def-function uv-prepare-stop "uv_prepare_stop" (void*) int)
  (def-function
    uv-check-init
    "uv_check_init"
    (void* void*)
    int)
  (def-function
    uv-check-start
    "uv_check_start"
    (void* uv_check_cb)
    int)
  (def-function uv-check-stop "uv_check_stop" (void*) int)
  (def-function uv-idle-init "uv_idle_init" (void* void*) int)
  (def-function
    uv-idle-start
    "uv_idle_start"
    (void* uv_idle_cb)
    int)
  (def-function uv-idle-stop "uv_idle_stop" (void*) int)
  (def-function
    uv-async-init
    "uv_async_init"
    (void* void* uv_async_cb)
    int)
  (def-function uv-async-send "uv_async_send" (void*) int)
  (def-function
    uv-timer-init
    "uv_timer_init"
    (void* void*)
    int)
  (def-function
    uv-timer-start
    "uv_timer_start"
    (void* uv_timer_cb int int)
    int)
  (def-function uv-timer-stop "uv_timer_stop" (void*) int)
  (def-function uv-timer-again "uv_timer_again" (void*) int)
  (def-function
    uv-timer-set-repeat
    "uv_timer_set_repeat"
    (void* int)
    void)
  (def-function
    uv-timer-get-repeat
    "uv_timer_get_repeat"
    (void*)
    int)
  (def-function
    uv-getaddrinfo
    "uv_getaddrinfo"
    (void* void* uv_getaddrinfo_cb string string void*)
    int)
  (def-function
    uv-freeaddrinfo
    "uv_freeaddrinfo"
    (void*)
    void)
  (def-function
    uv-getnameinfo
    "uv_getnameinfo"
    (void* void* uv_getnameinfo_cb void* int)
    int)
  (def-function uv-spawn "uv_spawn" (void* void* void*) int)
  (def-function
    uv-process-kill
    "uv_process_kill"
    (void* int)
    int)
  (def-function uv-kill "uv_kill" (int int) int)
  (def-function
    uv-process-get-pid
    "uv_process_get_pid"
    (void*)
    uv_pid_t)
  (def-function
    uv-queue-work
    "uv_queue_work"
    (void* void* uv_work_cb uv_after_work_cb)
    int)
  (def-function uv-cancel "uv_cancel" (void*) int)
  (def-function uv-setup-args "uv_setup_args" (int char) char)
  (def-function
    uv-get-process-title
    "uv_get_process_title"
    (string int)
    int)
  (def-function
    uv-set-process-title
    "uv_set_process_title"
    (string)
    int)
  (def-function
    uv-resident-set-memory
    "uv_resident_set_memory"
    (void*)
    int)
  (def-function uv-uptime "uv_uptime" (void*) int)
  (def-function
    uv-get-osfhandle
    "uv_get_osfhandle"
    (int)
    uv_os_fd_t)
  (def-function uv-getrusage "uv_getrusage" (void*) int)
  (def-function
    uv-os-homedir
    "uv_os_homedir"
    (string void*)
    int)
  (def-function
    uv-os-tmpdir
    "uv_os_tmpdir"
    (string void*)
    int)
  (def-function
    uv-os-get-passwd
    "uv_os_get_passwd"
    (void*)
    int)
  (def-function
    uv-os-free-passwd
    "uv_os_free_passwd"
    (void*)
    void)
  (def-function uv-os-getpid "uv_os_getpid" (void) uv_pid_t)
  (def-function uv-os-getppid "uv_os_getppid" (void) uv_pid_t)
  (def-function
    uv-cpu-info
    "uv_cpu_info"
    (uv_cpu_info_t void*)
    int)
  (def-function
    uv-free-cpu-info
    "uv_free_cpu_info"
    (void* int)
    void)
  (def-function
    uv-interface-addresses
    "uv_interface_addresses"
    (uv_interface_address_t void*)
    int)
  (def-function
    uv-free-interface-addresses
    "uv_free_interface_addresses"
    (void* int)
    void)
  (def-function
    uv-os-getenv
    "uv_os_getenv"
    (string string void*)
    int)
  (def-function
    uv-os-setenv
    "uv_os_setenv"
    (string string)
    int)
  (def-function uv-os-unsetenv "uv_os_unsetenv" (string) int)
  (def-function
    uv-os-gethostname
    "uv_os_gethostname"
    (string void*)
    int)
  (def-function
    uv-fs-get-type
    "uv_fs_get_type"
    (void*)
    uv_fs_type)
  (def-function
    uv-fs-get-result
    "uv_fs_get_result"
    (void*)
    int)
  (def-function uv-fs-get-ptr "uv_fs_get_ptr" (void*) void*)
  (def-function
    uv-fs-get-path
    "uv_fs_get_path"
    (void*)
    string)
  (def-function
    uv-fs-get-statbuf
    "uv_fs_get_statbuf"
    (void*)
    void*)
  (def-function
    uv-fs-req-cleanup
    "uv_fs_req_cleanup"
    (void*)
    void)
  (def-function
    uv-fs-close
    "uv_fs_close"
    (void* void* uv_file uv_fs_cb)
    int)
  (def-function
    uv-fs-open
    "uv_fs_open"
    (void* void* string int int uv_fs_cb)
    int)
  (def-function
    uv-fs-read
    "uv_fs_read"
    (void* void* uv_file void* int int uv_fs_cb)
    int)
  (def-function
    uv-fs-unlink
    "uv_fs_unlink"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-write
    "uv_fs_write"
    (void* void* uv_file void* int int uv_fs_cb)
    int)
  (def-function
    uv-fs-copyfile
    "uv_fs_copyfile"
    (void* void* string string int uv_fs_cb)
    int)
  (def-function
    uv-fs-mkdir
    "uv_fs_mkdir"
    (void* void* string int uv_fs_cb)
    int)
  (def-function
    uv-fs-mkdtemp
    "uv_fs_mkdtemp"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-rmdir
    "uv_fs_rmdir"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-scandir
    "uv_fs_scandir"
    (void* void* string int uv_fs_cb)
    int)
  (def-function
    uv-fs-scandir-next
    "uv_fs_scandir_next"
    (void* void*)
    int)
  (def-function
    uv-fs-stat
    "uv_fs_stat"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-fstat
    "uv_fs_fstat"
    (void* void* uv_file uv_fs_cb)
    int)
  (def-function
    uv-fs-rename
    "uv_fs_rename"
    (void* void* string string uv_fs_cb)
    int)
  (def-function
    uv-fs-fsync
    "uv_fs_fsync"
    (void* void* uv_file uv_fs_cb)
    int)
  (def-function
    uv-fs-fdatasync
    "uv_fs_fdatasync"
    (void* void* uv_file uv_fs_cb)
    int)
  (def-function
    uv-fs-ftruncate
    "uv_fs_ftruncate"
    (void* void* uv_file int uv_fs_cb)
    int)
  (def-function
    uv-fs-sendfile
    "uv_fs_sendfile"
    (void* void* uv_file uv_file int int uv_fs_cb)
    int)
  (def-function
    uv-fs-access
    "uv_fs_access"
    (void* void* string int uv_fs_cb)
    int)
  (def-function
    uv-fs-chmod
    "uv_fs_chmod"
    (void* void* string int uv_fs_cb)
    int)
  (def-function
    uv-fs-utime
    "uv_fs_utime"
    (void* void* string double double uv_fs_cb)
    int)
  (def-function
    uv-fs-futime
    "uv_fs_futime"
    (void* void* uv_file double double uv_fs_cb)
    int)
  (def-function
    uv-fs-lstat
    "uv_fs_lstat"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-link
    "uv_fs_link"
    (void* void* string string uv_fs_cb)
    int)
  (def-function
    uv-fs-symlink
    "uv_fs_symlink"
    (void* void* string string int uv_fs_cb)
    int)
  (def-function
    uv-fs-readlink
    "uv_fs_readlink"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-realpath
    "uv_fs_realpath"
    (void* void* string uv_fs_cb)
    int)
  (def-function
    uv-fs-fchmod
    "uv_fs_fchmod"
    (void* void* uv_file int uv_fs_cb)
    int)
  (def-function
    uv-fs-chown
    "uv_fs_chown"
    (void* void* string uv_uid_t uv_gid_t uv_fs_cb)
    int)
  (def-function
    uv-fs-fchown
    "uv_fs_fchown"
    (void* void* uv_file uv_uid_t uv_gid_t uv_fs_cb)
    int)
  (def-function
    uv-fs-poll-init
    "uv_fs_poll_init"
    (void* void*)
    int)
  (def-function
    uv-fs-poll-start
    "uv_fs_poll_start"
    (void* uv_fs_poll_cb string int)
    int)
  (def-function uv-fs-poll-stop "uv_fs_poll_stop" (void*) int)
  (def-function
    uv-fs-poll-getpath
    "uv_fs_poll_getpath"
    (void* string void*)
    int)
  (def-function
    uv-signal-init
    "uv_signal_init"
    (void* void*)
    int)
  (def-function
    uv-signal-start
    "uv_signal_start"
    (void* uv_signal_cb int)
    int)
  (def-function
    uv-signal-start-oneshot
    "uv_signal_start_oneshot"
    (void* uv_signal_cb int)
    int)
  (def-function uv-signal-stop "uv_signal_stop" (void*) int)
  (def-function uv-loadavg "uv_loadavg" (void*) void)
  (def-function
    uv-fs-event-init
    "uv_fs_event_init"
    (void* void*)
    int)
  (def-function
    uv-fs-event-start
    "uv_fs_event_start"
    (void* uv_fs_event_cb string int)
    int)
  (def-function
    uv-fs-event-stop
    "uv_fs_event_stop"
    (void*)
    int)
  (def-function
    uv-fs-event-getpath
    "uv_fs_event_getpath"
    (void* string void*)
    int)
  (def-function
    uv-ip4-addr
    "uv_ip4_addr"
    (string int void*)
    int)
  (def-function
    uv-ip6-addr
    "uv_ip6_addr"
    (string int void*)
    int)
  (def-function
    uv-ip4-name
    "uv_ip4_name"
    (void* string int)
    int)
  (def-function
    uv-ip6-name
    "uv_ip6_name"
    (void* string int)
    int)
  (def-function
    uv-inet-ntop
    "uv_inet_ntop"
    (int void* string int)
    int)
  (def-function
    uv-inet-pton
    "uv_inet_pton"
    (int string void*)
    int)
  (def-function
    uv-if-indextoname
    "uv_if_indextoname"
    (int string void*)
    int)
  (def-function
    uv-if-indextoiid
    "uv_if_indextoiid"
    (int string void*)
    int)
  (def-function uv-exepath "uv_exepath" (string void*) int)
  (def-function uv-cwd "uv_cwd" (string void*) int)
  (def-function uv-chdir "uv_chdir" (string) int)
  (def-function
    uv-get-free-memory
    "uv_get_free_memory"
    (void)
    int)
  (def-function
    uv-get-total-memory
    "uv_get_total_memory"
    (void)
    int)
  (def-function uv-hrtime "uv_hrtime" (void) int)
  (def-function
    uv-disable-stdio-inheritance
    "uv_disable_stdio_inheritance"
    (void)
    void)
  (def-function uv-dlopen "uv_dlopen" (string void*) int)
  (def-function uv-dlclose "uv_dlclose" (void*) void)
  (def-function uv-dlsym "uv_dlsym" (void* string void) int)
  (def-function uv-dlerror "uv_dlerror" (void*) string)
  (def-function uv-mutex-init "uv_mutex_init" (void*) int)
  (def-function
    uv-mutex-init-recursive
    "uv_mutex_init_recursive"
    (void*)
    int)
  (def-function
    uv-mutex-destroy
    "uv_mutex_destroy"
    (void*)
    void)
  (def-function uv-mutex-lock "uv_mutex_lock" (void*) void)
  (def-function
    uv-mutex-trylock
    "uv_mutex_trylock"
    (void*)
    int)
  (def-function
    uv-mutex-unlock
    "uv_mutex_unlock"
    (void*)
    void)
  (def-function uv-rwlock-init "uv_rwlock_init" (void*) int)
  (def-function
    uv-rwlock-destroy
    "uv_rwlock_destroy"
    (void*)
    void)
  (def-function
    uv-rwlock-rdlock
    "uv_rwlock_rdlock"
    (void*)
    void)
  (def-function
    uv-rwlock-tryrdlock
    "uv_rwlock_tryrdlock"
    (void*)
    int)
  (def-function
    uv-rwlock-rdunlock
    "uv_rwlock_rdunlock"
    (void*)
    void)
  (def-function
    uv-rwlock-wrlock
    "uv_rwlock_wrlock"
    (void*)
    void)
  (def-function
    uv-rwlock-trywrlock
    "uv_rwlock_trywrlock"
    (void*)
    int)
  (def-function
    uv-rwlock-wrunlock
    "uv_rwlock_wrunlock"
    (void*)
    void)
  (def-function uv-sem-init "uv_sem_init" (void* int) int)
  (def-function uv-sem-destroy "uv_sem_destroy" (void*) void)
  (def-function uv-sem-post "uv_sem_post" (void*) void)
  (def-function uv-sem-wait "uv_sem_wait" (void*) void)
  (def-function uv-sem-trywait "uv_sem_trywait" (void*) int)
  (def-function uv-cond-init "uv_cond_init" (void*) int)
  (def-function
    uv-cond-destroy
    "uv_cond_destroy"
    (void*)
    void)
  (def-function uv-cond-signal "uv_cond_signal" (void*) void)
  (def-function
    uv-cond-broadcast
    "uv_cond_broadcast"
    (void*)
    void)
  (def-function
    uv-barrier-init
    "uv_barrier_init"
    (void* int)
    int)
  (def-function
    uv-barrier-destroy
    "uv_barrier_destroy"
    (void*)
    void)
  (def-function uv-barrier-wait "uv_barrier_wait" (void*) int)
  (def-function
    uv-cond-wait
    "uv_cond_wait"
    (void* void*)
    void)
  (def-function
    uv-cond-timedwait
    "uv_cond_timedwait"
    (void* void* int)
    int)
  (def-function uv-once "uv_once" (void*) void)
  (def-function uv-key-create "uv_key_create" (void*) int)
  (def-function uv-key-delete "uv_key_delete" (void*) void)
  (def-function uv-key-get "uv_key_get" (void*) void*)
  (def-function uv-key-set "uv_key_set" (void* void*) void)
  (def-function
    uv-thread-create
    "uv_thread_create"
    (void* uv_thread_cb void*)
    int)
  (def-function
    uv-thread-self
    "uv_thread_self"
    (void)
    uv_thread_t)
  (def-function uv-thread-join "uv_thread_join" (void*) int)
  (def-function
    uv-thread-equal
    "uv_thread_equal"
    (void* void*)
    int)
  (def-function
    uv-loop-get-data
    "uv_loop_get_data"
    (void*)
    void*)
  (def-function
    uv-loop-set-data
    "uv_loop_set_data"
    (void* void*)
    void))

