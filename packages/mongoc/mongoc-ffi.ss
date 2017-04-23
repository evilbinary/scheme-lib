;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 04/22/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (mongoc mongoc-ffi ) 
  (export
  mongoc-read-prefs-new
  mongoc-read-prefs-copy
  mongoc-read-prefs-destroy
  mongoc-read-prefs-get-mode
  mongoc-read-prefs-set-mode
  mongoc-read-prefs-get-tags
  mongoc-read-prefs-set-tags
  mongoc-read-prefs-add-tag
  mongoc-read-prefs-get-max-staleness-seconds
  mongoc-read-prefs-set-max-staleness-seconds
  mongoc-read-prefs-is-valid
  mongoc-server-description-destroy
  mongoc-server-description-new-copy
  mongoc-server-description-id
  mongoc-server-description-host
  mongoc-server-description-round-trip-time
  mongoc-server-description-type
  mongoc-server-description-ismaster
  mongoc-topology-description-has-readable-server
  mongoc-topology-description-has-writable-server
  mongoc-topology-description-type
  mongoc-topology-description-get-servers
  mongoc-apm-command-started-get-command
  mongoc-apm-command-started-get-database-name
  mongoc-apm-command-started-get-command-name
  mongoc-apm-command-started-get-request-id
  mongoc-apm-command-started-get-operation-id
  mongoc-apm-command-started-get-host
  mongoc-apm-command-started-get-server-id
  mongoc-apm-command-started-get-context
  mongoc-apm-command-succeeded-get-duration
  mongoc-apm-command-succeeded-get-reply
  mongoc-apm-command-succeeded-get-command-name
  mongoc-apm-command-succeeded-get-request-id
  mongoc-apm-command-succeeded-get-operation-id
  mongoc-apm-command-succeeded-get-host
  mongoc-apm-command-succeeded-get-server-id
  mongoc-apm-command-succeeded-get-context
  mongoc-apm-command-failed-get-duration
  mongoc-apm-command-failed-get-command-name
  mongoc-apm-command-failed-get-error
  mongoc-apm-command-failed-get-request-id
  mongoc-apm-command-failed-get-operation-id
  mongoc-apm-command-failed-get-host
  mongoc-apm-command-failed-get-server-id
  mongoc-apm-command-failed-get-context
  mongoc-apm-server-changed-get-host
  mongoc-apm-server-changed-get-topology-id
  mongoc-apm-server-changed-get-previous-description
  mongoc-apm-server-changed-get-new-description
  mongoc-apm-server-changed-get-context
  mongoc-apm-server-opening-get-host
  mongoc-apm-server-opening-get-topology-id
  mongoc-apm-server-opening-get-context
  mongoc-apm-server-closed-get-host
  mongoc-apm-server-closed-get-topology-id
  mongoc-apm-server-closed-get-context
  mongoc-apm-topology-changed-get-topology-id
  mongoc-apm-topology-changed-get-previous-description
  mongoc-apm-topology-changed-get-new-description
  mongoc-apm-topology-changed-get-context
  mongoc-apm-topology-opening-get-topology-id
  mongoc-apm-topology-opening-get-context
  mongoc-apm-topology-closed-get-topology-id
  mongoc-apm-topology-closed-get-context
  mongoc-apm-server-heartbeat-started-get-host
  mongoc-apm-server-heartbeat-started-get-context
  mongoc-apm-server-heartbeat-succeeded-get-duration
  mongoc-apm-server-heartbeat-succeeded-get-reply
  mongoc-apm-server-heartbeat-succeeded-get-host
  mongoc-apm-server-heartbeat-succeeded-get-context
  mongoc-apm-server-heartbeat-failed-get-duration
  mongoc-apm-server-heartbeat-failed-get-error
  mongoc-apm-server-heartbeat-failed-get-host
  mongoc-apm-server-heartbeat-failed-get-context
  mongoc-apm-callbacks-new
  mongoc-apm-callbacks-destroy
  mongoc-apm-set-command-started-cb
  mongoc-apm-set-command-succeeded-cb
  mongoc-apm-set-command-failed-cb
  mongoc-apm-set-server-changed-cb
  mongoc-apm-set-server-opening-cb
  mongoc-apm-set-server-closed-cb
  mongoc-apm-set-topology-changed-cb
  mongoc-apm-set-topology-opening-cb
  mongoc-apm-set-topology-closed-cb
  mongoc-apm-set-server-heartbeat-started-cb
  mongoc-apm-set-server-heartbeat-succeeded-cb
  mongoc-apm-set-server-heartbeat-failed-cb
  mongoc-write-concern-new
  mongoc-write-concern-copy
  mongoc-write-concern-destroy
  mongoc-write-concern-get-fsync
  mongoc-write-concern-set-fsync
  mongoc-write-concern-get-journal
  mongoc-write-concern-journal-is-set
  mongoc-write-concern-set-journal
  mongoc-write-concern-get-w
  mongoc-write-concern-set-w
  mongoc-write-concern-get-wtag
  mongoc-write-concern-set-wtag
  mongoc-write-concern-get-wtimeout
  mongoc-write-concern-set-wtimeout
  mongoc-write-concern-get-wmajority
  mongoc-write-concern-set-wmajority
  mongoc-write-concern-is-acknowledged
  mongoc-write-concern-is-valid
  mongoc-write-concern-append
  mongoc-bulk-operation-destroy
  mongoc-bulk-operation-execute
  mongoc-bulk-operation-delete
  mongoc-bulk-operation-delete-one
  mongoc-bulk-operation-insert
  mongoc-bulk-operation-remove
  mongoc-bulk-operation-remove-many-with-opts
  mongoc-bulk-operation-remove-one
  mongoc-bulk-operation-remove-one-with-opts
  mongoc-bulk-operation-replace-one
  mongoc-bulk-operation-replace-one-with-opts
  mongoc-bulk-operation-update
  mongoc-bulk-operation-update-many-with-opts
  mongoc-bulk-operation-update-one
  mongoc-bulk-operation-update-one-with-opts
  mongoc-bulk-operation-set-bypass-document-validation
  mongoc-bulk-operation-new
  mongoc-bulk-operation-set-write-concern
  mongoc-bulk-operation-set-database
  mongoc-bulk-operation-set-collection
  mongoc-bulk-operation-set-client
  mongoc-bulk-operation-set-hint
  mongoc-bulk-operation-get-hint
  mongoc-bulk-operation-get-write-concern
  mongoc-cursor-clone
  mongoc-cursor-destroy
  mongoc-cursor-more
  mongoc-cursor-next
  mongoc-cursor-error
  mongoc-cursor-get-host
  mongoc-cursor-is-alive
  mongoc-cursor-current
  mongoc-cursor-set-batch-size
  mongoc-cursor-get-batch-size
  mongoc-cursor-set-limit
  mongoc-cursor-get-limit
  mongoc-cursor-set-hint
  mongoc-cursor-get-hint
  mongoc-cursor-get-id
  mongoc-cursor-set-max-await-time-ms
  mongoc-cursor-get-max-await-time-ms
  mongoc-cursor-new-from-command-reply
  mongoc-index-opt-get-default
  mongoc-index-opt-geo-get-default
  mongoc-index-opt-wt-get-default
  mongoc-index-opt-init
  mongoc-index-opt-geo-init
  mongoc-index-opt-wt-init
  mongoc-read-concern-new
  mongoc-read-concern-copy
  mongoc-read-concern-destroy
  mongoc-read-concern-get-level
  mongoc-read-concern-set-level
  mongoc-read-concern-append
  mongoc-find-and-modify-opts-new
  mongoc-find-and-modify-opts-set-sort
  mongoc-find-and-modify-opts-get-sort
  mongoc-find-and-modify-opts-set-update
  mongoc-find-and-modify-opts-get-update
  mongoc-find-and-modify-opts-set-fields
  mongoc-find-and-modify-opts-get-fields
  mongoc-find-and-modify-opts-set-flags
  mongoc-find-and-modify-opts-get-flags
  mongoc-find-and-modify-opts-set-bypass-document-validation
  mongoc-find-and-modify-opts-get-bypass-document-validation
  mongoc-find-and-modify-opts-set-max-time-ms
  mongoc-find-and-modify-opts-get-max-time-ms
  mongoc-find-and-modify-opts-append
  mongoc-find-and-modify-opts-get-extra
  mongoc-find-and-modify-opts-destroy
  mongoc-collection-aggregate
  mongoc-collection-destroy
  mongoc-collection-copy
  mongoc-collection-command
  mongoc-collection-read-command-with-opts
  mongoc-collection-write-command-with-opts
  mongoc-collection-read-write-command-with-opts
  mongoc-collection-command-simple
  mongoc-collection-count
  mongoc-collection-count-with-opts
  mongoc-collection-drop
  mongoc-collection-drop-with-opts
  mongoc-collection-drop-index
  mongoc-collection-drop-index-with-opts
  mongoc-collection-create-index
  mongoc-collection-create-index-with-opts
  mongoc-collection-ensure-index
  mongoc-collection-find-indexes
  mongoc-collection-find
  mongoc-collection-find-with-opts
  mongoc-collection-insert
  mongoc-collection-insert-bulk
  mongoc-collection-update
  mongoc-collection-delete
  mongoc-collection-save
  mongoc-collection-remove
  mongoc-collection-rename
  mongoc-collection-rename-with-opts
  mongoc-collection-find-and-modify-with-opts
  mongoc-collection-find-and-modify
  mongoc-collection-stats
  mongoc-collection-create-bulk-operation
  mongoc-collection-get-read-prefs
  mongoc-collection-set-read-prefs
  mongoc-collection-get-read-concern
  mongoc-collection-set-read-concern
  mongoc-collection-get-write-concern
  mongoc-collection-set-write-concern
  mongoc-collection-get-name
  mongoc-collection-get-last-error
  mongoc-collection-keys-to-index-string
  mongoc-collection-validate
  mongoc-database-get-name
  mongoc-database-remove-user
  mongoc-database-remove-all-users
  mongoc-database-add-user
  mongoc-database-destroy
  mongoc-database-copy
  mongoc-database-command
  mongoc-database-read-command-with-opts
  mongoc-database-write-command-with-opts
  mongoc-database-read-write-command-with-opts
  mongoc-database-command-simple
  mongoc-database-drop
  mongoc-database-drop-with-opts
  mongoc-database-has-collection
  mongoc-database-create-collection
  mongoc-database-get-read-prefs
  mongoc-database-set-read-prefs
  mongoc-database-get-write-concern
  mongoc-database-set-write-concern
  mongoc-database-get-read-concern
  mongoc-database-set-read-concern
  mongoc-database-find-collections
  mongoc-database-get-collection-names
  mongoc-database-get-collection
  mongoc-socket-accept
  mongoc-socket-bind
  mongoc-socket-close
  mongoc-socket-connect
  mongoc-socket-getnameinfo
  mongoc-socket-destroy
  mongoc-socket-errno
  mongoc-socket-getsockname
  mongoc-socket-listen
  mongoc-socket-new
  mongoc-socket-recv
  mongoc-socket-setsockopt
  mongoc-socket-send
  mongoc-socket-sendv
  mongoc-socket-check-closed
  mongoc-socket-inet-ntop
  mongoc-socket-poll
  mongoc-stream-get-base-stream
  mongoc-stream-get-tls-stream
  mongoc-stream-close
  mongoc-stream-destroy
  mongoc-stream-failed
  mongoc-stream-flush
  mongoc-stream-writev
  mongoc-stream-write
  mongoc-stream-readv
  mongoc-stream-read
  mongoc-stream-setsockopt
  mongoc-stream-check-closed
  mongoc-stream-poll
  mongoc-gridfs-file-get-md5
  mongoc-gridfs-file-set-md5
  mongoc-gridfs-file-get-filename
  mongoc-gridfs-file-set-filename
  mongoc-gridfs-file-get-content-type
  mongoc-gridfs-file-set-content-type
  mongoc-gridfs-file-get-aliases
  mongoc-gridfs-file-set-aliases
  mongoc-gridfs-file-get-metadata
  mongoc-gridfs-file-set-metadata
  mongoc-gridfs-file-get-id
  mongoc-gridfs-file-get-length
  mongoc-gridfs-file-get-chunk-size
  mongoc-gridfs-file-get-upload-date
  mongoc-gridfs-file-writev
  mongoc-gridfs-file-readv
  mongoc-gridfs-file-seek
  mongoc-gridfs-file-tell
  mongoc-gridfs-file-set-id
  mongoc-gridfs-file-save
  mongoc-gridfs-file-destroy
  mongoc-gridfs-file-error
  mongoc-gridfs-file-remove
  mongoc-gridfs-file-list-next
  mongoc-gridfs-file-list-destroy
  mongoc-gridfs-file-list-error
  mongoc-gridfs-create-file-from-stream
  mongoc-gridfs-create-file
  mongoc-gridfs-find
  mongoc-gridfs-find-one
  mongoc-gridfs-find-with-opts
  mongoc-gridfs-find-one-with-opts
  mongoc-gridfs-find-one-by-filename
  mongoc-gridfs-drop
  mongoc-gridfs-destroy
  mongoc-gridfs-get-files
  mongoc-gridfs-get-chunks
  mongoc-gridfs-remove-by-filename
  mongoc-ssl-opt-get-default
  mongoc-uri-copy
  mongoc-uri-destroy
  mongoc-uri-new
  mongoc-uri-new-for-host-port
  mongoc-uri-get-hosts
  mongoc-uri-get-database
  mongoc-uri-set-database
  mongoc-uri-get-options
  mongoc-uri-get-password
  mongoc-uri-set-password
  mongoc-uri-option-is-int32
  mongoc-uri-option-is-bool
  mongoc-uri-option-is-utf8
  mongoc-uri-get-option-as-int32
  mongoc-uri-get-option-as-bool
  mongoc-uri-get-option-as-utf8
  mongoc-uri-set-option-as-int32
  mongoc-uri-set-option-as-bool
  mongoc-uri-set-option-as-utf8
  mongoc-uri-get-read-prefs
  mongoc-uri-get-replica-set
  mongoc-uri-get-string
  mongoc-uri-get-username
  mongoc-uri-set-username
  mongoc-uri-get-credentials
  mongoc-uri-get-auth-source
  mongoc-uri-set-auth-source
  mongoc-uri-get-appname
  mongoc-uri-set-appname
  mongoc-uri-get-auth-mechanism
  mongoc-uri-get-mechanism-properties
  mongoc-uri-set-mechanism-properties
  mongoc-uri-get-ssl
  mongoc-uri-unescape
  mongoc-uri-get-read-prefs-t
  mongoc-uri-set-read-prefs-t
  mongoc-uri-get-write-concern
  mongoc-uri-set-write-concern
  mongoc-uri-get-read-concern
  mongoc-uri-set-read-concern
  mongoc-client-new
  mongoc-client-new-from-uri
  mongoc-client-get-uri
  mongoc-client-set-stream-initiator
  mongoc-client-command
  mongoc-client-kill-cursor
  mongoc-client-command-simple
  mongoc-client-read-command-with-opts
  mongoc-client-write-command-with-opts
  mongoc-client-read-write-command-with-opts
  mongoc-client-command-simple-with-server-id
  mongoc-client-destroy
  mongoc-client-get-database
  mongoc-client-get-default-database
  mongoc-client-get-gridfs
  mongoc-client-get-collection
  mongoc-client-get-database-names
  mongoc-client-find-databases
  mongoc-client-get-server-status
  mongoc-client-get-max-message-size
  mongoc-client-get-max-bson-size
  mongoc-client-get-write-concern
  mongoc-client-set-write-concern
  mongoc-client-get-read-concern
  mongoc-client-set-read-concern
  mongoc-client-get-read-prefs
  mongoc-client-set-read-prefs
  mongoc-client-set-ssl-opts
  mongoc-client-set-apm-callbacks
  mongoc-client-get-server-description
  mongoc-client-get-server-descriptions
  mongoc-server-descriptions-destroy-all
  mongoc-client-select-server
  mongoc-client-set-error-api
  mongoc-client-set-appname
  mongoc-client-pool-new
  mongoc-client-pool-destroy
  mongoc-client-pool-pop
  mongoc-client-pool-push
  mongoc-client-pool-try-pop
  mongoc-client-pool-max-size
  mongoc-client-pool-min-size
  mongoc-client-pool-set-ssl-opts
  mongoc-client-pool-set-apm-callbacks
  mongoc-client-pool-set-error-api
  mongoc-client-pool-set-appname
  mongoc-init
  mongoc-cleanup
  mongoc-matcher-new
  mongoc-matcher-match
  mongoc-matcher-destroy
  mongoc-handshake-data-append
  mongoc-log-set-handler
  mongoc-log
  mongoc-log-default-handler
  mongoc-log-level-str
  mongoc-log-trace-enable
  mongoc-log-trace-disable
  mongoc-stream-buffered-new
  mongoc-stream-file-new
  mongoc-stream-file-new-for-path
  mongoc-stream-file-get-fd
  mongoc-stream-gridfs-new
  mongoc-stream-socket-new
  mongoc-stream-socket-get-socket
  mongoc-get-major-version
  mongoc-get-minor-version
  mongoc-get-micro-version
  mongoc-get-version
  mongoc-check-version
  mongoc-rand-seed
  mongoc-rand-add
  mongoc-rand-status
  mongoc-stream-tls-handshake
  mongoc-stream-tls-handshake-block
  mongoc-stream-tls-do-handshake
  mongoc-stream-tls-check-cert
  mongoc-stream-tls-new-with-hostname
  mongoc-stream-tls-new)

 (import (scheme) (utils libutil) (cffi cffi) (mongoc bson-ffi ))

 (define lib-name
   (case (machine-type)
     ((arm32le) "libmongoc.so")
     ((a6nt i3nt) "libmongoc.dll")
     ((a6osx i3osx)  "libmongoc.so")
     ((a6le i3le) "libmongoc.so")))
 (define lib (load-librarys  lib-name ))




