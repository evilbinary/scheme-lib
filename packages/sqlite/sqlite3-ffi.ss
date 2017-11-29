;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-09-02 10:57:19.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (sqlite sqlite3-ffi ) 
  (export sqlite3-libversion
  sqlite3-sourceid
  sqlite3-libversion-number
  sqlite3-compileoption-used
  sqlite3-compileoption-get
  sqlite3-threadsafe
  sqlite3-close
  sqlite3-close-v2
  sqlite3-exec
  sqlite3-initialize
  sqlite3-shutdown
  sqlite3-os-init
  sqlite3-os-end
  sqlite3-config
  sqlite3-db-config
  sqlite3-extended-result-codes
  sqlite3-last-insert-rowid
  sqlite3-set-last-insert-rowid
  sqlite3-changes
  sqlite3-total-changes
  sqlite3-interrupt
  sqlite3-complete
  sqlite3-complete16
  sqlite3-busy-handler
  sqlite3-busy-timeout
  sqlite3-get-table
  sqlite3-free-table
  sqlite3-mprintf
  sqlite3-vmprintf
  sqlite3-snprintf
  sqlite3-vsnprintf
  sqlite3-malloc
  sqlite3-malloc64
  sqlite3-realloc
  sqlite3-realloc64
  sqlite3-free
  sqlite3-msize
  sqlite3-memory-used
  sqlite3-memory-highwater
  sqlite3-randomness
  sqlite3-set-authorizer
  sqlite3-trace
  sqlite3-profile
  sqlite3-trace-v2
  sqlite3-progress-handler
  sqlite3-open
  sqlite3-open16
  sqlite3-open-v2
  sqlite3-uri-parameter
  sqlite3-uri-boolean
  sqlite3-uri-int64
  sqlite3-errcode
  sqlite3-extended-errcode
  sqlite3-errmsg
  sqlite3-errmsg16
  sqlite3-errstr
  sqlite3-limit
  sqlite3-prepare
  sqlite3-prepare-v2
  sqlite3-prepare16
  sqlite3-prepare16-v2
  sqlite3-sql
  sqlite3-expanded-sql
  sqlite3-stmt-readonly
  sqlite3-stmt-busy
  sqlite3-bind-blob
  sqlite3-bind-blob64
  sqlite3-bind-double
  sqlite3-bind-int
  sqlite3-bind-int64
  sqlite3-bind-null
  sqlite3-bind-text
  sqlite3-bind-text16
  sqlite3-bind-text64
  sqlite3-bind-value
  sqlite3-bind-zeroblob
  sqlite3-bind-zeroblob64
  sqlite3-bind-parameter-count
  sqlite3-bind-parameter-name
  sqlite3-bind-parameter-index
  sqlite3-clear-bindings
  sqlite3-column-count
  sqlite3-column-name
  sqlite3-column-name16
  sqlite3-column-database-name
  sqlite3-column-database-name16
  sqlite3-column-table-name
  sqlite3-column-table-name16
  sqlite3-column-origin-name
  sqlite3-column-origin-name16
  sqlite3-column-decltype
  sqlite3-column-decltype16
  sqlite3-step
  sqlite3-data-count
  sqlite3-column-blob
  sqlite3-column-bytes
  sqlite3-column-bytes16
  sqlite3-column-double
  sqlite3-column-int
  sqlite3-column-int64
  sqlite3-column-text
  sqlite3-column-text16
  sqlite3-column-type
  sqlite3-column-value
  sqlite3-finalize
  sqlite3-reset
  sqlite3-create-function
  sqlite3-create-function16
  sqlite3-create-function-v2
  sqlite3-aggregate-count
  sqlite3-expired
  sqlite3-transfer-bindings
  sqlite3-global-recover
  sqlite3-thread-cleanup
  sqlite3-memory-alarm
  sqlite3-value-blob
  sqlite3-value-bytes
  sqlite3-value-bytes16
  sqlite3-value-double
  sqlite3-value-int
  sqlite3-value-int64
  sqlite3-value-text
  sqlite3-value-text16
  sqlite3-value-text16le
  sqlite3-value-text16be
  sqlite3-value-type
  sqlite3-value-numeric-type
  sqlite3-value-subtype
  sqlite3-value-dup
  sqlite3-value-free
  sqlite3-aggregate-context
  sqlite3-user-data
  sqlite3-context-db-handle
  sqlite3-get-auxdata
  sqlite3-set-auxdata
  sqlite3-result-blob
  sqlite3-result-blob64
  sqlite3-result-double
  sqlite3-result-error
  sqlite3-result-error16
  sqlite3-result-error-toobig
  sqlite3-result-error-nomem
  sqlite3-result-error-code
  sqlite3-result-int
  sqlite3-result-int64
  sqlite3-result-null
  sqlite3-result-text
  sqlite3-result-text64
  sqlite3-result-text16
  sqlite3-result-text16le
  sqlite3-result-text16be
  sqlite3-result-value
  sqlite3-result-zeroblob
  sqlite3-result-zeroblob64
  sqlite3-result-subtype
  sqlite3-create-collation
  sqlite3-create-collation-v2
  sqlite3-create-collation16
  sqlite3-collation-needed
  sqlite3-collation-needed16
  sqlite3-sleep
  sqlite3-get-autocommit
  sqlite3-db-handle
  sqlite3-db-filename
  sqlite3-db-readonly
  sqlite3-next-stmt
  sqlite3-commit-hook
  sqlite3-rollback-hook
  sqlite3-update-hook
  sqlite3-enable-shared-cache
  sqlite3-release-memory
  sqlite3-db-release-memory
  sqlite3-soft-heap-limit64
  sqlite3-soft-heap-limit
  sqlite3-table-column-metadata
  sqlite3-load-extension
  sqlite3-enable-load-extension
  sqlite3-auto-extension
  sqlite3-cancel-auto-extension
  sqlite3-reset-auto-extension
  sqlite3-create-module
  sqlite3-create-module-v2
  sqlite3-declare-vtab
  sqlite3-overload-function
  sqlite3-blob-open
  sqlite3-blob-reopen
  sqlite3-blob-close
  sqlite3-blob-bytes
  sqlite3-blob-read
  sqlite3-blob-write
  sqlite3-vfs-find
  sqlite3-vfs-register
  sqlite3-vfs-unregister
  sqlite3-mutex-alloc
  sqlite3-mutex-free
  sqlite3-mutex-enter
  sqlite3-mutex-try
  sqlite3-mutex-leave
  sqlite3-mutex-held
  sqlite3-mutex-notheld
  sqlite3-db-mutex
  sqlite3-file-control
  sqlite3-test-control
  sqlite3-status
  sqlite3-status64
  sqlite3-db-status
  sqlite3-stmt-status
  sqlite3-backup-init
  sqlite3-backup-step
  sqlite3-backup-finish
  sqlite3-backup-remaining
  sqlite3-backup-pagecount
  sqlite3-unlock-notify
  sqlite3-stricmp
  sqlite3-strnicmp
  sqlite3-strglob
  sqlite3-strlike
  sqlite3-log
  sqlite3-wal-hook
  sqlite3-wal-autocheckpoint
  sqlite3-wal-checkpoint
  sqlite3-wal-checkpoint-v2
  sqlite3-vtab-config
  sqlite3-vtab-on-conflict
  sqlite3-stmt-scanstatus
  sqlite3-stmt-scanstatus-reset
  sqlite3-db-cacheflush
  sqlite3-system-errno
  sqlite3-snapshot-get
  sqlite3-snapshot-open
  sqlite3-snapshot-free
  sqlite3-snapshot-cmp
  sqlite3-snapshot-recover
  sqlite3-rtree-geometry-callback
  sqlite3-rtree-query-callback)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libsqlite3.so")
   ((a6nt i3nt ta6nt ti3nt) "libsqlite3.dll")
   ((a6osx i3osx ta6osx ti3osx)  "libsqlite3.dylib")
   ((a6le i3le ta6le ti3le) "libsqlite3.so")))
 (define lib (load-librarys  lib-name ))

