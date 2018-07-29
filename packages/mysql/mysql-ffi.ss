;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-08-31 23:54:31.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (mysql mysql-ffi )
  (export my-net-init
  my-net-local-init
  net-end
  net-clear
  net-claim-memory-ownership
  net-realloc
  net-flush
  my-net-write
  net-write-command
  net-write-packet
  my-net-read
  randominit
  my-rnd
  create-random-string
  hash-password
  make-scrambled-password-323
  scramble-323
  check-scramble-323
  get-salt-from-password-323
  make-password-from-salt-323
  make-scrambled-password
  scramble
  check-scramble
  get-salt-from-password
  make-password-from-salt
  octet2hex
  get-tty-password
  mysql-errno-to-sqlstate
  my-thread-init
  my-thread-end
  list-add
  list-delete
  list-cons
  list-reverse
  list-free
  list-length
  list-walk
  mysql-load-plugin
  mysql-load-plugin-v
  mysql-client-find-plugin
  mysql-client-register-plugin
  mysql-plugin-options
  my-init
  find-typeset
  find-type-or-exit
  find-type
  make-type
  get-type
  copy-typelib
  find-set-from-flags
  mysql-get-parameters
  mysql-server-init
  mysql-server-end
  mysql-thread-init
  mysql-thread-end
  mysql-num-rows
  mysql-num-fields
  mysql-eof
  mysql-fetch-field-direct
  mysql-fetch-fields
  mysql-row-tell
  mysql-field-tell
  mysql-field-count
  mysql-affected-rows
  mysql-insert-id
  mysql-errno
  mysql-error
  mysql-sqlstate
  mysql-warning-count
  mysql-info
  mysql-thread-id
  mysql-character-set-name
  mysql-set-character-set
  mysql-init
  mysql-ssl-set
  mysql-get-ssl-cipher
  mysql-change-user
  mysql-real-connect
  mysql-select-db
  mysql-query
  mysql-send-query
  mysql-real-query
  mysql-store-result
  mysql-use-result
  mysql-get-character-set-info
  mysql-session-track-get-first
  mysql-session-track-get-next
  mysql-set-local-infile-handler
  mysql-set-local-infile-default
  mysql-shutdown
  mysql-dump-debug-info
  mysql-refresh
  mysql-kill
  mysql-set-server-option
  mysql-ping
  mysql-stat
  mysql-get-server-info
  mysql-get-client-info
  mysql-get-client-version
  mysql-get-host-info
  mysql-get-server-version
  mysql-get-proto-info
  mysql-list-dbs
  mysql-list-tables
  mysql-list-processes
  mysql-options
  mysql-options4
  mysql-get-option
  mysql-free-result
  mysql-data-seek
  mysql-row-seek
  mysql-field-seek
  mysql-fetch-row
  mysql-fetch-lengths
  mysql-fetch-field
  mysql-list-fields
  mysql-escape-string
  mysql-hex-string
  mysql-real-escape-string
  mysql-real-escape-string-quote
  mysql-debug
  myodbc-remove-escape
  mysql-thread-safe
  mysql-embedded
  mysql-read-query-result
  mysql-reset-connection
  mysql-stmt-init
  mysql-stmt-prepare
  mysql-stmt-execute
  mysql-stmt-fetch
  mysql-stmt-fetch-column
  mysql-stmt-store-result
  mysql-stmt-param-count
  mysql-stmt-attr-set
  mysql-stmt-attr-get
  mysql-stmt-bind-param
  mysql-stmt-bind-result
  mysql-stmt-close
  mysql-stmt-reset
  mysql-stmt-free-result
  mysql-stmt-send-long-data
  mysql-stmt-result-metadata
  mysql-stmt-param-metadata
  mysql-stmt-errno
  mysql-stmt-error
  mysql-stmt-sqlstate
  mysql-stmt-row-seek
  mysql-stmt-row-tell
  mysql-stmt-data-seek
  mysql-stmt-num-rows
  mysql-stmt-affected-rows
  mysql-stmt-insert-id
  mysql-stmt-field-count
  mysql-commit
  mysql-rollback
  mysql-autocommit
  mysql-more-results
  mysql-next-result
  mysql-stmt-next-result
  mysql-close)

 (import (scheme) (utils libutil) (cffi cffi) )


 (load-librarys "libmysqlclient" )

