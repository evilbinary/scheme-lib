;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;作者:evilbinary on 2017-09-16 13:52:59.
;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (tensorflow tensorflow-ffi )
  (export tf-data-type-size
	  tf-version
  tf-delete-status
  tf-set-status
  tf-get-code
  tf-message
  tf-new-buffer-from-string
  tf-delete-buffer
  tf-get-buffer
  tf-new-tensor
  tf-allocate-tensor
  tf-tensor-maybe-move
  tf-delete-tensor
  tf-tensor-type
  tf-num-dims
  tf-dim
  tf-tensor-byte-size
  tf-tensor-data
  tf-string-encode
  tf-string-decode
  tf-string-encoded-size
  tf-set-target
  tf-set-config
  tf-delete-session-options
  tf-delete-graph
  tf-graph-set-tensor-shape
  tf-graph-get-tensor-num-dims
  tf-graph-get-tensor-shape
  tf-new-operation
  tf-set-device
  tf-add-input
  tf-add-input-list
  tf-add-control-input
  tf-colocate-with
  tf-set-attr-string
  tf-set-attr-string-list
  tf-set-attr-int
  tf-set-attr-int-list
  tf-set-attr-float
  tf-set-attr-float-list
  tf-set-attr-bool
  tf-set-attr-bool-list
  tf-set-attr-type
  tf-set-attr-type-list
  tf-set-attr-shape
  tf-set-attr-shape-list
  tf-set-attr-tensor-shape-proto
  tf-set-attr-tensor-shape-proto-list
  tf-set-attr-tensor
  tf-set-attr-tensor-list
  tf-set-attr-value-proto
  tf-finish-operation
  tf-operation-name
  tf-operation-op-type
  tf-operation-device
  tf-operation-num-outputs
  tf-operation-output-type
  tf-operation-output-list-length
  tf-operation-num-inputs
  tf-operation-input-type
  tf-operation-input-list-length
  tf-operation-input
  tf-operation-output-num-consumers
  tf-operation-output-consumers
  tf-operation-num-control-inputs
  tf-operation-get-control-inputs
  tf-operation-num-control-outputs
  tf-operation-get-control-outputs
  tf-operation-get-attr-metadata
  tf-operation-get-attr-string
  tf-operation-get-attr-string-list
  tf-operation-get-attr-int
  tf-operation-get-attr-int-list
  tf-operation-get-attr-float
  tf-operation-get-attr-float-list
  tf-operation-get-attr-bool
  tf-operation-get-attr-bool-list
  tf-operation-get-attr-type
  tf-operation-get-attr-type-list
  tf-operation-get-attr-shape
  tf-operation-get-attr-shape-list
  tf-operation-get-attr-tensor-shape-proto
  tf-operation-get-attr-tensor-shape-proto-list
  tf-operation-get-attr-tensor
  tf-operation-get-attr-tensor-list
  tf-operation-get-attr-value-proto
  tf-graph-operation-by-name
  tf-graph-next-operation
  tf-graph-to-graph-def
  tf-delete-import-graph-def-options
  tf-import-graph-def-options-set-prefix
  tf-import-graph-def-options-add-input-mapping
  tf-import-graph-def-options-remap-control-dependency
  tf-import-graph-def-options-add-control-dependency
  tf-import-graph-def-options-add-return-output
  tf-import-graph-def-options-num-return-outputs
  tf-graph-import-graph-def-with-return-outputs
  tf-graph-import-graph-def
  tf-operation-to-node-def
  tf-new-while
  tf-finish-while
  tf-abort-while
  tf-add-gradients
  tf-new-session
  tf-load-session-from-saved-model
  tf-close-session
  tf-delete-session
  tf-session-run
  tf-session-p-run-setup
  tf-session-p-run
  tf-delete-p-run-handle
  tf-new-deprecated-session
  tf-close-deprecated-session
  tf-delete-deprecated-session
  tf-reset
  tf-extend-graph
  tf-run
  tfp-run-setup
  tfp-run
  tf-session-list-devices
  tf-deprecated-session-list-devices
  tf-delete-device-list
  tf-device-list-count
  tf-device-list-name
  tf-device-list-type
  tf-device-list-memory-bytes
  tf-load-library
  tf-get-op-list
  tf-delete-library-handle)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libtensorflow.so")
   ((a6nt i3nt ta6nt ti3nt) "libtensorflow.dll")
   ((a6osx i3osx ta6osx ti3osx)  "libtensorflow.so")
   ((a6le i3le ta6le ti3le) "libtensorflow.so")))
 (define lib (load-librarys  lib-name ))

