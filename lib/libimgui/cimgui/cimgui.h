
#include <stdio.h>

#if defined _WIN32 || defined __CYGWIN__ ||defined __MINGW32__
#define API __declspec(dllexport)
#define snprintf sprintf_s
#else
#define API
#endif

#if defined __cplusplus
#define EXTERN extern "C"
#else
#include <stdarg.h>
#include <stdbool.h>
#define EXTERN extern
#endif

#define CIMGUI_API EXTERN API
#define CONST const

struct ImGuiIO;
struct ImGuiStyle;
struct ImDrawData;
struct ImVec2;
struct ImVec4;
struct ImGuiTextEditCallbackData;
struct ImGuiSizeConstraintCallbackData;
struct ImDrawList;
struct ImGuiStorage;
struct ImFont;
struct ImFontConfig;
struct ImFontAtlas;
struct ImDrawCmd;

typedef unsigned short ImDrawIdx;
//typedef unsigned int ImU32;
typedef unsigned short ImWchar;     
typedef void* ImTextureID;       
typedef ImU32 ImGuiID;
//typedef int ImGuiCol;
typedef int ImGuiStyleVar;          
typedef int ImGuiKey;               
typedef int ImGuiAlign;             
typedef int ImGuiColorEditMode;     
typedef int ImGuiMouseCursor;       
typedef int ImGuiWindowFlags;       
typedef int ImGuiSetCond;           
typedef int ImGuiInputTextFlags;    
typedef int ImGuiSelectableFlags;   
typedef int ImGuiTreeNodeFlags;     
typedef int (*ImGuiTextEditCallback)(struct ImGuiTextEditCallbackData *data);
typedef void (*ImGuiSizeConstraintCallback)(struct ImGuiSizeConstraintCallbackData* data);
typedef void (*ImDrawCallback)(CONST struct ImDrawList* parent_list, CONST struct ImDrawCmd* cmd);

CIMGUI_API struct ImGuiIO*         imguiGetIo();
CIMGUI_API struct ImGuiStyle*      imguiGetStyle();
CIMGUI_API struct ImDrawData*      imguiGetDrawData();
CIMGUI_API void                    imguiNewFrame();
CIMGUI_API void                    imguiRender();
CIMGUI_API void                    imguiShutdown();
CIMGUI_API void                    imguiShowUserGuide();
CIMGUI_API void                    imguiShowStyleEditor(struct ImGuiStyle* ref);
CIMGUI_API void                    imguiShowTestWindow(bool* opened);
CIMGUI_API void                    imguiShowMetricsWindow(bool* opened);

// Window
CIMGUI_API bool             imguiBegin(CONST char* name, ImGuiWindowFlags flags);
CIMGUI_API bool             imguiBegin1(CONST char* name, bool* p_open, ImGuiWindowFlags flags);
CIMGUI_API bool             imguiBegin2(CONST char* name, bool* p_open, CONST struct ImVec2 size_on_first_use, float bg_alpha, ImGuiWindowFlags flags);
CIMGUI_API void             imguiEnd();
CIMGUI_API bool             imguiBeginChild(CONST char* str_id, CONST struct ImVec2 size, bool border, ImGuiWindowFlags extra_flags);
CIMGUI_API bool             imguiBeginChildEx(ImGuiID id, CONST struct ImVec2 size, bool border, ImGuiWindowFlags extra_flags);
CIMGUI_API void             imguiEndChild();
CIMGUI_API void             imguiGetContentRegionMax(struct ImVec2* out);
CIMGUI_API void             imguiGetContentRegionAvail(struct ImVec2* out);
CIMGUI_API float            imguiGetContentRegionAvailWidth();
CIMGUI_API void             imguiGetWindowContentRegionMin(struct ImVec2* out);
CIMGUI_API void             imguiGetWindowContentRegionMax(struct ImVec2* out);
CIMGUI_API float            imguiGetWindowContentRegionWidth();
CIMGUI_API struct ImDrawList*      imguiGetWindowDrawList();
CIMGUI_API void             imguiGetWindowPos(struct ImVec2* out);
CIMGUI_API void             imguiGetWindowSize(struct ImVec2* out);
CIMGUI_API float            imguiGetWindowWidth();
CIMGUI_API float            imguiGetWindowHeight();
CIMGUI_API bool             imguiIsWindowCollapsed();
CIMGUI_API void             imguiSetWindowFontScale(float scale);

