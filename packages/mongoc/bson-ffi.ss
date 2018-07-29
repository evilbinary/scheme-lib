;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 04/22/16.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (mongoc bson-ffi )
  (export
   bson-context-new
   bson-context-destroy
   bson-context-get-default
   bson-get-monotonic-time
   bson-gettimeofday
   bson-decimal128-to-string
   bson-decimal128-from-string
   bson-set-error
   bson-strerror-r
   bson-iter-value
   bson-iter-array
   bson-iter-binary
   bson-iter-code
   bson-iter-codewscope
   bson-iter-dbpointer
   bson-iter-document
   bson-iter-double
   bson-iter-init
   bson-iter-init-find
   bson-iter-init-find-case
   bson-iter-int32
   bson-iter-int64
   bson-iter-as-int64
   bson-iter-find
   bson-iter-find-case
   bson-iter-find-descendant
   bson-iter-next
   bson-iter-oid
   bson-iter-decimal128
   bson-iter-key
   bson-iter-utf8
   bson-iter-dup-utf8
   bson-iter-date-time
   bson-iter-time-t
   bson-iter-timeval
   bson-iter-timestamp
   bson-iter-bool
   bson-iter-as-bool
   bson-iter-regex
   bson-iter-symbol
   bson-iter-type
   bson-iter-recurse
   bson-iter-overwrite-int32
   bson-iter-overwrite-int64
   bson-iter-overwrite-double
   bson-iter-overwrite-decimal128
   bson-iter-overwrite-bool
   bson-iter-visit-all
   bson-json-reader-new
   bson-json-reader-new-from-fd
   bson-json-reader-new-from-file
   bson-json-reader-destroy
   bson-json-reader-read
   bson-json-data-reader-new
   bson-json-data-reader-ingest
   bson-uint32-to-string
   bson-md5-init
   bson-md5-append
   bson-md5-finish
   bson-mem-set-vtable
   bson-mem-restore-vtable
   bson-malloc
   bson-malloc0
   bson-realloc
   bson-realloc-ctx
   bson-free
   bson-zero-free
   bson-oid-compare
   bson-oid-copy
   bson-oid-equal
   bson-oid-is-valid
   bson-oid-get-time-t
   bson-oid-hash
   bson-oid-init
   bson-oid-init-from-data
   bson-oid-init-from-string
   bson-oid-init-sequence
   bson-oid-to-string
   bson-reader-new-from-handle
   bson-reader-new-from-fd
   bson-reader-new-from-file
   bson-reader-new-from-data
   bson-reader-destroy
   bson-reader-set-read-func
   bson-reader-set-destroy-func
   bson-reader-read
   bson-reader-tell
   bson-reader-reset
   bson-string-new
   bson-string-free
   bson-string-append
   bson-string-append-c
   bson-string-append-unichar
   bson-string-append-printf
   bson-string-truncate
   bson-strdup
   bson-strdup-printf
   bson-strdupv-printf
   bson-strndup
   bson-strncpy
   bson-vsnprintf
   bson-snprintf
   bson-strfreev
   bson-strnlen
   bson-ascii-strtoll
   bson-utf8-validate
   bson-utf8-escape-for-json
   bson-utf8-get-char
   bson-utf8-next-char
   bson-utf8-from-unichar
   bson-value-copy
   bson-value-destroy
   bson-get-major-version
   bson-get-minor-version
   bson-get-micro-version
   bson-get-version
   bson-check-version
   bson-writer-new
   bson-writer-destroy
   bson-writer-get-length
   bson-writer-begin
   bson-writer-end
   bson-writer-rollback
   bcon-append
   bcon-append-ctx
   bcon-append-ctx-va
   bcon-append-ctx-init
   bcon-extract-ctx-init
   bcon-extract-ctx
   bcon-extract-ctx-va
   bcon-extract
   bcon-extract-va
   bcon-new
   bson-bcon-magic
   bson-bcone-magic
   bson-new
   bson-new-from-json
   bson-init-from-json
   bson-init-static
   bson-init
   bson-reinit
   bson-new-from-data
   bson-new-from-buffer
   bson-sized-new
   bson-copy
   bson-copy-to
   bson-copy-to-excluding
   bson-copy-to-excluding-noinit
   bson-destroy
   bson-reserve-buffer
   bson-steal
   bson-destroy-with-steal
   bson-get-data
   bson-count-keys
   bson-has-field
   bson-compare
   bson-equal
   bson-validate
   bson-as-json
   bson-array-as-json
   bson-append-value
   bson-append-array
   bson-append-binary
   bson-append-bool
   bson-append-code
   bson-append-code-with-scope
   bson-append-dbpointer
   bson-append-double
   bson-append-document
   bson-append-document-begin
   bson-append-document-end
   bson-append-array-begin
   bson-append-array-end
   bson-append-int32
   bson-append-int64
   bson-append-decimal128
   bson-append-iter
   bson-append-minkey
   bson-append-maxkey
   bson-append-null
   bson-append-oid
   bson-append-regex
   bson-append-utf8
   bson-append-symbol
   bson-append-time-t
   bson-append-timeval
   bson-append-date-time
   bson-append-now-utc
   bson-append-timestamp
   bson-append-undefined
   bson-concat

   )

  (import (scheme) (utils libutil) (cffi cffi) )

  (load-librarys  "libbson"  "libbson-1.0" )