;;my_bool my_net_init(NET* net ,Vio* vio)
(def-function my-net-init
             "my_net_init" (void* void*) int)

;;void my_net_local_init(NET* net)
(def-function my-net-local-init
             "my_net_local_init" (void*) void)

;;void net_end(NET* net)
(def-function net-end
             "net_end" (void*) void)

;;void net_clear(NET* net ,my_bool check_buffer)
(def-function net-clear
             "net_clear" (void* int) void)

;;void net_claim_memory_ownership(NET* net)
(def-function net-claim-memory-ownership
             "net_claim_memory_ownership" (void*) void)

;;my_bool net_realloc(NET* net ,size_t length)
(def-function net-realloc
             "net_realloc" (void* int) int)

;;my_bool net_flush(NET* net)
(def-function net-flush
             "net_flush" (void*) int)

;;my_bool my_net_write(NET* net ,unsigned* packet ,size_t len)
(def-function my-net-write
             "my_net_write" (void* void* int) int)

;;my_bool net_write_command(NET* net ,unsigned char command ,unsigned* header ,size_t head_len ,unsigned* packet ,size_t len)
(def-function net-write-command
             "net_write_command" (void* int void* int void* int) int)

;;my_bool net_write_packet(NET* net ,unsigned* packet ,size_t length)
(def-function net-write-packet
             "net_write_packet" (void* void* int) int)

;;unsigned my_net_read(NET* net)
(def-function my-net-read
             "my_net_read" (void*) int)

;;void randominit(struct rand_struct*  ,unsigned long seed1 ,unsigned long seed2)
(def-function randominit
             "randominit" (void* long long) void)

;;double my_rnd(struct rand_struct* )
(def-function my-rnd
             "my_rnd" (void*) double)

;;void create_random_string(char* to ,unsigned int length ,struct rand_struct* rand_st)
(def-function create-random-string
             "create_random_string" (string int void*) void)

;;void hash_password(unsigned* to ,char* password ,unsigned int password_len)
(def-function hash-password
             "hash_password" (void* string int) void)

;;void make_scrambled_password_323(char* to ,char* password)
(def-function make-scrambled-password-323
             "make_scrambled_password_323" (string string) void)

;;void scramble_323(char* to ,char* message ,char* password)
(def-function scramble-323
             "scramble_323" (string string string) void)

;;my_bool check_scramble_323(unsigned* reply ,char* message ,unsigned* salt)
(def-function check-scramble-323
             "check_scramble_323" (void* string void*) int)

;;void get_salt_from_password_323(unsigned* res ,char* password)
(def-function get-salt-from-password-323
             "get_salt_from_password_323" (void* string) void)

;;void make_password_from_salt_323(char* to ,unsigned* salt)
(def-function make-password-from-salt-323
             "make_password_from_salt_323" (string void*) void)

;;void make_scrambled_password(char* to ,char* password)
(def-function make-scrambled-password
             "make_scrambled_password" (string string) void)

;;void scramble(char* to ,char* message ,char* password)
(def-function scramble
             "scramble" (string string string) void)

;;my_bool check_scramble(unsigned* reply ,char* message ,unsigned* hash_stage2)
(def-function check-scramble
             "check_scramble" (void* string void*) int)

;;void get_salt_from_password(unsigned* res ,char* password)
(def-function get-salt-from-password
             "get_salt_from_password" (void* string) void)

;;void make_password_from_salt(char* to ,unsigned* hash_stage2)
(def-function make-password-from-salt
             "make_password_from_salt" (string void*) void)

;;char* octet2hex(char* to ,char* str ,unsigned int len)
(def-function octet2hex
             "octet2hex" (string string int) string)

;;char* get_tty_password(char* opt_message)
(def-function get-tty-password
             "get_tty_password" (string) string)

;;char* mysql_errno_to_sqlstate(unsigned int mysql_errno)
(def-function mysql-errno-to-sqlstate
             "mysql_errno_to_sqlstate" (int) string)

;;my_bool my_thread_init(void )
(def-function my-thread-init
             "my_thread_init" (void) int)

;;void my_thread_end(void )
(def-function my-thread-end
             "my_thread_end" (void) void)

;;LIST* list_add(LIST* root ,LIST* element)
(def-function list-add
             "list_add" (void* void*) void*)