;;const char* TF_Version();
 (def-function tf-version
   "TF_Version" (void) string)
 
;;size_t TF_DataTypeSize(TF_DataType dt)
(def-function tf-data-type-size
             "TF_DataTypeSize" (TF_DataType) int)

;;void TF_DeleteStatus(TF_Status* )
(def-function tf-delete-status
             "TF_DeleteStatus" (void*) void)

;;void TF_SetStatus(TF_Status* s ,TF_Code code ,char* msg)
(def-function tf-set-status
             "TF_SetStatus" (void* TF_Code string) void)

;;TF_Code TF_GetCode(TF_Status* s)
(def-function tf-get-code
             "TF_GetCode" (void*) TF_Code)

;;char* TF_Message(TF_Status* s)
(def-function tf-message
             "TF_Message" (void*) string)

;;TF_Buffer* TF_NewBufferFromString(void* proto ,size_t proto_len)
(def-function tf-new-buffer-from-string
             "TF_NewBufferFromString" (void* int) void*)

;;void TF_DeleteBuffer(TF_Buffer* )
(def-function tf-delete-buffer
             "TF_DeleteBuffer" (void*) void)

;;TF_Buffer TF_GetBuffer(TF_Buffer* buffer)
(def-function tf-get-buffer
             "TF_GetBuffer" (void*) TF_Buffer)

;;TF_Tensor* TF_NewTensor(TF_DataType  ,int64_t* dims ,int num_dims ,void* data ,size_t len ,void* deallocator_arg)
(def-function tf-new-tensor
             "TF_NewTensor" (TF_DataType void* int void* int void*) void*)

;;TF_Tensor* TF_AllocateTensor(TF_DataType  ,int64_t* dims ,int num_dims ,size_t len)
(def-function tf-allocate-tensor
             "TF_AllocateTensor" (TF_DataType void* int int) void*)

;;TF_Tensor* TF_TensorMaybeMove(TF_Tensor* tensor)
(def-function tf-tensor-maybe-move
             "TF_TensorMaybeMove" (void*) void*)

;;void TF_DeleteTensor(TF_Tensor* )
(def-function tf-delete-tensor
             "TF_DeleteTensor" (void*) void)

;;TF_DataType TF_TensorType(TF_Tensor* )
(def-function tf-tensor-type
             "TF_TensorType" (void*) TF_DataType)

;;int TF_NumDims(TF_Tensor* )
(def-function tf-num-dims
             "TF_NumDims" (void*) int)

;;int64_t TF_Dim(TF_Tensor* tensor ,int dim_index)
(def-function tf-dim
             "TF_Dim" (void* int) int)

;;size_t TF_TensorByteSize(TF_Tensor* )
(def-function tf-tensor-byte-size
             "TF_TensorByteSize" (void*) int)

;;void* TF_TensorData(TF_Tensor* )
(def-function tf-tensor-data
             "TF_TensorData" (void*) void*)

;;size_t TF_StringEncode(char* src ,size_t src_len ,char* dst ,size_t dst_len ,TF_Status* status)
(def-function tf-string-encode
             "TF_StringEncode" (string int string int void*) int)

;;size_t TF_StringDecode(char* src ,size_t src_len ,char dst ,size_t* dst_len ,TF_Status* status)
(def-function tf-string-decode
             "TF_StringDecode" (string int char void* void*) int)

;;size_t TF_StringEncodedSize(size_t len)
(def-function tf-string-encoded-size
             "TF_StringEncodedSize" (int) int)

;;void TF_SetTarget(TF_SessionOptions* options ,char* target)
(def-function tf-set-target
             "TF_SetTarget" (void* string) void)

;;void TF_SetConfig(TF_SessionOptions* options ,void* proto ,size_t proto_len ,TF_Status* status)
(def-function tf-set-config
             "TF_SetConfig" (void* void* int void*) void)