;;bson_context_t* bson_context_new(bson_context_flags_t flags)
(def-function bson-context-new
             "bson_context_new" (bson_context_flags_t) void*)

;;void bson_context_destroy(bson_context_t* context)
(def-function bson-context-destroy
             "bson_context_destroy" (void*) void)

;;bson_context_t* bson_context_get_default()
(def-function bson-context-get-default
             "bson_context_get_default" () void*)

;;int64_t bson_get_monotonic_time()
(def-function bson-get-monotonic-time
             "bson_get_monotonic_time" () int)

;;int bson_gettimeofday(timeval tv)
(def-function bson-gettimeofday
             "bson_gettimeofday" (timeval) int)

;;void bson_decimal128_to_string(bson_decimal128_t* dec ,char* str)
(def-function bson-decimal128-to-string
             "bson_decimal128_to_string" (void* string) void)

;;bool bson_decimal128_from_string(char* string ,bson_decimal128_t* dec)
(def-function bson-decimal128-from-string
             "bson_decimal128_from_string" (string void*) int)

;;void bson_set_error(bson_error_t* error ,uint32_t domain ,uint32_t code ,char* format)
(def-function bson-set-error
             "bson_set_error" (void* int int string) void)

;;char* bson_strerror_r(int err_code ,char* buf ,size_t buflen)
(def-function bson-strerror-r
             "bson_strerror_r" (int string size_t) string)

;;bson_value_t* bson_iter_value(bson_iter_t* iter)
(def-function bson-iter-value
             "bson_iter_value" (void*) void*)

;;void bson_iter_array(bson_iter_t* iter ,uint32_t* array_len ,uint8_t array)
(def-function bson-iter-array
             "bson_iter_array" (void* void* uint8_t) void)

;;void bson_iter_binary(bson_iter_t* iter ,bson_subtype_t* subtype ,uint32_t* binary_len ,uint8_t binary)
(def-function bson-iter-binary
             "bson_iter_binary" (void* void* void* uint8_t) void)

;;char* bson_iter_code(bson_iter_t* iter ,uint32_t* length)
(def-function bson-iter-code
             "bson_iter_code" (void* void*) string)

;;char* bson_iter_codewscope(bson_iter_t* iter ,uint32_t* length ,uint32_t* scope_len ,uint8_t scope)
(def-function bson-iter-codewscope
             "bson_iter_codewscope" (void* void* void* uint8_t) string)

;;void bson_iter_dbpointer(bson_iter_t* iter ,uint32_t* collection_len ,char collection ,bson_oid_t oid)
(def-function bson-iter-dbpointer
             "bson_iter_dbpointer" (void* void* char bson_oid_t) void)

;;void bson_iter_document(bson_iter_t* iter ,uint32_t* document_len ,uint8_t document)
(def-function bson-iter-document
             "bson_iter_document" (void* void* uint8_t) void)

;;double bson_iter_double(bson_iter_t* iter)
(def-function bson-iter-double
             "bson_iter_double" (void*) double)

;;bool bson_iter_init(bson_iter_t* iter ,bson_t* bson)
(def-function bson-iter-init
             "bson_iter_init" (void* void*) int)

;;bool bson_iter_init_find(bson_iter_t* iter ,bson_t* bson ,char* key)
(def-function bson-iter-init-find
             "bson_iter_init_find" (void* void* string) int)

;;bool bson_iter_init_find_case(bson_iter_t* iter ,bson_t* bson ,char* key)
(def-function bson-iter-init-find-case
             "bson_iter_init_find_case" (void* void* string) int)

;;int32_t bson_iter_int32(bson_iter_t* iter)
(def-function bson-iter-int32
             "bson_iter_int32" (void*) int)

;;int64_t bson_iter_int64(bson_iter_t* iter)
(def-function bson-iter-int64
             "bson_iter_int64" (void*) int)

;;int64_t bson_iter_as_int64(bson_iter_t* iter)
(def-function bson-iter-as-int64
             "bson_iter_as_int64" (void*) int)

;;bool bson_iter_find(bson_iter_t* iter ,char* key)
(def-function bson-iter-find
             "bson_iter_find" (void* string) int)