;;LIST* list_delete(LIST* root ,LIST* element)
(def-function list-delete
             "list_delete" (void* void*) void*)

;;LIST* list_cons(void* data ,LIST* root)
(def-function list-cons
             "list_cons" (void* void*) void*)

;;LIST* list_reverse(LIST* root)
(def-function list-reverse
             "list_reverse" (void*) void*)

;;void list_free(LIST* root ,unsigned int free_data)
(def-function list-free
             "list_free" (void* int) void)

;;unsigned list_length(LIST* )
(def-function list-length
             "list_length" (void*) int)

;;int list_walk(LIST*  ,list_walk_action action ,unsigned* argument)
(def-function list-walk
             "list_walk" (void* void* void*) int)

;; mysql_load_plugin(struct st_mysql* mysql ,char* name ,int type ,int argc)
(def-function mysql-load-plugin
             "mysql_load_plugin" (void* string int int) void*)

;; mysql_load_plugin_v(struct st_mysql* mysql ,char* name ,int type ,int argc ,va_list args)
(def-function mysql-load-plugin-v
             "mysql_load_plugin_v" (void* string int int va_list) void*)

;; mysql_client_find_plugin(struct st_mysql* mysql ,char* name ,int type)
(def-function mysql-client-find-plugin
             "mysql_client_find_plugin" (void* string int) void*)

;; mysql_client_register_plugin(struct st_mysql* mysql ,struct st_mysql_client_plugin* plugin)
(def-function mysql-client-register-plugin
             "mysql_client_register_plugin" (void* void*) void*)

;;int mysql_plugin_options(struct st_mysql_client_plugin* plugin ,char* option ,void* value)
(def-function mysql-plugin-options
             "mysql_plugin_options" (void* string void*) int)

;;my_bool my_init(void )
(def-function my-init
             "my_init" (void) int)

;;my_ulonglong find_typeset(char* x ,TYPELIB* typelib ,int* error_position)
(def-function find-typeset
             "find_typeset" (string void* void*) long)

;;int find_type_or_exit(char* x ,TYPELIB* typelib ,char* option)
(def-function find-type-or-exit
             "find_type_or_exit" (string void* string) int)

;;int find_type(char* x ,TYPELIB* typelib ,unsigned int flags)
(def-function find-type
             "find_type" (string void* int) int)

;;void make_type(char* to ,unsigned int nr ,TYPELIB* typelib)
(def-function make-type
             "make_type" (string int void*) void)

;;char* get_type(TYPELIB* typelib ,unsigned int nr)
(def-function get-type
             "get_type" (void* int) string)

;;TYPELIB* copy_typelib(MEM_ROOT* root ,TYPELIB* from)
(def-function copy-typelib
             "copy_typelib" (void* void*) void*)

;;my_ulonglong find_set_from_flags(TYPELIB* lib ,unsigned int default_name ,my_ulonglong cur_set ,my_ulonglong default_set ,char* str ,unsigned int length ,char err_pos ,unsigned* err_len)
(def-function find-set-from-flags
             "find_set_from_flags" (void* int long long string int char void*) long)

;;MYSQL_PARAMETERS* mysql_get_parameters(void )
(def-function mysql-get-parameters
             "mysql_get_parameters" (void) void*)

;;int mysql_server_init(int argc ,char argv ,char groups)
(def-function mysql-server-init
             "mysql_server_init" (int char char) int)

;;void mysql_server_end(void )
(def-function mysql-server-end
             "mysql_server_end" (void) void)

;;my_bool mysql_thread_init(void )
(def-function mysql-thread-init
             "mysql_thread_init" (void) int)

;;void mysql_thread_end(void )
(def-function mysql-thread-end
             "mysql_thread_end" (void) void)

;;my_ulonglong mysql_num_rows(MYSQL_RES* res)
(def-function mysql-num-rows
             "mysql_num_rows" (void*) long)

;;unsigned mysql_num_fields(MYSQL_RES* res)
(def-function mysql-num-fields
             "mysql_num_fields" (void*) int)

;;my_bool mysql_eof(MYSQL_RES* res)
(def-function mysql-eof
             "mysql_eof" (void*) int)

;;MYSQL_FIELD* mysql_fetch_field_direct(MYSQL_RES* res ,unsigned int fieldnr)
(def-function mysql-fetch-field-direct
             "mysql_fetch_field_direct" (void* int) void*)