;;char* sqlite3_libversion(void )
(def-function sqlite3-libversion
             "sqlite3_libversion" (void) string)

;;char* sqlite3_sourceid(void )
(def-function sqlite3-sourceid
             "sqlite3_sourceid" (void) string)

;;int sqlite3_libversion_number(void )
(def-function sqlite3-libversion-number
             "sqlite3_libversion_number" (void) int)

;;int sqlite3_compileoption_used(char* zOptName)
(def-function sqlite3-compileoption-used
             "sqlite3_compileoption_used" (string) int)

;;char* sqlite3_compileoption_get(int N)
(def-function sqlite3-compileoption-get
             "sqlite3_compileoption_get" (int) string)

;;int sqlite3_threadsafe(void )
(def-function sqlite3-threadsafe
             "sqlite3_threadsafe" (void) int)

;;int sqlite3_close(sqlite3* )
(def-function sqlite3-close
             "sqlite3_close" (void*) int)

;;int sqlite3_close_v2(sqlite3* )
(def-function sqlite3-close-v2
             "sqlite3_close_v2" (void*) int)

;;int sqlite3_exec(sqlite3*  ,char* sql ,void*  ,char errmsg)
(def-function sqlite3-exec
             "sqlite3_exec" (void* string void* void* void*) int)

;;int sqlite3_initialize(void )
(def-function sqlite3-initialize
             "sqlite3_initialize" (void) int)

;;int sqlite3_shutdown(void )
(def-function sqlite3-shutdown
             "sqlite3_shutdown" (void) int)

;;int sqlite3_os_init(void )
(def-function sqlite3-os-init
             "sqlite3_os_init" (void) int)

;;int sqlite3_os_end(void )
(def-function sqlite3-os-end
             "sqlite3_os_end" (void) int)

;;int sqlite3_config(int )
(def-function sqlite3-config
             "sqlite3_config" (int) int)

;;int sqlite3_db_config(sqlite3*  ,int op)
(def-function sqlite3-db-config
             "sqlite3_db_config" (void* int) int)

;;int sqlite3_extended_result_codes(sqlite3*  ,int onoff)
(def-function sqlite3-extended-result-codes
             "sqlite3_extended_result_codes" (void* int) int)

;;sqlite3_int64 sqlite3_last_insert_rowid(sqlite3* )
(def-function sqlite3-last-insert-rowid
             "sqlite3_last_insert_rowid" (void*) int64)

;;void sqlite3_set_last_insert_rowid(sqlite3*  ,sqlite3_int64 )
(def-function sqlite3-set-last-insert-rowid
             "sqlite3_set_last_insert_rowid" (void* int64) void)

;;int sqlite3_changes(sqlite3* )
(def-function sqlite3-changes
             "sqlite3_changes" (void*) int)

;;int sqlite3_total_changes(sqlite3* )
(def-function sqlite3-total-changes
             "sqlite3_total_changes" (void*) int)

;;void sqlite3_interrupt(sqlite3* )
(def-function sqlite3-interrupt
             "sqlite3_interrupt" (void*) void)

;;int sqlite3_complete(char* sql)
(def-function sqlite3-complete
             "sqlite3_complete" (string) int)

;;int sqlite3_complete16(void* sql)
(def-function sqlite3-complete16
             "sqlite3_complete16" (void*) int)

;;int sqlite3_busy_handler(sqlite3*  ,void* )
(def-function sqlite3-busy-handler
             "sqlite3_busy_handler" (void* void*) int)

;;int sqlite3_busy_timeout(sqlite3*  ,int ms)
(def-function sqlite3-busy-timeout
             "sqlite3_busy_timeout" (void* int) int)

;;int sqlite3_get_table(sqlite3* db ,char* zSql ,int* pnRow ,int* pnColumn ,char pzErrmsg)
(def-function sqlite3-get-table
             "sqlite3_get_table" (void* string void* void* char) int)

;;void sqlite3_free_table(char result)
(def-function sqlite3-free-table
             "sqlite3_free_table" (char) void)

;;char* sqlite3_mprintf(char* )
(def-function sqlite3-mprintf
             "sqlite3_mprintf" (string) string)