;;mongoc_read_prefs_t* mongoc_read_prefs_new(mongoc_read_mode_t read_mode)
(def-function mongoc-read-prefs-new
             "mongoc_read_prefs_new" (mongoc_read_mode_t) void*)

;;mongoc_read_prefs_t* mongoc_read_prefs_copy(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-copy
             "mongoc_read_prefs_copy" (void*) void*)

;;void mongoc_read_prefs_destroy(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-destroy
             "mongoc_read_prefs_destroy" (void*) void)

;;mongoc_read_mode_t mongoc_read_prefs_get_mode(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-get-mode
             "mongoc_read_prefs_get_mode" (void*) mongoc_read_mode_t)

;;void mongoc_read_prefs_set_mode(mongoc_read_prefs_t* read_prefs ,mongoc_read_mode_t mode)
(def-function mongoc-read-prefs-set-mode
             "mongoc_read_prefs_set_mode" (void* mongoc_read_mode_t) void)

;;bson_t* mongoc_read_prefs_get_tags(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-get-tags
             "mongoc_read_prefs_get_tags" (void*) void*)

;;void mongoc_read_prefs_set_tags(mongoc_read_prefs_t* read_prefs ,bson_t* tags)
(def-function mongoc-read-prefs-set-tags
             "mongoc_read_prefs_set_tags" (void* void*) void)

;;void mongoc_read_prefs_add_tag(mongoc_read_prefs_t* read_prefs ,bson_t* tag)
(def-function mongoc-read-prefs-add-tag
             "mongoc_read_prefs_add_tag" (void* void*) void)

;;int64_t mongoc_read_prefs_get_max_staleness_seconds(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-get-max-staleness-seconds
             "mongoc_read_prefs_get_max_staleness_seconds" (void*) int)

;;void mongoc_read_prefs_set_max_staleness_seconds(mongoc_read_prefs_t* read_prefs ,int64_t max_staleness_seconds)
(def-function mongoc-read-prefs-set-max-staleness-seconds
             "mongoc_read_prefs_set_max_staleness_seconds" (void* int) void)

;;bool mongoc_read_prefs_is_valid(mongoc_read_prefs_t* read_prefs)
(def-function mongoc-read-prefs-is-valid
             "mongoc_read_prefs_is_valid" (void*) int)

;;void mongoc_server_description_destroy(mongoc_server_description_t* description)
(def-function mongoc-server-description-destroy
             "mongoc_server_description_destroy" (void*) void)

;;mongoc_server_description_t* mongoc_server_description_new_copy(mongoc_server_description_t* description)
(def-function mongoc-server-description-new-copy
             "mongoc_server_description_new_copy" (void*) void*)

;;uint32_t mongoc_server_description_id(mongoc_server_description_t* description)
(def-function mongoc-server-description-id
             "mongoc_server_description_id" (void*) int)

;;mongoc_host_list_t* mongoc_server_description_host(mongoc_server_description_t* description)
(def-function mongoc-server-description-host
             "mongoc_server_description_host" (void*) void*)

;;int64_t mongoc_server_description_round_trip_time(mongoc_server_description_t* description)
(def-function mongoc-server-description-round-trip-time
             "mongoc_server_description_round_trip_time" (void*) int)

;;char* mongoc_server_description_type(mongoc_server_description_t* description)
(def-function mongoc-server-description-type
             "mongoc_server_description_type" (void*) string)

;;bson_t* mongoc_server_description_ismaster(mongoc_server_description_t* description)
(def-function mongoc-server-description-ismaster
             "mongoc_server_description_ismaster" (void*) void*)

;;bool mongoc_topology_description_has_readable_server(mongoc_topology_description_t* td ,mongoc_read_prefs_t* prefs)
(def-function mongoc-topology-description-has-readable-server
             "mongoc_topology_description_has_readable_server" (void* void*) int)

;;bool mongoc_topology_description_has_writable_server(mongoc_topology_description_t* td)
(def-function mongoc-topology-description-has-writable-server
             "mongoc_topology_description_has_writable_server" (void*) int)

;;char* mongoc_topology_description_type(mongoc_topology_description_t* td)
(def-function mongoc-topology-description-type
             "mongoc_topology_description_type" (void*) string)

;;mongoc_server_description_t mongoc_topology_description_get_servers(mongoc_topology_description_t* td ,size_t* n)
(def-function mongoc-topology-description-get-servers
             "mongoc_topology_description_get_servers" (void* void*) mongoc_server_description_t)

;;bson_t* mongoc_apm_command_started_get_command(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-command
             "mongoc_apm_command_started_get_command" (void*) void*)

;;char* mongoc_apm_command_started_get_database_name(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-database-name
             "mongoc_apm_command_started_get_database_name" (void*) string)

;;char* mongoc_apm_command_started_get_command_name(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-command-name
             "mongoc_apm_command_started_get_command_name" (void*) string)

;;int64_t mongoc_apm_command_started_get_request_id(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-request-id
             "mongoc_apm_command_started_get_request_id" (void*) int)

;;int64_t mongoc_apm_command_started_get_operation_id(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-operation-id
             "mongoc_apm_command_started_get_operation_id" (void*) int)

;;mongoc_host_list_t* mongoc_apm_command_started_get_host(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-host
             "mongoc_apm_command_started_get_host" (void*) void*)

;;uint32_t mongoc_apm_command_started_get_server_id(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-server-id
             "mongoc_apm_command_started_get_server_id" (void*) int)

;;void* mongoc_apm_command_started_get_context(mongoc_apm_command_started_t* event)
(def-function mongoc-apm-command-started-get-context
             "mongoc_apm_command_started_get_context" (void*) void*)

;;int64_t mongoc_apm_command_succeeded_get_duration(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-duration
             "mongoc_apm_command_succeeded_get_duration" (void*) int)

;;bson_t* mongoc_apm_command_succeeded_get_reply(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-reply
             "mongoc_apm_command_succeeded_get_reply" (void*) void*)

;;char* mongoc_apm_command_succeeded_get_command_name(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-command-name
             "mongoc_apm_command_succeeded_get_command_name" (void*) string)

;;int64_t mongoc_apm_command_succeeded_get_request_id(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-request-id
             "mongoc_apm_command_succeeded_get_request_id" (void*) int)

;;int64_t mongoc_apm_command_succeeded_get_operation_id(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-operation-id
             "mongoc_apm_command_succeeded_get_operation_id" (void*) int)

;;mongoc_host_list_t* mongoc_apm_command_succeeded_get_host(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-host
             "mongoc_apm_command_succeeded_get_host" (void*) void*)

;;uint32_t mongoc_apm_command_succeeded_get_server_id(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-server-id
             "mongoc_apm_command_succeeded_get_server_id" (void*) int)

;;void* mongoc_apm_command_succeeded_get_context(mongoc_apm_command_succeeded_t* event)
(def-function mongoc-apm-command-succeeded-get-context
             "mongoc_apm_command_succeeded_get_context" (void*) void*)

;;int64_t mongoc_apm_command_failed_get_duration(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-duration
             "mongoc_apm_command_failed_get_duration" (void*) int)

;;char* mongoc_apm_command_failed_get_command_name(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-command-name
             "mongoc_apm_command_failed_get_command_name" (void*) string)

;;void mongoc_apm_command_failed_get_error(mongoc_apm_command_failed_t* event ,bson_error_t* error)
(def-function mongoc-apm-command-failed-get-error
             "mongoc_apm_command_failed_get_error" (void* void*) void)

;;int64_t mongoc_apm_command_failed_get_request_id(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-request-id
             "mongoc_apm_command_failed_get_request_id" (void*) int)

;;int64_t mongoc_apm_command_failed_get_operation_id(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-operation-id
             "mongoc_apm_command_failed_get_operation_id" (void*) int)

;;mongoc_host_list_t* mongoc_apm_command_failed_get_host(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-host
             "mongoc_apm_command_failed_get_host" (void*) void*)

;;uint32_t mongoc_apm_command_failed_get_server_id(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-server-id
             "mongoc_apm_command_failed_get_server_id" (void*) int)

;;void* mongoc_apm_command_failed_get_context(mongoc_apm_command_failed_t* event)
(def-function mongoc-apm-command-failed-get-context
             "mongoc_apm_command_failed_get_context" (void*) void*)

;;mongoc_host_list_t* mongoc_apm_server_changed_get_host(mongoc_apm_server_changed_t* event)
(def-function mongoc-apm-server-changed-get-host
             "mongoc_apm_server_changed_get_host" (void*) void*)

;;void mongoc_apm_server_changed_get_topology_id(mongoc_apm_server_changed_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-server-changed-get-topology-id
             "mongoc_apm_server_changed_get_topology_id" (void* void*) void)

;;mongoc_server_description_t* mongoc_apm_server_changed_get_previous_description(mongoc_apm_server_changed_t* event)
(def-function mongoc-apm-server-changed-get-previous-description
             "mongoc_apm_server_changed_get_previous_description" (void*) void*)

;;mongoc_server_description_t* mongoc_apm_server_changed_get_new_description(mongoc_apm_server_changed_t* event)
(def-function mongoc-apm-server-changed-get-new-description
             "mongoc_apm_server_changed_get_new_description" (void*) void*)

;;void* mongoc_apm_server_changed_get_context(mongoc_apm_server_changed_t* event)
(def-function mongoc-apm-server-changed-get-context
             "mongoc_apm_server_changed_get_context" (void*) void*)