;;bool bson_iter_find_case(bson_iter_t* iter ,char* key)
(def-function bson-iter-find-case
             "bson_iter_find_case" (void* string) int)

;;bool bson_iter_find_descendant(bson_iter_t* iter ,char* dotkey ,bson_iter_t* descendant)
(def-function bson-iter-find-descendant
             "bson_iter_find_descendant" (void* string void*) int)

;;bool bson_iter_next(bson_iter_t* iter)
(def-function bson-iter-next
             "bson_iter_next" (void*) int)

;;bson_oid_t* bson_iter_oid(bson_iter_t* iter)
(def-function bson-iter-oid
             "bson_iter_oid" (void*) void*)

;;bool bson_iter_decimal128(bson_iter_t* iter ,bson_decimal128_t* dec)
(def-function bson-iter-decimal128
             "bson_iter_decimal128" (void* void*) int)

;;char* bson_iter_key(bson_iter_t* iter)
(def-function bson-iter-key
             "bson_iter_key" (void*) string)

;;char* bson_iter_utf8(bson_iter_t* iter ,uint32_t* length)
(def-function bson-iter-utf8
             "bson_iter_utf8" (void* void*) string)

;;char* bson_iter_dup_utf8(bson_iter_t* iter ,uint32_t* length)
(def-function bson-iter-dup-utf8
             "bson_iter_dup_utf8" (void* void*) string)

;;int64_t bson_iter_date_time(bson_iter_t* iter)
(def-function bson-iter-date-time
             "bson_iter_date_time" (void*) int)

;;time_t bson_iter_time_t(bson_iter_t* iter)
(def-function bson-iter-time-t
             "bson_iter_time_t" (void*) time_t)

;;void bson_iter_timeval(bson_iter_t* iter ,timeval tv)
(def-function bson-iter-timeval
             "bson_iter_timeval" (void* timeval) void)

;;void bson_iter_timestamp(bson_iter_t* iter ,uint32_t* timestamp ,uint32_t* increment)
(def-function bson-iter-timestamp
             "bson_iter_timestamp" (void* void* void*) void)

;;bool bson_iter_bool(bson_iter_t* iter)
(def-function bson-iter-bool
             "bson_iter_bool" (void*) int)

;;bool bson_iter_as_bool(bson_iter_t* iter)
(def-function bson-iter-as-bool
             "bson_iter_as_bool" (void*) int)

;;char* bson_iter_regex(bson_iter_t* iter ,char options)
(def-function bson-iter-regex
             "bson_iter_regex" (void* char) string)

;;char* bson_iter_symbol(bson_iter_t* iter ,uint32_t* length)
(def-function bson-iter-symbol
             "bson_iter_symbol" (void* void*) string)

;;bson_type_t bson_iter_type(bson_iter_t* iter)
(def-function bson-iter-type
             "bson_iter_type" (void*) bson_type_t)

;;bool bson_iter_recurse(bson_iter_t* iter ,bson_iter_t* child)
(def-function bson-iter-recurse
             "bson_iter_recurse" (void* void*) int)

;;void bson_iter_overwrite_int32(bson_iter_t* iter ,int32_t value)
(def-function bson-iter-overwrite-int32
             "bson_iter_overwrite_int32" (void* int) void)

;;void bson_iter_overwrite_int64(bson_iter_t* iter ,int64_t value)
(def-function bson-iter-overwrite-int64
             "bson_iter_overwrite_int64" (void* int) void)

;;void bson_iter_overwrite_double(bson_iter_t* iter ,double value)
(def-function bson-iter-overwrite-double
             "bson_iter_overwrite_double" (void* double) void)

;;void bson_iter_overwrite_decimal128(bson_iter_t* iter ,bson_decimal128_t* value)
(def-function bson-iter-overwrite-decimal128
             "bson_iter_overwrite_decimal128" (void* void*) void)

;;void bson_iter_overwrite_bool(bson_iter_t* iter ,bool value)
(def-function bson-iter-overwrite-bool
             "bson_iter_overwrite_bool" (void* int) void)

;;bool bson_iter_visit_all(bson_iter_t* iter ,bson_visitor_t* visitor ,void* data)
(def-function bson-iter-visit-all
             "bson_iter_visit_all" (void* void* void*) int)

;;bson_json_reader_t* bson_json_reader_new(void* data ,bson_json_reader_cb cb ,bson_json_destroy_cb dcb ,bool allow_multiple ,size_t buf_size)
(def-function bson-json-reader-new
             "bson_json_reader_new" (void* bson_json_reader_cb bson_json_destroy_cb int size_t) void*)

;;bson_json_reader_t* bson_json_reader_new_from_fd(int fd ,bool close_on_destroy)
(def-function bson-json-reader-new-from-fd
             "bson_json_reader_new_from_fd" (int int) void*)