;;char* sqlite3_vmprintf(char*  ,va_list )
(def-function sqlite3-vmprintf
             "sqlite3_vmprintf" (string va_list) string)

;;char* sqlite3_snprintf(int  ,char*  ,char* )
(def-function sqlite3-snprintf
             "sqlite3_snprintf" (int string string) string)

;;char* sqlite3_vsnprintf(int  ,char*  ,char*  ,va_list )
(def-function sqlite3-vsnprintf
             "sqlite3_vsnprintf" (int string string va_list) string)

;;void* sqlite3_malloc(int )
(def-function sqlite3-malloc
             "sqlite3_malloc" (int) void*)

;;void* sqlite3_malloc64(sqlite3_uint64 )
(def-function sqlite3-malloc64
             "sqlite3_malloc64" (int64) void*)

;;void* sqlite3_realloc(void*  ,int )
(def-function sqlite3-realloc
             "sqlite3_realloc" (void* int) void*)

;;void* sqlite3_realloc64(void*  ,sqlite3_uint64 )
(def-function sqlite3-realloc64
             "sqlite3_realloc64" (void* int64) void*)

;;void sqlite3_free(void* )
(def-function sqlite3-free
             "sqlite3_free" (void*) void)

;;sqlite3_uint64 sqlite3_msize(void* )
(def-function sqlite3-msize
             "sqlite3_msize" (void*) int64)

;;sqlite3_int64 sqlite3_memory_used(void )
(def-function sqlite3-memory-used
             "sqlite3_memory_used" (void) int64)

;;sqlite3_int64 sqlite3_memory_highwater(int resetFlag)
(def-function sqlite3-memory-highwater
             "sqlite3_memory_highwater" (int) int64)

;;void sqlite3_randomness(int N ,void* P)
(def-function sqlite3-randomness
             "sqlite3_randomness" (int void*) void)

;;int sqlite3_set_authorizer(sqlite3*  ,void* pUserData)
(def-function sqlite3-set-authorizer
             "sqlite3_set_authorizer" (void* void*) int)

;;void* sqlite3_trace(sqlite3*  ,void* )
(def-function sqlite3-trace
             "sqlite3_trace" (void* void*) void*)

;;void* sqlite3_profile(sqlite3*  ,void* )
(def-function sqlite3-profile
             "sqlite3_profile" (void* void*) void*)

;;int sqlite3_trace_v2(sqlite3*  ,unsigned uMask ,void* pCtx)
(def-function sqlite3-trace-v2
             "sqlite3_trace_v2" (void* int void*) int)

;;void sqlite3_progress_handler(sqlite3*  ,int  ,void* )
(def-function sqlite3-progress-handler
             "sqlite3_progress_handler" (void* int void*) void)

;;int sqlite3_open(char* filename ,sqlite3 ppDb)
(def-function sqlite3-open
             "sqlite3_open" (string void*) int)

;;int sqlite3_open16(void* filename ,sqlite3 ppDb)
(def-function sqlite3-open16
             "sqlite3_open16" (void* void*) int)

;;int sqlite3_open_v2(char* filename ,sqlite3 ppDb ,int flags ,char* zVfs)
(def-function sqlite3-open-v2
             "sqlite3_open_v2" (string void* int string) int)

;;char* sqlite3_uri_parameter(char* zFilename ,char* zParam)
(def-function sqlite3-uri-parameter
             "sqlite3_uri_parameter" (string string) string)

;;int sqlite3_uri_boolean(char* zFile ,char* zParam ,int bDefault)
(def-function sqlite3-uri-boolean
             "sqlite3_uri_boolean" (string string int) int)

;;sqlite3_int64 sqlite3_uri_int64(char*  ,char*  ,sqlite3_int64 )
(def-function sqlite3-uri-int64
             "sqlite3_uri_int64" (string string int64) int64)

;;int sqlite3_errcode(sqlite3* db)
(def-function sqlite3-errcode
             "sqlite3_errcode" (void*) int)

;;int sqlite3_extended_errcode(sqlite3* db)
(def-function sqlite3-extended-errcode
             "sqlite3_extended_errcode" (void*) int)

;;char* sqlite3_errmsg(sqlite3* )
(def-function sqlite3-errmsg
             "sqlite3_errmsg" (void*) string)

;;void* sqlite3_errmsg16(sqlite3* )
(def-function sqlite3-errmsg16
             "sqlite3_errmsg16" (void*) void*)

;;char* sqlite3_errstr(int )
(def-function sqlite3-errstr
             "sqlite3_errstr" (int) string)

;;int sqlite3_limit(sqlite3*  ,int id ,int newVal)
(def-function sqlite3-limit
             "sqlite3_limit" (void* int int) int)

;;int sqlite3_prepare(sqlite3* db ,char* zSql ,int nByte ,sqlite3_stmt ppStmt ,char pzTail)
(def-function sqlite3-prepare
             "sqlite3_prepare" (void* string int sqlite3_stmt char) int)

;;int sqlite3_prepare_v2(sqlite3* db ,char* zSql ,int nByte ,sqlite3_stmt ppStmt ,char pzTail)
(def-function sqlite3-prepare-v2
             "sqlite3_prepare_v2" (void* string int sqlite3_stmt char) int)

;;int sqlite3_prepare16(sqlite3* db ,void* zSql ,int nByte ,sqlite3_stmt ppStmt ,void pzTail)
(def-function sqlite3-prepare16
             "sqlite3_prepare16" (void* void* int sqlite3_stmt void) int)

;;int sqlite3_prepare16_v2(sqlite3* db ,void* zSql ,int nByte ,sqlite3_stmt ppStmt ,void pzTail)
(def-function sqlite3-prepare16-v2
             "sqlite3_prepare16_v2" (void* void* int sqlite3_stmt void) int)

;;char* sqlite3_sql(sqlite3_stmt* pStmt)
(def-function sqlite3-sql
             "sqlite3_sql" (void*) string)

;;char* sqlite3_expanded_sql(sqlite3_stmt* pStmt)
(def-function sqlite3-expanded-sql
             "sqlite3_expanded_sql" (void*) string)

;;int sqlite3_stmt_readonly(sqlite3_stmt* pStmt)
(def-function sqlite3-stmt-readonly
             "sqlite3_stmt_readonly" (void*) int)