;;mongoc_host_list_t* mongoc_apm_server_opening_get_host(mongoc_apm_server_opening_t* event)
(def-function mongoc-apm-server-opening-get-host
             "mongoc_apm_server_opening_get_host" (void*) void*)

;;void mongoc_apm_server_opening_get_topology_id(mongoc_apm_server_opening_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-server-opening-get-topology-id
             "mongoc_apm_server_opening_get_topology_id" (void* void*) void)

;;void* mongoc_apm_server_opening_get_context(mongoc_apm_server_opening_t* event)
(def-function mongoc-apm-server-opening-get-context
             "mongoc_apm_server_opening_get_context" (void*) void*)

;;mongoc_host_list_t* mongoc_apm_server_closed_get_host(mongoc_apm_server_closed_t* event)
(def-function mongoc-apm-server-closed-get-host
             "mongoc_apm_server_closed_get_host" (void*) void*)

;;void mongoc_apm_server_closed_get_topology_id(mongoc_apm_server_closed_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-server-closed-get-topology-id
             "mongoc_apm_server_closed_get_topology_id" (void* void*) void)

;;void* mongoc_apm_server_closed_get_context(mongoc_apm_server_closed_t* event)
(def-function mongoc-apm-server-closed-get-context
             "mongoc_apm_server_closed_get_context" (void*) void*)

;;void mongoc_apm_topology_changed_get_topology_id(mongoc_apm_topology_changed_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-topology-changed-get-topology-id
             "mongoc_apm_topology_changed_get_topology_id" (void* void*) void)

;;mongoc_topology_description_t* mongoc_apm_topology_changed_get_previous_description(mongoc_apm_topology_changed_t* event)
(def-function mongoc-apm-topology-changed-get-previous-description
             "mongoc_apm_topology_changed_get_previous_description" (void*) void*)

;;mongoc_topology_description_t* mongoc_apm_topology_changed_get_new_description(mongoc_apm_topology_changed_t* event)
(def-function mongoc-apm-topology-changed-get-new-description
             "mongoc_apm_topology_changed_get_new_description" (void*) void*)

;;void* mongoc_apm_topology_changed_get_context(mongoc_apm_topology_changed_t* event)
(def-function mongoc-apm-topology-changed-get-context
             "mongoc_apm_topology_changed_get_context" (void*) void*)

;;void mongoc_apm_topology_opening_get_topology_id(mongoc_apm_topology_opening_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-topology-opening-get-topology-id
             "mongoc_apm_topology_opening_get_topology_id" (void* void*) void)

;;void* mongoc_apm_topology_opening_get_context(mongoc_apm_topology_opening_t* event)
(def-function mongoc-apm-topology-opening-get-context
             "mongoc_apm_topology_opening_get_context" (void*) void*)

;;void mongoc_apm_topology_closed_get_topology_id(mongoc_apm_topology_closed_t* event ,bson_oid_t* topology_id)
(def-function mongoc-apm-topology-closed-get-topology-id
             "mongoc_apm_topology_closed_get_topology_id" (void* void*) void)

;;void* mongoc_apm_topology_closed_get_context(mongoc_apm_topology_closed_t* event)
(def-function mongoc-apm-topology-closed-get-context
             "mongoc_apm_topology_closed_get_context" (void*) void*)

;;mongoc_host_list_t* mongoc_apm_server_heartbeat_started_get_host(mongoc_apm_server_heartbeat_started_t* event)
(def-function mongoc-apm-server-heartbeat-started-get-host
             "mongoc_apm_server_heartbeat_started_get_host" (void*) void*)

;;void* mongoc_apm_server_heartbeat_started_get_context(mongoc_apm_server_heartbeat_started_t* event)
(def-function mongoc-apm-server-heartbeat-started-get-context
             "mongoc_apm_server_heartbeat_started_get_context" (void*) void*)

;;int64_t mongoc_apm_server_heartbeat_succeeded_get_duration(mongoc_apm_server_heartbeat_succeeded_t* event)
(def-function mongoc-apm-server-heartbeat-succeeded-get-duration
             "mongoc_apm_server_heartbeat_succeeded_get_duration" (void*) int)

;;bson_t* mongoc_apm_server_heartbeat_succeeded_get_reply(mongoc_apm_server_heartbeat_succeeded_t* event)
(def-function mongoc-apm-server-heartbeat-succeeded-get-reply
             "mongoc_apm_server_heartbeat_succeeded_get_reply" (void*) void*)

;;mongoc_host_list_t* mongoc_apm_server_heartbeat_succeeded_get_host(mongoc_apm_server_heartbeat_succeeded_t* event)
(def-function mongoc-apm-server-heartbeat-succeeded-get-host
             "mongoc_apm_server_heartbeat_succeeded_get_host" (void*) void*)

;;void* mongoc_apm_server_heartbeat_succeeded_get_context(mongoc_apm_server_heartbeat_succeeded_t* event)
(def-function mongoc-apm-server-heartbeat-succeeded-get-context
             "mongoc_apm_server_heartbeat_succeeded_get_context" (void*) void*)

;;int64_t mongoc_apm_server_heartbeat_failed_get_duration(mongoc_apm_server_heartbeat_failed_t* event)
(def-function mongoc-apm-server-heartbeat-failed-get-duration
             "mongoc_apm_server_heartbeat_failed_get_duration" (void*) int)

;;void mongoc_apm_server_heartbeat_failed_get_error(mongoc_apm_server_heartbeat_failed_t* event ,bson_error_t* error)
(def-function mongoc-apm-server-heartbeat-failed-get-error
             "mongoc_apm_server_heartbeat_failed_get_error" (void* void*) void)

;;mongoc_host_list_t* mongoc_apm_server_heartbeat_failed_get_host(mongoc_apm_server_heartbeat_failed_t* event)
(def-function mongoc-apm-server-heartbeat-failed-get-host
             "mongoc_apm_server_heartbeat_failed_get_host" (void*) void*)

;;void* mongoc_apm_server_heartbeat_failed_get_context(mongoc_apm_server_heartbeat_failed_t* event)
(def-function mongoc-apm-server-heartbeat-failed-get-context
             "mongoc_apm_server_heartbeat_failed_get_context" (void*) void*)

;;mongoc_apm_callbacks_t* mongoc_apm_callbacks_new()
(def-function mongoc-apm-callbacks-new
             "mongoc_apm_callbacks_new" () void*)

;;void mongoc_apm_callbacks_destroy(mongoc_apm_callbacks_t* callbacks)
(def-function mongoc-apm-callbacks-destroy
             "mongoc_apm_callbacks_destroy" (void*) void)

;;void mongoc_apm_set_command_started_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_command_started_cb_t cb)
(def-function mongoc-apm-set-command-started-cb
             "mongoc_apm_set_command_started_cb" (void* mongoc_apm_command_started_cb_t) void)

;;void mongoc_apm_set_command_succeeded_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_command_succeeded_cb_t cb)
(def-function mongoc-apm-set-command-succeeded-cb
             "mongoc_apm_set_command_succeeded_cb" (void* mongoc_apm_command_succeeded_cb_t) void)

;;void mongoc_apm_set_command_failed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_command_failed_cb_t cb)
(def-function mongoc-apm-set-command-failed-cb
             "mongoc_apm_set_command_failed_cb" (void* mongoc_apm_command_failed_cb_t) void)

;;void mongoc_apm_set_server_changed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_changed_cb_t cb)
(def-function mongoc-apm-set-server-changed-cb
             "mongoc_apm_set_server_changed_cb" (void* mongoc_apm_server_changed_cb_t) void)

;;void mongoc_apm_set_server_opening_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_opening_cb_t cb)
(def-function mongoc-apm-set-server-opening-cb
             "mongoc_apm_set_server_opening_cb" (void* mongoc_apm_server_opening_cb_t) void)

;;void mongoc_apm_set_server_closed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_closed_cb_t cb)
(def-function mongoc-apm-set-server-closed-cb
             "mongoc_apm_set_server_closed_cb" (void* mongoc_apm_server_closed_cb_t) void)

;;void mongoc_apm_set_topology_changed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_topology_changed_cb_t cb)
(def-function mongoc-apm-set-topology-changed-cb
             "mongoc_apm_set_topology_changed_cb" (void* mongoc_apm_topology_changed_cb_t) void)

;;void mongoc_apm_set_topology_opening_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_topology_opening_cb_t cb)
(def-function mongoc-apm-set-topology-opening-cb
             "mongoc_apm_set_topology_opening_cb" (void* mongoc_apm_topology_opening_cb_t) void)

;;void mongoc_apm_set_topology_closed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_topology_closed_cb_t cb)
(def-function mongoc-apm-set-topology-closed-cb
             "mongoc_apm_set_topology_closed_cb" (void* mongoc_apm_topology_closed_cb_t) void)

;;void mongoc_apm_set_server_heartbeat_started_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_heartbeat_started_cb_t cb)
(def-function mongoc-apm-set-server-heartbeat-started-cb
             "mongoc_apm_set_server_heartbeat_started_cb" (void* mongoc_apm_server_heartbeat_started_cb_t) void)

;;void mongoc_apm_set_server_heartbeat_succeeded_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_heartbeat_succeeded_cb_t cb)
(def-function mongoc-apm-set-server-heartbeat-succeeded-cb
             "mongoc_apm_set_server_heartbeat_succeeded_cb" (void* mongoc_apm_server_heartbeat_succeeded_cb_t) void)

;;void mongoc_apm_set_server_heartbeat_failed_cb(mongoc_apm_callbacks_t* callbacks ,mongoc_apm_server_heartbeat_failed_cb_t cb)
(def-function mongoc-apm-set-server-heartbeat-failed-cb
             "mongoc_apm_set_server_heartbeat_failed_cb" (void* mongoc_apm_server_heartbeat_failed_cb_t) void)

;;mongoc_write_concern_t* mongoc_write_concern_new()
(def-function mongoc-write-concern-new
             "mongoc_write_concern_new" () void*)

;;mongoc_write_concern_t* mongoc_write_concern_copy(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-copy
             "mongoc_write_concern_copy" (void*) void*)

;;void mongoc_write_concern_destroy(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-destroy
             "mongoc_write_concern_destroy" (void*) void)

;;bool mongoc_write_concern_get_fsync(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-fsync
             "mongoc_write_concern_get_fsync" (void*) int)

;;void mongoc_write_concern_set_fsync(mongoc_write_concern_t* write_concern ,bool fsync_)
(def-function mongoc-write-concern-set-fsync
             "mongoc_write_concern_set_fsync" (void* int) void)

;;bool mongoc_write_concern_get_journal(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-journal
             "mongoc_write_concern_get_journal" (void*) int)

;;bool mongoc_write_concern_journal_is_set(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-journal-is-set
             "mongoc_write_concern_journal_is_set" (void*) int)

;;void mongoc_write_concern_set_journal(mongoc_write_concern_t* write_concern ,bool journal)
(def-function mongoc-write-concern-set-journal
             "mongoc_write_concern_set_journal" (void* int) void)

;;int32_t mongoc_write_concern_get_w(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-w
             "mongoc_write_concern_get_w" (void*) int)

;;void mongoc_write_concern_set_w(mongoc_write_concern_t* write_concern ,int32_t w)
(def-function mongoc-write-concern-set-w
             "mongoc_write_concern_set_w" (void* int) void)

;;char* mongoc_write_concern_get_wtag(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-wtag
             "mongoc_write_concern_get_wtag" (void*) string)

;;void mongoc_write_concern_set_wtag(mongoc_write_concern_t* write_concern ,char* tag)
(def-function mongoc-write-concern-set-wtag
             "mongoc_write_concern_set_wtag" (void* string) void)

;;int32_t mongoc_write_concern_get_wtimeout(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-wtimeout
             "mongoc_write_concern_get_wtimeout" (void*) int)

;;void mongoc_write_concern_set_wtimeout(mongoc_write_concern_t* write_concern ,int32_t wtimeout_msec)
(def-function mongoc-write-concern-set-wtimeout
             "mongoc_write_concern_set_wtimeout" (void* int) void)

;;bool mongoc_write_concern_get_wmajority(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-get-wmajority
             "mongoc_write_concern_get_wmajority" (void*) int)

;;void mongoc_write_concern_set_wmajority(mongoc_write_concern_t* write_concern ,int32_t wtimeout_msec)
(def-function mongoc-write-concern-set-wmajority
             "mongoc_write_concern_set_wmajority" (void* int) void)

;;bool mongoc_write_concern_is_acknowledged(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-is-acknowledged
             "mongoc_write_concern_is_acknowledged" (void*) int)

;;bool mongoc_write_concern_is_valid(mongoc_write_concern_t* write_concern)
(def-function mongoc-write-concern-is-valid
             "mongoc_write_concern_is_valid" (void*) int)

;;bool mongoc_write_concern_append(mongoc_write_concern_t* write_concern ,bson_t* doc)
(def-function mongoc-write-concern-append
             "mongoc_write_concern_append" (void* void*) int)

;;void mongoc_bulk_operation_destroy(mongoc_bulk_operation_t* bulk)
(def-function mongoc-bulk-operation-destroy
             "mongoc_bulk_operation_destroy" (void*) void)

;;uint32_t mongoc_bulk_operation_execute(mongoc_bulk_operation_t* bulk ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-bulk-operation-execute
             "mongoc_bulk_operation_execute" (void* void* void*) int)

;;void mongoc_bulk_operation_delete(mongoc_bulk_operation_t* bulk ,bson_t* selector)
(def-function mongoc-bulk-operation-delete
             "mongoc_bulk_operation_delete" (void* void*) void)

;;void mongoc_bulk_operation_delete_one(mongoc_bulk_operation_t* bulk ,bson_t* selector)
(def-function mongoc-bulk-operation-delete-one
             "mongoc_bulk_operation_delete_one" (void* void*) void)