;;MYSQL_FIELD* mysql_fetch_fields(MYSQL_RES* res)
(def-function mysql-fetch-fields
             "mysql_fetch_fields" (void*) void*)

;;MYSQL_ROW_OFFSET mysql_row_tell(MYSQL_RES* res)
(def-function mysql-row-tell
             "mysql_row_tell" (void*) void*)

;;MYSQL_FIELD_OFFSET mysql_field_tell(MYSQL_RES* res)
(def-function mysql-field-tell
             "mysql_field_tell" (void*) int)

;;unsigned mysql_field_count(MYSQL* mysql)
(def-function mysql-field-count
             "mysql_field_count" (void*) int)

;;my_ulonglong mysql_affected_rows(MYSQL* mysql)
(def-function mysql-affected-rows
             "mysql_affected_rows" (void*) long)

;;my_ulonglong mysql_insert_id(MYSQL* mysql)
(def-function mysql-insert-id
             "mysql_insert_id" (void*) long)

;;unsigned mysql_errno(MYSQL* mysql)
(def-function mysql-errno
             "mysql_errno" (void*) int)

;;char* mysql_error(MYSQL* mysql)
(def-function mysql-error
             "mysql_error" (void*) string)

;;char* mysql_sqlstate(MYSQL* mysql)
(def-function mysql-sqlstate
             "mysql_sqlstate" (void*) string)

;;unsigned mysql_warning_count(MYSQL* mysql)
(def-function mysql-warning-count
             "mysql_warning_count" (void*) int)

;;char* mysql_info(MYSQL* mysql)
(def-function mysql-info
             "mysql_info" (void*) string)

;;unsigned mysql_thread_id(MYSQL* mysql)
(def-function mysql-thread-id
             "mysql_thread_id" (void*) int)

;;char* mysql_character_set_name(MYSQL* mysql)
(def-function mysql-character-set-name
             "mysql_character_set_name" (void*) string)

;;int mysql_set_character_set(MYSQL* mysql ,char* csname)
(def-function mysql-set-character-set
             "mysql_set_character_set" (void* string) int)

;;MYSQL* mysql_init(MYSQL* mysql)
(def-function mysql-init
             "mysql_init" (void*) void*)

;;my_bool mysql_ssl_set(MYSQL* mysql ,char* key ,char* cert ,char* ca ,char* capath ,char* cipher)
(def-function mysql-ssl-set
             "mysql_ssl_set" (void* string string string string string) int)

;;char* mysql_get_ssl_cipher(MYSQL* mysql)
(def-function mysql-get-ssl-cipher
             "mysql_get_ssl_cipher" (void*) string)

;;my_bool mysql_change_user(MYSQL* mysql ,char* user ,char* passwd ,char* db)
(def-function mysql-change-user
             "mysql_change_user" (void* string string string) int)

;;MYSQL* mysql_real_connect(MYSQL* mysql ,char* host ,char* user ,char* passwd ,char* db ,unsigned int port ,char* unix_socket ,unsigned long clientflag)
(def-function mysql-real-connect
             "mysql_real_connect" (void* string string string string int string long) void*)

;;int mysql_select_db(MYSQL* mysql ,char* db)
(def-function mysql-select-db
             "mysql_select_db" (void* string) int)

;;int mysql_query(MYSQL* mysql ,char* q)
(def-function mysql-query
             "mysql_query" (void* string) int)

;;int mysql_send_query(MYSQL* mysql ,char* q ,unsigned long length)
(def-function mysql-send-query
             "mysql_send_query" (void* string long) int)

;;int mysql_real_query(MYSQL* mysql ,char* q ,unsigned long length)
(def-function mysql-real-query
             "mysql_real_query" (void* string long) int)

;;MYSQL_RES* mysql_store_result(MYSQL* mysql)
(def-function mysql-store-result
             "mysql_store_result" (void*) void*)

;;MYSQL_RES* mysql_use_result(MYSQL* mysql)
(def-function mysql-use-result
             "mysql_use_result" (void*) void*)

;;void mysql_get_character_set_info(MYSQL* mysql ,MY_CHARSET_INFO* charset)
(def-function mysql-get-character-set-info
             "mysql_get_character_set_info" (void* void*) void)