;;int sqlite3_stmt_busy(sqlite3_stmt* )
(def-function sqlite3-stmt-busy
             "sqlite3_stmt_busy" (void*) int)

;;int sqlite3_bind_blob(sqlite3_stmt*  ,int  ,void*  ,int n)
(def-function sqlite3-bind-blob
             "sqlite3_bind_blob" (void* int void* int) int)

;;int sqlite3_bind_blob64(sqlite3_stmt*  ,int  ,void*  ,sqlite3_uint64 )
(def-function sqlite3-bind-blob64
             "sqlite3_bind_blob64" (void* int void* int64) int)

;;int sqlite3_bind_double(sqlite3_stmt*  ,int  ,double )
(def-function sqlite3-bind-double
             "sqlite3_bind_double" (void* int double) int)

;;int sqlite3_bind_int(sqlite3_stmt*  ,int  ,int )
(def-function sqlite3-bind-int
             "sqlite3_bind_int" (void* int int) int)

;;int sqlite3_bind_int64(sqlite3_stmt*  ,int  ,sqlite3_int64 )
(def-function sqlite3-bind-int64
             "sqlite3_bind_int64" (void* int int64) int)

;;int sqlite3_bind_null(sqlite3_stmt*  ,int )
(def-function sqlite3-bind-null
             "sqlite3_bind_null" (void* int) int)

;;int sqlite3_bind_text(sqlite3_stmt*  ,int  ,char*  ,int )
(def-function sqlite3-bind-text
             "sqlite3_bind_text" (void* int string int) int)

;;int sqlite3_bind_text16(sqlite3_stmt*  ,int  ,void*  ,int )
(def-function sqlite3-bind-text16
             "sqlite3_bind_text16" (void* int void* int) int)

;;int sqlite3_bind_text64(sqlite3_stmt*  ,int  ,char*  ,sqlite3_uint64  ,unsigned char encoding)
(def-function sqlite3-bind-text64
             "sqlite3_bind_text64" (void* int string int64 int) int)

;;int sqlite3_bind_value(sqlite3_stmt*  ,int  ,sqlite3_value* )
(def-function sqlite3-bind-value
             "sqlite3_bind_value" (void* int void*) int)

;;int sqlite3_bind_zeroblob(sqlite3_stmt*  ,int  ,int n)
(def-function sqlite3-bind-zeroblob
             "sqlite3_bind_zeroblob" (void* int int) int)

;;int sqlite3_bind_zeroblob64(sqlite3_stmt*  ,int  ,sqlite3_uint64 )
(def-function sqlite3-bind-zeroblob64
             "sqlite3_bind_zeroblob64" (void* int int64) int)

;;int sqlite3_bind_parameter_count(sqlite3_stmt* )
(def-function sqlite3-bind-parameter-count
             "sqlite3_bind_parameter_count" (void*) int)

;;char* sqlite3_bind_parameter_name(sqlite3_stmt*  ,int )
(def-function sqlite3-bind-parameter-name
             "sqlite3_bind_parameter_name" (void* int) string)

;;int sqlite3_bind_parameter_index(sqlite3_stmt*  ,char* zName)
(def-function sqlite3-bind-parameter-index
             "sqlite3_bind_parameter_index" (void* string) int)

;;int sqlite3_clear_bindings(sqlite3_stmt* )
(def-function sqlite3-clear-bindings
             "sqlite3_clear_bindings" (void*) int)

;;int sqlite3_column_count(sqlite3_stmt* pStmt)
(def-function sqlite3-column-count
             "sqlite3_column_count" (void*) int)

;;char* sqlite3_column_name(sqlite3_stmt*  ,int N)
(def-function sqlite3-column-name
             "sqlite3_column_name" (void* int) string)

;;void* sqlite3_column_name16(sqlite3_stmt*  ,int N)
(def-function sqlite3-column-name16
             "sqlite3_column_name16" (void* int) void*)

;;char* sqlite3_column_database_name(sqlite3_stmt*  ,int )
(def-function sqlite3-column-database-name
             "sqlite3_column_database_name" (void* int) string)

;;void* sqlite3_column_database_name16(sqlite3_stmt*  ,int )
(def-function sqlite3-column-database-name16
             "sqlite3_column_database_name16" (void* int) void*)

;;char* sqlite3_column_table_name(sqlite3_stmt*  ,int )
(def-function sqlite3-column-table-name
             "sqlite3_column_table_name" (void* int) string)

;;void* sqlite3_column_table_name16(sqlite3_stmt*  ,int )
(def-function sqlite3-column-table-name16
             "sqlite3_column_table_name16" (void* int) void*)

;;char* sqlite3_column_origin_name(sqlite3_stmt*  ,int )
(def-function sqlite3-column-origin-name
             "sqlite3_column_origin_name" (void* int) string)

;;void* sqlite3_column_origin_name16(sqlite3_stmt*  ,int )
(def-function sqlite3-column-origin-name16
             "sqlite3_column_origin_name16" (void* int) void*)

;;char* sqlite3_column_decltype(sqlite3_stmt*  ,int )
(def-function sqlite3-column-decltype
             "sqlite3_column_decltype" (void* int) string)

;;void* sqlite3_column_decltype16(sqlite3_stmt*  ,int )
(def-function sqlite3-column-decltype16
             "sqlite3_column_decltype16" (void* int) void*)

;;int sqlite3_step(sqlite3_stmt* )
(def-function sqlite3-step
             "sqlite3_step" (void*) int)

;;int sqlite3_data_count(sqlite3_stmt* pStmt)
(def-function sqlite3-data-count
             "sqlite3_data_count" (void*) int)

;;void* sqlite3_column_blob(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-blob
             "sqlite3_column_blob" (void* int) void*)

;;int sqlite3_column_bytes(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-bytes
             "sqlite3_column_bytes" (void* int) int)

;;int sqlite3_column_bytes16(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-bytes16
             "sqlite3_column_bytes16" (void* int) int)

;;double sqlite3_column_double(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-double
             "sqlite3_column_double" (void* int) double)