;;void mongoc_bulk_operation_insert(mongoc_bulk_operation_t* bulk ,bson_t* document)
(def-function mongoc-bulk-operation-insert
             "mongoc_bulk_operation_insert" (void* void*) void)

;;void mongoc_bulk_operation_remove(mongoc_bulk_operation_t* bulk ,bson_t* selector)
(def-function mongoc-bulk-operation-remove
             "mongoc_bulk_operation_remove" (void* void*) void)

;;bool mongoc_bulk_operation_remove_many_with_opts(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-bulk-operation-remove-many-with-opts
             "mongoc_bulk_operation_remove_many_with_opts" (void* void* void* void*) int)

;;void mongoc_bulk_operation_remove_one(mongoc_bulk_operation_t* bulk ,bson_t* selector)
(def-function mongoc-bulk-operation-remove-one
             "mongoc_bulk_operation_remove_one" (void* void*) void)

;;bool mongoc_bulk_operation_remove_one_with_opts(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-bulk-operation-remove-one-with-opts
             "mongoc_bulk_operation_remove_one_with_opts" (void* void* void* void*) int)

;;void mongoc_bulk_operation_replace_one(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bool upsert)
(def-function mongoc-bulk-operation-replace-one
             "mongoc_bulk_operation_replace_one" (void* void* void* int) void)

;;bool mongoc_bulk_operation_replace_one_with_opts(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-bulk-operation-replace-one-with-opts
             "mongoc_bulk_operation_replace_one_with_opts" (void* void* void* void* void*) int)

;;void mongoc_bulk_operation_update(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bool upsert)
(def-function mongoc-bulk-operation-update
             "mongoc_bulk_operation_update" (void* void* void* int) void)

;;bool mongoc_bulk_operation_update_many_with_opts(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-bulk-operation-update-many-with-opts
             "mongoc_bulk_operation_update_many_with_opts" (void* void* void* void* void*) int)

;;void mongoc_bulk_operation_update_one(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bool upsert)
(def-function mongoc-bulk-operation-update-one
             "mongoc_bulk_operation_update_one" (void* void* void* int) void)

;;bool mongoc_bulk_operation_update_one_with_opts(mongoc_bulk_operation_t* bulk ,bson_t* selector ,bson_t* document ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-bulk-operation-update-one-with-opts
             "mongoc_bulk_operation_update_one_with_opts" (void* void* void* void* void*) int)

;;void mongoc_bulk_operation_set_bypass_document_validation(mongoc_bulk_operation_t* bulk ,bool bypass)
(def-function mongoc-bulk-operation-set-bypass-document-validation
             "mongoc_bulk_operation_set_bypass_document_validation" (void* int) void)

;;mongoc_bulk_operation_t* mongoc_bulk_operation_new(bool ordered)
(def-function mongoc-bulk-operation-new
             "mongoc_bulk_operation_new" (int) void*)

;;void mongoc_bulk_operation_set_write_concern(mongoc_bulk_operation_t* bulk ,mongoc_write_concern_t* write_concern)
(def-function mongoc-bulk-operation-set-write-concern
             "mongoc_bulk_operation_set_write_concern" (void* void*) void)

;;void mongoc_bulk_operation_set_database(mongoc_bulk_operation_t* bulk ,char* database)
(def-function mongoc-bulk-operation-set-database
             "mongoc_bulk_operation_set_database" (void* string) void)

;;void mongoc_bulk_operation_set_collection(mongoc_bulk_operation_t* bulk ,char* collection)
(def-function mongoc-bulk-operation-set-collection
             "mongoc_bulk_operation_set_collection" (void* string) void)

;;void mongoc_bulk_operation_set_client(mongoc_bulk_operation_t* bulk ,void* client)
(def-function mongoc-bulk-operation-set-client
             "mongoc_bulk_operation_set_client" (void* void*) void)

;;void mongoc_bulk_operation_set_hint(mongoc_bulk_operation_t* bulk ,uint32_t server_id)
(def-function mongoc-bulk-operation-set-hint
             "mongoc_bulk_operation_set_hint" (void* int) void)

;;uint32_t mongoc_bulk_operation_get_hint(mongoc_bulk_operation_t* bulk)
(def-function mongoc-bulk-operation-get-hint
             "mongoc_bulk_operation_get_hint" (void*) int)

;;mongoc_write_concern_t* mongoc_bulk_operation_get_write_concern(mongoc_bulk_operation_t* bulk)
(def-function mongoc-bulk-operation-get-write-concern
             "mongoc_bulk_operation_get_write_concern" (void*) void*)

;;mongoc_cursor_t* mongoc_cursor_clone(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-clone
             "mongoc_cursor_clone" (void*) void*)

;;void mongoc_cursor_destroy(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-destroy
             "mongoc_cursor_destroy" (void*) void)

;;bool mongoc_cursor_more(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-more
             "mongoc_cursor_more" (void*) int)

;;bool mongoc_cursor_next(mongoc_cursor_t* cursor ,bson_t** bson)
(def-function mongoc-cursor-next
             "mongoc_cursor_next" (void* void*) int)

;;bool mongoc_cursor_error(mongoc_cursor_t* cursor ,bson_error_t* error)
(def-function mongoc-cursor-error
             "mongoc_cursor_error" (void* void*) int)

;;void mongoc_cursor_get_host(mongoc_cursor_t* cursor ,mongoc_host_list_t* host)
(def-function mongoc-cursor-get-host
             "mongoc_cursor_get_host" (void* void*) void)

;;bool mongoc_cursor_is_alive(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-is-alive
             "mongoc_cursor_is_alive" (void*) int)

;;bson_t* mongoc_cursor_current(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-current
             "mongoc_cursor_current" (void*) void*)

;;void mongoc_cursor_set_batch_size(mongoc_cursor_t* cursor ,uint32_t batch_size)
(def-function mongoc-cursor-set-batch-size
             "mongoc_cursor_set_batch_size" (void* int) void)

;;uint32_t mongoc_cursor_get_batch_size(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-get-batch-size
             "mongoc_cursor_get_batch_size" (void*) int)

;;bool mongoc_cursor_set_limit(mongoc_cursor_t* cursor ,int64_t limit)
(def-function mongoc-cursor-set-limit
             "mongoc_cursor_set_limit" (void* int) int)

;;int64_t mongoc_cursor_get_limit(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-get-limit
             "mongoc_cursor_get_limit" (void*) int)

;;bool mongoc_cursor_set_hint(mongoc_cursor_t* cursor ,uint32_t server_id)
(def-function mongoc-cursor-set-hint
             "mongoc_cursor_set_hint" (void* int) int)

;;uint32_t mongoc_cursor_get_hint(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-get-hint
             "mongoc_cursor_get_hint" (void*) int)

;;int64_t mongoc_cursor_get_id(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-get-id
             "mongoc_cursor_get_id" (void*) int)

;;void mongoc_cursor_set_max_await_time_ms(mongoc_cursor_t* cursor ,uint32_t max_await_time_ms)
(def-function mongoc-cursor-set-max-await-time-ms
             "mongoc_cursor_set_max_await_time_ms" (void* int) void)

;;uint32_t mongoc_cursor_get_max_await_time_ms(mongoc_cursor_t* cursor)
(def-function mongoc-cursor-get-max-await-time-ms
             "mongoc_cursor_get_max_await_time_ms" (void*) int)

;;mongoc_cursor_t* mongoc_cursor_new_from_command_reply(_mongoc_client_t client ,bson_t* reply ,uint32_t server_id)
(def-function mongoc-cursor-new-from-command-reply
             "mongoc_cursor_new_from_command_reply" (_mongoc_client_t void* int) void*)

;;mongoc_index_opt_t* mongoc_index_opt_get_default()
(def-function mongoc-index-opt-get-default
             "mongoc_index_opt_get_default" () void*)

;;mongoc_index_opt_geo_t* mongoc_index_opt_geo_get_default()
(def-function mongoc-index-opt-geo-get-default
             "mongoc_index_opt_geo_get_default" () void*)

;;mongoc_index_opt_wt_t* mongoc_index_opt_wt_get_default()
(def-function mongoc-index-opt-wt-get-default
             "mongoc_index_opt_wt_get_default" () void*)

;;void mongoc_index_opt_init(mongoc_index_opt_t* opt)
(def-function mongoc-index-opt-init
             "mongoc_index_opt_init" (void*) void)

;;void mongoc_index_opt_geo_init(mongoc_index_opt_geo_t* opt)
(def-function mongoc-index-opt-geo-init
             "mongoc_index_opt_geo_init" (void*) void)

;;void mongoc_index_opt_wt_init(mongoc_index_opt_wt_t* opt)
(def-function mongoc-index-opt-wt-init
             "mongoc_index_opt_wt_init" (void*) void)

;;mongoc_read_concern_t* mongoc_read_concern_new()
(def-function mongoc-read-concern-new
             "mongoc_read_concern_new" () void*)

;;mongoc_read_concern_t* mongoc_read_concern_copy(mongoc_read_concern_t* read_concern)
(def-function mongoc-read-concern-copy
             "mongoc_read_concern_copy" (void*) void*)

;;void mongoc_read_concern_destroy(mongoc_read_concern_t* read_concern)
(def-function mongoc-read-concern-destroy
             "mongoc_read_concern_destroy" (void*) void)

;;char* mongoc_read_concern_get_level(mongoc_read_concern_t* read_concern)
(def-function mongoc-read-concern-get-level
             "mongoc_read_concern_get_level" (void*) string)

;;bool mongoc_read_concern_set_level(mongoc_read_concern_t* read_concern ,char* level)
(def-function mongoc-read-concern-set-level
             "mongoc_read_concern_set_level" (void* string) int)

;;bool mongoc_read_concern_append(mongoc_read_concern_t* read_concern ,bson_t* doc)
(def-function mongoc-read-concern-append
             "mongoc_read_concern_append" (void* void*) int)

;;mongoc_find_and_modify_opts_t* mongoc_find_and_modify_opts_new()
(def-function mongoc-find-and-modify-opts-new
             "mongoc_find_and_modify_opts_new" () void*)

;;bool mongoc_find_and_modify_opts_set_sort(mongoc_find_and_modify_opts_t* opts ,bson_t* sort)
(def-function mongoc-find-and-modify-opts-set-sort
             "mongoc_find_and_modify_opts_set_sort" (void* void*) int)

;;void mongoc_find_and_modify_opts_get_sort(mongoc_find_and_modify_opts_t* opts ,bson_t* sort)
(def-function mongoc-find-and-modify-opts-get-sort
             "mongoc_find_and_modify_opts_get_sort" (void* void*) void)

;;bool mongoc_find_and_modify_opts_set_update(mongoc_find_and_modify_opts_t* opts ,bson_t* update)
(def-function mongoc-find-and-modify-opts-set-update
             "mongoc_find_and_modify_opts_set_update" (void* void*) int)

;;void mongoc_find_and_modify_opts_get_update(mongoc_find_and_modify_opts_t* opts ,bson_t* update)
(def-function mongoc-find-and-modify-opts-get-update
             "mongoc_find_and_modify_opts_get_update" (void* void*) void)

;;bool mongoc_find_and_modify_opts_set_fields(mongoc_find_and_modify_opts_t* opts ,bson_t* fields)
(def-function mongoc-find-and-modify-opts-set-fields
             "mongoc_find_and_modify_opts_set_fields" (void* void*) int)

;;void mongoc_find_and_modify_opts_get_fields(mongoc_find_and_modify_opts_t* opts ,bson_t* fields)
(def-function mongoc-find-and-modify-opts-get-fields
             "mongoc_find_and_modify_opts_get_fields" (void* void*) void)

;;bool mongoc_find_and_modify_opts_set_flags(mongoc_find_and_modify_opts_t* opts ,mongoc_find_and_modify_flags_t flags)
(def-function mongoc-find-and-modify-opts-set-flags
             "mongoc_find_and_modify_opts_set_flags" (void* mongoc_find_and_modify_flags_t) int)

;;mongoc_find_and_modify_flags_t mongoc_find_and_modify_opts_get_flags(mongoc_find_and_modify_opts_t* opts)
(def-function mongoc-find-and-modify-opts-get-flags
             "mongoc_find_and_modify_opts_get_flags" (void*) mongoc_find_and_modify_flags_t)

;;bool mongoc_find_and_modify_opts_set_bypass_document_validation(mongoc_find_and_modify_opts_t* opts ,bool bypass)
(def-function mongoc-find-and-modify-opts-set-bypass-document-validation
             "mongoc_find_and_modify_opts_set_bypass_document_validation" (void* int) int)

;;bool mongoc_find_and_modify_opts_get_bypass_document_validation(mongoc_find_and_modify_opts_t* opts)
(def-function mongoc-find-and-modify-opts-get-bypass-document-validation
             "mongoc_find_and_modify_opts_get_bypass_document_validation" (void*) int)

;;bool mongoc_find_and_modify_opts_set_max_time_ms(mongoc_find_and_modify_opts_t* opts ,uint32_t max_time_ms)
(def-function mongoc-find-and-modify-opts-set-max-time-ms
             "mongoc_find_and_modify_opts_set_max_time_ms" (void* int) int)

;;uint32_t mongoc_find_and_modify_opts_get_max_time_ms(mongoc_find_and_modify_opts_t* opts)
(def-function mongoc-find-and-modify-opts-get-max-time-ms
             "mongoc_find_and_modify_opts_get_max_time_ms" (void*) int)

;;bool mongoc_find_and_modify_opts_append(mongoc_find_and_modify_opts_t* opts ,bson_t* extra)
(def-function mongoc-find-and-modify-opts-append
             "mongoc_find_and_modify_opts_append" (void* void*) int)