;;bson_json_reader_t* bson_json_reader_new_from_file(char* filename ,bson_error_t* error)
(def-function bson-json-reader-new-from-file
             "bson_json_reader_new_from_file" (string void*) void*)

;;void bson_json_reader_destroy(bson_json_reader_t* reader)
(def-function bson-json-reader-destroy
             "bson_json_reader_destroy" (void*) void)

;;int bson_json_reader_read(bson_json_reader_t* reader ,bson_t* bson ,bson_error_t* error)
(def-function bson-json-reader-read
             "bson_json_reader_read" (void* void* void*) int)

;;bson_json_reader_t* bson_json_data_reader_new(bool allow_multiple ,size_t size)
(def-function bson-json-data-reader-new
             "bson_json_data_reader_new" (int size_t) void*)

;;void bson_json_data_reader_ingest(bson_json_reader_t* reader ,uint8_t* data ,size_t len)
(def-function bson-json-data-reader-ingest
             "bson_json_data_reader_ingest" (void* void* size_t) void)

;;size_t bson_uint32_to_string(uint32_t value ,char strptr ,char* str ,size_t size)
(def-function bson-uint32-to-string
             "bson_uint32_to_string" (int char string size_t) size_t)

;;void bson_md5_init(bson_md5_t* pms)
(def-function bson-md5-init
             "bson_md5_init" (void*) void)

;;void bson_md5_append(bson_md5_t* pms ,uint8_t* data ,uint32_t nbytes)
(def-function bson-md5-append
             "bson_md5_append" (void* void* int) void)

;;void bson_md5_finish(bson_md5_t* pms)
(def-function bson-md5-finish
             "bson_md5_finish" (void*) void)

;;void bson_mem_set_vtable(bson_mem_vtable_t* vtable)
(def-function bson-mem-set-vtable
             "bson_mem_set_vtable" (void*) void)

;;void bson_mem_restore_vtable()
(def-function bson-mem-restore-vtable
             "bson_mem_restore_vtable" () void)

;;void* bson_malloc(size_t num_bytes)
(def-function bson-malloc
             "bson_malloc" (size_t) void*)

;;void* bson_malloc0(size_t num_bytes)
(def-function bson-malloc0
             "bson_malloc0" (size_t) void*)

;;void* bson_realloc(void* mem ,size_t num_bytes)
(def-function bson-realloc
             "bson_realloc" (void* size_t) void*)

;;void* bson_realloc_ctx(void* mem ,size_t num_bytes ,void* ctx)
(def-function bson-realloc-ctx
             "bson_realloc_ctx" (void* size_t void*) void*)

;;void bson_free(void* mem)
(def-function bson-free
             "bson_free" (void*) void)

;;void bson_zero_free(void* mem ,size_t size)
(def-function bson-zero-free
             "bson_zero_free" (void* size_t) void)

;;int bson_oid_compare(bson_oid_t* oid1 ,bson_oid_t* oid2)
(def-function bson-oid-compare
             "bson_oid_compare" (void* void*) int)

;;void bson_oid_copy(bson_oid_t* src ,bson_oid_t* dst)
(def-function bson-oid-copy
             "bson_oid_copy" (void* void*) void)

;;bool bson_oid_equal(bson_oid_t* oid1 ,bson_oid_t* oid2)
(def-function bson-oid-equal
             "bson_oid_equal" (void* void*) int)

;;bool bson_oid_is_valid(char* str ,size_t length)
(def-function bson-oid-is-valid
             "bson_oid_is_valid" (string size_t) int)

;;time_t bson_oid_get_time_t(bson_oid_t* oid)
(def-function bson-oid-get-time-t
             "bson_oid_get_time_t" (void*) time_t)

;;uint32_t bson_oid_hash(bson_oid_t* oid)
(def-function bson-oid-hash
             "bson_oid_hash" (void*) int)

;;void bson_oid_init(bson_oid_t* oid ,bson_context_t* context)
(def-function bson-oid-init
             "bson_oid_init" (void* void*) void)

;;void bson_oid_init_from_data(bson_oid_t* oid ,uint8_t* data)
(def-function bson-oid-init-from-data
             "bson_oid_init_from_data" (void* void*) void)

;;void bson_oid_init_from_string(bson_oid_t* oid ,char* str)
(def-function bson-oid-init-from-string
             "bson_oid_init_from_string" (void* string) void)

;;void bson_oid_init_sequence(bson_oid_t* oid ,bson_context_t* context)
(def-function bson-oid-init-sequence
             "bson_oid_init_sequence" (void* void*) void)

;;void bson_oid_to_string(bson_oid_t* oid)
(def-function bson-oid-to-string
             "bson_oid_to_string" (void*) void)