;;int sqlite3_column_int(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-int
             "sqlite3_column_int" (void* int) int)

;;sqlite3_int64 sqlite3_column_int64(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-int64
             "sqlite3_column_int64" (void* int) int64)

;;unsigned* sqlite3_column_text(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-text
             "sqlite3_column_text" (void* int) void*)

;;void* sqlite3_column_text16(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-text16
             "sqlite3_column_text16" (void* int) void*)

;;int sqlite3_column_type(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-type
             "sqlite3_column_type" (void* int) int)

;;sqlite3_value* sqlite3_column_value(sqlite3_stmt*  ,int iCol)
(def-function sqlite3-column-value
             "sqlite3_column_value" (void* int) void*)

;;int sqlite3_finalize(sqlite3_stmt* pStmt)
(def-function sqlite3-finalize
             "sqlite3_finalize" (void*) int)

;;int sqlite3_reset(sqlite3_stmt* pStmt)
(def-function sqlite3-reset
             "sqlite3_reset" (void*) int)

;;int sqlite3_create_function(sqlite3* db ,char* zFunctionName ,int nArg ,int eTextRep ,void* pApp)
(def-function sqlite3-create-function
             "sqlite3_create_function" (void* string int int void*) int)

;;int sqlite3_create_function16(sqlite3* db ,void* zFunctionName ,int nArg ,int eTextRep ,void* pApp)
(def-function sqlite3-create-function16
             "sqlite3_create_function16" (void* void* int int void*) int)

;;int sqlite3_create_function_v2(sqlite3* db ,char* zFunctionName ,int nArg ,int eTextRep ,void* pApp)
(def-function sqlite3-create-function-v2
             "sqlite3_create_function_v2" (void* string int int void*) int)

;;int sqlite3_aggregate_count(sqlite3_context* )
(def-function sqlite3-aggregate-count
             "sqlite3_aggregate_count" (void*) int)

;;int sqlite3_expired(sqlite3_stmt* )
(def-function sqlite3-expired
             "sqlite3_expired" (void*) int)

;;int sqlite3_transfer_bindings(sqlite3_stmt*  ,sqlite3_stmt* )
(def-function sqlite3-transfer-bindings
             "sqlite3_transfer_bindings" (void* void*) int)

;;int sqlite3_global_recover(void )
(def-function sqlite3-global-recover
             "sqlite3_global_recover" (void) int)

;;void sqlite3_thread_cleanup(void )
(def-function sqlite3-thread-cleanup
             "sqlite3_thread_cleanup" (void) void)

;;int sqlite3_memory_alarm(void*  ,sqlite3_int64 )
(def-function sqlite3-memory-alarm
             "sqlite3_memory_alarm" (void* int64) int)

;;void* sqlite3_value_blob(sqlite3_value* )
(def-function sqlite3-value-blob
             "sqlite3_value_blob" (void*) void*)

;;int sqlite3_value_bytes(sqlite3_value* )
(def-function sqlite3-value-bytes
             "sqlite3_value_bytes" (void*) int)

;;int sqlite3_value_bytes16(sqlite3_value* )
(def-function sqlite3-value-bytes16
             "sqlite3_value_bytes16" (void*) int)

;;double sqlite3_value_double(sqlite3_value* )
(def-function sqlite3-value-double
             "sqlite3_value_double" (void*) double)

;;int sqlite3_value_int(sqlite3_value* )
(def-function sqlite3-value-int
             "sqlite3_value_int" (void*) int)

;;sqlite3_int64 sqlite3_value_int64(sqlite3_value* )
(def-function sqlite3-value-int64
             "sqlite3_value_int64" (void*) int64)

;;unsigned* sqlite3_value_text(sqlite3_value* )
(def-function sqlite3-value-text
             "sqlite3_value_text" (void*) void*)

;;void* sqlite3_value_text16(sqlite3_value* )
(def-function sqlite3-value-text16
             "sqlite3_value_text16" (void*) void*)

;;void* sqlite3_value_text16le(sqlite3_value* )
(def-function sqlite3-value-text16le
             "sqlite3_value_text16le" (void*) void*)

;;void* sqlite3_value_text16be(sqlite3_value* )
(def-function sqlite3-value-text16be
             "sqlite3_value_text16be" (void*) void*)

;;int sqlite3_value_type(sqlite3_value* )
(def-function sqlite3-value-type
             "sqlite3_value_type" (void*) int)

;;int sqlite3_value_numeric_type(sqlite3_value* )
(def-function sqlite3-value-numeric-type
             "sqlite3_value_numeric_type" (void*) int)

;;unsigned sqlite3_value_subtype(sqlite3_value* )
(def-function sqlite3-value-subtype
             "sqlite3_value_subtype" (void*) int)

;;sqlite3_value* sqlite3_value_dup(sqlite3_value* )
(def-function sqlite3-value-dup
             "sqlite3_value_dup" (void*) void*)

;;void sqlite3_value_free(sqlite3_value* )
(def-function sqlite3-value-free
             "sqlite3_value_free" (void*) void)

;;void* sqlite3_aggregate_context(sqlite3_context*  ,int nBytes)
(def-function sqlite3-aggregate-context
             "sqlite3_aggregate_context" (void* int) void*)

;;void* sqlite3_user_data(sqlite3_context* )
(def-function sqlite3-user-data
             "sqlite3_user_data" (void*) void*)

;;sqlite3* sqlite3_context_db_handle(sqlite3_context* )
(def-function sqlite3-context-db-handle
             "sqlite3_context_db_handle" (void*) void*)

;;void* sqlite3_get_auxdata(sqlite3_context*  ,int N)
(def-function sqlite3-get-auxdata
             "sqlite3_get_auxdata" (void* int) void*)

;;void sqlite3_set_auxdata(sqlite3_context*  ,int N ,void* )
(def-function sqlite3-set-auxdata
             "sqlite3_set_auxdata" (void* int void*) void)

;;void sqlite3_result_blob(sqlite3_context*  ,void*  ,int )
(def-function sqlite3-result-blob
             "sqlite3_result_blob" (void* void* int) void)