;;void TF_DeleteSessionOptions(TF_SessionOptions* )
(def-function tf-delete-session-options
             "TF_DeleteSessionOptions" (void*) void)

;;void TF_DeleteGraph(TF_Graph* )
(def-function tf-delete-graph
             "TF_DeleteGraph" (void*) void)

;;void TF_GraphSetTensorShape(TF_Graph* graph ,TF_Output output ,int64_t* dims ,int num_dims ,TF_Status* status)
(def-function tf-graph-set-tensor-shape
             "TF_GraphSetTensorShape" (void* TF_Output void* int void*) void)

;;int TF_GraphGetTensorNumDims(TF_Graph* graph ,TF_Output output ,TF_Status* status)
(def-function tf-graph-get-tensor-num-dims
             "TF_GraphGetTensorNumDims" (void* TF_Output void*) int)

;;void TF_GraphGetTensorShape(TF_Graph* graph ,TF_Output output ,int64_t* dims ,int num_dims ,TF_Status* status)
(def-function tf-graph-get-tensor-shape
             "TF_GraphGetTensorShape" (void* TF_Output void* int void*) void)

;;TF_OperationDescription* TF_NewOperation(TF_Graph* graph ,char* op_type ,char* oper_name)
(def-function tf-new-operation
             "TF_NewOperation" (void* string string) void*)

;;void TF_SetDevice(TF_OperationDescription* desc ,char* device)
(def-function tf-set-device
             "TF_SetDevice" (void* string) void)

;;void TF_AddInput(TF_OperationDescription* desc ,TF_Output input)
(def-function tf-add-input
             "TF_AddInput" (void* TF_Output) void)

;;void TF_AddInputList(TF_OperationDescription* desc ,TF_Output* inputs ,int num_inputs)
(def-function tf-add-input-list
             "TF_AddInputList" (void* void* int) void)

;;void TF_AddControlInput(TF_OperationDescription* desc ,TF_Operation* input)
(def-function tf-add-control-input
             "TF_AddControlInput" (void* void*) void)

;;void TF_ColocateWith(TF_OperationDescription* desc ,TF_Operation* op)
(def-function tf-colocate-with
             "TF_ColocateWith" (void* void*) void)

;;void TF_SetAttrString(TF_OperationDescription* desc ,char* attr_name ,void* value ,size_t length)
(def-function tf-set-attr-string
             "TF_SetAttrString" (void* string void* int) void)

;;void TF_SetAttrStringList(TF_OperationDescription* desc ,char* attr_name ,void values ,size_t* lengths ,int num_values)
(def-function tf-set-attr-string-list
             "TF_SetAttrStringList" (void* string void void* int) void)

;;void TF_SetAttrInt(TF_OperationDescription* desc ,char* attr_name ,int64_t value)
(def-function tf-set-attr-int
             "TF_SetAttrInt" (void* string int) void)

;;void TF_SetAttrIntList(TF_OperationDescription* desc ,char* attr_name ,int64_t* values ,int num_values)
(def-function tf-set-attr-int-list
             "TF_SetAttrIntList" (void* string void* int) void)

;;void TF_SetAttrFloat(TF_OperationDescription* desc ,char* attr_name ,float value)
(def-function tf-set-attr-float
             "TF_SetAttrFloat" (void* string float) void)

;;void TF_SetAttrFloatList(TF_OperationDescription* desc ,char* attr_name ,float* values ,int num_values)
(def-function tf-set-attr-float-list
             "TF_SetAttrFloatList" (void* string void* int) void)

;;void TF_SetAttrBool(TF_OperationDescription* desc ,char* attr_name ,unsigned char value)
(def-function tf-set-attr-bool
             "TF_SetAttrBool" (void* string int) void)

;;void TF_SetAttrBoolList(TF_OperationDescription* desc ,char* attr_name ,unsigned* values ,int num_values)
(def-function tf-set-attr-bool-list
             "TF_SetAttrBoolList" (void* string void* int) void)

;;void TF_SetAttrType(TF_OperationDescription* desc ,char* attr_name ,TF_DataType value)
(def-function tf-set-attr-type
             "TF_SetAttrType" (void* string TF_DataType) void)