;;int mysql_session_track_get_first(MYSQL* mysql ,char data ,size_t* length)
(def-function mysql-session-track-get-first
             "mysql_session_track_get_first" (void* char void*) int)

;;int mysql_session_track_get_next(MYSQL* mysql ,char data ,size_t* length)
(def-function mysql-session-track-get-next
             "mysql_session_track_get_next" (void* char void*) int)

;;void mysql_set_local_infile_handler(MYSQL* mysql ,void* )
(def-function mysql-set-local-infile-handler
             "mysql_set_local_infile_handler" (void* void*) void)

;;void mysql_set_local_infile_default(MYSQL* mysql)
(def-function mysql-set-local-infile-default
             "mysql_set_local_infile_default" (void*) void)

;;int mysql_shutdown(MYSQL* mysql)
(def-function mysql-shutdown
             "mysql_shutdown" (void*) int)

;;int mysql_dump_debug_info(MYSQL* mysql)
(def-function mysql-dump-debug-info
             "mysql_dump_debug_info" (void*) int)

;;int mysql_refresh(MYSQL* mysql ,unsigned int refresh_options)
(def-function mysql-refresh
             "mysql_refresh" (void* int) int)

;;int mysql_kill(MYSQL* mysql ,unsigned long pid)
(def-function mysql-kill
             "mysql_kill" (void* long) int)

;;int mysql_set_server_option(MYSQL* mysql)
(def-function mysql-set-server-option
             "mysql_set_server_option" (void*) int)

;;int mysql_ping(MYSQL* mysql)
(def-function mysql-ping
             "mysql_ping" (void*) int)

;;char* mysql_stat(MYSQL* mysql)
(def-function mysql-stat
             "mysql_stat" (void*) string)

;;char* mysql_get_server_info(MYSQL* mysql)
(def-function mysql-get-server-info
             "mysql_get_server_info" (void*) string)

;;char* mysql_get_client_info(void )
(def-function mysql-get-client-info
             "mysql_get_client_info" (void) string)

;;unsigned mysql_get_client_version(void )
(def-function mysql-get-client-version
             "mysql_get_client_version" (void) int)

;;char* mysql_get_host_info(MYSQL* mysql)
(def-function mysql-get-host-info
             "mysql_get_host_info" (void*) string)

;;unsigned mysql_get_server_version(MYSQL* mysql)
(def-function mysql-get-server-version
             "mysql_get_server_version" (void*) int)

;;unsigned mysql_get_proto_info(MYSQL* mysql)
(def-function mysql-get-proto-info
             "mysql_get_proto_info" (void*) int)

;;MYSQL_RES* mysql_list_dbs(MYSQL* mysql ,char* wild)
(def-function mysql-list-dbs
             "mysql_list_dbs" (void* string) void*)

;;MYSQL_RES* mysql_list_tables(MYSQL* mysql ,char* wild)
(def-function mysql-list-tables
             "mysql_list_tables" (void* string) void*)

;;MYSQL_RES* mysql_list_processes(MYSQL* mysql)
(def-function mysql-list-processes
             "mysql_list_processes" (void*) void*)

;;int mysql_options(MYSQL* mysql ,void* arg)
(def-function mysql-options
             "mysql_options" (void* void*) int)

;;int mysql_options4(MYSQL* mysql ,void* arg1 ,void* arg2)
(def-function mysql-options4
             "mysql_options4" (void* void* void*) int)

;;int mysql_get_option(MYSQL* mysql ,void* arg)
(def-function mysql-get-option
             "mysql_get_option" (void* void*) int)

;;void mysql_free_result(MYSQL_RES* result)
(def-function mysql-free-result
             "mysql_free_result" (void*) void)

;;void mysql_data_seek(MYSQL_RES* result ,my_ulonglong offset)
(def-function mysql-data-seek
             "mysql_data_seek" (void* long) void)

;;MYSQL_ROW_OFFSET mysql_row_seek(MYSQL_RES* result ,MYSQL_ROW_OFFSET offset)
(def-function mysql-row-seek
             "mysql_row_seek" (void* void*) void*)

;;MYSQL_FIELD_OFFSET mysql_field_seek(MYSQL_RES* result ,MYSQL_FIELD_OFFSET offset)
(def-function mysql-field-seek
             "mysql_field_seek" (void* int) int)