;;void sqlite3_result_blob64(sqlite3_context*  ,void*  ,sqlite3_uint64 )
(def-function sqlite3-result-blob64
             "sqlite3_result_blob64" (void* void* int64) void)

;;void sqlite3_result_double(sqlite3_context*  ,double )
(def-function sqlite3-result-double
             "sqlite3_result_double" (void* double) void)

;;void sqlite3_result_error(sqlite3_context*  ,char*  ,int )
(def-function sqlite3-result-error
             "sqlite3_result_error" (void* string int) void)

;;void sqlite3_result_error16(sqlite3_context*  ,void*  ,int )
(def-function sqlite3-result-error16
             "sqlite3_result_error16" (void* void* int) void)

;;void sqlite3_result_error_toobig(sqlite3_context* )
(def-function sqlite3-result-error-toobig
             "sqlite3_result_error_toobig" (void*) void)

;;void sqlite3_result_error_nomem(sqlite3_context* )
(def-function sqlite3-result-error-nomem
             "sqlite3_result_error_nomem" (void*) void)

;;void sqlite3_result_error_code(sqlite3_context*  ,int )
(def-function sqlite3-result-error-code
             "sqlite3_result_error_code" (void* int) void)

;;void sqlite3_result_int(sqlite3_context*  ,int )
(def-function sqlite3-result-int
             "sqlite3_result_int" (void* int) void)

;;void sqlite3_result_int64(sqlite3_context*  ,sqlite3_int64 )
(def-function sqlite3-result-int64
             "sqlite3_result_int64" (void* int64) void)

;;void sqlite3_result_null(sqlite3_context* )
(def-function sqlite3-result-null
             "sqlite3_result_null" (void*) void)

;;void sqlite3_result_text(sqlite3_context*  ,char*  ,int )
(def-function sqlite3-result-text
             "sqlite3_result_text" (void* string int) void)

;;void sqlite3_result_text64(sqlite3_context*  ,char*  ,sqlite3_uint64  ,unsigned char encoding)
(def-function sqlite3-result-text64
             "sqlite3_result_text64" (void* string int64 int) void)

;;void sqlite3_result_text16(sqlite3_context*  ,void*  ,int )
(def-function sqlite3-result-text16
             "sqlite3_result_text16" (void* void* int) void)

;;void sqlite3_result_text16le(sqlite3_context*  ,void*  ,int )
(def-function sqlite3-result-text16le
             "sqlite3_result_text16le" (void* void* int) void)

;;void sqlite3_result_text16be(sqlite3_context*  ,void*  ,int )
(def-function sqlite3-result-text16be
             "sqlite3_result_text16be" (void* void* int) void)

;;void sqlite3_result_value(sqlite3_context*  ,sqlite3_value* )
(def-function sqlite3-result-value
             "sqlite3_result_value" (void* void*) void)

;;void sqlite3_result_zeroblob(sqlite3_context*  ,int n)
(def-function sqlite3-result-zeroblob
             "sqlite3_result_zeroblob" (void* int) void)

;;int sqlite3_result_zeroblob64(sqlite3_context*  ,sqlite3_uint64 n)
(def-function sqlite3-result-zeroblob64
             "sqlite3_result_zeroblob64" (void* int64) int)

;;void sqlite3_result_subtype(sqlite3_context*  ,unsigned int )
(def-function sqlite3-result-subtype
             "sqlite3_result_subtype" (void* int) void)

;;int sqlite3_create_collation(sqlite3*  ,char* zName ,int eTextRep ,void* pArg)
(def-function sqlite3-create-collation
             "sqlite3_create_collation" (void* string int void*) int)

;;int sqlite3_create_collation_v2(sqlite3*  ,char* zName ,int eTextRep ,void* pArg)
(def-function sqlite3-create-collation-v2
             "sqlite3_create_collation_v2" (void* string int void*) int)

;;int sqlite3_create_collation16(sqlite3*  ,void* zName ,int eTextRep ,void* pArg)
(def-function sqlite3-create-collation16
             "sqlite3_create_collation16" (void* void* int void*) int)

;;int sqlite3_collation_needed(sqlite3*  ,void* )
(def-function sqlite3-collation-needed
             "sqlite3_collation_needed" (void* void*) int)

;;int sqlite3_collation_needed16(sqlite3*  ,void* )
(def-function sqlite3-collation-needed16
             "sqlite3_collation_needed16" (void* void*) int)

;;int sqlite3_sleep(int )
(def-function sqlite3-sleep
             "sqlite3_sleep" (int) int)

;;int sqlite3_get_autocommit(sqlite3* )
(def-function sqlite3-get-autocommit
             "sqlite3_get_autocommit" (void*) int)

;;sqlite3* sqlite3_db_handle(sqlite3_stmt* )
(def-function sqlite3-db-handle
             "sqlite3_db_handle" (void*) void*)

;;char* sqlite3_db_filename(sqlite3* db ,char* zDbName)
(def-function sqlite3-db-filename
             "sqlite3_db_filename" (void* string) string)

;;int sqlite3_db_readonly(sqlite3* db ,char* zDbName)
(def-function sqlite3-db-readonly
             "sqlite3_db_readonly" (void* string) int)

;;sqlite3_stmt* sqlite3_next_stmt(sqlite3* pDb ,sqlite3_stmt* pStmt)
(def-function sqlite3-next-stmt
             "sqlite3_next_stmt" (void* void*) void*)

;;void* sqlite3_commit_hook(sqlite3*  ,void* )
(def-function sqlite3-commit-hook
             "sqlite3_commit_hook" (void* void*) void*)

;;void* sqlite3_rollback_hook(sqlite3*  ,void* )
(def-function sqlite3-rollback-hook
             "sqlite3_rollback_hook" (void* void*) void*)

;;void* sqlite3_update_hook(sqlite3*  ,void* )
(def-function sqlite3-update-hook
             "sqlite3_update_hook" (void* void*) void*)

;;int sqlite3_enable_shared_cache(int )
(def-function sqlite3-enable-shared-cache
             "sqlite3_enable_shared_cache" (int) int)

;;int sqlite3_release_memory(int )
(def-function sqlite3-release-memory
             "sqlite3_release_memory" (int) int)