;;void TF_SetAttrTypeList(TF_OperationDescription* desc ,char* attr_name ,TF_DataType* values ,int num_values)
(def-function tf-set-attr-type-list
             "TF_SetAttrTypeList" (void* string void* int) void)

;;void TF_SetAttrShape(TF_OperationDescription* desc ,char* attr_name ,int64_t* dims ,int num_dims)
(def-function tf-set-attr-shape
             "TF_SetAttrShape" (void* string void* int) void)

;;void TF_SetAttrShapeList(TF_OperationDescription* desc ,char* attr_name ,int64_t dims ,int* num_dims ,int num_shapes)
(def-function tf-set-attr-shape-list
             "TF_SetAttrShapeList" (void* string int void* int) void)

;;void TF_SetAttrTensorShapeProto(TF_OperationDescription* desc ,char* attr_name ,void* proto ,size_t proto_len ,TF_Status* status)
(def-function tf-set-attr-tensor-shape-proto
             "TF_SetAttrTensorShapeProto" (void* string void* int void*) void)

;;void TF_SetAttrTensorShapeProtoList(TF_OperationDescription* desc ,char* attr_name ,void protos ,size_t* proto_lens ,int num_shapes ,TF_Status* status)
(def-function tf-set-attr-tensor-shape-proto-list
             "TF_SetAttrTensorShapeProtoList" (void* string void void* int void*) void)

;;void TF_SetAttrTensor(TF_OperationDescription* desc ,char* attr_name ,TF_Tensor* value ,TF_Status* status)
(def-function tf-set-attr-tensor
             "TF_SetAttrTensor" (void* string void* void*) void)

;;void TF_SetAttrTensorList(TF_OperationDescription* desc ,char* attr_name ,TF_Tensor values ,int num_values ,TF_Status* status)
(def-function tf-set-attr-tensor-list
             "TF_SetAttrTensorList" (void* string TF_Tensor int void*) void)

;;void TF_SetAttrValueProto(TF_OperationDescription* desc ,char* attr_name ,void* proto ,size_t proto_len ,TF_Status* status)
(def-function tf-set-attr-value-proto
             "TF_SetAttrValueProto" (void* string void* int void*) void)

;;TF_Operation* TF_FinishOperation(TF_OperationDescription* desc ,TF_Status* status)
(def-function tf-finish-operation
             "TF_FinishOperation" (void* void*) void*)

;;char* TF_OperationName(TF_Operation* oper)
(def-function tf-operation-name
             "TF_OperationName" (void*) string)

;;char* TF_OperationOpType(TF_Operation* oper)
(def-function tf-operation-op-type
             "TF_OperationOpType" (void*) string)

;;char* TF_OperationDevice(TF_Operation* oper)
(def-function tf-operation-device
             "TF_OperationDevice" (void*) string)

;;int TF_OperationNumOutputs(TF_Operation* oper)
(def-function tf-operation-num-outputs
             "TF_OperationNumOutputs" (void*) int)

;;TF_DataType TF_OperationOutputType(TF_Output oper_out)
(def-function tf-operation-output-type
             "TF_OperationOutputType" (TF_Output) TF_DataType)

;;int TF_OperationOutputListLength(TF_Operation* oper ,char* arg_name ,TF_Status* status)
(def-function tf-operation-output-list-length
             "TF_OperationOutputListLength" (void* string void*) int)

;;int TF_OperationNumInputs(TF_Operation* oper)
(def-function tf-operation-num-inputs
             "TF_OperationNumInputs" (void*) int)

;;TF_DataType TF_OperationInputType(TF_Input oper_in)
(def-function tf-operation-input-type
             "TF_OperationInputType" (TF_Input) TF_DataType)

;;int TF_OperationInputListLength(TF_Operation* oper ,char* arg_name ,TF_Status* status)
(def-function tf-operation-input-list-length
             "TF_OperationInputListLength" (void* string void*) int)

;;TF_Output TF_OperationInput(TF_Input oper_in)
(def-function tf-operation-input
             "TF_OperationInput" (TF_Input) TF_Output)

;;int TF_OperationOutputNumConsumers(TF_Output oper_out)
(def-function tf-operation-output-num-consumers
             "TF_OperationOutputNumConsumers" (TF_Output) int)