;;void mongoc_find_and_modify_opts_get_extra(mongoc_find_and_modify_opts_t* opts ,bson_t* extra)
(def-function mongoc-find-and-modify-opts-get-extra
             "mongoc_find_and_modify_opts_get_extra" (void* void*) void)

;;void mongoc_find_and_modify_opts_destroy(mongoc_find_and_modify_opts_t* opts)
(def-function mongoc-find-and-modify-opts-destroy
             "mongoc_find_and_modify_opts_destroy" (void*) void)

;;mongoc_cursor_t* mongoc_collection_aggregate(mongoc_collection_t* collection ,mongoc_query_flags_t flags ,bson_t* pipeline ,bson_t* opts ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-collection-aggregate
             "mongoc_collection_aggregate" (void* mongoc_query_flags_t void* void* void*) void*)

;;void mongoc_collection_destroy(mongoc_collection_t* collection)
(def-function mongoc-collection-destroy
             "mongoc_collection_destroy" (void*) void)

;;mongoc_collection_t* mongoc_collection_copy(mongoc_collection_t* collection)
(def-function mongoc-collection-copy
             "mongoc_collection_copy" (void*) void*)

;;mongoc_cursor_t* mongoc_collection_command(mongoc_collection_t* collection ,mongoc_query_flags_t flags ,uint32_t skip ,uint32_t limit ,uint32_t batch_size ,bson_t* command ,bson_t* fields ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-collection-command
             "mongoc_collection_command" (void* mongoc_query_flags_t int int int void* void* void*) void*)

;;bool mongoc_collection_read_command_with_opts(mongoc_collection_t* collection ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-read-command-with-opts
             "mongoc_collection_read_command_with_opts" (void* void* void* void* void* void*) int)

;;bool mongoc_collection_write_command_with_opts(mongoc_collection_t* collection ,bson_t* command ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-write-command-with-opts
             "mongoc_collection_write_command_with_opts" (void* void* void* void* void*) int)

;;bool mongoc_collection_read_write_command_with_opts(mongoc_collection_t* collection ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-read-write-command-with-opts
             "mongoc_collection_read_write_command_with_opts" (void* void* void* void* void* void*) int)

;;bool mongoc_collection_command_simple(mongoc_collection_t* collection ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-command-simple
             "mongoc_collection_command_simple" (void* void* void* void* void*) int)

;;int64_t mongoc_collection_count(mongoc_collection_t* collection ,mongoc_query_flags_t flags ,bson_t* query ,int64_t skip ,int64_t limit ,mongoc_read_prefs_t* read_prefs ,bson_error_t* error)
(def-function mongoc-collection-count
             "mongoc_collection_count" (void* mongoc_query_flags_t void* int int void* void*) int)

;;int64_t mongoc_collection_count_with_opts(mongoc_collection_t* collection ,mongoc_query_flags_t flags ,bson_t* query ,int64_t skip ,int64_t limit ,bson_t* opts ,mongoc_read_prefs_t* read_prefs ,bson_error_t* error)
(def-function mongoc-collection-count-with-opts
             "mongoc_collection_count_with_opts" (void* mongoc_query_flags_t void* int int void* void* void*) int)

;;bool mongoc_collection_drop(mongoc_collection_t* collection ,bson_error_t* error)
(def-function mongoc-collection-drop
             "mongoc_collection_drop" (void* void*) int)

;;bool mongoc_collection_drop_with_opts(mongoc_collection_t* collection ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-collection-drop-with-opts
             "mongoc_collection_drop_with_opts" (void* void* void*) int)

;;bool mongoc_collection_drop_index(mongoc_collection_t* collection ,char* index_name ,bson_error_t* error)
(def-function mongoc-collection-drop-index
             "mongoc_collection_drop_index" (void* string void*) int)

;;bool mongoc_collection_drop_index_with_opts(mongoc_collection_t* collection ,char* index_name ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-collection-drop-index-with-opts
             "mongoc_collection_drop_index_with_opts" (void* string void* void*) int)

;;bool mongoc_collection_create_index(mongoc_collection_t* collection ,bson_t* keys ,mongoc_index_opt_t* opt ,bson_error_t* error)
(def-function mongoc-collection-create-index
             "mongoc_collection_create_index" (void* void* void* void*) int)

;;bool mongoc_collection_create_index_with_opts(mongoc_collection_t* collection ,bson_t* keys ,mongoc_index_opt_t* opt ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-create-index-with-opts
             "mongoc_collection_create_index_with_opts" (void* void* void* void* void* void*) int)

;;bool mongoc_collection_ensure_index(mongoc_collection_t* collection ,bson_t* keys ,mongoc_index_opt_t* opt ,bson_error_t* error)
(def-function mongoc-collection-ensure-index
             "mongoc_collection_ensure_index" (void* void* void* void*) int)

;;mongoc_cursor_t* mongoc_collection_find_indexes(mongoc_collection_t* collection ,bson_error_t* error)
(def-function mongoc-collection-find-indexes
             "mongoc_collection_find_indexes" (void* void*) void*)

;;mongoc_cursor_t* mongoc_collection_find(mongoc_collection_t* collection ,mongoc_query_flags_t flags ,uint32_t skip ,uint32_t limit ,uint32_t batch_size ,bson_t* query ,bson_t* fields ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-collection-find
             "mongoc_collection_find" (void* mongoc_query_flags_t int int int void* void* void*) void*)

;;mongoc_cursor_t* mongoc_collection_find_with_opts(mongoc_collection_t* collection ,bson_t* filter ,bson_t* opts ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-collection-find-with-opts
             "mongoc_collection_find_with_opts" (void* void* void* void*) void*)

;;bool mongoc_collection_insert(mongoc_collection_t* collection ,mongoc_insert_flags_t flags ,bson_t* document ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-insert
             "mongoc_collection_insert" (void* int void* void* void*) int)

;;bool mongoc_collection_insert_bulk(mongoc_collection_t* collection ,mongoc_insert_flags_t flags ,bson_t documents ,uint32_t n_documents ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-insert-bulk
             "mongoc_collection_insert_bulk" (void* int bson_t int void* void*) int)

;;bool mongoc_collection_update(mongoc_collection_t* collection ,mongoc_update_flags_t flags ,bson_t* selector ,bson_t* update ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-update
             "mongoc_collection_update" (void* mongoc_update_flags_t void* void* void* void*) int)

;;bool mongoc_collection_delete(mongoc_collection_t* collection ,mongoc_delete_flags_t flags ,bson_t* selector ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-delete
             "mongoc_collection_delete" (void* mongoc_delete_flags_t void* void* void*) int)

;;bool mongoc_collection_save(mongoc_collection_t* collection ,bson_t* document ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-save
             "mongoc_collection_save" (void* void* void* void*) int)

;;bool mongoc_collection_remove(mongoc_collection_t* collection ,mongoc_remove_flags_t flags ,bson_t* selector ,mongoc_write_concern_t* write_concern ,bson_error_t* error)
(def-function mongoc-collection-remove
             "mongoc_collection_remove" (void* mongoc_remove_flags_t void* void* void*) int)

;;bool mongoc_collection_rename(mongoc_collection_t* collection ,char* new_db ,char* new_name ,bool drop_target_before_rename ,bson_error_t* error)
(def-function mongoc-collection-rename
             "mongoc_collection_rename" (void* string string int void*) int)

;;bool mongoc_collection_rename_with_opts(mongoc_collection_t* collection ,char* new_db ,char* new_name ,bool drop_target_before_rename ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-collection-rename-with-opts
             "mongoc_collection_rename_with_opts" (void* string string int void* void*) int)

;;bool mongoc_collection_find_and_modify_with_opts(mongoc_collection_t* collection ,bson_t* query ,mongoc_find_and_modify_opts_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-find-and-modify-with-opts
             "mongoc_collection_find_and_modify_with_opts" (void* void* void* void* void*) int)

;;bool mongoc_collection_find_and_modify(mongoc_collection_t* collection ,bson_t* query ,bson_t* sort ,bson_t* update ,bson_t* fields ,bool _remove ,bool upsert ,bool _new ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-find-and-modify
             "mongoc_collection_find_and_modify" (void* void* void* void* void* int int int void* void*) int)

;;bool mongoc_collection_stats(mongoc_collection_t* collection ,bson_t* options ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-stats
             "mongoc_collection_stats" (void* void* void* void*) int)

;;mongoc_bulk_operation_t* mongoc_collection_create_bulk_operation(mongoc_collection_t* collection ,bool ordered ,mongoc_write_concern_t* write_concern)
(def-function mongoc-collection-create-bulk-operation
             "mongoc_collection_create_bulk_operation" (void* int void*) void*)

;;mongoc_read_prefs_t* mongoc_collection_get_read_prefs(mongoc_collection_t* collection)
(def-function mongoc-collection-get-read-prefs
             "mongoc_collection_get_read_prefs" (void*) void*)

;;void mongoc_collection_set_read_prefs(mongoc_collection_t* collection ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-collection-set-read-prefs
             "mongoc_collection_set_read_prefs" (void* void*) void)

;;mongoc_read_concern_t* mongoc_collection_get_read_concern(mongoc_collection_t* collection)
(def-function mongoc-collection-get-read-concern
             "mongoc_collection_get_read_concern" (void*) void*)

;;void mongoc_collection_set_read_concern(mongoc_collection_t* collection ,mongoc_read_concern_t* read_concern)
(def-function mongoc-collection-set-read-concern
             "mongoc_collection_set_read_concern" (void* void*) void)

;;mongoc_write_concern_t* mongoc_collection_get_write_concern(mongoc_collection_t* collection)
(def-function mongoc-collection-get-write-concern
             "mongoc_collection_get_write_concern" (void*) void*)

;;void mongoc_collection_set_write_concern(mongoc_collection_t* collection ,mongoc_write_concern_t* write_concern)
(def-function mongoc-collection-set-write-concern
             "mongoc_collection_set_write_concern" (void* void*) void)

;;char* mongoc_collection_get_name(mongoc_collection_t* collection)
(def-function mongoc-collection-get-name
             "mongoc_collection_get_name" (void*) string)

;;bson_t* mongoc_collection_get_last_error(mongoc_collection_t* collection)
(def-function mongoc-collection-get-last-error
             "mongoc_collection_get_last_error" (void*) void*)

;;char* mongoc_collection_keys_to_index_string(bson_t* keys)
(def-function mongoc-collection-keys-to-index-string
             "mongoc_collection_keys_to_index_string" (void*) string)

;;bool mongoc_collection_validate(mongoc_collection_t* collection ,bson_t* options ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-collection-validate
             "mongoc_collection_validate" (void* void* void* void*) int)

;;char* mongoc_database_get_name(mongoc_database_t* database)
(def-function mongoc-database-get-name
             "mongoc_database_get_name" (void*) string)

;;bool mongoc_database_remove_user(mongoc_database_t* database ,char* username ,bson_error_t* error)
(def-function mongoc-database-remove-user
             "mongoc_database_remove_user" (void* string void*) int)

;;bool mongoc_database_remove_all_users(mongoc_database_t* database ,bson_error_t* error)
(def-function mongoc-database-remove-all-users
             "mongoc_database_remove_all_users" (void* void*) int)

;;bool mongoc_database_add_user(mongoc_database_t* database ,char* username ,char* password ,bson_t* roles ,bson_t* custom_data ,bson_error_t* error)
(def-function mongoc-database-add-user
             "mongoc_database_add_user" (void* string string void* void* void*) int)

;;void mongoc_database_destroy(mongoc_database_t* database)
(def-function mongoc-database-destroy
             "mongoc_database_destroy" (void*) void)

;;mongoc_database_t* mongoc_database_copy(mongoc_database_t* database)
(def-function mongoc-database-copy
             "mongoc_database_copy" (void*) void*)

;;mongoc_cursor_t* mongoc_database_command(mongoc_database_t* database ,mongoc_query_flags_t flags ,uint32_t skip ,uint32_t limit ,uint32_t batch_size ,bson_t* command ,bson_t* fields ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-database-command
             "mongoc_database_command" (void* mongoc_query_flags_t int int int void* void* void*) void*)

;;bool mongoc_database_read_command_with_opts(mongoc_database_t* database ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-database-read-command-with-opts
             "mongoc_database_read_command_with_opts" (void* void* void* void* void* void*) int)

;;bool mongoc_database_write_command_with_opts(mongoc_database_t* database ,bson_t* command ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-database-write-command-with-opts
             "mongoc_database_write_command_with_opts" (void* void* void* void* void*) int)

;;bool mongoc_database_read_write_command_with_opts(mongoc_database_t* database ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-database-read-write-command-with-opts
             "mongoc_database_read_write_command_with_opts" (void* void* void* void* void* void*) int)

;;bool mongoc_database_command_simple(mongoc_database_t* database ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-database-command-simple
             "mongoc_database_command_simple" (void* void* void* void* void*) int)

;;bool mongoc_database_drop(mongoc_database_t* database ,bson_error_t* error)
(def-function mongoc-database-drop
             "mongoc_database_drop" (void* void*) int)

;;bool mongoc_database_drop_with_opts(mongoc_database_t* database ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-database-drop-with-opts
             "mongoc_database_drop_with_opts" (void* void* void*) int)

;;bool mongoc_database_has_collection(mongoc_database_t* database ,char* name ,bson_error_t* error)
(def-function mongoc-database-has-collection
             "mongoc_database_has_collection" (void* string void*) int)

;;mongoc_collection_t* mongoc_database_create_collection(mongoc_database_t* database ,char* name ,bson_t* options ,bson_error_t* error)
(def-function mongoc-database-create-collection
             "mongoc_database_create_collection" (void* string void* void*) void*)