;;MYSQL_ROW mysql_fetch_row(MYSQL_RES* result)
(def-function mysql-fetch-row
             "mysql_fetch_row" (void*) void*)

;;unsigned* mysql_fetch_lengths(MYSQL_RES* result)
(def-function mysql-fetch-lengths
             "mysql_fetch_lengths" (void*) void*)

;;MYSQL_FIELD* mysql_fetch_field(MYSQL_RES* result)
(def-function mysql-fetch-field
             "mysql_fetch_field" (void*) void*)

;;MYSQL_RES* mysql_list_fields(MYSQL* mysql ,char* table ,char* wild)
(def-function mysql-list-fields
             "mysql_list_fields" (void* string string) void*)

;;unsigned mysql_escape_string(char* to ,char* from ,unsigned long from_length)
(def-function mysql-escape-string
             "mysql_escape_string" (string string long) int)

;;unsigned mysql_hex_string(char* to ,char* from ,unsigned long from_length)
(def-function mysql-hex-string
             "mysql_hex_string" (string string long) int)

;;unsigned mysql_real_escape_string(MYSQL* mysql ,char* to ,char* from ,unsigned long length)
(def-function mysql-real-escape-string
             "mysql_real_escape_string" (void* string string long) int)

;;unsigned mysql_real_escape_string_quote(MYSQL* mysql ,char* to ,char* from ,unsigned long length ,char quote)
(def-function mysql-real-escape-string-quote
             "mysql_real_escape_string_quote" (void* string string long char) int)

;;void mysql_debug(char* debug)
(def-function mysql-debug
             "mysql_debug" (string) void)

;;void myodbc_remove_escape(MYSQL* mysql ,char* name)
(def-function myodbc-remove-escape
             "myodbc_remove_escape" (void* string) void)

;;unsigned mysql_thread_safe(void )
(def-function mysql-thread-safe
             "mysql_thread_safe" (void) int)

;;my_bool mysql_embedded(void )
(def-function mysql-embedded
             "mysql_embedded" (void) int)

;;my_bool mysql_read_query_result(MYSQL* mysql)
(def-function mysql-read-query-result
             "mysql_read_query_result" (void*) int)

;;int mysql_reset_connection(MYSQL* mysql)
(def-function mysql-reset-connection
             "mysql_reset_connection" (void*) int)

;;MYSQL_STMT* mysql_stmt_init(MYSQL* mysql)
(def-function mysql-stmt-init
             "mysql_stmt_init" (void*) void*)

;;int mysql_stmt_prepare(MYSQL_STMT* stmt ,char* query ,unsigned long length)
(def-function mysql-stmt-prepare
             "mysql_stmt_prepare" (void* string long) int)

;;int mysql_stmt_execute(MYSQL_STMT* stmt)
(def-function mysql-stmt-execute
             "mysql_stmt_execute" (void*) int)

;;int mysql_stmt_fetch(MYSQL_STMT* stmt)
(def-function mysql-stmt-fetch
             "mysql_stmt_fetch" (void*) int)

;;int mysql_stmt_fetch_column(MYSQL_STMT* stmt ,MYSQL_BIND* bind_arg ,unsigned int column ,unsigned long offset)
(def-function mysql-stmt-fetch-column
             "mysql_stmt_fetch_column" (void* void* int long) int)

;;int mysql_stmt_store_result(MYSQL_STMT* stmt)
(def-function mysql-stmt-store-result
             "mysql_stmt_store_result" (void*) int)

;;unsigned mysql_stmt_param_count(MYSQL_STMT* stmt)
(def-function mysql-stmt-param-count
             "mysql_stmt_param_count" (void*) int)

;;my_bool mysql_stmt_attr_set(MYSQL_STMT* stmt ,void* attr)
(def-function mysql-stmt-attr-set
             "mysql_stmt_attr_set" (void* void*) int)

;;my_bool mysql_stmt_attr_get(MYSQL_STMT* stmt ,void* attr)
(def-function mysql-stmt-attr-get
             "mysql_stmt_attr_get" (void* void*) int)

;;my_bool mysql_stmt_bind_param(MYSQL_STMT* stmt ,MYSQL_BIND* bnd)
(def-function mysql-stmt-bind-param
             "mysql_stmt_bind_param" (void* void*) int)