CIMGUI_API void             imguiSetNextWindowPos(CONST struct ImVec2 pos, ImGuiSetCond cond);
CIMGUI_API void             imguiSetNextWindowPosCenter(ImGuiSetCond cond);
CIMGUI_API void             imguiSetNextWindowSize(CONST struct ImVec2 size, ImGuiSetCond cond);
CIMGUI_API void             imguiSetNextWindowSizeConstraints(CONST struct ImVec2 size_min, CONST struct ImVec2 size_max, ImGuiSizeConstraintCallback custom_callback, void* custom_callback_data);
CIMGUI_API void             imguiSetNextWindowContentSize(CONST struct ImVec2 size);
CIMGUI_API void             imguiSetNextWindowContentWidth(float width);
CIMGUI_API void             imguiSetNextWindowCollapsed(bool collapsed, ImGuiSetCond cond);
CIMGUI_API void             imguiSetNextWindowFocus();
CIMGUI_API void             imguiSetWindowPos(CONST struct ImVec2 pos, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowSize(CONST struct ImVec2 size, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowCollapsed(bool collapsed, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowFocus();
CIMGUI_API void             imguiSetWindowPosByName(CONST char* name, CONST struct ImVec2 pos, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowSize2(CONST char* name, CONST struct ImVec2 size, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowCollapsed2(CONST char* name, bool collapsed, ImGuiSetCond cond);
CIMGUI_API void             imguiSetWindowFocus2(CONST char* name);

CIMGUI_API float            imguiGetScrollX();
CIMGUI_API float            imguiGetScrollY();
CIMGUI_API float            imguiGetScrollMaxX();
CIMGUI_API float            imguiGetScrollMaxY();
CIMGUI_API void             imguiSetScrollX(float scroll_x);
CIMGUI_API void             imguiSetScrollY(float scroll_y);
CIMGUI_API void             imguiSetScrollHere(float center_y_ratio);
CIMGUI_API void             imguiSetScrollFromPosY(float pos_y, float center_y_ratio);
CIMGUI_API void             imguiSetKeyboardFocusHere(int offset);
CIMGUI_API void             imguiSetStateStorage(struct ImGuiStorage* tree);
CIMGUI_API struct ImGuiStorage*    imguiGetStateStorage();

// Parameters stacks (shared)
CIMGUI_API void             imguiPushFont(struct ImFont* font);
CIMGUI_API void             imguiPopFont();
CIMGUI_API void             imguiPushStyleColor(ImGuiCol idx, CONST struct ImVec4 col);
CIMGUI_API void             imguiPopStyleColor(int count);
CIMGUI_API void             imguiPushStyleVar(ImGuiStyleVar idx, float val);
CIMGUI_API void             imguiPushStyleVarVec(ImGuiStyleVar idx, CONST struct ImVec2 val);
CIMGUI_API void             imguiPopStyleVar(int count);
CIMGUI_API struct ImFont*          imguiGetFont();
CIMGUI_API float            imguiGetFontSize();
CIMGUI_API void             imguiGetFontTexUvWhitePixel(struct ImVec2* pOut);
CIMGUI_API ImU32            imguiGetColorU32(ImGuiCol idx, float alpha_mul);
CIMGUI_API ImU32            imguiGetColorU32Vec(CONST struct ImVec4* col);


// Parameters stacks (current window)
CIMGUI_API void             imguiPushItemWidth(float item_width);
CIMGUI_API void             imguiPopItemWidth();
CIMGUI_API float            imguiCalcItemWidth();
CIMGUI_API void             imguiPushTextWrapPos(float wrap_pos_x);
CIMGUI_API void             imguiPopTextWrapPos();
CIMGUI_API void             imguiPushAllowKeyboardFocus(bool v);
CIMGUI_API void             imguiPopAllowKeyboardFocus();
CIMGUI_API void             imguiPushButtonRepeat(bool repeat);
CIMGUI_API void             imguiPopButtonRepeat();

// Layout
CIMGUI_API void             imguiSeparator();
CIMGUI_API void 			imguiSameLine2(float pos_x, float spacing_w);
CIMGUI_API void             imguiSameLine();
CIMGUI_API void             imguiNewLine();
CIMGUI_API void             imguiSpacing();
CIMGUI_API void             imguiDummy(CONST struct ImVec2* size);
CIMGUI_API void             imguiIndent(float indent_w);
CIMGUI_API void             imguiUnindent(float indent_w);
CIMGUI_API void             imguiBeginGroup();
CIMGUI_API void             imguiEndGroup();
CIMGUI_API void             imguiGetCursorPos(struct ImVec2* pOut);
CIMGUI_API float            imguiGetCursorPosX();
CIMGUI_API float            imguiGetCursorPosY();
CIMGUI_API void             imguiSetCursorPos(CONST struct ImVec2 local_pos);
CIMGUI_API void             imguiSetCursorPosX(float x);
CIMGUI_API void             imguiSetCursorPosY(float y);
CIMGUI_API void             imguiGetCursorStartPos(struct ImVec2* pOut);
CIMGUI_API void             imguiGetCursorScreenPos(struct ImVec2* pOut);
CIMGUI_API void             imguiSetCursorScreenPos(CONST struct ImVec2 pos);
CIMGUI_API void             imguiAlignFirstTextHeightToWidgets();
CIMGUI_API float            imguiGetTextLineHeight();
CIMGUI_API float            imguiGetTextLineHeightWithSpacing();
CIMGUI_API float            imguiGetItemsLineHeightWithSpacing();

//Columns
CIMGUI_API void             imguiColumns(int count, CONST char* id, bool border);
CIMGUI_API void             imguiNextColumn();
CIMGUI_API int              imguiGetColumnIndex();
CIMGUI_API float            imguiGetColumnOffset(int column_index);
CIMGUI_API void             imguiSetColumnOffset(int column_index, float offset_x);
CIMGUI_API float            imguiGetColumnWidth(int column_index);
CIMGUI_API int              imguiGetColumnsCount();

// ID scopes
// If you are creating widgets in a loop you most likely want to push a unique identifier so ImGui can differentiate them
// You can also use "##extra" within your widget name to distinguish them from each others (see 'Programmer Guide')
CIMGUI_API void             imguiPushIdStr(CONST char* str_id);
CIMGUI_API void             imguiPushIdStrRange(CONST char* str_begin, CONST char* str_end);
CIMGUI_API void             imguiPushIdPtr(CONST void* ptr_id);
CIMGUI_API void             imguiPushIdInt(int int_id);
CIMGUI_API void             imguiPopId();
CIMGUI_API ImGuiID          imguiGetIdStr(CONST char* str_id);
CIMGUI_API ImGuiID          imguiGetIdStrRange(CONST char* str_begin,CONST char* str_end);
CIMGUI_API ImGuiID          imguiGetIdPtr(CONST void* ptr_id);

// Widgets
CIMGUI_API void             imguiText(CONST char* fmt, ...);
CIMGUI_API void             imguiTextV(CONST char* fmt, va_list args);
CIMGUI_API void             imguiTextColored(CONST struct ImVec4 col, CONST char* fmt, ...);
CIMGUI_API void             imguiTextColoredV(CONST struct ImVec4 col, CONST char* fmt, va_list args);
CIMGUI_API void             imguiTextDisabled(CONST char* fmt, ...);
CIMGUI_API void             imguiTextDisabledV(CONST char* fmt, va_list args);
CIMGUI_API void             imguiTextWrapped(CONST char* fmt, ...);
CIMGUI_API void             imguiTextWrappedV(CONST char* fmt, va_list args);
CIMGUI_API void             imguiTextUnformatted(CONST char* text, CONST char* text_end);
CIMGUI_API void             imguiLabelText(CONST char* label, CONST char* fmt, ...);
CIMGUI_API void             imguiLabelTextV(CONST char* label, CONST char* fmt, va_list args);
CIMGUI_API void             imguiBullet();
CIMGUI_API void             imguiBulletText(CONST char* fmt, ...);
CIMGUI_API void             imguiBulletTextV(CONST char* fmt, va_list args);
CIMGUI_API bool             imguiButton(CONST char* label, CONST struct ImVec2 size);
CIMGUI_API bool             imguiSmallButton(CONST char* label);
CIMGUI_API bool             imguiInvisibleButton(CONST char* str_id, CONST struct ImVec2 size);
CIMGUI_API void 		imguiImage(ImTextureID user_texture_id, CONST ImVec2& size, CONST ImVec2& uv0,CONST ImVec2& uv1);

CIMGUI_API void             imguiImage2(ImTextureID user_texture_id, CONST struct ImVec2 size, CONST struct ImVec2 uv0, CONST struct ImVec2 uv1, CONST struct ImVec4 tint_col, CONST struct ImVec4 border_col);

CIMGUI_API bool             imguiImageButton(ImTextureID user_texture_id, CONST struct ImVec2 size, CONST struct ImVec2 uv0, CONST struct ImVec2 uv1, int frame_padding, CONST struct ImVec4 bg_col, CONST struct ImVec4 tint_col);
CIMGUI_API bool             imguiCheckbox(CONST char* label, bool* v);
CIMGUI_API bool             imguiCheckboxFlags(CONST char* label, unsigned int* flags, unsigned int flags_value);
CIMGUI_API bool             imguiRadioButtonBool(CONST char* label, bool active);
CIMGUI_API bool             imguiRadioButton(CONST char* label, int* v, int v_button);
CIMGUI_API bool             imguiCombo(CONST char* label, int* current_item, CONST char** items, int items_count, int height_in_items);
CIMGUI_API bool             imguiCombo2(CONST char* label, int* current_item, CONST char* items_separated_by_zeros, int height_in_items);
CIMGUI_API bool             imguiCombo3(CONST char* label, int* current_item, bool(*items_getter)(void* data, int idx, CONST char** out_text), void* data, int items_count, int height_in_items);
CIMGUI_API bool             imguiColorButton(CONST struct ImVec4 col, bool small_height, bool outline_border);
CIMGUI_API bool             imguiColorEdit3(CONST char* label, float col[3]);
CIMGUI_API bool             imguiColorEdit4(CONST char* label, float col[4], bool show_alpha);
CIMGUI_API void             imguiColorEditMode(ImGuiColorEditMode mode);
CIMGUI_API void             imguiPlotLines(CONST char* label, CONST float* values, int values_count, int values_offset, CONST char* overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size, int stride);
CIMGUI_API void             imguiPlotLines2(CONST char* label, float(*values_getter)(void* data, int idx), void* data, int values_count, int values_offset, CONST char* overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size);
CIMGUI_API void             imguiPlotHistogram(CONST char* label, CONST float* values, int values_count, int values_offset, CONST char* overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size, int stride);
CIMGUI_API void             imguiPlotHistogram2(CONST char* label, float(*values_getter)(void* data, int idx), void* data, int values_count, int values_offset, CONST char* overlay_text, float scale_min, float scale_max, struct ImVec2 graph_size);
CIMGUI_API void             imguiProgressBar(float fraction, CONST struct ImVec2* size_arg, CONST char* overlay);


// Widgets: Sliders (tip: ctrl+click on a slider to input text)
CIMGUI_API bool             imguiSliderFloat(CONST char* label, float* v, float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiSliderFloat2(CONST char* label, float v[2], float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiSliderFloat3(CONST char* label, float v[3], float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiSliderFloat4(CONST char* label, float v[4], float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiSliderAngle(CONST char* label, float* v_rad, float v_degrees_min, float v_degrees_max);
CIMGUI_API bool             imguiSliderInt(CONST char* label, int* v, int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiSliderInt2(CONST char* label, int v[2], int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiSliderInt3(CONST char* label, int v[3], int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiSliderInt4(CONST char* label, int v[4], int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiVSliderFloat(CONST char* label, CONST struct ImVec2 size, float* v, float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiVSliderInt(CONST char* label, CONST struct ImVec2 size, int* v, int v_min, int v_max, CONST char* display_format);

// Widgets: Drags (tip: ctrl+click on a drag box to input text)
CIMGUI_API bool             imguiDragFloat(CONST char* label, float* v, float v_speed, float v_min, float v_max, CONST char* display_format, float power);     // If v_max >= v_max we have no bound
CIMGUI_API bool             imguiDragFloat2(CONST char* label, float v[2], float v_speed, float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiDragFloat3(CONST char* label, float v[3], float v_speed, float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiDragFloat4(CONST char* label, float v[4], float v_speed, float v_min, float v_max, CONST char* display_format, float power);
CIMGUI_API bool             imguiDragFloatRange2(CONST char* label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, CONST char* display_format, CONST char* display_format_max, float power);
CIMGUI_API bool             imguiDragInt(CONST char* label, int* v, float v_speed, int v_min, int v_max, CONST char* display_format);                                       // If v_max >= v_max we have no bound
CIMGUI_API bool             imguiDragInt2(CONST char* label, int v[2], float v_speed, int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiDragInt3(CONST char* label, int v[3], float v_speed, int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiDragInt4(CONST char* label, int v[4], float v_speed, int v_min, int v_max, CONST char* display_format);
CIMGUI_API bool             imguiDragIntRange2(CONST char* label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, CONST char* display_format, CONST char* display_format_max);


// Widgets: Input
CIMGUI_API bool             imguiInputText(CONST char* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags, ImGuiTextEditCallback callback, void* user_data);
CIMGUI_API bool             imguiInputTextMultiline(CONST char* label, char* buf, size_t buf_size,  ImGuiInputTextFlags flags, ImGuiTextEditCallback callback, void* user_data,CONST struct ImVec2 size);
CIMGUI_API bool             imguiInputFloat(CONST char* label, float* v, float step, float step_fast, int decimal_precision, ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputFloat2(CONST char* label, float v[2], int decimal_precision, ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputFloat3(CONST char* label, float v[3], int decimal_precision, ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputFloat4(CONST char* label, float v[4], int decimal_precision, ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputInt(CONST char* label, int* v, int step, int step_fast, ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputInt2(CONST char* label, int v[2], ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputInt3(CONST char* label, int v[3], ImGuiInputTextFlags extra_flags);
CIMGUI_API bool             imguiInputInt4(CONST char* label, int v[4], ImGuiInputTextFlags extra_flags);

// Widgets: Trees
CIMGUI_API bool             imguiTreeNode(CONST char* label);
CIMGUI_API bool             imguiTreeNodeStr(CONST char* str_id, CONST char* fmt, ...);
CIMGUI_API bool             imguiTreeNodePtr(CONST void* ptr_id, CONST char* fmt, ...);
CIMGUI_API bool             imguiTreeNodeStrV(CONST char* str_id, CONST char* fmt, va_list args);
CIMGUI_API bool             imguiTreeNodePtrV(CONST void* ptr_id, CONST char* fmt, va_list args);
CIMGUI_API bool             imguiTreeNodeEx(CONST char* label, ImGuiTreeNodeFlags flags);
CIMGUI_API bool             imguiTreeNodeExStr(CONST char* str_id, ImGuiTreeNodeFlags flags, CONST char* fmt, ...);
CIMGUI_API bool             imguiTreeNodeExPtr(CONST void* ptr_id, ImGuiTreeNodeFlags flags, CONST char* fmt, ...);
CIMGUI_API bool             imguiTreeNodeExV(CONST char* str_id, ImGuiTreeNodeFlags flags, CONST char* fmt, va_list args);
CIMGUI_API bool             imguiTreeNodeExVPtr(CONST void* ptr_id, ImGuiTreeNodeFlags flags, CONST char* fmt, va_list args);
CIMGUI_API void             imguiTreePushStr(CONST char* str_id);
CIMGUI_API void             imguiTreePushPtr(CONST void* ptr_id);
CIMGUI_API void             imguiTreePop();
CIMGUI_API void             imguiTreeAdvanceToLabelPos();
CIMGUI_API float            imguiGetTreeNodeToLabelSpacing();
CIMGUI_API void             imguiSetNextTreeNodeOpen(bool opened, ImGuiSetCond cond);
CIMGUI_API bool             imguiCollapsingHeader(CONST char* label, ImGuiTreeNodeFlags flags);
CIMGUI_API bool             imguiCollapsingHeaderEx(CONST char* label, bool* p_open, ImGuiTreeNodeFlags flags);

// Widgets: Selectable / Lists
CIMGUI_API bool             imguiSelectable(CONST char* label, bool selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size);
CIMGUI_API bool             imguiSelectableEx(CONST char* label, bool* p_selected, ImGuiSelectableFlags flags, CONST struct ImVec2 size);
CIMGUI_API bool             imguiListBox(CONST char* label, int* current_item, CONST char** items, int items_count, int height_in_items);
CIMGUI_API bool             imguiListBox2(CONST char* label, int* current_item, bool(*items_getter)(void* data, int idx, CONST char** out_text), void* data, int items_count, int height_in_items);
CIMGUI_API bool             imguiListBoxHeader(CONST char* label, CONST struct ImVec2 size);
CIMGUI_API bool             imguiListBoxHeader2(CONST char* label, int items_count, int height_in_items);
CIMGUI_API void             imguiListBoxFooter();

// Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely declare your own within the ImGui namespace!)
CIMGUI_API void             imguiValueBool(CONST char* prefix, bool b);
CIMGUI_API void             imguiValueInt(CONST char* prefix, int v);
CIMGUI_API void             imguiValueUInt(CONST char* prefix, unsigned int v);
CIMGUI_API void             imguiValueFloat(CONST char* prefix, float v, CONST char* float_format);
CIMGUI_API void             imguiValueColor(CONST char* prefix, CONST struct ImVec4 v);
CIMGUI_API void             imguiValueColor2(CONST char* prefix, unsigned int v);

// Tooltip
CIMGUI_API void             imguiSetTooltip(CONST char* fmt, ...);
CIMGUI_API void             imguiSetTooltipV(CONST char* fmt, va_list args);
CIMGUI_API void             imguiBeginTooltip();
CIMGUI_API void             imguiEndTooltip();

// Widgets: Menus
CIMGUI_API bool             imguiBeginMainMenuBar();
CIMGUI_API void             imguiEndMainMenuBar();
CIMGUI_API bool             imguiBeginMenuBar();
CIMGUI_API void             imguiEndMenuBar();
CIMGUI_API bool             imguiBeginMenu(CONST char* label, bool enabled);
CIMGUI_API void             imguiEndMenu();
CIMGUI_API bool             imguiMenuItem(CONST char* label, CONST char* shortcut, bool selected, bool enabled);
CIMGUI_API bool             imguiMenuItemPtr(CONST char* label, CONST char* shortcut, bool* p_selected, bool enabled);

// Popup
CIMGUI_API void             imguiOpenPopup(CONST char* str_id);
CIMGUI_API bool             imguiBeginPopup(CONST char* str_id);
CIMGUI_API bool             imguiBeginPopupModal(CONST char* name, bool* p_open, ImGuiWindowFlags extra_flags);
CIMGUI_API bool             imguiBeginPopupContextItem(CONST char* str_id, int mouse_button);
CIMGUI_API bool             imguiBeginPopupContextWindow(bool also_over_items, CONST char* str_id, int mouse_button);
CIMGUI_API bool             imguiBeginPopupContextVoid(CONST char* str_id, int mouse_button);
CIMGUI_API void             imguiEndPopup();
CIMGUI_API void             imguiCloseCurrentPopup();

// Logging: all text output from interface is redirected to tty/file/clipboard. Tree nodes are automatically opened.
CIMGUI_API void             imguiLogToTTY(int max_depth);
CIMGUI_API void             imguiLogToFile(int max_depth, CONST char* filename);
CIMGUI_API void             imguiLogToClipboard(int max_depth);
CIMGUI_API void             imguiLogFinish();
CIMGUI_API void             imguiLogButtons();
CIMGUI_API void             imguiLogText(CONST char* fmt, ...);

// Clipping
CIMGUI_API void             imguiPushClipRect(CONST struct ImVec2 clip_rect_min, CONST struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect);
CIMGUI_API void             imguiPopClipRect();

// Utilities
CIMGUI_API bool             imguiIsItemHovered();
CIMGUI_API bool             imguiIsItemHoveredRect();
CIMGUI_API bool             imguiIsItemActive();
CIMGUI_API bool             imguiIsItemClicked(int mouse_button);
CIMGUI_API bool             imguiIsItemVisible();
CIMGUI_API bool             imguiIsAnyItemHovered();
CIMGUI_API bool             imguiIsAnyItemActive();
CIMGUI_API void             imguiGetItemRectMin(struct ImVec2* pOut);
CIMGUI_API void             imguiGetItemRectMax(struct ImVec2* pOut);
CIMGUI_API void             imguiGetItemRectSize(struct ImVec2* pOut);
CIMGUI_API void             imguiSetItemAllowOverlap();
CIMGUI_API bool             imguiIsWindowHovered();
CIMGUI_API bool             imguiIsWindowFocused();
CIMGUI_API bool             imguiIsRootWindowFocused();
CIMGUI_API bool             imguiIsRootWindowOrAnyChildFocused();
CIMGUI_API bool             imguiIsRootWindowOrAnyChildHovered();
CIMGUI_API bool             imguiIsRectVisible(CONST struct ImVec2 item_size);
CIMGUI_API bool             imguiIsPosHoveringAnyWindow(CONST struct ImVec2 pos);
CIMGUI_API float            imguiGetTime();
CIMGUI_API int              imguiGetFrameCount();
CIMGUI_API CONST char*      imguiGetStyleColName(ImGuiCol idx);
CIMGUI_API void             imguiCalcItemRectClosestPoint(struct ImVec2* pOut, CONST struct ImVec2 pos, bool on_edge, float outward);
CIMGUI_API void             imguiCalcTextSize(struct ImVec2* pOut, CONST char* text, CONST char* text_end, bool hide_text_after_double_hash, float wrap_width);
CIMGUI_API void             imguiCalcListClipping(int items_count, float items_height, int* out_items_display_start, int* out_items_display_end);

CIMGUI_API bool             imguiBeginChildFrame(ImGuiID id, CONST struct ImVec2 size, ImGuiWindowFlags extra_flags);
CIMGUI_API void             imguiEndChildFrame();

CIMGUI_API void             imguiColorConvertU32ToFloat4(struct ImVec4* pOut, ImU32 in);
CIMGUI_API ImU32            imguiColorConvertFloat4ToU32(CONST struct ImVec4 in);
CIMGUI_API void             imguiColorConvertRGBtoHSV(float r, float g, float b, float* out_h, float* out_s, float* out_v);
CIMGUI_API void             imguiColorConvertHSVtoRGB(float h, float s, float v, float* out_r, float* out_g, float* out_b);

CIMGUI_API int              imguiGetKeyIndex(ImGuiKey key);
CIMGUI_API bool             imguiIsKeyDown(int key_index);
CIMGUI_API bool             imguiIsKeyPressed(int key_index, bool repeat);
CIMGUI_API bool             imguiIsKeyReleased(int key_index);
CIMGUI_API bool             imguiIsMouseDown(int button);
CIMGUI_API bool             imguiIsMouseClicked(int button, bool repeat);
CIMGUI_API bool             imguiIsMouseDoubleClicked(int button);
CIMGUI_API bool             imguiIsMouseReleased(int button);
CIMGUI_API bool             imguiIsMouseHoveringWindow();
CIMGUI_API bool             imguiIsMouseHoveringAnyWindow();
CIMGUI_API bool             imguiIsMouseHoveringRect(CONST struct ImVec2 r_min, CONST struct ImVec2 r_max, bool clip);
CIMGUI_API bool             imguiIsMouseDragging(int button, float lock_threshold);
CIMGUI_API void             imguiGetMousePos(struct ImVec2* pOut);
CIMGUI_API void             imguiGetMousePosOnOpeningCurrentPopup(struct ImVec2* pOut);
CIMGUI_API void             imguiGetMouseDragDelta(struct ImVec2* pOut, int button, float lock_threshold);
CIMGUI_API void             imguiResetMouseDragDelta(int button);
CIMGUI_API ImGuiMouseCursor imguiGetMouseCursor();
CIMGUI_API void             imguiSetMouseCursor(ImGuiMouseCursor type);
CIMGUI_API void             imguiCaptureKeyboardFromApp(bool capture);
CIMGUI_API void             imguiCaptureMouseFromApp(bool capture);

// Helpers functions to access functions pointers in ImGui::GetIO()
CIMGUI_API void*            imguiMemAlloc(size_t sz);
CIMGUI_API void             imguiMemFree(void* ptr);
CIMGUI_API CONST char*      imguiGetClipboardText();
CIMGUI_API void             imguiSetClipboardText(CONST char* text);

// Internal state access - if you want to share ImGui state between modules (e.g. DLL) or allocate it yourself
CIMGUI_API CONST char*             imguiGetVersion();
CIMGUI_API struct ImGuiContext*    imguiCreateContext(void* (*malloc_fn)(size_t), void (*free_fn)(void*));
CIMGUI_API void                    imguiDestroyContext(struct ImGuiContext* ctx);
CIMGUI_API struct ImGuiContext*    imguiGetCurrentContext();
CIMGUI_API void                    imguiSetCurrentContext(struct ImGuiContext* ctx);

CIMGUI_API void             ImFontConfig_DefaultConstructor(struct ImFontConfig* config);

CIMGUI_API void             ImFontAtlas_GetTexDataAsRGBA32(struct ImFontAtlas* atlas, unsigned char** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel);
CIMGUI_API void             ImFontAtlas_GetTexDataAsAlpha8(struct ImFontAtlas* atlas, unsigned char** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel);
CIMGUI_API void             ImFontAtlas_SetTexID(struct ImFontAtlas* atlas, void* tex);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFont(struct ImFontAtlas* atlas, CONST struct ImFontConfig* font_cfg);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFontDefault(struct ImFontAtlas* atlas, CONST struct ImFontConfig* font_cfg);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFontFromFileTTF(struct ImFontAtlas* atlas, CONST char* filename, float size_pixels, CONST struct ImFontConfig* font_cfg, CONST ImWchar* glyph_ranges);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFontFromMemoryTTF(struct ImFontAtlas* atlas, void* ttf_data, int ttf_size, float size_pixels, CONST struct ImFontConfig* font_cfg, CONST ImWchar* glyph_ranges);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFontFromMemoryCompressedTTF(struct ImFontAtlas* atlas, CONST void* compressed_ttf_data, int compressed_ttf_size, float size_pixels, CONST struct ImFontConfig* font_cfg, CONST ImWchar* glyph_ranges);
CIMGUI_API struct ImFont*   ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(struct ImFontAtlas* atlas, CONST char* compressed_ttf_data_base85, float size_pixels, CONST struct ImFontConfig* font_cfg, CONST ImWchar* glyph_ranges);
CIMGUI_API void             ImFontAtlas_ClearTexData(struct ImFontAtlas* atlas);
CIMGUI_API void             ImFontAtlas_Clear(struct ImFontAtlas* atlas);

CIMGUI_API void             ImGuiIO_AddInputCharacter(unsigned short c);
CIMGUI_API void             ImGuiIO_AddInputCharactersUTF8(CONST char* utf8_chars);
CIMGUI_API void             ImGuiIO_ClearInputCharacters();

//ImDrawData
CIMGUI_API void                 ImDrawData_DeIndexAllBuffers(struct ImDrawData* drawData);

//ImDrawList
CIMGUI_API int                  ImDrawList_GetVertexBufferSize(struct ImDrawList* list);
CIMGUI_API struct ImDrawVert*   ImDrawList_GetVertexPtr(struct ImDrawList* list, int n);
CIMGUI_API int                  ImDrawList_GetIndexBufferSize(struct ImDrawList* list);
CIMGUI_API ImDrawIdx*           ImDrawList_GetIndexPtr(struct ImDrawList* list, int n);
CIMGUI_API int                  ImDrawList_GetCmdSize(struct ImDrawList* list);
CIMGUI_API struct ImDrawCmd*    ImDrawList_GetCmdPtr(struct ImDrawList* list, int n);

CIMGUI_API void             ImDrawList_Clear(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_ClearFreeMemory(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_PushClipRect(struct ImDrawList* list, struct ImVec2 clip_rect_min, struct ImVec2 clip_rect_max, bool intersect_with_current_clip_rect);
CIMGUI_API void             ImDrawList_PushClipRectFullScreen(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_PopClipRect(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_PushTextureID(struct ImDrawList* list, CONST ImTextureID texture_id);
CIMGUI_API void             ImDrawList_PopTextureID(struct ImDrawList* list);

// Primitives
CIMGUI_API void             ImDrawList_AddLine(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float thickness);
CIMGUI_API void             ImDrawList_AddRect(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners, float thickness);
CIMGUI_API void             ImDrawList_AddRectFilled(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col, float rounding, int rounding_corners);
CIMGUI_API void             ImDrawList_AddRectFilledMultiColor(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left);
CIMGUI_API void             ImDrawList_AddQuad(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col, float thickness);
CIMGUI_API void             ImDrawList_AddQuadFilled(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, ImU32 col);
CIMGUI_API void             ImDrawList_AddTriangle(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col, float thickness);
CIMGUI_API void             ImDrawList_AddTriangleFilled(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, ImU32 col);
CIMGUI_API void             ImDrawList_AddCircle(struct ImDrawList* list, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments, float thickness);
CIMGUI_API void             ImDrawList_AddCircleFilled(struct ImDrawList* list, CONST struct ImVec2 centre, float radius, ImU32 col, int num_segments);
CIMGUI_API void             ImDrawList_AddText(struct ImDrawList* list, CONST struct ImVec2 pos, ImU32 col, CONST char* text_begin, CONST char* text_end);
CIMGUI_API void             ImDrawList_AddTextExt(struct ImDrawList* list, CONST struct ImFont* font, float font_size, CONST struct ImVec2 pos, ImU32 col, CONST char* text_begin, CONST char* text_end, float wrap_width, CONST struct ImVec4* cpu_fine_clip_rect);
CIMGUI_API void             ImDrawList_AddImage(struct ImDrawList* list, ImTextureID user_texture_id, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv0, CONST struct ImVec2 uv1, ImU32 col);
CIMGUI_API void             ImDrawList_AddPolyline(struct ImDrawList* list, CONST struct ImVec2* points, CONST int num_points, ImU32 col, bool closed, float thickness, bool anti_aliased);
CIMGUI_API void             ImDrawList_AddConvexPolyFilled(struct ImDrawList* list, CONST struct ImVec2* points, CONST int num_points, ImU32 col, bool anti_aliased);
CIMGUI_API void             ImDrawList_AddBezierCurve(struct ImDrawList* list, CONST struct ImVec2 pos0, CONST struct ImVec2 cp0, CONST struct ImVec2 cp1, CONST struct ImVec2 pos1, ImU32 col, float thickness, int num_segments);

// Stateful path API, add points then finish with PathFill() or PathStroke()
CIMGUI_API void             ImDrawList_PathClear(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_PathLineTo(struct ImDrawList* list, CONST struct ImVec2 pos);
CIMGUI_API void             ImDrawList_PathLineToMergeDuplicate(struct ImDrawList* list, CONST struct ImVec2 pos);
CIMGUI_API void             ImDrawList_PathFill(struct ImDrawList* list, ImU32 col);
CIMGUI_API void             ImDrawList_PathStroke(struct ImDrawList* list, ImU32 col, bool closed, float thickness);
CIMGUI_API void             ImDrawList_PathArcTo(struct ImDrawList* list, CONST struct ImVec2 centre, float radius, float a_min, float a_max, int num_segments);
CIMGUI_API void             ImDrawList_PathArcToFast(struct ImDrawList* list, CONST struct ImVec2 centre, float radius, int a_min_of_12, int a_max_of_12); // Use precomputed angles for a 12 steps circle
CIMGUI_API void             ImDrawList_PathBezierCurveTo(struct ImDrawList* list, CONST struct ImVec2 p1, CONST struct ImVec2 p2, CONST struct ImVec2 p3, int num_segments);
CIMGUI_API void             ImDrawList_PathRect(struct ImDrawList* list, CONST struct ImVec2 rect_min, CONST struct ImVec2 rect_max, float rounding, int rounding_corners);

// Channels
CIMGUI_API void             ImDrawList_ChannelsSplit(struct ImDrawList* list, int channels_count);
CIMGUI_API void             ImDrawList_ChannelsMerge(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_ChannelsSetCurrent(struct ImDrawList* list, int channel_index);

// Advanced
CIMGUI_API void             ImDrawList_AddCallback(struct ImDrawList* list, ImDrawCallback callback, void* callback_data); // Your rendering function must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles.
CIMGUI_API void             ImDrawList_AddDrawCmd(struct ImDrawList* list); // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible

// Internal helpers
CIMGUI_API void             ImDrawList_PrimReserve(struct ImDrawList* list, int idx_count, int vtx_count);
CIMGUI_API void             ImDrawList_PrimRect(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, ImU32 col);
CIMGUI_API void             ImDrawList_PrimRectUV(struct ImDrawList* list, CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, ImU32 col);
CIMGUI_API void             ImDrawList_PrimQuadUV(struct ImDrawList* list,CONST struct ImVec2 a, CONST struct ImVec2 b, CONST struct ImVec2 c, CONST struct ImVec2 d, CONST struct ImVec2 uv_a, CONST struct ImVec2 uv_b, CONST struct ImVec2 uv_c, CONST struct ImVec2 uv_d, ImU32 col);
CIMGUI_API void             ImDrawList_PrimWriteVtx(struct ImDrawList* list, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col);
CIMGUI_API void             ImDrawList_PrimWriteIdx(struct ImDrawList* list, ImDrawIdx idx);
CIMGUI_API void             ImDrawList_PrimVtx(struct ImDrawList* list, CONST struct ImVec2 pos, CONST struct ImVec2 uv, ImU32 col);
CIMGUI_API void             ImDrawList_UpdateClipRect(struct ImDrawList* list);
CIMGUI_API void             ImDrawList_UpdateTextureID(struct ImDrawList* list);