;;mongoc_read_prefs_t* mongoc_database_get_read_prefs(mongoc_database_t* database)
(def-function mongoc-database-get-read-prefs
             "mongoc_database_get_read_prefs" (void*) void*)

;;void mongoc_database_set_read_prefs(mongoc_database_t* database ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-database-set-read-prefs
             "mongoc_database_set_read_prefs" (void* void*) void)

;;mongoc_write_concern_t* mongoc_database_get_write_concern(mongoc_database_t* database)
(def-function mongoc-database-get-write-concern
             "mongoc_database_get_write_concern" (void*) void*)

;;void mongoc_database_set_write_concern(mongoc_database_t* database ,mongoc_write_concern_t* write_concern)
(def-function mongoc-database-set-write-concern
             "mongoc_database_set_write_concern" (void* void*) void)

;;mongoc_read_concern_t* mongoc_database_get_read_concern(mongoc_database_t* database)
(def-function mongoc-database-get-read-concern
             "mongoc_database_get_read_concern" (void*) void*)

;;void mongoc_database_set_read_concern(mongoc_database_t* database ,mongoc_read_concern_t* read_concern)
(def-function mongoc-database-set-read-concern
             "mongoc_database_set_read_concern" (void* void*) void)

;;mongoc_cursor_t* mongoc_database_find_collections(mongoc_database_t* database ,bson_t* filter ,bson_error_t* error)
(def-function mongoc-database-find-collections
             "mongoc_database_find_collections" (void* void* void*) void*)

;;char mongoc_database_get_collection_names(mongoc_database_t* database ,bson_error_t* error)
(def-function mongoc-database-get-collection-names
             "mongoc_database_get_collection_names" (void* void*) char)

;;mongoc_collection_t* mongoc_database_get_collection(mongoc_database_t* database ,char* name)
(def-function mongoc-database-get-collection
             "mongoc_database_get_collection" (void* string) void*)

;;mongoc_socket_t* mongoc_socket_accept(mongoc_socket_t* sock ,int64_t expire_at)
(def-function mongoc-socket-accept
             "mongoc_socket_accept" (void* int) void*)

;;int mongoc_socket_bind(mongoc_socket_t* sock ,sockaddr addr ,mongoc_socklen_t addrlen)
(def-function mongoc-socket-bind
             "mongoc_socket_bind" (void* sockaddr mongoc_socklen_t) int)

;;int mongoc_socket_close(mongoc_socket_t* socket)
(def-function mongoc-socket-close
             "mongoc_socket_close" (void*) int)

;;int mongoc_socket_connect(mongoc_socket_t* sock ,sockaddr addr ,mongoc_socklen_t addrlen ,int64_t expire_at)
(def-function mongoc-socket-connect
             "mongoc_socket_connect" (void* sockaddr mongoc_socklen_t int) int)

;;char* mongoc_socket_getnameinfo(mongoc_socket_t* sock)
(def-function mongoc-socket-getnameinfo
             "mongoc_socket_getnameinfo" (void*) string)

;;void mongoc_socket_destroy(mongoc_socket_t* sock)
(def-function mongoc-socket-destroy
             "mongoc_socket_destroy" (void*) void)

;;int mongoc_socket_errno(mongoc_socket_t* sock)
(def-function mongoc-socket-errno
             "mongoc_socket_errno" (void*) int)

;;int mongoc_socket_getsockname(mongoc_socket_t* sock ,sockaddr addr ,mongoc_socklen_t* addrlen)
(def-function mongoc-socket-getsockname
             "mongoc_socket_getsockname" (void* sockaddr void*) int)

;;int mongoc_socket_listen(mongoc_socket_t* sock ,unsigned backlog)
(def-function mongoc-socket-listen
             "mongoc_socket_listen" (void* unsigned) int)

;;mongoc_socket_t* mongoc_socket_new(int domain ,int type ,int protocol)
(def-function mongoc-socket-new
             "mongoc_socket_new" (int int int) void*)

;;ssize_t mongoc_socket_recv(mongoc_socket_t* sock ,void* buf ,size_t buflen ,int flags ,int64_t expire_at)
(def-function mongoc-socket-recv
             "mongoc_socket_recv" (void* void* int int int) ssize_t)

;;int mongoc_socket_setsockopt(mongoc_socket_t* sock ,int level ,int optname ,void* optval ,mongoc_socklen_t optlen)
(def-function mongoc-socket-setsockopt
             "mongoc_socket_setsockopt" (void* int int void* mongoc_socklen_t) int)

;;ssize_t mongoc_socket_send(mongoc_socket_t* sock ,void* buf ,size_t buflen ,int64_t expire_at)
(def-function mongoc-socket-send
             "mongoc_socket_send" (void* void* int int) ssize_t)

;;ssize_t mongoc_socket_sendv(mongoc_socket_t* sock ,mongoc_iovec_t* iov ,size_t iovcnt ,int64_t expire_at)
(def-function mongoc-socket-sendv
             "mongoc_socket_sendv" (void* void* int int) ssize_t)

;;bool mongoc_socket_check_closed(mongoc_socket_t* sock)
(def-function mongoc-socket-check-closed
             "mongoc_socket_check_closed" (void*) int)

;;void mongoc_socket_inet_ntop(addrinfo rp ,char* buf ,size_t buflen)
(def-function mongoc-socket-inet-ntop
             "mongoc_socket_inet_ntop" (addrinfo string int) void)

;;ssize_t mongoc_socket_poll(mongoc_socket_poll_t* sds ,size_t nsds ,int32_t timeout)
(def-function mongoc-socket-poll
             "mongoc_socket_poll" (void* int int) ssize_t)

;;mongoc_stream_t* mongoc_stream_get_base_stream(mongoc_stream_t* stream)
(def-function mongoc-stream-get-base-stream
             "mongoc_stream_get_base_stream" (void*) void*)

;;mongoc_stream_t* mongoc_stream_get_tls_stream(mongoc_stream_t* stream)
(def-function mongoc-stream-get-tls-stream
             "mongoc_stream_get_tls_stream" (void*) void*)

;;int mongoc_stream_close(mongoc_stream_t* stream)
(def-function mongoc-stream-close
             "mongoc_stream_close" (void*) int)

;;void mongoc_stream_destroy(mongoc_stream_t* stream)
(def-function mongoc-stream-destroy
             "mongoc_stream_destroy" (void*) void)

;;void mongoc_stream_failed(mongoc_stream_t* stream)
(def-function mongoc-stream-failed
             "mongoc_stream_failed" (void*) void)

;;int mongoc_stream_flush(mongoc_stream_t* stream)
(def-function mongoc-stream-flush
             "mongoc_stream_flush" (void*) int)

;;ssize_t mongoc_stream_writev(mongoc_stream_t* stream ,mongoc_iovec_t* iov ,size_t iovcnt ,int32_t timeout_msec)
(def-function mongoc-stream-writev
             "mongoc_stream_writev" (void* void* int int) ssize_t)

;;ssize_t mongoc_stream_write(mongoc_stream_t* stream ,void* buf ,size_t count ,int32_t timeout_msec)
(def-function mongoc-stream-write
             "mongoc_stream_write" (void* void* int int) ssize_t)

;;ssize_t mongoc_stream_readv(mongoc_stream_t* stream ,mongoc_iovec_t* iov ,size_t iovcnt ,size_t min_bytes ,int32_t timeout_msec)
(def-function mongoc-stream-readv
             "mongoc_stream_readv" (void* void* int int int) ssize_t)

;;ssize_t mongoc_stream_read(mongoc_stream_t* stream ,void* buf ,size_t count ,size_t min_bytes ,int32_t timeout_msec)
(def-function mongoc-stream-read
             "mongoc_stream_read" (void* void* int int int) ssize_t)

;;int mongoc_stream_setsockopt(mongoc_stream_t* stream ,int level ,int optname ,void* optval ,mongoc_socklen_t optlen)
(def-function mongoc-stream-setsockopt
             "mongoc_stream_setsockopt" (void* int int void* mongoc_socklen_t) int)

;;bool mongoc_stream_check_closed(mongoc_stream_t* stream)
(def-function mongoc-stream-check-closed
             "mongoc_stream_check_closed" (void*) int)

;;ssize_t mongoc_stream_poll(mongoc_stream_poll_t* streams ,size_t nstreams ,int32_t timeout)
(def-function mongoc-stream-poll
             "mongoc_stream_poll" (void* int int) ssize_t)

;;char* mongoc_gridfs_file_get_md5(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-md5
             "mongoc_gridfs_file_get_md5" (void*) string)

;;void mongoc_gridfs_file_set_md5(mongoc_gridfs_file_t* file ,char* str)
(def-function mongoc-gridfs-file-set-md5
             "mongoc_gridfs_file_set_md5" (void* string) void)

;;char* mongoc_gridfs_file_get_filename(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-filename
             "mongoc_gridfs_file_get_filename" (void*) string)

;;void mongoc_gridfs_file_set_filename(mongoc_gridfs_file_t* file ,char* str)
(def-function mongoc-gridfs-file-set-filename
             "mongoc_gridfs_file_set_filename" (void* string) void)

;;char* mongoc_gridfs_file_get_content_type(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-content-type
             "mongoc_gridfs_file_get_content_type" (void*) string)

;;void mongoc_gridfs_file_set_content_type(mongoc_gridfs_file_t* file ,char* str)
(def-function mongoc-gridfs-file-set-content-type
             "mongoc_gridfs_file_set_content_type" (void* string) void)

;;bson_t* mongoc_gridfs_file_get_aliases(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-aliases
             "mongoc_gridfs_file_get_aliases" (void*) void*)

;;void mongoc_gridfs_file_set_aliases(mongoc_gridfs_file_t* file ,bson_t* bson)
(def-function mongoc-gridfs-file-set-aliases
             "mongoc_gridfs_file_set_aliases" (void* void*) void)

;;bson_t* mongoc_gridfs_file_get_metadata(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-metadata
             "mongoc_gridfs_file_get_metadata" (void*) void*)

;;void mongoc_gridfs_file_set_metadata(mongoc_gridfs_file_t* file ,bson_t* bson)
(def-function mongoc-gridfs-file-set-metadata
             "mongoc_gridfs_file_set_metadata" (void* void*) void)

;;bson_value_t* mongoc_gridfs_file_get_id(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-id
             "mongoc_gridfs_file_get_id" (void*) void*)

;;int64_t mongoc_gridfs_file_get_length(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-length
             "mongoc_gridfs_file_get_length" (void*) int)

;;int32_t mongoc_gridfs_file_get_chunk_size(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-chunk-size
             "mongoc_gridfs_file_get_chunk_size" (void*) int)

;;int64_t mongoc_gridfs_file_get_upload_date(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-get-upload-date
             "mongoc_gridfs_file_get_upload_date" (void*) int)

;;ssize_t mongoc_gridfs_file_writev(mongoc_gridfs_file_t* file ,mongoc_iovec_t* iov ,size_t iovcnt ,uint32_t timeout_msec)
(def-function mongoc-gridfs-file-writev
             "mongoc_gridfs_file_writev" (void* void* int int) ssize_t)

;;ssize_t mongoc_gridfs_file_readv(mongoc_gridfs_file_t* file ,mongoc_iovec_t* iov ,size_t iovcnt ,size_t min_bytes ,uint32_t timeout_msec)
(def-function mongoc-gridfs-file-readv
             "mongoc_gridfs_file_readv" (void* void* int int int) ssize_t)

;;int mongoc_gridfs_file_seek(mongoc_gridfs_file_t* file ,int64_t delta ,int whence)
(def-function mongoc-gridfs-file-seek
             "mongoc_gridfs_file_seek" (void* int int) int)

;;uint64_t mongoc_gridfs_file_tell(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-tell
             "mongoc_gridfs_file_tell" (void*) uint64_t)

;;bool mongoc_gridfs_file_set_id(mongoc_gridfs_file_t* file ,bson_value_t* id ,bson_error_t* error)
(def-function mongoc-gridfs-file-set-id
             "mongoc_gridfs_file_set_id" (void* void* void*) int)

;;bool mongoc_gridfs_file_save(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-save
             "mongoc_gridfs_file_save" (void*) int)

;;void mongoc_gridfs_file_destroy(mongoc_gridfs_file_t* file)
(def-function mongoc-gridfs-file-destroy
             "mongoc_gridfs_file_destroy" (void*) void)

;;bool mongoc_gridfs_file_error(mongoc_gridfs_file_t* file ,bson_error_t* error)
(def-function mongoc-gridfs-file-error
             "mongoc_gridfs_file_error" (void* void*) int)

;;bool mongoc_gridfs_file_remove(mongoc_gridfs_file_t* file ,bson_error_t* error)
(def-function mongoc-gridfs-file-remove
             "mongoc_gridfs_file_remove" (void* void*) int)

;;mongoc_gridfs_file_t* mongoc_gridfs_file_list_next(mongoc_gridfs_file_list_t* list)
(def-function mongoc-gridfs-file-list-next
             "mongoc_gridfs_file_list_next" (void*) void*)

;;void mongoc_gridfs_file_list_destroy(mongoc_gridfs_file_list_t* list)
(def-function mongoc-gridfs-file-list-destroy
             "mongoc_gridfs_file_list_destroy" (void*) void)

;;bool mongoc_gridfs_file_list_error(mongoc_gridfs_file_list_t* list ,bson_error_t* error)
(def-function mongoc-gridfs-file-list-error
             "mongoc_gridfs_file_list_error" (void* void*) int)

;;mongoc_gridfs_file_t* mongoc_gridfs_create_file_from_stream(mongoc_gridfs_t* gridfs ,mongoc_stream_t* stream ,mongoc_gridfs_file_opt_t* opt)
(def-function mongoc-gridfs-create-file-from-stream
             "mongoc_gridfs_create_file_from_stream" (void* void* void*) void*)