;;bson_reader_t* bson_reader_new_from_handle(void* handle ,bson_reader_read_func_t rf ,bson_reader_destroy_func_t df)
(def-function bson-reader-new-from-handle
             "bson_reader_new_from_handle" (void* bson_reader_read_func_t bson_reader_destroy_func_t) void*)

;;bson_reader_t* bson_reader_new_from_fd(int fd ,bool close_on_destroy)
(def-function bson-reader-new-from-fd
             "bson_reader_new_from_fd" (int int) void*)

;;bson_reader_t* bson_reader_new_from_file(char* path ,bson_error_t* error)
(def-function bson-reader-new-from-file
             "bson_reader_new_from_file" (string void*) void*)

;;bson_reader_t* bson_reader_new_from_data(uint8_t* data ,size_t length)
(def-function bson-reader-new-from-data
             "bson_reader_new_from_data" (void* size_t) void*)

;;void bson_reader_destroy(bson_reader_t* reader)
(def-function bson-reader-destroy
             "bson_reader_destroy" (void*) void)

;;void bson_reader_set_read_func(bson_reader_t* reader ,bson_reader_read_func_t func)
(def-function bson-reader-set-read-func
             "bson_reader_set_read_func" (void* bson_reader_read_func_t) void)

;;void bson_reader_set_destroy_func(bson_reader_t* reader ,bson_reader_destroy_func_t func)
(def-function bson-reader-set-destroy-func
             "bson_reader_set_destroy_func" (void* bson_reader_destroy_func_t) void)

;;bson_t* bson_reader_read(bson_reader_t* reader ,bool* reached_eof)
(def-function bson-reader-read
             "bson_reader_read" (void* void*) void*)

;;off_t bson_reader_tell(bson_reader_t* reader)
(def-function bson-reader-tell
             "bson_reader_tell" (void*) off_t)

;;void bson_reader_reset(bson_reader_t* reader)
(def-function bson-reader-reset
             "bson_reader_reset" (void*) void)

;;bson_string_t* bson_string_new(char* str)
(def-function bson-string-new
             "bson_string_new" (string) void*)

;;char* bson_string_free(bson_string_t* string ,bool free_segment)
(def-function bson-string-free
             "bson_string_free" (void* int) string)

;;void bson_string_append(bson_string_t* string ,char* str)
(def-function bson-string-append
             "bson_string_append" (void* string) void)

;;void bson_string_append_c(bson_string_t* string ,char str)
(def-function bson-string-append-c
             "bson_string_append_c" (void* char) void)

;;void bson_string_append_unichar(bson_string_t* string ,bson_unichar_t unichar)
(def-function bson-string-append-unichar
             "bson_string_append_unichar" (void* bson_unichar_t) void)

;;void bson_string_append_printf(bson_string_t* string ,char* format)
(def-function bson-string-append-printf
             "bson_string_append_printf" (void* string) void)

;;void bson_string_truncate(bson_string_t* string ,uint32_t len)
(def-function bson-string-truncate
             "bson_string_truncate" (void* int) void)

;;char* bson_strdup(char* str)
(def-function bson-strdup
             "bson_strdup" (string) string)

;;char* bson_strdup_printf(char* format)
(def-function bson-strdup-printf
             "bson_strdup_printf" (string) string)

;;char* bson_strdupv_printf(char* format ,va_list args)
(def-function bson-strdupv-printf
             "bson_strdupv_printf" (string va_list) string)

;;char* bson_strndup(char* str ,size_t n_bytes)
(def-function bson-strndup
             "bson_strndup" (string size_t) string)

;;void bson_strncpy(char* dst ,char* src ,size_t size)
(def-function bson-strncpy
             "bson_strncpy" (string string size_t) void)

;;int bson_vsnprintf(char* str ,size_t size ,char* format ,va_list ap)
(def-function bson-vsnprintf
             "bson_vsnprintf" (string size_t string va_list) int)

;;int bson_snprintf(char* str ,size_t size ,char* format)
(def-function bson-snprintf
             "bson_snprintf" (string size_t string) int)

;;void bson_strfreev(char strv)
(def-function bson-strfreev
             "bson_strfreev" (char) void)

;;size_t bson_strnlen(char* s ,size_t maxlen)
(def-function bson-strnlen
             "bson_strnlen" (string size_t) size_t)

;;int64_t bson_ascii_strtoll(char* str ,char endptr ,int base)
(def-function bson-ascii-strtoll
             "bson_ascii_strtoll" (string char int) int)

;;bool bson_utf8_validate(char* utf8 ,size_t utf8_len ,bool allow_null)
(def-function bson-utf8-validate
             "bson_utf8_validate" (string size_t int) int)