;;int TF_OperationOutputConsumers(TF_Output oper_out ,TF_Input* consumers ,int max_consumers)
(def-function tf-operation-output-consumers
             "TF_OperationOutputConsumers" (TF_Output void* int) int)

;;int TF_OperationNumControlInputs(TF_Operation* oper)
(def-function tf-operation-num-control-inputs
             "TF_OperationNumControlInputs" (void*) int)

;;int TF_OperationGetControlInputs(TF_Operation* oper ,TF_Operation control_inputs ,int max_control_inputs)
(def-function tf-operation-get-control-inputs
             "TF_OperationGetControlInputs" (void* TF_Operation int) int)

;;int TF_OperationNumControlOutputs(TF_Operation* oper)
(def-function tf-operation-num-control-outputs
             "TF_OperationNumControlOutputs" (void*) int)

;;int TF_OperationGetControlOutputs(TF_Operation* oper ,TF_Operation control_outputs ,int max_control_outputs)
(def-function tf-operation-get-control-outputs
             "TF_OperationGetControlOutputs" (void* TF_Operation int) int)

;;TF_AttrMetadata TF_OperationGetAttrMetadata(TF_Operation* oper ,char* attr_name ,TF_Status* status)
(def-function tf-operation-get-attr-metadata
             "TF_OperationGetAttrMetadata" (void* string void*) TF_AttrMetadata)

;;void TF_OperationGetAttrString(TF_Operation* oper ,char* attr_name ,void* value ,size_t max_length ,TF_Status* status)
(def-function tf-operation-get-attr-string
             "TF_OperationGetAttrString" (void* string void* int void*) void)

;;void TF_OperationGetAttrStringList(TF_Operation* oper ,char* attr_name ,void values ,size_t* lengths ,int max_values ,void* storage ,size_t storage_size ,TF_Status* status)
(def-function tf-operation-get-attr-string-list
             "TF_OperationGetAttrStringList" (void* string void void* int void* int void*) void)

;;void TF_OperationGetAttrInt(TF_Operation* oper ,char* attr_name ,int64_t* value ,TF_Status* status)
(def-function tf-operation-get-attr-int
             "TF_OperationGetAttrInt" (void* string void* void*) void)

;;void TF_OperationGetAttrIntList(TF_Operation* oper ,char* attr_name ,int64_t* values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-int-list
             "TF_OperationGetAttrIntList" (void* string void* int void*) void)

;;void TF_OperationGetAttrFloat(TF_Operation* oper ,char* attr_name ,float* value ,TF_Status* status)
(def-function tf-operation-get-attr-float
             "TF_OperationGetAttrFloat" (void* string void* void*) void)

;;void TF_OperationGetAttrFloatList(TF_Operation* oper ,char* attr_name ,float* values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-float-list
             "TF_OperationGetAttrFloatList" (void* string void* int void*) void)

;;void TF_OperationGetAttrBool(TF_Operation* oper ,char* attr_name ,unsigned* value ,TF_Status* status)
(def-function tf-operation-get-attr-bool
             "TF_OperationGetAttrBool" (void* string void* void*) void)

;;void TF_OperationGetAttrBoolList(TF_Operation* oper ,char* attr_name ,unsigned* values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-bool-list
             "TF_OperationGetAttrBoolList" (void* string void* int void*) void)

;;void TF_OperationGetAttrType(TF_Operation* oper ,char* attr_name ,TF_DataType* value ,TF_Status* status)
(def-function tf-operation-get-attr-type
             "TF_OperationGetAttrType" (void* string void* void*) void)

;;void TF_OperationGetAttrTypeList(TF_Operation* oper ,char* attr_name ,TF_DataType* values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-type-list
             "TF_OperationGetAttrTypeList" (void* string void* int void*) void)

;;void TF_OperationGetAttrShape(TF_Operation* oper ,char* attr_name ,int64_t* value ,int num_dims ,TF_Status* status)
(def-function tf-operation-get-attr-shape
             "TF_OperationGetAttrShape" (void* string void* int void*) void)