;;mongoc_gridfs_file_t* mongoc_gridfs_create_file(mongoc_gridfs_t* gridfs ,mongoc_gridfs_file_opt_t* opt)
(def-function mongoc-gridfs-create-file
             "mongoc_gridfs_create_file" (void* void*) void*)

;;mongoc_gridfs_file_list_t* mongoc_gridfs_find(mongoc_gridfs_t* gridfs ,bson_t* query)
(def-function mongoc-gridfs-find
             "mongoc_gridfs_find" (void* void*) void*)

;;mongoc_gridfs_file_t* mongoc_gridfs_find_one(mongoc_gridfs_t* gridfs ,bson_t* query ,bson_error_t* error)
(def-function mongoc-gridfs-find-one
             "mongoc_gridfs_find_one" (void* void* void*) void*)

;;mongoc_gridfs_file_list_t* mongoc_gridfs_find_with_opts(mongoc_gridfs_t* gridfs ,bson_t* filter ,bson_t* opts)
(def-function mongoc-gridfs-find-with-opts
             "mongoc_gridfs_find_with_opts" (void* void* void*) void*)

;;mongoc_gridfs_file_t* mongoc_gridfs_find_one_with_opts(mongoc_gridfs_t* gridfs ,bson_t* filter ,bson_t* opts ,bson_error_t* error)
(def-function mongoc-gridfs-find-one-with-opts
             "mongoc_gridfs_find_one_with_opts" (void* void* void* void*) void*)

;;mongoc_gridfs_file_t* mongoc_gridfs_find_one_by_filename(mongoc_gridfs_t* gridfs ,char* filename ,bson_error_t* error)
(def-function mongoc-gridfs-find-one-by-filename
             "mongoc_gridfs_find_one_by_filename" (void* string void*) void*)

;;bool mongoc_gridfs_drop(mongoc_gridfs_t* gridfs ,bson_error_t* error)
(def-function mongoc-gridfs-drop
             "mongoc_gridfs_drop" (void* void*) int)

;;void mongoc_gridfs_destroy(mongoc_gridfs_t* gridfs)
(def-function mongoc-gridfs-destroy
             "mongoc_gridfs_destroy" (void*) void)

;;mongoc_collection_t* mongoc_gridfs_get_files(mongoc_gridfs_t* gridfs)
(def-function mongoc-gridfs-get-files
             "mongoc_gridfs_get_files" (void*) void*)

;;mongoc_collection_t* mongoc_gridfs_get_chunks(mongoc_gridfs_t* gridfs)
(def-function mongoc-gridfs-get-chunks
             "mongoc_gridfs_get_chunks" (void*) void*)

;;bool mongoc_gridfs_remove_by_filename(mongoc_gridfs_t* gridfs ,char* filename ,bson_error_t* error)
(def-function mongoc-gridfs-remove-by-filename
             "mongoc_gridfs_remove_by_filename" (void* string void*) int)

;;mongoc_ssl_opt_t* mongoc_ssl_opt_get_default()
(def-function mongoc-ssl-opt-get-default
             "mongoc_ssl_opt_get_default" () void*)

;;mongoc_uri_t* mongoc_uri_copy(mongoc_uri_t* uri)
(def-function mongoc-uri-copy
             "mongoc_uri_copy" (void*) void*)

;;void mongoc_uri_destroy(mongoc_uri_t* uri)
(def-function mongoc-uri-destroy
             "mongoc_uri_destroy" (void*) void)

;;mongoc_uri_t* mongoc_uri_new(char* uri_string)
(def-function mongoc-uri-new
             "mongoc_uri_new" (string) void*)

;;mongoc_uri_t* mongoc_uri_new_for_host_port(char* hostname ,uint16_t port)
(def-function mongoc-uri-new-for-host-port
             "mongoc_uri_new_for_host_port" (string uint16_t) void*)

;;mongoc_host_list_t* mongoc_uri_get_hosts(mongoc_uri_t* uri)
(def-function mongoc-uri-get-hosts
             "mongoc_uri_get_hosts" (void*) void*)

;;char* mongoc_uri_get_database(mongoc_uri_t* uri)
(def-function mongoc-uri-get-database
             "mongoc_uri_get_database" (void*) string)

;;bool mongoc_uri_set_database(mongoc_uri_t* uri ,char* database)
(def-function mongoc-uri-set-database
             "mongoc_uri_set_database" (void* string) int)

;;bson_t* mongoc_uri_get_options(mongoc_uri_t* uri)
(def-function mongoc-uri-get-options
             "mongoc_uri_get_options" (void*) void*)

;;char* mongoc_uri_get_password(mongoc_uri_t* uri)
(def-function mongoc-uri-get-password
             "mongoc_uri_get_password" (void*) string)

;;bool mongoc_uri_set_password(mongoc_uri_t* uri ,char* password)
(def-function mongoc-uri-set-password
             "mongoc_uri_set_password" (void* string) int)

;;bool mongoc_uri_option_is_int32(char* key)
(def-function mongoc-uri-option-is-int32
             "mongoc_uri_option_is_int32" (string) int)

;;bool mongoc_uri_option_is_bool(char* key)
(def-function mongoc-uri-option-is-bool
             "mongoc_uri_option_is_bool" (string) int)

;;bool mongoc_uri_option_is_utf8(char* key)
(def-function mongoc-uri-option-is-utf8
             "mongoc_uri_option_is_utf8" (string) int)

;;int32_t mongoc_uri_get_option_as_int32(mongoc_uri_t* uri ,char* option ,int32_t fallback)
(def-function mongoc-uri-get-option-as-int32
             "mongoc_uri_get_option_as_int32" (void* string int) int)

;;bool mongoc_uri_get_option_as_bool(mongoc_uri_t* uri ,char* option ,bool fallback)
(def-function mongoc-uri-get-option-as-bool
             "mongoc_uri_get_option_as_bool" (void* string int) int)

;;char* mongoc_uri_get_option_as_utf8(mongoc_uri_t* uri ,char* option ,char* fallback)
(def-function mongoc-uri-get-option-as-utf8
             "mongoc_uri_get_option_as_utf8" (void* string string) string)

;;bool mongoc_uri_set_option_as_int32(mongoc_uri_t* uri ,char* option ,int32_t value)
(def-function mongoc-uri-set-option-as-int32
             "mongoc_uri_set_option_as_int32" (void* string int) int)

;;bool mongoc_uri_set_option_as_bool(mongoc_uri_t* uri ,char* option ,bool value)
(def-function mongoc-uri-set-option-as-bool
             "mongoc_uri_set_option_as_bool" (void* string int) int)

;;bool mongoc_uri_set_option_as_utf8(mongoc_uri_t* uri ,char* option ,char* value)
(def-function mongoc-uri-set-option-as-utf8
             "mongoc_uri_set_option_as_utf8" (void* string string) int)

;;bson_t* mongoc_uri_get_read_prefs(mongoc_uri_t* uri)
(def-function mongoc-uri-get-read-prefs
             "mongoc_uri_get_read_prefs" (void*) void*)

;;char* mongoc_uri_get_replica_set(mongoc_uri_t* uri)
(def-function mongoc-uri-get-replica-set
             "mongoc_uri_get_replica_set" (void*) string)

;;char* mongoc_uri_get_string(mongoc_uri_t* uri)
(def-function mongoc-uri-get-string
             "mongoc_uri_get_string" (void*) string)

;;char* mongoc_uri_get_username(mongoc_uri_t* uri)
(def-function mongoc-uri-get-username
             "mongoc_uri_get_username" (void*) string)

;;bool mongoc_uri_set_username(mongoc_uri_t* uri ,char* username)
(def-function mongoc-uri-set-username
             "mongoc_uri_set_username" (void* string) int)

;;bson_t* mongoc_uri_get_credentials(mongoc_uri_t* uri)
(def-function mongoc-uri-get-credentials
             "mongoc_uri_get_credentials" (void*) void*)

;;char* mongoc_uri_get_auth_source(mongoc_uri_t* uri)
(def-function mongoc-uri-get-auth-source
             "mongoc_uri_get_auth_source" (void*) string)

;;bool mongoc_uri_set_auth_source(mongoc_uri_t* uri ,char* value)
(def-function mongoc-uri-set-auth-source
             "mongoc_uri_set_auth_source" (void* string) int)

;;char* mongoc_uri_get_appname(mongoc_uri_t* uri)
(def-function mongoc-uri-get-appname
             "mongoc_uri_get_appname" (void*) string)

;;bool mongoc_uri_set_appname(mongoc_uri_t* uri ,char* value)
(def-function mongoc-uri-set-appname
             "mongoc_uri_set_appname" (void* string) int)

;;char* mongoc_uri_get_auth_mechanism(mongoc_uri_t* uri)
(def-function mongoc-uri-get-auth-mechanism
             "mongoc_uri_get_auth_mechanism" (void*) string)

;;bool mongoc_uri_get_mechanism_properties(mongoc_uri_t* uri ,bson_t* properties)
(def-function mongoc-uri-get-mechanism-properties
             "mongoc_uri_get_mechanism_properties" (void* void*) int)

;;bool mongoc_uri_set_mechanism_properties(mongoc_uri_t* uri ,bson_t* properties)
(def-function mongoc-uri-set-mechanism-properties
             "mongoc_uri_set_mechanism_properties" (void* void*) int)

;;bool mongoc_uri_get_ssl(mongoc_uri_t* uri)
(def-function mongoc-uri-get-ssl
             "mongoc_uri_get_ssl" (void*) int)

;;char* mongoc_uri_unescape(char* escaped_string)
(def-function mongoc-uri-unescape
             "mongoc_uri_unescape" (string) string)

;;mongoc_read_prefs_t* mongoc_uri_get_read_prefs_t(mongoc_uri_t* uri)
(def-function mongoc-uri-get-read-prefs-t
             "mongoc_uri_get_read_prefs_t" (void*) void*)

;;void mongoc_uri_set_read_prefs_t(mongoc_uri_t* uri ,mongoc_read_prefs_t* prefs)
(def-function mongoc-uri-set-read-prefs-t
             "mongoc_uri_set_read_prefs_t" (void* void*) void)

;;mongoc_write_concern_t* mongoc_uri_get_write_concern(mongoc_uri_t* uri)
(def-function mongoc-uri-get-write-concern
             "mongoc_uri_get_write_concern" (void*) void*)

;;void mongoc_uri_set_write_concern(mongoc_uri_t* uri ,mongoc_write_concern_t* wc)
(def-function mongoc-uri-set-write-concern
             "mongoc_uri_set_write_concern" (void* void*) void)

;;mongoc_read_concern_t* mongoc_uri_get_read_concern(mongoc_uri_t* uri)
(def-function mongoc-uri-get-read-concern
             "mongoc_uri_get_read_concern" (void*) void*)

;;void mongoc_uri_set_read_concern(mongoc_uri_t* uri ,mongoc_read_concern_t* rc)
(def-function mongoc-uri-set-read-concern
             "mongoc_uri_set_read_concern" (void* void*) void)

;;mongoc_client_t* mongoc_client_new(char* uri_string)
(def-function mongoc-client-new
             "mongoc_client_new" (string) void*)

;;mongoc_client_t* mongoc_client_new_from_uri(mongoc_uri_t* uri)
(def-function mongoc-client-new-from-uri
             "mongoc_client_new_from_uri" (void*) void*)

;;mongoc_uri_t* mongoc_client_get_uri(mongoc_client_t* client)
(def-function mongoc-client-get-uri
             "mongoc_client_get_uri" (void*) void*)

;;void mongoc_client_set_stream_initiator(mongoc_client_t* client ,mongoc_stream_initiator_t initiator ,void* user_data)
(def-function mongoc-client-set-stream-initiator
             "mongoc_client_set_stream_initiator" (void* mongoc_stream_initiator_t void*) void)

;;mongoc_cursor_t* mongoc_client_command(mongoc_client_t* client ,char* db_name ,mongoc_query_flags_t flags ,uint32_t skip ,uint32_t limit ,uint32_t batch_size ,bson_t* query ,bson_t* fields ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-client-command
             "mongoc_client_command" (void* string mongoc_query_flags_t int int int void* void* void*) void*)

;;void mongoc_client_kill_cursor(mongoc_client_t* client ,int64_t cursor_id)
(def-function mongoc-client-kill-cursor
             "mongoc_client_kill_cursor" (void* int) void)

;;bool mongoc_client_command_simple(mongoc_client_t* client ,char* db_name ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-command-simple
             "mongoc_client_command_simple" (void* string void* void* void* void*) int)

;;bool mongoc_client_read_command_with_opts(mongoc_client_t* client ,char* db_name ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-read-command-with-opts
             "mongoc_client_read_command_with_opts" (void* string void* void* void* void* void*) int)

;;bool mongoc_client_write_command_with_opts(mongoc_client_t* client ,char* db_name ,bson_t* command ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-write-command-with-opts
             "mongoc_client_write_command_with_opts" (void* string void* void* void* void*) int)

;;bool mongoc_client_read_write_command_with_opts(mongoc_client_t* client ,char* db_name ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,bson_t* opts ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-read-write-command-with-opts
             "mongoc_client_read_write_command_with_opts" (void* string void* void* void* void* void*) int)

;;bool mongoc_client_command_simple_with_server_id(mongoc_client_t* client ,char* db_name ,bson_t* command ,mongoc_read_prefs_t* read_prefs ,uint32_t server_id ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-command-simple-with-server-id
             "mongoc_client_command_simple_with_server_id" (void* string void* void* int void* void*) int)