;;int sqlite3_db_release_memory(sqlite3* )
(def-function sqlite3-db-release-memory
             "sqlite3_db_release_memory" (void*) int)

;;sqlite3_int64 sqlite3_soft_heap_limit64(sqlite3_int64 N)
(def-function sqlite3-soft-heap-limit64
             "sqlite3_soft_heap_limit64" (int64) int64)

;;void sqlite3_soft_heap_limit(int N)
(def-function sqlite3-soft-heap-limit
             "sqlite3_soft_heap_limit" (int) void)

;;int sqlite3_table_column_metadata(sqlite3* db ,char* zDbName ,char* zTableName ,char* zColumnName ,char pzDataType ,char pzCollSeq ,int* pNotNull ,int* pPrimaryKey ,int* pAutoinc)
(def-function sqlite3-table-column-metadata
             "sqlite3_table_column_metadata" (void* string string string char char void* void* void*) int)

;;int sqlite3_load_extension(sqlite3* db ,char* zFile ,char* zProc ,char pzErrMsg)
(def-function sqlite3-load-extension
             "sqlite3_load_extension" (void* string string char) int)

;;int sqlite3_enable_load_extension(sqlite3* db ,int onoff)
(def-function sqlite3-enable-load-extension
             "sqlite3_enable_load_extension" (void* int) int)

;;int sqlite3_auto_extension()
(def-function sqlite3-auto-extension
             "sqlite3_auto_extension" () int)

;;int sqlite3_cancel_auto_extension()
(def-function sqlite3-cancel-auto-extension
             "sqlite3_cancel_auto_extension" () int)

;;void sqlite3_reset_auto_extension(void )
(def-function sqlite3-reset-auto-extension
             "sqlite3_reset_auto_extension" (void) void)

;;int sqlite3_create_module(sqlite3* db ,char* zName ,sqlite3_module* p ,void* pClientData)
(def-function sqlite3-create-module
             "sqlite3_create_module" (void* string void* void*) int)

;;int sqlite3_create_module_v2(sqlite3* db ,char* zName ,sqlite3_module* p ,void* pClientData)
(def-function sqlite3-create-module-v2
             "sqlite3_create_module_v2" (void* string void* void*) int)

;;int sqlite3_declare_vtab(sqlite3*  ,char* zSQL)
(def-function sqlite3-declare-vtab
             "sqlite3_declare_vtab" (void* string) int)

;;int sqlite3_overload_function(sqlite3*  ,char* zFuncName ,int nArg)
(def-function sqlite3-overload-function
             "sqlite3_overload_function" (void* string int) int)

;;int sqlite3_blob_open(sqlite3*  ,char* zDb ,char* zTable ,char* zColumn ,sqlite3_int64 iRow ,int flags ,sqlite3_blob ppBlob)
(def-function sqlite3-blob-open
             "sqlite3_blob_open" (void* string string string int64 int sqlite3_blob) int)

;;int sqlite3_blob_reopen(sqlite3_blob*  ,sqlite3_int64 )
(def-function sqlite3-blob-reopen
             "sqlite3_blob_reopen" (void* int64) int)

;;int sqlite3_blob_close(sqlite3_blob* )
(def-function sqlite3-blob-close
             "sqlite3_blob_close" (void*) int)

;;int sqlite3_blob_bytes(sqlite3_blob* )
(def-function sqlite3-blob-bytes
             "sqlite3_blob_bytes" (void*) int)

;;int sqlite3_blob_read(sqlite3_blob*  ,void* Z ,int N ,int iOffset)
(def-function sqlite3-blob-read
             "sqlite3_blob_read" (void* void* int int) int)

;;int sqlite3_blob_write(sqlite3_blob*  ,void* z ,int n ,int iOffset)
(def-function sqlite3-blob-write
             "sqlite3_blob_write" (void* void* int int) int)

;;sqlite3_vfs* sqlite3_vfs_find(char* zVfsName)
(def-function sqlite3-vfs-find
             "sqlite3_vfs_find" (string) void*)

;;int sqlite3_vfs_register(sqlite3_vfs*  ,int makeDflt)
(def-function sqlite3-vfs-register
             "sqlite3_vfs_register" (void* int) int)

;;int sqlite3_vfs_unregister(sqlite3_vfs* )
(def-function sqlite3-vfs-unregister
             "sqlite3_vfs_unregister" (void*) int)

;;sqlite3_mutex* sqlite3_mutex_alloc(int )
(def-function sqlite3-mutex-alloc
             "sqlite3_mutex_alloc" (int) void*)

;;void sqlite3_mutex_free(sqlite3_mutex* )
(def-function sqlite3-mutex-free
             "sqlite3_mutex_free" (void*) void)

;;void sqlite3_mutex_enter(sqlite3_mutex* )
(def-function sqlite3-mutex-enter
             "sqlite3_mutex_enter" (void*) void)

;;int sqlite3_mutex_try(sqlite3_mutex* )
(def-function sqlite3-mutex-try
             "sqlite3_mutex_try" (void*) int)

;;void sqlite3_mutex_leave(sqlite3_mutex* )
(def-function sqlite3-mutex-leave
             "sqlite3_mutex_leave" (void*) void)

;;int sqlite3_mutex_held(sqlite3_mutex* )
(def-function sqlite3-mutex-held
             "sqlite3_mutex_held" (void*) int)

;;int sqlite3_mutex_notheld(sqlite3_mutex* )
(def-function sqlite3-mutex-notheld
             "sqlite3_mutex_notheld" (void*) int)

;;sqlite3_mutex* sqlite3_db_mutex(sqlite3* )
(def-function sqlite3-db-mutex
             "sqlite3_db_mutex" (void*) void*)

;;int sqlite3_file_control(sqlite3*  ,char* zDbName ,int op ,void* )
(def-function sqlite3-file-control
             "sqlite3_file_control" (void* string int void*) int)

;;int sqlite3_test_control(int op)
(def-function sqlite3-test-control
             "sqlite3_test_control" (int) int)

;;int sqlite3_status(int op ,int* pCurrent ,int* pHighwater ,int resetFlag)
(def-function sqlite3-status
             "sqlite3_status" (int void* void* int) int)