;;void TF_OperationGetAttrShapeList(TF_Operation* oper ,char* attr_name ,int64_t dims ,int* num_dims ,int num_shapes ,int64_t* storage ,int storage_size ,TF_Status* status)
(def-function tf-operation-get-attr-shape-list
             "TF_OperationGetAttrShapeList" (void* string int void* int void* int void*) void)

;;void TF_OperationGetAttrTensorShapeProto(TF_Operation* oper ,char* attr_name ,TF_Buffer* value ,TF_Status* status)
(def-function tf-operation-get-attr-tensor-shape-proto
             "TF_OperationGetAttrTensorShapeProto" (void* string void* void*) void)

;;void TF_OperationGetAttrTensorShapeProtoList(TF_Operation* oper ,char* attr_name ,TF_Buffer values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-tensor-shape-proto-list
             "TF_OperationGetAttrTensorShapeProtoList" (void* string TF_Buffer int void*) void)

;;void TF_OperationGetAttrTensor(TF_Operation* oper ,char* attr_name ,TF_Tensor value ,TF_Status* status)
(def-function tf-operation-get-attr-tensor
             "TF_OperationGetAttrTensor" (void* string TF_Tensor void*) void)

;;void TF_OperationGetAttrTensorList(TF_Operation* oper ,char* attr_name ,TF_Tensor values ,int max_values ,TF_Status* status)
(def-function tf-operation-get-attr-tensor-list
             "TF_OperationGetAttrTensorList" (void* string TF_Tensor int void*) void)

;;void TF_OperationGetAttrValueProto(TF_Operation* oper ,char* attr_name ,TF_Buffer* output_attr_value ,TF_Status* status)
(def-function tf-operation-get-attr-value-proto
             "TF_OperationGetAttrValueProto" (void* string void* void*) void)

;;TF_Operation* TF_GraphOperationByName(TF_Graph* graph ,char* oper_name)
(def-function tf-graph-operation-by-name
             "TF_GraphOperationByName" (void* string) void*)

;;TF_Operation* TF_GraphNextOperation(TF_Graph* graph ,size_t* pos)
(def-function tf-graph-next-operation
             "TF_GraphNextOperation" (void* void*) void*)

;;void TF_GraphToGraphDef(TF_Graph* graph ,TF_Buffer* output_graph_def ,TF_Status* status)
(def-function tf-graph-to-graph-def
             "TF_GraphToGraphDef" (void* void* void*) void)

;;void TF_DeleteImportGraphDefOptions(TF_ImportGraphDefOptions* opts)
(def-function tf-delete-import-graph-def-options
             "TF_DeleteImportGraphDefOptions" (void*) void)

;;void TF_ImportGraphDefOptionsSetPrefix(TF_ImportGraphDefOptions* opts ,char* prefix)
(def-function tf-import-graph-def-options-set-prefix
             "TF_ImportGraphDefOptionsSetPrefix" (void* string) void)

;;void TF_ImportGraphDefOptionsAddInputMapping(TF_ImportGraphDefOptions* opts ,char* src_name ,int src_index ,TF_Output dst)
(def-function tf-import-graph-def-options-add-input-mapping
             "TF_ImportGraphDefOptionsAddInputMapping" (void* string int TF_Output) void)

;;void TF_ImportGraphDefOptionsRemapControlDependency(TF_ImportGraphDefOptions* opts ,char* src_name ,TF_Operation* dst)
(def-function tf-import-graph-def-options-remap-control-dependency
             "TF_ImportGraphDefOptionsRemapControlDependency" (void* string void*) void)

;;void TF_ImportGraphDefOptionsAddControlDependency(TF_ImportGraphDefOptions* opts ,TF_Operation* oper)
(def-function tf-import-graph-def-options-add-control-dependency
             "TF_ImportGraphDefOptionsAddControlDependency" (void* void*) void)

;;void TF_ImportGraphDefOptionsAddReturnOutput(TF_ImportGraphDefOptions* opts ,char* oper_name ,int index)
(def-function tf-import-graph-def-options-add-return-output
             "TF_ImportGraphDefOptionsAddReturnOutput" (void* string int) void)

;;int TF_ImportGraphDefOptionsNumReturnOutputs(TF_ImportGraphDefOptions* opts)
(def-function tf-import-graph-def-options-num-return-outputs
             "TF_ImportGraphDefOptionsNumReturnOutputs" (void*) int)