;;void mongoc_client_destroy(mongoc_client_t* client)
(def-function mongoc-client-destroy
             "mongoc_client_destroy" (void*) void)

;;mongoc_database_t* mongoc_client_get_database(mongoc_client_t* client ,char* name)
(def-function mongoc-client-get-database
             "mongoc_client_get_database" (void* string) void*)

;;mongoc_database_t* mongoc_client_get_default_database(mongoc_client_t* client)
(def-function mongoc-client-get-default-database
             "mongoc_client_get_default_database" (void*) void*)

;;mongoc_gridfs_t* mongoc_client_get_gridfs(mongoc_client_t* client ,char* db ,char* prefix ,bson_error_t* error)
(def-function mongoc-client-get-gridfs
             "mongoc_client_get_gridfs" (void* string string void*) void*)

;;mongoc_collection_t* mongoc_client_get_collection(mongoc_client_t* client ,char* db ,char* collection)
(def-function mongoc-client-get-collection
             "mongoc_client_get_collection" (void* string string) void*)

;;char mongoc_client_get_database_names(mongoc_client_t* client ,bson_error_t* error)
(def-function mongoc-client-get-database-names
             "mongoc_client_get_database_names" (void* void*) char)

;;mongoc_cursor_t* mongoc_client_find_databases(mongoc_client_t* client ,bson_error_t* error)
(def-function mongoc-client-find-databases
             "mongoc_client_find_databases" (void* void*) void*)

;;bool mongoc_client_get_server_status(mongoc_client_t* client ,mongoc_read_prefs_t* read_prefs ,bson_t* reply ,bson_error_t* error)
(def-function mongoc-client-get-server-status
             "mongoc_client_get_server_status" (void* void* void* void*) int)

;;int32_t mongoc_client_get_max_message_size(mongoc_client_t* client)
(def-function mongoc-client-get-max-message-size
             "mongoc_client_get_max_message_size" (void*) int)

;;int32_t mongoc_client_get_max_bson_size(mongoc_client_t* client)
(def-function mongoc-client-get-max-bson-size
             "mongoc_client_get_max_bson_size" (void*) int)

;;mongoc_write_concern_t* mongoc_client_get_write_concern(mongoc_client_t* client)
(def-function mongoc-client-get-write-concern
             "mongoc_client_get_write_concern" (void*) void*)

;;void mongoc_client_set_write_concern(mongoc_client_t* client ,mongoc_write_concern_t* write_concern)
(def-function mongoc-client-set-write-concern
             "mongoc_client_set_write_concern" (void* void*) void)

;;mongoc_read_concern_t* mongoc_client_get_read_concern(mongoc_client_t* client)
(def-function mongoc-client-get-read-concern
             "mongoc_client_get_read_concern" (void*) void*)

;;void mongoc_client_set_read_concern(mongoc_client_t* client ,mongoc_read_concern_t* read_concern)
(def-function mongoc-client-set-read-concern
             "mongoc_client_set_read_concern" (void* void*) void)

;;mongoc_read_prefs_t* mongoc_client_get_read_prefs(mongoc_client_t* client)
(def-function mongoc-client-get-read-prefs
             "mongoc_client_get_read_prefs" (void*) void*)

;;void mongoc_client_set_read_prefs(mongoc_client_t* client ,mongoc_read_prefs_t* read_prefs)
(def-function mongoc-client-set-read-prefs
             "mongoc_client_set_read_prefs" (void* void*) void)

;;void mongoc_client_set_ssl_opts(mongoc_client_t* client ,mongoc_ssl_opt_t* opts)
(def-function mongoc-client-set-ssl-opts
             "mongoc_client_set_ssl_opts" (void* void*) void)

;;bool mongoc_client_set_apm_callbacks(mongoc_client_t* client ,mongoc_apm_callbacks_t* callbacks ,void* context)
(def-function mongoc-client-set-apm-callbacks
             "mongoc_client_set_apm_callbacks" (void* void* void*) int)

;;mongoc_server_description_t* mongoc_client_get_server_description(mongoc_client_t* client ,uint32_t server_id)
(def-function mongoc-client-get-server-description
             "mongoc_client_get_server_description" (void* int) void*)

;;mongoc_server_description_t mongoc_client_get_server_descriptions(mongoc_client_t* client ,size_t* n)
(def-function mongoc-client-get-server-descriptions
             "mongoc_client_get_server_descriptions" (void* void*) mongoc_server_description_t)

;;void mongoc_server_descriptions_destroy_all(mongoc_server_description_t sds ,size_t n)
(def-function mongoc-server-descriptions-destroy-all
             "mongoc_server_descriptions_destroy_all" (mongoc_server_description_t int) void)

;;mongoc_server_description_t* mongoc_client_select_server(mongoc_client_t* client ,bool for_writes ,mongoc_read_prefs_t* prefs ,bson_error_t* error)
(def-function mongoc-client-select-server
             "mongoc_client_select_server" (void* int void* void*) void*)

;;bool mongoc_client_set_error_api(mongoc_client_t* client ,int32_t version)
(def-function mongoc-client-set-error-api
             "mongoc_client_set_error_api" (void* int) int)

;;bool mongoc_client_set_appname(mongoc_client_t* client ,char* appname)
(def-function mongoc-client-set-appname
             "mongoc_client_set_appname" (void* string) int)

;;mongoc_client_pool_t* mongoc_client_pool_new(mongoc_uri_t* uri)
(def-function mongoc-client-pool-new
             "mongoc_client_pool_new" (void*) void*)

;;void mongoc_client_pool_destroy(mongoc_client_pool_t* pool)
(def-function mongoc-client-pool-destroy
             "mongoc_client_pool_destroy" (void*) void)

;;mongoc_client_t* mongoc_client_pool_pop(mongoc_client_pool_t* pool)
(def-function mongoc-client-pool-pop
             "mongoc_client_pool_pop" (void*) void*)

;;void mongoc_client_pool_push(mongoc_client_pool_t* pool ,mongoc_client_t* client)
(def-function mongoc-client-pool-push
             "mongoc_client_pool_push" (void* void*) void)

;;mongoc_client_t* mongoc_client_pool_try_pop(mongoc_client_pool_t* pool)
(def-function mongoc-client-pool-try-pop
             "mongoc_client_pool_try_pop" (void*) void*)

;;void mongoc_client_pool_max_size(mongoc_client_pool_t* pool ,uint32_t max_pool_size)
(def-function mongoc-client-pool-max-size
             "mongoc_client_pool_max_size" (void* int) void)

;;void mongoc_client_pool_min_size(mongoc_client_pool_t* pool ,uint32_t min_pool_size)
(def-function mongoc-client-pool-min-size
             "mongoc_client_pool_min_size" (void* int) void)

;;void mongoc_client_pool_set_ssl_opts(mongoc_client_pool_t* pool ,mongoc_ssl_opt_t* opts)
(def-function mongoc-client-pool-set-ssl-opts
             "mongoc_client_pool_set_ssl_opts" (void* void*) void)

;;bool mongoc_client_pool_set_apm_callbacks(mongoc_client_pool_t* pool ,mongoc_apm_callbacks_t* callbacks ,void* context)
(def-function mongoc-client-pool-set-apm-callbacks
             "mongoc_client_pool_set_apm_callbacks" (void* void* void*) int)

;;bool mongoc_client_pool_set_error_api(mongoc_client_pool_t* pool ,int32_t version)
(def-function mongoc-client-pool-set-error-api
             "mongoc_client_pool_set_error_api" (void* int) int)

;;bool mongoc_client_pool_set_appname(mongoc_client_pool_t* pool ,char* appname)
(def-function mongoc-client-pool-set-appname
             "mongoc_client_pool_set_appname" (void* string) int)

;;void mongoc_init()
(def-function mongoc-init
             "mongoc_init" () void)

;;void mongoc_cleanup()
(def-function mongoc-cleanup
             "mongoc_cleanup" () void)

;;mongoc_matcher_t* mongoc_matcher_new(bson_t* query ,bson_error_t* error)
(def-function mongoc-matcher-new
             "mongoc_matcher_new" (void* void*) void*)

;;bool mongoc_matcher_match(mongoc_matcher_t* matcher ,bson_t* document)
(def-function mongoc-matcher-match
             "mongoc_matcher_match" (void* void*) int)

;;void mongoc_matcher_destroy(mongoc_matcher_t* matcher)
(def-function mongoc-matcher-destroy
             "mongoc_matcher_destroy" (void*) void)

;;bool mongoc_handshake_data_append(char* driver_name ,char* driver_version ,char* platform)
(def-function mongoc-handshake-data-append
             "mongoc_handshake_data_append" (string string string) int)

;;void mongoc_log_set_handler(mongoc_log_func_t log_func ,void* user_data)
(def-function mongoc-log-set-handler
             "mongoc_log_set_handler" (mongoc_log_func_t void*) void)

;;void mongoc_log(mongoc_log_level_t log_level ,char* log_domain ,char* format)
(def-function mongoc-log
             "mongoc_log" (mongoc_log_level_t string string) void)

;;void mongoc_log_default_handler(mongoc_log_level_t log_level ,char* log_domain ,char* message ,void* user_data)
(def-function mongoc-log-default-handler
             "mongoc_log_default_handler" (mongoc_log_level_t string string void*) void)

;;char* mongoc_log_level_str(mongoc_log_level_t log_level)
(def-function mongoc-log-level-str
             "mongoc_log_level_str" (mongoc_log_level_t) string)

;;void mongoc_log_trace_enable()
(def-function mongoc-log-trace-enable
             "mongoc_log_trace_enable" () void)

;;void mongoc_log_trace_disable()
(def-function mongoc-log-trace-disable
             "mongoc_log_trace_disable" () void)

;;mongoc_stream_t* mongoc_stream_buffered_new(mongoc_stream_t* base_stream ,size_t buffer_size)
(def-function mongoc-stream-buffered-new
             "mongoc_stream_buffered_new" (void* int) void*)

;;mongoc_stream_t* mongoc_stream_file_new(int fd)
(def-function mongoc-stream-file-new
             "mongoc_stream_file_new" (int) void*)

;;mongoc_stream_t* mongoc_stream_file_new_for_path(char* path ,int flags ,int mode)
(def-function mongoc-stream-file-new-for-path
             "mongoc_stream_file_new_for_path" (string int int) void*)

;;int mongoc_stream_file_get_fd(mongoc_stream_file_t* stream)
(def-function mongoc-stream-file-get-fd
             "mongoc_stream_file_get_fd" (void*) int)

;;mongoc_stream_t* mongoc_stream_gridfs_new(mongoc_gridfs_file_t* file)
(def-function mongoc-stream-gridfs-new
             "mongoc_stream_gridfs_new" (void*) void*)

;;mongoc_stream_t* mongoc_stream_socket_new(mongoc_socket_t* socket)
(def-function mongoc-stream-socket-new
             "mongoc_stream_socket_new" (void*) void*)

;;mongoc_socket_t* mongoc_stream_socket_get_socket(mongoc_stream_socket_t* stream)
(def-function mongoc-stream-socket-get-socket
             "mongoc_stream_socket_get_socket" (void*) void*)

;;int mongoc_get_major_version()
(def-function mongoc-get-major-version
             "mongoc_get_major_version" () int)

;;int mongoc_get_minor_version()
(def-function mongoc-get-minor-version
             "mongoc_get_minor_version" () int)

;;int mongoc_get_micro_version()
(def-function mongoc-get-micro-version
             "mongoc_get_micro_version" () int)

;;char* mongoc_get_version()
(def-function mongoc-get-version
             "mongoc_get_version" () string)

;;bool mongoc_check_version(int required_major ,int required_minor ,int required_micro)
(def-function mongoc-check-version
             "mongoc_check_version" (int int int) int)

;;void mongoc_rand_seed(void* buf ,int num)
(def-function mongoc-rand-seed
             "mongoc_rand_seed" (void* int) void)

;;void mongoc_rand_add(void* buf ,int num ,double entropy)
(def-function mongoc-rand-add
             "mongoc_rand_add" (void* int double) void)

;;int mongoc_rand_status()
(def-function mongoc-rand-status
             "mongoc_rand_status" () int)

;;bool mongoc_stream_tls_handshake(mongoc_stream_t* stream ,char* host ,int32_t timeout_msec ,int* events ,bson_error_t* error)
(def-function mongoc-stream-tls-handshake
             "mongoc_stream_tls_handshake" (void* string int void* void*) int)

;;bool mongoc_stream_tls_handshake_block(mongoc_stream_t* stream ,char* host ,int32_t timeout_msec ,bson_error_t* error)
(def-function mongoc-stream-tls-handshake-block
             "mongoc_stream_tls_handshake_block" (void* string int void*) int)

;;bool mongoc_stream_tls_do_handshake(mongoc_stream_t* stream ,int32_t timeout_msec)
(def-function mongoc-stream-tls-do-handshake
             "mongoc_stream_tls_do_handshake" (void* int) int)

;;bool mongoc_stream_tls_check_cert(mongoc_stream_t* stream ,char* host)
(def-function mongoc-stream-tls-check-cert
             "mongoc_stream_tls_check_cert" (void* string) int)

;;mongoc_stream_t* mongoc_stream_tls_new_with_hostname(mongoc_stream_t* base_stream ,char* host ,mongoc_ssl_opt_t* opt ,int client)
(def-function mongoc-stream-tls-new-with-hostname
             "mongoc_stream_tls_new_with_hostname" (void* string void* int) void*)

;;mongoc_stream_t* mongoc_stream_tls_new(mongoc_stream_t* base_stream ,mongoc_ssl_opt_t* opt ,int client)
(def-function mongoc-stream-tls-new
             "mongoc_stream_tls_new" (void* void* int) void*)



 
)