;;char* bson_utf8_escape_for_json(char* utf8 ,ssize_t utf8_len)
(def-function bson-utf8-escape-for-json
             "bson_utf8_escape_for_json" (string ssize_t) string)

;;bson_unichar_t bson_utf8_get_char(char* utf8)
(def-function bson-utf8-get-char
             "bson_utf8_get_char" (string) bson_unichar_t)

;;char* bson_utf8_next_char(char* utf8)
(def-function bson-utf8-next-char
             "bson_utf8_next_char" (string) string)

;;void bson_utf8_from_unichar(bson_unichar_t unichar ,uint32_t* len)
(def-function bson-utf8-from-unichar
             "bson_utf8_from_unichar" (bson_unichar_t void*) void)

;;void bson_value_copy(bson_value_t* src ,bson_value_t* dst)
(def-function bson-value-copy
             "bson_value_copy" (void* void*) void)

;;void bson_value_destroy(bson_value_t* value)
(def-function bson-value-destroy
             "bson_value_destroy" (void*) void)

;;int bson_get_major_version()
(def-function bson-get-major-version
             "bson_get_major_version" () int)

;;int bson_get_minor_version()
(def-function bson-get-minor-version
             "bson_get_minor_version" () int)

;;int bson_get_micro_version()
(def-function bson-get-micro-version
             "bson_get_micro_version" () int)

;;char* bson_get_version()
(def-function bson-get-version
             "bson_get_version" () string)

;;bool bson_check_version(int required_major ,int required_minor ,int required_micro)
(def-function bson-check-version
             "bson_check_version" (int int int) int)

;;bson_writer_t* bson_writer_new(uint8_t buf ,size_t* buflen ,size_t offset ,bson_realloc_func realloc_func ,void* realloc_func_ctx)
(def-function bson-writer-new
             "bson_writer_new" (uint8_t void* size_t bson_realloc_func void*) void*)

;;void bson_writer_destroy(bson_writer_t* writer)
(def-function bson-writer-destroy
             "bson_writer_destroy" (void*) void)

;;size_t bson_writer_get_length(bson_writer_t* writer)
(def-function bson-writer-get-length
             "bson_writer_get_length" (void*) size_t)

;;bool bson_writer_begin(bson_writer_t* writer ,bson_t bson)
(def-function bson-writer-begin
             "bson_writer_begin" (void* bson_t) int)

;;void bson_writer_end(bson_writer_t* writer)
(def-function bson-writer-end
             "bson_writer_end" (void*) void)

;;void bson_writer_rollback(bson_writer_t* writer)
(def-function bson-writer-rollback
             "bson_writer_rollback" (void*) void)

;;void bcon_append(bson_t* bson)
(def-function bcon-append
             "bcon_append" (void*) void)

;;void bcon_append_ctx(bson_t* bson ,bcon_append_ctx_t* ctx)
(def-function bcon-append-ctx
             "bcon_append_ctx" (void* void*) void)

;;void bcon_append_ctx_va(bson_t* bson ,bcon_append_ctx_t* ctx ,va_list* va)
(def-function bcon-append-ctx-va
             "bcon_append_ctx_va" (void* void* void*) void)

;;void bcon_append_ctx_init(bcon_append_ctx_t* ctx)
(def-function bcon-append-ctx-init
             "bcon_append_ctx_init" (void*) void)

;;void bcon_extract_ctx_init(bcon_extract_ctx_t* ctx)
(def-function bcon-extract-ctx-init
             "bcon_extract_ctx_init" (void*) void)

;;void bcon_extract_ctx(bson_t* bson ,bcon_extract_ctx_t* ctx)
(def-function bcon-extract-ctx
             "bcon_extract_ctx" (void* void*) void)

;;bool bcon_extract_ctx_va(bson_t* bson ,bcon_extract_ctx_t* ctx ,va_list* ap)
(def-function bcon-extract-ctx-va
             "bcon_extract_ctx_va" (void* void* void*) int)

;;bool bcon_extract(bson_t* bson)
(def-function bcon-extract
             "bcon_extract" (void*) int)

;;bool bcon_extract_va(bson_t* bson ,bcon_extract_ctx_t* ctx)
(def-function bcon-extract-va
             "bcon_extract_va" (void* void*) int)

;;bson_t* bcon_new(void* unused)
(def-function bcon-new
             "bcon_new" (void*) void*)

;;char* bson_bcon_magic()
(def-function bson-bcon-magic
             "bson_bcon_magic" () string)

;;char* bson_bcone_magic()
(def-function bson-bcone-magic
             "bson_bcone_magic" () string)

;;bson_t* bson_new()
(def-function bson-new
             "bson_new" () void*)

;;bson_t* bson_new_from_json(uint8_t* data ,ssize_t len ,bson_error_t* error)
(def-function bson-new-from-json
             "bson_new_from_json" (string int void*) void*)