;;int sqlite3_status64(int op ,sqlite3_int64* pCurrent ,sqlite3_int64* pHighwater ,int resetFlag)
(def-function sqlite3-status64
             "sqlite3_status64" (int void* void* int) int)

;;int sqlite3_db_status(sqlite3*  ,int op ,int* pCur ,int* pHiwtr ,int resetFlg)
(def-function sqlite3-db-status
             "sqlite3_db_status" (void* int void* void* int) int)

;;int sqlite3_stmt_status(sqlite3_stmt*  ,int op ,int resetFlg)
(def-function sqlite3-stmt-status
             "sqlite3_stmt_status" (void* int int) int)

;;sqlite3_backup* sqlite3_backup_init(sqlite3* pDest ,char* zDestName ,sqlite3* pSource ,char* zSourceName)
(def-function sqlite3-backup-init
             "sqlite3_backup_init" (void* string void* string) void*)

;;int sqlite3_backup_step(sqlite3_backup* p ,int nPage)
(def-function sqlite3-backup-step
             "sqlite3_backup_step" (void* int) int)

;;int sqlite3_backup_finish(sqlite3_backup* p)
(def-function sqlite3-backup-finish
             "sqlite3_backup_finish" (void*) int)

;;int sqlite3_backup_remaining(sqlite3_backup* p)
(def-function sqlite3-backup-remaining
             "sqlite3_backup_remaining" (void*) int)

;;int sqlite3_backup_pagecount(sqlite3_backup* p)
(def-function sqlite3-backup-pagecount
             "sqlite3_backup_pagecount" (void*) int)

;;int sqlite3_unlock_notify(sqlite3* pBlocked ,void* pNotifyArg)
(def-function sqlite3-unlock-notify
             "sqlite3_unlock_notify" (void* void*) int)

;;int sqlite3_stricmp(char*  ,char* )
(def-function sqlite3-stricmp
             "sqlite3_stricmp" (string string) int)

;;int sqlite3_strnicmp(char*  ,char*  ,int )
(def-function sqlite3-strnicmp
             "sqlite3_strnicmp" (string string int) int)

;;int sqlite3_strglob(char* zGlob ,char* zStr)
(def-function sqlite3-strglob
             "sqlite3_strglob" (string string) int)

;;int sqlite3_strlike(char* zGlob ,char* zStr ,unsigned int cEsc)
(def-function sqlite3-strlike
             "sqlite3_strlike" (string string int) int)

;;void sqlite3_log(int iErrCode ,char* zFormat)
(def-function sqlite3-log
             "sqlite3_log" (int string) void)

;;void* sqlite3_wal_hook(sqlite3*  ,void* )
(def-function sqlite3-wal-hook
             "sqlite3_wal_hook" (void* void*) void*)

;;int sqlite3_wal_autocheckpoint(sqlite3* db ,int N)
(def-function sqlite3-wal-autocheckpoint
             "sqlite3_wal_autocheckpoint" (void* int) int)

;;int sqlite3_wal_checkpoint(sqlite3* db ,char* zDb)
(def-function sqlite3-wal-checkpoint
             "sqlite3_wal_checkpoint" (void* string) int)

;;int sqlite3_wal_checkpoint_v2(sqlite3* db ,char* zDb ,int eMode ,int* pnLog ,int* pnCkpt)
(def-function sqlite3-wal-checkpoint-v2
             "sqlite3_wal_checkpoint_v2" (void* string int void* void*) int)

;;int sqlite3_vtab_config(sqlite3*  ,int op)
(def-function sqlite3-vtab-config
             "sqlite3_vtab_config" (void* int) int)

;;int sqlite3_vtab_on_conflict(sqlite3* )
(def-function sqlite3-vtab-on-conflict
             "sqlite3_vtab_on_conflict" (void*) int)

;;int sqlite3_stmt_scanstatus(sqlite3_stmt* pStmt ,int idx ,int iScanStatusOp ,void* pOut)
(def-function sqlite3-stmt-scanstatus
             "sqlite3_stmt_scanstatus" (void* int int void*) int)

;;void sqlite3_stmt_scanstatus_reset(sqlite3_stmt* )
(def-function sqlite3-stmt-scanstatus-reset
             "sqlite3_stmt_scanstatus_reset" (void*) void)

;;int sqlite3_db_cacheflush(sqlite3* )
(def-function sqlite3-db-cacheflush
             "sqlite3_db_cacheflush" (void*) int)

;;int sqlite3_system_errno(sqlite3* )
(def-function sqlite3-system-errno
             "sqlite3_system_errno" (void*) int)

;;int sqlite3_snapshot_get(sqlite3* db ,char* zSchema ,sqlite3_snapshot ppSnapshot)
(def-function sqlite3-snapshot-get
             "sqlite3_snapshot_get" (void* string sqlite3_snapshot) int)

;;int sqlite3_snapshot_open(sqlite3* db ,char* zSchema ,sqlite3_snapshot* pSnapshot)
(def-function sqlite3-snapshot-open
             "sqlite3_snapshot_open" (void* string void*) int)

;;void sqlite3_snapshot_free(sqlite3_snapshot* )
(def-function sqlite3-snapshot-free
             "sqlite3_snapshot_free" (void*) void)

;;int sqlite3_snapshot_cmp(sqlite3_snapshot* p1 ,sqlite3_snapshot* p2)
(def-function sqlite3-snapshot-cmp
             "sqlite3_snapshot_cmp" (void* void*) int)

;;int sqlite3_snapshot_recover(sqlite3* db ,char* zDb)
(def-function sqlite3-snapshot-recover
             "sqlite3_snapshot_recover" (void* string) int)

;;int sqlite3_rtree_geometry_callback(sqlite3* db ,char* zGeom ,void* pContext)
(def-function sqlite3-rtree-geometry-callback
             "sqlite3_rtree_geometry_callback" (void* string void*) int)

;;int sqlite3_rtree_query_callback(sqlite3* db ,char* zQueryFunc ,void* pContext)
(def-function sqlite3-rtree-query-callback
             "sqlite3_rtree_query_callback" (void* string void*) int)


)