;;void TF_GraphImportGraphDefWithReturnOutputs(TF_Graph* graph ,TF_Buffer* graph_def ,TF_ImportGraphDefOptions* options ,TF_Output* return_outputs ,int num_return_outputs ,TF_Status* status)
(def-function tf-graph-import-graph-def-with-return-outputs
             "TF_GraphImportGraphDefWithReturnOutputs" (void* void* void* void* int void*) void)

;;void TF_GraphImportGraphDef(TF_Graph* graph ,TF_Buffer* graph_def ,TF_ImportGraphDefOptions* options ,TF_Status* status)
(def-function tf-graph-import-graph-def
             "TF_GraphImportGraphDef" (void* void* void* void*) void)

;;void TF_OperationToNodeDef(TF_Operation* oper ,TF_Buffer* output_node_def ,TF_Status* status)
(def-function tf-operation-to-node-def
             "TF_OperationToNodeDef" (void* void* void*) void)

;;TF_WhileParams TF_NewWhile(TF_Graph* g ,TF_Output* inputs ,int ninputs ,TF_Status* status)
(def-function tf-new-while
             "TF_NewWhile" (void* void* int void*) TF_WhileParams)

;;void TF_FinishWhile(TF_WhileParams* params ,TF_Status* status ,TF_Output* outputs)
(def-function tf-finish-while
             "TF_FinishWhile" (void* void* void*) void)

;;void TF_AbortWhile(TF_WhileParams* params)
(def-function tf-abort-while
             "TF_AbortWhile" (void*) void)

;;void TF_AddGradients(TF_Graph* g ,TF_Output* y ,int ny ,TF_Output* x ,int nx ,TF_Output* dx ,TF_Status* status ,TF_Output* dy)
(def-function tf-add-gradients
             "TF_AddGradients" (void* void* int void* int void* void* void*) void)

;;TF_Session* TF_NewSession(TF_Graph* graph ,TF_SessionOptions* opts ,TF_Status* status)
(def-function tf-new-session
             "TF_NewSession" (void* void* void*) void*)

;;TF_Session* TF_LoadSessionFromSavedModel(TF_SessionOptions* session_options ,TF_Buffer* run_options ,char* export_dir ,char tags ,int tags_len ,TF_Graph* graph ,TF_Buffer* meta_graph_def ,TF_Status* status)
(def-function tf-load-session-from-saved-model
             "TF_LoadSessionFromSavedModel" (void* void* string char int void* void* void*) void*)

;;void TF_CloseSession(TF_Session*  ,TF_Status* status)
(def-function tf-close-session
             "TF_CloseSession" (void* void*) void)

;;void TF_DeleteSession(TF_Session*  ,TF_Status* status)
(def-function tf-delete-session
             "TF_DeleteSession" (void* void*) void)

;;void TF_SessionRun(TF_Session* session ,TF_Buffer* run_options ,TF_Output* inputs ,TF_Tensor input_values ,int ninputs ,TF_Output* outputs ,TF_Tensor output_values ,int noutputs ,TF_Operation target_opers ,int ntargets ,TF_Buffer* run_metadata ,TF_Status* )
(def-function tf-session-run
             "TF_SessionRun" (void* void* void* TF_Tensor int void* TF_Tensor int TF_Operation int void* void*) void)

;;void TF_SessionPRunSetup(TF_Session*  ,TF_Output* inputs ,int ninputs ,TF_Output* outputs ,int noutputs ,TF_Operation target_opers ,int ntargets ,char handle ,TF_Status* )
(def-function tf-session-p-run-setup
             "TF_SessionPRunSetup" (void* void* int void* int TF_Operation int char void*) void)

;;void TF_SessionPRun(TF_Session*  ,char* handle ,TF_Output* inputs ,TF_Tensor input_values ,int ninputs ,TF_Output* outputs ,TF_Tensor output_values ,int noutputs ,TF_Operation target_opers ,int ntargets ,TF_Status* )
(def-function tf-session-p-run
             "TF_SessionPRun" (void* string void* TF_Tensor int void* TF_Tensor int TF_Operation int void*) void)