;;bool bson_init_from_json(bson_t* bson ,char* data ,ssize_t len ,bson_error_t* error)
(def-function bson-init-from-json
             "bson_init_from_json" (void* string ssize_t void*) int)

;;bool bson_init_static(bson_t* b ,uint8_t* data ,size_t length)
(def-function bson-init-static
             "bson_init_static" (void* void* size_t) int)

;;void bson_init(bson_t* b)
(def-function bson-init
             "bson_init" (void*) void)

;;void bson_reinit(bson_t* b)
(def-function bson-reinit
             "bson_reinit" (void*) void)

;;bson_t* bson_new_from_data(uint8_t* data ,size_t length)
(def-function bson-new-from-data
             "bson_new_from_data" (void* size_t) void*)

;;bson_t* bson_new_from_buffer(uint8_t buf ,size_t* buf_len ,bson_realloc_func realloc_func ,void* realloc_func_ctx)
(def-function bson-new-from-buffer
             "bson_new_from_buffer" (uint8_t void* bson_realloc_func void*) void*)

;;bson_t* bson_sized_new(size_t size)
(def-function bson-sized-new
             "bson_sized_new" (size_t) void*)

;;bson_t* bson_copy(bson_t* bson)
(def-function bson-copy
             "bson_copy" (void*) void*)

;;void bson_copy_to(bson_t* src ,bson_t* dst)
(def-function bson-copy-to
             "bson_copy_to" (void* void*) void)

;;void bson_copy_to_excluding(bson_t* src ,bson_t* dst ,char* first_exclude)
(def-function bson-copy-to-excluding
             "bson_copy_to_excluding" (void* void* string) void)

;;void bson_copy_to_excluding_noinit(bson_t* src ,bson_t* dst ,char* first_exclude)
(def-function bson-copy-to-excluding-noinit
             "bson_copy_to_excluding_noinit" (void* void* string) void)

;;void bson_destroy(bson_t* bson)
(def-function bson-destroy
             "bson_destroy" (void*) void)

;;uint8_t* bson_reserve_buffer(bson_t* bson ,uint32_t size)
(def-function bson-reserve-buffer
             "bson_reserve_buffer" (void* int) void*)

;;bool bson_steal(bson_t* dst ,bson_t* src)
(def-function bson-steal
             "bson_steal" (void* void*) int)

;;uint8_t* bson_destroy_with_steal(bson_t* bson ,bool steal ,uint32_t* length)
(def-function bson-destroy-with-steal
             "bson_destroy_with_steal" (void* int void*) void*)

;;uint8_t* bson_get_data(bson_t* bson)
(def-function bson-get-data
             "bson_get_data" (void*) void*)

;;uint32_t bson_count_keys(bson_t* bson)
(def-function bson-count-keys
             "bson_count_keys" (void*) int)

;;bool bson_has_field(bson_t* bson ,char* key)
(def-function bson-has-field
             "bson_has_field" (void* string) int)

;;int bson_compare(bson_t* bson ,bson_t* other)
(def-function bson-compare
             "bson_compare" (void* void*) int)

;;bool bson_equal(bson_t* bson ,bson_t* other)
(def-function bson-equal
             "bson_equal" (void* void*) int)

;;bool bson_validate(bson_t* bson ,bson_validate_flags_t flags ,size_t* offset)
(def-function bson-validate
             "bson_validate" (void* bson_validate_flags_t void*) int)

;;char* bson_as_json(bson_t* bson ,size_t* length)
(def-function bson-as-json
             "bson_as_json" (void* void*) string)

;;char* bson_array_as_json(bson_t* bson ,size_t* length)
(def-function bson-array-as-json
             "bson_array_as_json" (void* void*) string)

;;bool bson_append_value(bson_t* bson ,char* key ,int key_length ,bson_value_t* value)
(def-function bson-append-value
             "bson_append_value" (void* string int void*) int)

;;bool bson_append_array(bson_t* bson ,char* key ,int key_length ,bson_t* array)
(def-function bson-append-array
             "bson_append_array" (void* string int void*) int)

;;bool bson_append_binary(bson_t* bson ,char* key ,int key_length ,bson_subtype_t subtype ,uint8_t* binary ,uint32_t length)
(def-function bson-append-binary
             "bson_append_binary" (void* string int bson_subtype_t void* int) int)

;;bool bson_append_bool(bson_t* bson ,char* key ,int key_length ,bool value)
(def-function bson-append-bool
             "bson_append_bool" (void* string int int) int)

;;bool bson_append_code(bson_t* bson ,char* key ,int key_length ,char* javascript)
(def-function bson-append-code
             "bson_append_code" (void* string int string) int)