;;my_bool mysql_stmt_bind_result(MYSQL_STMT* stmt ,MYSQL_BIND* bnd)
(def-function mysql-stmt-bind-result
             "mysql_stmt_bind_result" (void* void*) int)

;;my_bool mysql_stmt_close(MYSQL_STMT* stmt)
(def-function mysql-stmt-close
             "mysql_stmt_close" (void*) int)

;;my_bool mysql_stmt_reset(MYSQL_STMT* stmt)
(def-function mysql-stmt-reset
             "mysql_stmt_reset" (void*) int)

;;my_bool mysql_stmt_free_result(MYSQL_STMT* stmt)
(def-function mysql-stmt-free-result
             "mysql_stmt_free_result" (void*) int)

;;my_bool mysql_stmt_send_long_data(MYSQL_STMT* stmt ,unsigned int param_number ,char* data ,unsigned long length)
(def-function mysql-stmt-send-long-data
             "mysql_stmt_send_long_data" (void* int string long) int)

;;MYSQL_RES* mysql_stmt_result_metadata(MYSQL_STMT* stmt)
(def-function mysql-stmt-result-metadata
             "mysql_stmt_result_metadata" (void*) void*)

;;MYSQL_RES* mysql_stmt_param_metadata(MYSQL_STMT* stmt)
(def-function mysql-stmt-param-metadata
             "mysql_stmt_param_metadata" (void*) void*)

;;unsigned mysql_stmt_errno(MYSQL_STMT* stmt)
(def-function mysql-stmt-errno
             "mysql_stmt_errno" (void*) int)

;;char* mysql_stmt_error(MYSQL_STMT* stmt)
(def-function mysql-stmt-error
             "mysql_stmt_error" (void*) string)

;;char* mysql_stmt_sqlstate(MYSQL_STMT* stmt)
(def-function mysql-stmt-sqlstate
             "mysql_stmt_sqlstate" (void*) string)

;;MYSQL_ROW_OFFSET mysql_stmt_row_seek(MYSQL_STMT* stmt ,MYSQL_ROW_OFFSET offset)
(def-function mysql-stmt-row-seek
             "mysql_stmt_row_seek" (void* void*) void*)

;;MYSQL_ROW_OFFSET mysql_stmt_row_tell(MYSQL_STMT* stmt)
(def-function mysql-stmt-row-tell
             "mysql_stmt_row_tell" (void*) void*)

;;void mysql_stmt_data_seek(MYSQL_STMT* stmt ,my_ulonglong offset)
(def-function mysql-stmt-data-seek
             "mysql_stmt_data_seek" (void* long) void)

;;my_ulonglong mysql_stmt_num_rows(MYSQL_STMT* stmt)
(def-function mysql-stmt-num-rows
             "mysql_stmt_num_rows" (void*) long)

;;my_ulonglong mysql_stmt_affected_rows(MYSQL_STMT* stmt)
(def-function mysql-stmt-affected-rows
             "mysql_stmt_affected_rows" (void*) long)

;;my_ulonglong mysql_stmt_insert_id(MYSQL_STMT* stmt)
(def-function mysql-stmt-insert-id
             "mysql_stmt_insert_id" (void*) long)

;;unsigned mysql_stmt_field_count(MYSQL_STMT* stmt)
(def-function mysql-stmt-field-count
             "mysql_stmt_field_count" (void*) int)

;;my_bool mysql_commit(MYSQL* mysql)
(def-function mysql-commit
             "mysql_commit" (void*) int)

;;my_bool mysql_rollback(MYSQL* mysql)
(def-function mysql-rollback
             "mysql_rollback" (void*) int)

;;my_bool mysql_autocommit(MYSQL* mysql ,my_bool auto_mode)
(def-function mysql-autocommit
             "mysql_autocommit" (void* int) int)

;;my_bool mysql_more_results(MYSQL* mysql)
(def-function mysql-more-results
             "mysql_more_results" (void*) int)

;;int mysql_next_result(MYSQL* mysql)
(def-function mysql-next-result
             "mysql_next_result" (void*) int)

;;int mysql_stmt_next_result(MYSQL_STMT* stmt)
(def-function mysql-stmt-next-result
             "mysql_stmt_next_result" (void*) int)

;;void mysql_close(MYSQL* sock)
(def-function mysql-close
             "mysql_close" (void*) void)


)