;;void TF_DeletePRunHandle(char* handle)
(def-function tf-delete-p-run-handle
             "TF_DeletePRunHandle" (string) void)

;;TF_DeprecatedSession* TF_NewDeprecatedSession(TF_SessionOptions*  ,TF_Status* status)
(def-function tf-new-deprecated-session
             "TF_NewDeprecatedSession" (void* void*) void*)

;;void TF_CloseDeprecatedSession(TF_DeprecatedSession*  ,TF_Status* status)
(def-function tf-close-deprecated-session
             "TF_CloseDeprecatedSession" (void* void*) void)

;;void TF_DeleteDeprecatedSession(TF_DeprecatedSession*  ,TF_Status* status)
(def-function tf-delete-deprecated-session
             "TF_DeleteDeprecatedSession" (void* void*) void)

;;void TF_Reset(TF_SessionOptions* opt ,char containers ,int ncontainers ,TF_Status* status)
(def-function tf-reset
             "TF_Reset" (void* char int void*) void)

;;void TF_ExtendGraph(TF_DeprecatedSession*  ,void* proto ,size_t proto_len ,TF_Status* )
(def-function tf-extend-graph
             "TF_ExtendGraph" (void* void* int void*) void)

;;void TF_Run(TF_DeprecatedSession*  ,TF_Buffer* run_options ,char input_names ,TF_Tensor inputs ,int ninputs ,char output_names ,TF_Tensor outputs ,int noutputs ,char target_oper_names ,int ntargets ,TF_Buffer* run_metadata ,TF_Status* )
(def-function tf-run
             "TF_Run" (void* void* char TF_Tensor int char TF_Tensor int char int void* void*) void)

;;void TF_PRunSetup(TF_DeprecatedSession*  ,char input_names ,int ninputs ,char output_names ,int noutputs ,char target_oper_names ,int ntargets ,char handle ,TF_Status* )
(def-function tfp-run-setup
             "TF_PRunSetup" (void* char int char int char int char void*) void)

;;void TF_PRun(TF_DeprecatedSession*  ,char* handle ,char input_names ,TF_Tensor inputs ,int ninputs ,char output_names ,TF_Tensor outputs ,int noutputs ,char target_oper_names ,int ntargets ,TF_Status* )
(def-function tfp-run
             "TF_PRun" (void* string char TF_Tensor int char TF_Tensor int char int void*) void)

;;TF_DeviceList* TF_SessionListDevices(TF_Session* session ,TF_Status* status)
(def-function tf-session-list-devices
             "TF_SessionListDevices" (void* void*) void*)

;;TF_DeviceList* TF_DeprecatedSessionListDevices(TF_DeprecatedSession* session ,TF_Status* status)
(def-function tf-deprecated-session-list-devices
             "TF_DeprecatedSessionListDevices" (void* void*) void*)

;;void TF_DeleteDeviceList(TF_DeviceList* list)
(def-function tf-delete-device-list
             "TF_DeleteDeviceList" (void*) void)

;;int TF_DeviceListCount(TF_DeviceList* list)
(def-function tf-device-list-count
             "TF_DeviceListCount" (void*) int)

;;char* TF_DeviceListName(TF_DeviceList* list ,int index ,TF_Status* )
(def-function tf-device-list-name
             "TF_DeviceListName" (void* int void*) string)

;;char* TF_DeviceListType(TF_DeviceList* list ,int index ,TF_Status* )
(def-function tf-device-list-type
             "TF_DeviceListType" (void* int void*) string)

;;int64_t TF_DeviceListMemoryBytes(TF_DeviceList* list ,int index ,TF_Status* )
(def-function tf-device-list-memory-bytes
             "TF_DeviceListMemoryBytes" (void* int void*) int)

;;TF_Library* TF_LoadLibrary(char* library_filename ,TF_Status* status)
(def-function tf-load-library
             "TF_LoadLibrary" (string void*) void*)

;;TF_Buffer TF_GetOpList(TF_Library* lib_handle)
(def-function tf-get-op-list
             "TF_GetOpList" (void*) TF_Buffer)

;;void TF_DeleteLibraryHandle(TF_Library* lib_handle)
(def-function tf-delete-library-handle
             "TF_DeleteLibraryHandle" (void*) void)


)