;;bool bson_append_code_with_scope(bson_t* bson ,char* key ,int key_length ,char* javascript ,bson_t* scope)
(def-function bson-append-code-with-scope
             "bson_append_code_with_scope" (void* string int string void*) int)

;;bool bson_append_dbpointer(bson_t* bson ,char* key ,int key_length ,char* collection ,bson_oid_t* oid)
(def-function bson-append-dbpointer
             "bson_append_dbpointer" (void* string int string void*) int)

;;bool bson_append_double(bson_t* bson ,char* key ,int key_length ,double value)
(def-function bson-append-double
             "bson_append_double" (void* string int double) int)

;;bool bson_append_document(bson_t* bson ,char* key ,int key_length ,bson_t* value)
(def-function bson-append-document
             "bson_append_document" (void* string int void*) int)

;;bool bson_append_document_begin(bson_t* bson ,char* key ,int key_length ,bson_t* child)
(def-function bson-append-document-begin
             "bson_append_document_begin" (void* string int void*) int)

;;bool bson_append_document_end(bson_t* bson ,bson_t* child)
(def-function bson-append-document-end
             "bson_append_document_end" (void* void*) int)

;;bool bson_append_array_begin(bson_t* bson ,char* key ,int key_length ,bson_t* child)
(def-function bson-append-array-begin
             "bson_append_array_begin" (void* string int void*) int)

;;bool bson_append_array_end(bson_t* bson ,bson_t* child)
(def-function bson-append-array-end
             "bson_append_array_end" (void* void*) int)

;;bool bson_append_int32(bson_t* bson ,char* key ,int key_length ,int32_t value)
(def-function bson-append-int32
             "bson_append_int32" (void* string int int) int)

;;bool bson_append_int64(bson_t* bson ,char* key ,int key_length ,int64_t value)
(def-function bson-append-int64
             "bson_append_int64" (void* string int int) int)

;;bool bson_append_decimal128(bson_t* bson ,char* key ,int key_length ,bson_decimal128_t* value)
(def-function bson-append-decimal128
             "bson_append_decimal128" (void* string int void*) int)

;;bool bson_append_iter(bson_t* bson ,char* key ,int key_length ,bson_iter_t* iter)
(def-function bson-append-iter
             "bson_append_iter" (void* string int void*) int)

;;bool bson_append_minkey(bson_t* bson ,char* key ,int key_length)
(def-function bson-append-minkey
             "bson_append_minkey" (void* string int) int)

;;bool bson_append_maxkey(bson_t* bson ,char* key ,int key_length)
(def-function bson-append-maxkey
             "bson_append_maxkey" (void* string int) int)

;;bool bson_append_null(bson_t* bson ,char* key ,int key_length)
(def-function bson-append-null
             "bson_append_null" (void* string int) int)

;;bool bson_append_oid(bson_t* bson ,char* key ,int key_length ,bson_oid_t* oid)
(def-function bson-append-oid
             "bson_append_oid" (void* string int void*) int)

;;bool bson_append_regex(bson_t* bson ,char* key ,int key_length ,char* regex ,char* options)
(def-function bson-append-regex
             "bson_append_regex" (void* string int string string) int)

;;bool bson_append_utf8(bson_t* bson ,char* key ,int key_length ,char* value ,int length)
(def-function bson-append-utf8
             "bson_append_utf8" (void* string int string int) int)

;;bool bson_append_symbol(bson_t* bson ,char* key ,int key_length ,char* value ,int length)
(def-function bson-append-symbol
             "bson_append_symbol" (void* string int string int) int)

;;bool bson_append_time_t(bson_t* bson ,char* key ,int key_length ,time_t value)
(def-function bson-append-time-t
             "bson_append_time_t" (void* string int time_t) int)

;;bool bson_append_timeval(bson_t* bson ,char* key ,int key_length ,timeval value)
(def-function bson-append-timeval
             "bson_append_timeval" (void* string int timeval) int)

;;bool bson_append_date_time(bson_t* bson ,char* key ,int key_length ,int64_t value)
(def-function bson-append-date-time
             "bson_append_date_time" (void* string int int) int)

;;bool bson_append_now_utc(bson_t* bson ,char* key ,int key_length)
(def-function bson-append-now-utc
             "bson_append_now_utc" (void* string int) int)

;;bool bson_append_timestamp(bson_t* bson ,char* key ,int key_length ,uint32_t timestamp ,uint32_t increment)
(def-function bson-append-timestamp
             "bson_append_timestamp" (void* string int int int) int)

;;bool bson_append_undefined(bson_t* bson ,char* key ,int key_length)
(def-function bson-append-undefined
             "bson_append_undefined" (void* string int) int)

;;bool bson_concat(bson_t* dst ,bson_t* src)
(def-function bson-concat
             "bson_concat" (void* void*) int)



)
