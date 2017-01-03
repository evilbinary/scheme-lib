#include "../imgui/imgui.h"
#include "cimgui.h"

#ifdef __cplusplus
extern "C" {
#endif


CIMGUI_API ImGuiIO *imguiGetIo() {
    return &ImGui::GetIO();
}

CIMGUI_API ImGuiStyle *imguiGetStyle() {
    return &ImGui::GetStyle();
}

CIMGUI_API ImDrawData *imguiGetDrawData() {
    return ImGui::GetDrawData();
}

CIMGUI_API void imguiNewFrame() {
    ImGui::NewFrame();
}

CIMGUI_API void imguiRender() {
    ImGui::Render();
}

CIMGUI_API void imguiShutdown() {
    ImGui::Shutdown();
}

CIMGUI_API void imguiShowUserGuide() {
    ImGui::ShowUserGuide();
}

CIMGUI_API void imguiShowStyleEditor(ImGuiStyle *ref) {
    ImGui::ShowStyleEditor(ref);
}

CIMGUI_API void imguiShowTestWindow(bool *opened) {
    ImGui::ShowTestWindow(opened);
}

IMGUI_API void imguiShowMetricsWindow(bool *opened) {
    ImGui::ShowMetricsWindow(opened);
}

// Window

CIMGUI_API bool imguiBegin(CONST char *name, ImGuiWindowFlags flags) {
    return ImGui::Begin(name,NULL,flags);
}

CIMGUI_API bool imguiBegin1(CONST char *name, bool *p_opened, ImGuiWindowFlags flags) {
    return ImGui::Begin(name, p_opened, flags);
}

CIMGUI_API bool imguiBegin2(CONST char *name, bool *p_opened, CONST ImVec2 size_on_first_use,
                         float bg_alpha, ImGuiWindowFlags flags) {
    return ImGui::Begin(name, p_opened, size_on_first_use, bg_alpha, flags);
}

CIMGUI_API void imguiEnd() {
    ImGui::End();
}

CIMGUI_API bool imguiBeginChild(CONST char *str_id, CONST ImVec2 size, bool border,
                             ImGuiWindowFlags extra_flags) {
    return ImGui::BeginChild(str_id, size, border, extra_flags);
}

CIMGUI_API bool imguiBeginChildEx(ImGuiID id, CONST ImVec2 size, bool border,
                               ImGuiWindowFlags extra_flags) {
    return ImGui::BeginChild(id, size, border, extra_flags);
}

CIMGUI_API void imguiEndChild() {
    ImGui::EndChild();
}

CIMGUI_API void imguiGetContentRegionMax(ImVec2 *out) {
    *out = ImGui::GetContentRegionMax();
}

CIMGUI_API void imguiGetContentRegionAvail(struct ImVec2 *out) {
    *out = ImGui::GetContentRegionAvail();
}

CIMGUI_API float imguiGetContentRegionAvailWidth() {
    return ImGui::GetContentRegionAvailWidth();
}

CIMGUI_API void imguiGetWindowContentRegionMin(ImVec2 *out) {
    *out = ImGui::GetWindowContentRegionMin();
}

CIMGUI_API void imguiGetWindowContentRegionMax(ImVec2 *out) {
    *out = ImGui::GetWindowContentRegionMax();
}

CIMGUI_API float imguiGetWindowContentRegionWidth() {
    return ImGui::GetWindowContentRegionWidth();
}

CIMGUI_API ImDrawList *imguiGetWindowDrawList() {
    return ImGui::GetWindowDrawList();
}

CIMGUI_API void imguiGetWindowPos(ImVec2 *out) {
    *out = ImGui::GetWindowPos();
}

CIMGUI_API void imguiGetWindowSize(ImVec2 *out) {
    *out = ImGui::GetWindowSize();
}

CIMGUI_API float imguiGetWindowWidth() {
    return ImGui::GetWindowWidth();
}

CIMGUI_API float imguiGetWindowHeight() {
    return ImGui::GetWindowHeight();
}

CIMGUI_API bool imguiIsWindowCollapsed() {
    return ImGui::IsWindowCollapsed();
}

CIMGUI_API void imguiSetWindowFontScale(float scale) {
    ImGui::SetWindowFontScale(scale);
}

CIMGUI_API void imguiSetNextWindowPos(CONST ImVec2 pos, ImGuiSetCond cond) {
    ImGui::SetNextWindowPos(pos, cond);
}

CIMGUI_API void imguiSetNextWindowPosCenter(ImGuiSetCond cond) {
    ImGui::SetNextWindowPosCenter(cond);
}

CIMGUI_API void imguiSetNextWindowSize(CONST ImVec2 size, ImGuiSetCond cond) {
    ImGui::SetNextWindowSize(size, cond);
}

CIMGUI_API void imguiSetNextWindowSizeConstraints(CONST struct ImVec2 size_min,
                                               CONST struct ImVec2 size_max,
                                               ImGuiSizeConstraintCallback custom_callback,
                                               void *custom_callback_data) {
    ImGui::SetNextWindowSizeConstraints(size_min, size_max, custom_callback, custom_callback_data);
}

CIMGUI_API void imguiSetNextWindowContentSize(CONST ImVec2 size) {
    ImGui::SetNextWindowContentSize(size);
}

CIMGUI_API void imguiSetNextWindowContentWidth(float width) {
    ImGui::SetNextWindowContentWidth(width);
}

CIMGUI_API void imguiSetNextWindowCollapsed(bool collapsed, ImGuiSetCond cond) {
    ImGui::SetNextWindowCollapsed(collapsed, cond);
}

CIMGUI_API void imguiSetNextWindowFocus() {
    ImGui::SetNextWindowFocus();
}

CIMGUI_API void imguiSetWindowPos(CONST ImVec2 pos, ImGuiSetCond cond) {
    ImGui::SetWindowPos(pos, cond);
}

CIMGUI_API void imguiSetWindowSize(CONST ImVec2 size, ImGuiSetCond cond) {
    ImGui::SetWindowSize(size, cond);
}

CIMGUI_API void imguiSetWindowCollapsed(bool collapsed, ImGuiSetCond cond) {
    ImGui::SetWindowCollapsed(collapsed, cond);
}

CIMGUI_API void imguiSetWindowFocus() {
    ImGui::SetWindowFocus();
}

CIMGUI_API void imguiSetWindowPosByName(CONST char *name, CONST ImVec2 pos, ImGuiSetCond cond) {
    ImGui::SetWindowPos(name, pos, cond);
}

CIMGUI_API void imguiSetWindowSize2(CONST char *name, CONST ImVec2 size, ImGuiSetCond cond) {
    ImGui::SetWindowSize(name, size, cond);
}

CIMGUI_API void imguiSetWindowCollapsed2(CONST char *name, bool collapsed, ImGuiSetCond cond) {
    ImGui::SetWindowCollapsed(name, collapsed, cond);
}

CIMGUI_API void imguiSetWindowFocus2(CONST char *name) {
    ImGui::SetWindowFocus(name);
}

CIMGUI_API float imguiGetScrollX() {
    return ImGui::GetScrollX();
}

CIMGUI_API float imguiGetScrollY() {
    return ImGui::GetScrollY();
}

CIMGUI_API float imguiGetScrollMaxX() {
    return ImGui::GetScrollMaxX();
}

CIMGUI_API float imguiGetScrollMaxY() {
    return ImGui::GetScrollMaxY();
}

CIMGUI_API void imguiSetScrollX(float scroll_x) {
    return ImGui::SetScrollX(scroll_x);
}

CIMGUI_API void imguiSetScrollY(float scroll_y) {
    return ImGui::SetScrollY(scroll_y);
}

CIMGUI_API void imguiSetScrollHere(float center_y_ratio) {
    ImGui::SetScrollHere(center_y_ratio);
}

CIMGUI_API void imguiSetScrollFromPosY(float pos_y, float center_y_ratio) {
    return ImGui::SetScrollFromPosY(pos_y, center_y_ratio);
}

CIMGUI_API void imguiSetKeyboardFocusHere(int offset) {
    ImGui::SetKeyboardFocusHere(offset);
}

CIMGUI_API void imguiSetStateStorage(ImGuiStorage *tree) {
    ImGui::SetStateStorage(tree);
}

CIMGUI_API ImGuiStorage *imguiGetStateStorage() {
    return ImGui::GetStateStorage();
}

// Parameters stacks (shared)
CIMGUI_API void imguiPushFont(ImFont *font) {
    ImGui::PushFont(font);
}

CIMGUI_API void imguiPopFont() {
    return ImGui::PopFont();
}

CIMGUI_API void imguiPushStyleColor(ImGuiCol idx, CONST ImVec4 col) {
    return ImGui::PushStyleColor(idx, col);
}

CIMGUI_API void imguiPopStyleColor(int count) {
    return ImGui::PopStyleColor(count);
}

CIMGUI_API void imguiPushStyleVar(ImGuiStyleVar idx, float val) {
    return ImGui::PushStyleVar(idx, val);
}

CIMGUI_API void imguiPushStyleVarVec(ImGuiStyleVar idx, CONST ImVec2 val) {
    return ImGui::PushStyleVar(idx, val);
}

CIMGUI_API void imguiPopStyleVar(int count) {
    return ImGui::PopStyleVar(count);
}

CIMGUI_API ImFont *imguiGetFont() {
    return ImGui::GetFont();
}

CIMGUI_API float imguiGetFontSize() {
    return ImGui::GetFontSize();
}

CIMGUI_API void imguiGetFontTexUvWhitePixel(ImVec2 *pOut) {
    *pOut = ImGui::GetFontTexUvWhitePixel();
}

CIMGUI_API ImU32 imguiGetColorU32(ImGuiCol idx, float alpha_mul) {
    return ImGui::GetColorU32(idx, alpha_mul);
}

CIMGUI_API ImU32 imguiGetColorU32Vec(CONST ImVec4 *col) {
    return ImGui::GetColorU32(*col);
}

// Parameters stacks (current window)
CIMGUI_API void imguiPushItemWidth(float item_width) {
    return ImGui::PushItemWidth(item_width);
}

CIMGUI_API void imguiPopItemWidth() {
    return ImGui::PopItemWidth();
}

CIMGUI_API float imguiCalcItemWidth() {
    return ImGui::CalcItemWidth();
}

CIMGUI_API void imguiPushAllowKeyboardFocus(bool v) {
    return ImGui::PushAllowKeyboardFocus(v);
}

CIMGUI_API void imguiPopAllowKeyboardFocus() {
    return ImGui::PopAllowKeyboardFocus();
}

CIMGUI_API void imguiPushTextWrapPos(float wrap_pos_x) {
    return ImGui::PushTextWrapPos(wrap_pos_x);
}

CIMGUI_API void imguiPopTextWrapPos() {
    return ImGui::PopTextWrapPos();
}

CIMGUI_API void imguiPushButtonRepeat(bool repeat) {
    return ImGui::PushButtonRepeat(repeat);
}

CIMGUI_API void imguiPopButtonRepeat() {
    return ImGui::PopButtonRepeat();
}

// Tooltip
CIMGUI_API void imguiSetTooltip(CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::SetTooltipV(fmt, args);
    va_end(args);
}

CIMGUI_API void imguiSetTooltipV(CONST char *fmt, va_list args) {
    ImGui::SetTooltipV(fmt, args);
}

CIMGUI_API void imguiBeginTooltip() {
    return ImGui::BeginTooltip();
}

CIMGUI_API void imguiEndTooltip() {
    return ImGui::EndTooltip();
}

// Popup
CIMGUI_API void imguiOpenPopup(CONST char *str_id) {
    return ImGui::OpenPopup(str_id);
}

CIMGUI_API bool imguiBeginPopup(CONST char *str_id) {
    return ImGui::BeginPopup(str_id);
}

CIMGUI_API bool imguiBeginPopupModal(CONST char *name, bool *p_open, ImGuiWindowFlags extra_flags) {
    return ImGui::BeginPopupModal(name, p_open, extra_flags);
}

CIMGUI_API bool imguiBeginPopupContextItem(CONST char *str_id, int mouse_button) {
    return ImGui::BeginPopupContextItem(str_id, mouse_button);
}

CIMGUI_API bool imguiBeginPopupContextWindow(bool also_over_items, CONST char *str_id,
                                          int mouse_button) {
    return ImGui::BeginPopupContextWindow(also_over_items, str_id, mouse_button);
}

CIMGUI_API bool imguiBeginPopupContextVoid(CONST char *str_id, int mouse_button) {
    return ImGui::BeginPopupContextVoid(str_id, mouse_button);
}

CIMGUI_API void imguiEndPopup() {
    return ImGui::EndPopup();
}

CIMGUI_API void imguiCloseCurrentPopup() {
    return ImGui::CloseCurrentPopup();
}

// Layout

CIMGUI_API void imguiSeparator() {
    return ImGui::Separator();
}

CIMGUI_API void imguiSameLine() {
    return ImGui::SameLine();
}
CIMGUI_API void imguiSameLine2(float pos_x, float spacing_w) {
    return ImGui::SameLine(pos_x, spacing_w);
}

CIMGUI_API void imguiNewLine() {
    return ImGui::NewLine();
}

CIMGUI_API void imguiSpacing() {
    return ImGui::Spacing();
}

CIMGUI_API void imguiDummy(CONST ImVec2 *size) {
    return ImGui::Dummy(*size);
}

CIMGUI_API void imguiIndent(float indent_w) {
    return ImGui::Indent(indent_w);
}

CIMGUI_API void imguiUnindent(float indent_w) {
    return ImGui::Unindent(indent_w);
}

CIMGUI_API void imguiBeginGroup() {
    return ImGui::BeginGroup();
}

CIMGUI_API void imguiEndGroup() {
    return ImGui::EndGroup();
}

CIMGUI_API void imguiGetCursorPos(ImVec2 *pOut) {
    *pOut = ImGui::GetCursorPos();
}

CIMGUI_API float imguiGetCursorPosX() {
    return ImGui::GetCursorPosX();
}

CIMGUI_API float imguiGetCursorPosY() {
    return ImGui::GetCursorPosY();
}

CIMGUI_API void imguiSetCursorPos(CONST ImVec2 local_pos) {
    return ImGui::SetCursorPos(local_pos);
}

CIMGUI_API void imguiSetCursorPosX(float x) {
    return ImGui::SetCursorPosX(x);
}

CIMGUI_API void imguiSetCursorPosY(float y) {
    return ImGui::SetCursorPosY(y);
}

CIMGUI_API void imguiGetCursorStartPos(ImVec2 *pOut) {
    *pOut = ImGui::GetCursorStartPos();
}

CIMGUI_API void imguiGetCursorScreenPos(ImVec2 *pOut) {
    *pOut = ImGui::GetCursorScreenPos();
}

CIMGUI_API void imguiSetCursorScreenPos(CONST ImVec2 pos) {
    return ImGui::SetCursorScreenPos(pos);
}

CIMGUI_API void imguiAlignFirstTextHeightToWidgets() {
    return ImGui::AlignFirstTextHeightToWidgets();
}

CIMGUI_API float imguiGetTextLineHeight() {
    return ImGui::GetTextLineHeight();
}

CIMGUI_API float imguiGetTextLineHeightWithSpacing() {
    return ImGui::GetTextLineHeightWithSpacing();
}

CIMGUI_API float imguiGetItemsLineHeightWithSpacing() {
    return ImGui::GetItemsLineHeightWithSpacing();
}

//Columns

CIMGUI_API void imguiColumns(int count, CONST char *id, bool border) {
    return ImGui::Columns(count, id, border);
}

CIMGUI_API void imguiNextColumn() {
    return ImGui::NextColumn();
}

CIMGUI_API int imguiGetColumnIndex() {
    return ImGui::GetColumnIndex();
}

CIMGUI_API float imguiGetColumnOffset(int column_index) {
    return ImGui::GetColumnOffset(column_index);
}

CIMGUI_API void imguiSetColumnOffset(int column_index, float offset_x) {
    return ImGui::SetColumnOffset(column_index, offset_x);
}

CIMGUI_API float imguiGetColumnWidth(int column_index) {
    return ImGui::GetColumnWidth(column_index);
}

CIMGUI_API int imguiGetColumnsCount() {
    return ImGui::GetColumnsCount();
}

// ID scopes
// If you are creating widgets in a loop you most likely want to push a unique identifier so ImGui can differentiate them
// You can also use "##extra" within your widget name to distinguish them from each others (see 'Programmer Guide')
CIMGUI_API void imguiPushIdStr(CONST char *str_id) {
    return ImGui::PushID(str_id);
}

CIMGUI_API void imguiPushIdStrRange(CONST char *str_begin, CONST char *str_end) {
    return ImGui::PushID(str_begin, str_end);
}


CIMGUI_API void imguiPushIdPtr(CONST void *ptr_id) {
    return ImGui::PushID(ptr_id);
}

CIMGUI_API void imguiPushIdInt(int int_id) {
    return ImGui::PushID(int_id);
}

CIMGUI_API void imguiPopId() {
    return ImGui::PopID();
}

CIMGUI_API ImGuiID imguiGetIdStr(CONST char *str_id) {
    return ImGui::GetID(str_id);
}

CIMGUI_API ImGuiID imguiGetIdStrRange(CONST char *str_begin, CONST char *str_end) {
    return ImGui::GetID(str_begin, str_end);
}

CIMGUI_API ImGuiID imguiGetIdPtr(CONST void *ptr_id) {
    return ImGui::GetID(ptr_id);
}

// Widgets
CIMGUI_API void imguiText(CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextV(fmt, args);
    va_end(args);
}

CIMGUI_API void imguiTextV(CONST char *fmt, va_list args) {
    ImGui::TextV(fmt, args);
}

CIMGUI_API void imguiTextColored(CONST ImVec4 col, CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextColoredV(col, fmt, args);
    va_end(args);
}

CIMGUI_API void imguiTextColoredV(CONST ImVec4 col, CONST char *fmt, va_list args) {
    ImGui::TextColoredV(col, fmt, args);
}

CIMGUI_API void imguiTextDisabled(CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextDisabledV(fmt, args);
    va_end(args);
}

CIMGUI_API void imguiTextDisabledV(CONST char *fmt, va_list args) {
    return ImGui::TextDisabledV(fmt, args);
}

CIMGUI_API void imguiTextWrapped(CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::TextWrappedV(fmt, args);
    va_end(args);
}

CIMGUI_API void imguiTextWrappedV(CONST char *fmt, va_list args) {
    ImGui::TextWrappedV(fmt, args);
}

CIMGUI_API void imguiTextUnformatted(CONST char *text, CONST char *text_end) {
    return ImGui::TextUnformatted(text, text_end);
}

CIMGUI_API void imguiLabelText(CONST char *label, CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::LabelTextV(label, fmt, args);
    va_end(args);
}

CIMGUI_API void imguiLabelTextV(CONST char *label, CONST char *fmt, va_list args) {
    ImGui::LabelTextV(label, fmt, args);
}

CIMGUI_API void imguiBullet() {
    return ImGui::Bullet();
}

CIMGUI_API void imguiBulletText(CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    ImGui::BulletTextV(fmt, args);
    va_end(args);
}

CIMGUI_API void imguiBulletTextV(CONST char *fmt, va_list args) {
    ImGui::BulletTextV(fmt, args);
}

CIMGUI_API bool imguiButton(CONST char *label, CONST ImVec2 size) {
    return ImGui::Button(label, size);
}

CIMGUI_API bool imguiSmallButton(CONST char *label) {
    return ImGui::SmallButton(label);
}

CIMGUI_API bool imguiInvisibleButton(CONST char *str_id, CONST ImVec2 size) {
    return ImGui::InvisibleButton(str_id, size);
}

CIMGUI_API void imguiImage(ImTextureID user_texture_id, CONST ImVec2& size, CONST ImVec2& uv0,
                        CONST ImVec2& uv1) {
    return ImGui::Image(user_texture_id, size, uv0, uv1);
}

CIMGUI_API void imguiImage2(ImTextureID user_texture_id, CONST ImVec2 size, CONST ImVec2 uv0,
                        CONST ImVec2 uv1, CONST ImVec4 tint_col, CONST ImVec4 border_col) {
    return ImGui::Image(user_texture_id, size, uv0, uv1, tint_col, border_col);
}

CIMGUI_API bool imguiImageButton(ImTextureID user_texture_id, CONST ImVec2 size, CONST ImVec2 uv0,
                              CONST ImVec2 uv1, int frame_padding, CONST ImVec4 bg_col,
                              CONST ImVec4 tint_col) {
    return ImGui::ImageButton(user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col);
}

CIMGUI_API bool imguiCheckbox(CONST char *label, bool *v) {
    return ImGui::Checkbox(label, v);
}

CIMGUI_API bool imguiCheckboxFlags(CONST char *label, unsigned int *flags, unsigned int flags_value) {
    return ImGui::CheckboxFlags(label, flags, flags_value);
}

CIMGUI_API bool imguiRadioButtonBool(CONST char *label, bool active) {
    return ImGui::RadioButton(label, active);
}

CIMGUI_API bool imguiRadioButton(CONST char *label, int *v, int v_button) {
    return ImGui::RadioButton(label, v, v_button);
}

CIMGUI_API bool imguiCombo(CONST char *label, int *current_item, CONST char **items, int items_count,
                        int height_in_items) {
    return ImGui::Combo(label, current_item, items, items_count, height_in_items);
}

CIMGUI_API bool imguiCombo2(CONST char *label, int *current_item, CONST char *items_separated_by_zeros,
                         int height_in_items) {
    return ImGui::Combo(label, current_item, items_separated_by_zeros, height_in_items);
}

CIMGUI_API bool imguiCombo3(CONST char *label, int *current_item,
                         bool(*items_getter)(void *data, int idx, CONST char **out_text),
                         void *data, int items_count, int height_in_items) {
    return ImGui::Combo(label, current_item, items_getter, data, items_count, height_in_items);
}

CIMGUI_API bool imguiColorButton(CONST ImVec4 col, bool small_height, bool outline_border) {
    return ImGui::ColorButton(col, small_height, outline_border);
}

CIMGUI_API bool imguiColorEdit3(CONST char *label, float col[3]) {
    return ImGui::ColorEdit3(label, col);
}

CIMGUI_API bool imguiColorEdit4(CONST char *label, float col[4], bool show_alpha) {
    return ImGui::ColorEdit4(label, col, show_alpha);
}

CIMGUI_API void imguiColorEditMode(ImGuiColorEditMode mode) {
    return ImGui::ColorEditMode(mode);
}

CIMGUI_API void imguiPlotLines(CONST char *label, CONST float *values, int values_count,
                            int values_offset, CONST char *overlay_text, float scale_min,
                            float scale_max, ImVec2 graph_size, int stride) {
    return ImGui::PlotLines(label, values, values_count, values_offset, overlay_text, scale_min,
                            scale_max, graph_size, stride);
}

CIMGUI_API void imguiPlotLines2(CONST char *label, float(*values_getter)(void *data, int idx),
                             void *data, int values_count, int values_offset,
                             CONST char *overlay_text, float scale_min, float scale_max,
                             ImVec2 graph_size) {
    return ImGui::PlotLines(label, values_getter, data, values_count, values_offset, overlay_text,
                            scale_min, scale_max, graph_size);
}

CIMGUI_API void imguiPlotHistogram(CONST char *label, CONST float *values, int values_count,
                                int values_offset, CONST char *overlay_text, float scale_min,
                                float scale_max, ImVec2 graph_size, int stride) {
    return ImGui::PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min,
                                scale_max, graph_size, stride);
}

CIMGUI_API void imguiPlotHistogram2(CONST char *label, float(*values_getter)(void *data, int idx),
                                 void *data, int values_count, int values_offset,
                                 CONST char *overlay_text, float scale_min, float scale_max,
                                 ImVec2 graph_size) {
    return ImGui::PlotHistogram(label, values_getter, data, values_count, values_offset,
                                overlay_text, scale_min, scale_max, graph_size);
}

CIMGUI_API void imguiProgressBar(float fraction, CONST ImVec2 *size_arg, const char *overlay) {
    return ImGui::ProgressBar(fraction, *size_arg, overlay);
}

// Widgets: Sliders (tip: ctrl+click on a slider to input text)
CIMGUI_API bool imguiSliderFloat(CONST char *label, float *v, float v_min, float v_max,
                              CONST char *display_format, float power) {
    return ImGui::SliderFloat(label, v, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiSliderFloat2(CONST char *label, float v[2], float v_min, float v_max,
                               CONST char *display_format, float power) {
    return ImGui::SliderFloat(label, v, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiSliderFloat3(CONST char *label, float v[3], float v_min, float v_max,
                               CONST char *display_format, float power) {
    return ImGui::SliderFloat3(label, v, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiSliderFloat4(CONST char *label, float v[4], float v_min, float v_max,
                               CONST char *display_format, float power) {
    return ImGui::SliderFloat4(label, v, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiSliderAngle(CONST char *label, float *v_rad, float v_degrees_min,
                              float v_degrees_max) {
    return ImGui::SliderAngle(label, v_rad, v_degrees_min, v_degrees_max);
}

CIMGUI_API bool imguiSliderInt(CONST char *label, int *v, int v_min, int v_max,
                            CONST char *display_format) {
    return ImGui::SliderInt(label, v, v_min, v_max, display_format);
}

CIMGUI_API bool imguiSliderInt2(CONST char *label, int v[2], int v_min, int v_max,
                             CONST char *display_format) {
    return ImGui::SliderInt2(label, v, v_min, v_max, display_format);
}

CIMGUI_API bool imguiSliderInt3(CONST char *label, int v[3], int v_min, int v_max,
                             CONST char *display_format) {
    return ImGui::SliderInt3(label, v, v_min, v_max, display_format);
}

CIMGUI_API bool imguiSliderInt4(CONST char *label, int v[4], int v_min, int v_max,
                             CONST char *display_format) {
    return ImGui::SliderInt4(label, v, v_min, v_max, display_format);
}

CIMGUI_API bool imguiVSliderFloat(CONST char *label, CONST ImVec2 size, float *v, float v_min,
                               float v_max, CONST char *display_format, float power) {
    return ImGui::VSliderFloat(label, size, v, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiVSliderInt(CONST char *label, CONST ImVec2 size, int *v, int v_min, int v_max,
                             CONST char *display_format) {
    return ImGui::VSliderInt(label, size, v, v_min, v_max, display_format);
}

// Widgets: Drags (tip: ctrl+click on a drag box to input text)
CIMGUI_API bool imguiDragFloat(CONST char *label, float *v, float v_speed, float v_min, float v_max,
                            CONST char *display_format, float power) {
    return ImGui::DragFloat(label, v, v_speed, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiDragFloat2(CONST char *label, float v[2], float v_speed, float v_min, float v_max,
                             CONST char *display_format, float power) {
    return ImGui::DragFloat2(label, v, v_speed, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiDragFloat3(CONST char *label, float v[3], float v_speed, float v_min, float v_max,
                             CONST char *display_format, float power) {
    return ImGui::DragFloat3(label, v, v_speed, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiDragFloat4(CONST char *label, float v[4], float v_speed, float v_min, float v_max,
                             CONST char *display_format, float power) {
    return ImGui::DragFloat4(label, v, v_speed, v_min, v_max, display_format, power);
}

CIMGUI_API bool imguiDragFloatRange2(CONST char *label, float *v_current_min, float *v_current_max,
                                  float v_speed, float v_min, float v_max,
                                  CONST char *display_format, CONST char *display_format_max,
                                  float power) {
    return ImGui::DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max,
                                  display_format, display_format_max, power);
}

CIMGUI_API bool imguiDragInt(CONST char *label, int *v, float v_speed, int v_min, int v_max,
                          CONST char *display_format) {
    return ImGui::DragInt(label, v, v_speed, v_min, v_max, display_format);
}

CIMGUI_API bool imguiDragInt2(CONST char *label, int v[2], float v_speed, int v_min, int v_max,
                           CONST char *display_format) {
    return ImGui::DragInt2(label, v, v_speed, v_min, v_max, display_format);
}

CIMGUI_API bool imguiDragInt3(CONST char *label, int v[3], float v_speed, int v_min, int v_max,
                           CONST char *display_format) {
    return ImGui::DragInt3(label, v, v_speed, v_min, v_max, display_format);
}

CIMGUI_API bool imguiDragInt4(CONST char *label, int v[4], float v_speed, int v_min, int v_max,
                           CONST char *display_format) {
    return ImGui::DragInt4(label, v, v_speed, v_min, v_max, display_format);
}

CIMGUI_API bool imguiDragIntRange2(CONST char *label, int *v_current_min, int *v_current_max,
                                float v_speed, int v_min, int v_max, CONST char *display_format,
                                CONST char *display_format_max) {
    return ImGui::DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max,
                                display_format, display_format_max);
}

// Widgets: Input
CIMGUI_API bool imguiInputText(CONST char *label, char *buf, size_t buf_size,
                            ImGuiInputTextFlags flags, ImGuiTextEditCallback callback,
                            void *user_data) {
    return ImGui::InputText(label, buf, buf_size, flags, callback, user_data);
}

CIMGUI_API bool imguiInputTextMultiline(CONST char *label, char *buf, size_t buf_size,
                                      ImGuiInputTextFlags flags,
                                     ImGuiTextEditCallback callback, void *user_data,CONST ImVec2 size) {
    return ImGui::InputTextMultiline(label, buf, buf_size, size, flags, callback, user_data);
}

CIMGUI_API bool imguiInputFloat(CONST char *label, float *v, float step, float step_fast,
                             int decimal_precision, ImGuiInputTextFlags extra_flags) {
    return ImGui::InputFloat(label, v, step, step_fast, decimal_precision, extra_flags);
}

CIMGUI_API bool imguiInputFloat2(CONST char *label, float v[2], int decimal_precision,
                              ImGuiInputTextFlags extra_flags) {
    return ImGui::InputFloat2(label, v, decimal_precision, extra_flags);
}

CIMGUI_API bool imguiInputFloat3(CONST char *label, float v[3], int decimal_precision,
                              ImGuiInputTextFlags extra_flags) {
    return ImGui::InputFloat3(label, v, decimal_precision, extra_flags);
}

CIMGUI_API bool imguiInputFloat4(CONST char *label, float v[4], int decimal_precision,
                              ImGuiInputTextFlags extra_flags) {
    return ImGui::InputFloat4(label, v, decimal_precision, extra_flags);
}

CIMGUI_API bool imguiInputInt(CONST char *label, int *v, int step, int step_fast,
                           ImGuiInputTextFlags extra_flags) {
    return ImGui::InputInt(label, v, step, step_fast, extra_flags);
}

CIMGUI_API bool imguiInputInt2(CONST char *label, int v[2], ImGuiInputTextFlags extra_flags) {
    return ImGui::InputInt2(label, v, extra_flags);
}

CIMGUI_API bool imguiInputInt3(CONST char *label, int v[3], ImGuiInputTextFlags extra_flags) {
    return ImGui::InputInt3(label, v, extra_flags);
}

CIMGUI_API bool imguiInputInt4(CONST char *label, int v[4], ImGuiInputTextFlags extra_flags) {
    return ImGui::InputInt4(label, v, extra_flags);
}


// Widgets: Trees
CIMGUI_API bool imguiTreeNode(CONST char *label) {
    return ImGui::TreeNode(label);
}

CIMGUI_API bool imguiTreeNodeStr(CONST char *str_id, CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    bool res = ImGui::TreeNodeV(str_id, fmt, args);
    va_end(args);

    return res;
}

CIMGUI_API bool imguiTreeNodePtr(CONST void *ptr_id, CONST char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    bool res = ImGui::TreeNodeV(ptr_id, fmt, args);
    va_end(args);

    return res;
}

CIMGUI_API bool imguiTreeNodeStrV(CONST char *str_id, CONST char *fmt, va_list args) {
    return ImGui::TreeNodeV(str_id, fmt, args);
}

CIMGUI_API bool imguiTreeNodePtrV(CONST void *ptr_id, CONST char *fmt, va_list args) {
    return ImGui::TreeNodeV(ptr_id, fmt, args);
}

CIMGUI_API bool imguiTreeNodeEx(CONST char *label, ImGuiTreeNodeFlags flags) {
    return ImGui::TreeNodeEx(label, flags);
}

CIMGUI_API bool imguiTreeNodeExStr(CONST char *str_id, ImGuiTreeNodeFlags flags, CONST char *fmt,
                                ...) {
    va_list args;
    va_start(args, fmt);
    bool res = ImGui::TreeNodeExV(str_id, flags, fmt, args);
    va_end(args);

    return res;
}

CIMGUI_API bool imguiTreeNodeExPtr(CONST void *ptr_id, ImGuiTreeNodeFlags flags, CONST char *fmt,
                                ...) {
    va_list args;
    va_start(args, fmt);
    bool res = ImGui::TreeNodeExV(ptr_id, flags, fmt, args);
    va_end(args);

    return res;
}

CIMGUI_API bool imguiTreeNodeExV(CONST char *str_id, ImGuiTreeNodeFlags flags, CONST char *fmt,
                              va_list args) {
    return ImGui::TreeNodeExV(str_id, flags, fmt, args);
}

CIMGUI_API bool imguiTreeNodeExVPtr(CONST void *ptr_id, ImGuiTreeNodeFlags flags, CONST char *fmt,
                                 va_list args) {
    return ImGui::TreeNodeExV(ptr_id, flags, fmt, args);
}

CIMGUI_API void imguiTreePushStr(CONST char *str_id) {
    return ImGui::TreePush(str_id);
}

CIMGUI_API void imguiTreePushPtr(CONST void *ptr_id) {
    return ImGui::TreePush(ptr_id);
}

CIMGUI_API void imguiTreePop() {
    return ImGui::TreePop();
}

CIMGUI_API void imguiTreeAdvanceToLabelPos() {
    return ImGui::TreeAdvanceToLabelPos();
}

CIMGUI_API float imguiGetTreeNodeToLabelSpacing() {
    return ImGui::GetTreeNodeToLabelSpacing();
}

CIMGUI_API void imguiSetNextTreeNodeOpen(bool opened, ImGuiSetCond cond) {
    return ImGui::SetNextTreeNodeOpen(opened, cond);
}

CIMGUI_API bool imguiCollapsingHeader(CONST char *label, ImGuiTreeNodeFlags flags) {
    return ImGui::CollapsingHeader(label, flags);
}

CIMGUI_API bool imguiCollapsingHeaderEx(CONST char *label, bool *p_open, ImGuiTreeNodeFlags flags) {
    return ImGui::CollapsingHeader(label, p_open, flags);
}

// Widgets: Selectable / Lists
CIMGUI_API bool imguiSelectable(CONST char *label, bool selected, ImGuiSelectableFlags flags,
                             CONST ImVec2 size) {
    return ImGui::Selectable(label, selected, flags, size);
}

CIMGUI_API bool imguiSelectableEx(CONST char *label, bool *p_selected, ImGuiSelectableFlags flags,
                               CONST ImVec2 size) {
    return ImGui::Selectable(label, p_selected, flags, size);
}

CIMGUI_API bool imguiListBox(CONST char *label, int *current_item, CONST char **items, int items_count,
                          int height_in_items) {
    return ImGui::ListBox(label, current_item, items, items_count, height_in_items);
}

CIMGUI_API bool imguiListBox2(CONST char *label, int *current_item,
                           bool(*items_getter)(void *data, int idx, CONST char **out_text),
                           void *data, int items_count, int height_in_items) {
    return ImGui::ListBox(label, current_item, items_getter, data, items_count, height_in_items);
}

CIMGUI_API bool imguiListBoxHeader(CONST char *label, CONST ImVec2 size) {
    return ImGui::ListBoxHeader(label, size);
}

CIMGUI_API bool imguiListBoxHeader2(CONST char *label, int items_count, int height_in_items) {
    return ImGui::ListBoxHeader(label, items_count, height_in_items);
}

CIMGUI_API void imguiListBoxFooter() {
    return ImGui::ListBoxFooter();
}

CIMGUI_API bool imguiBeginMainMenuBar() {
    return ImGui::BeginMainMenuBar();
}

CIMGUI_API void imguiEndMainMenuBar() {
    return ImGui::EndMainMenuBar();
}

CIMGUI_API bool imguiBeginMenuBar() {
    return ImGui::BeginMenuBar();
}

CIMGUI_API void imguiEndMenuBar() {
    return ImGui::EndMenuBar();
}

CIMGUI_API bool imguiBeginMenu(CONST char *label, bool enabled) {
    return ImGui::BeginMenu(label, enabled);
}

CIMGUI_API void imguiEndMenu() {
    return ImGui::EndMenu();
}

CIMGUI_API bool imguiMenuItem(CONST char *label, CONST char *shortcut, bool selected, bool enabled) {
    return ImGui::MenuItem(label, shortcut, selected, enabled);
}

CIMGUI_API bool imguiMenuItemPtr(CONST char *label, CONST char *shortcut, bool *p_selected,
                              bool enabled) {
    return ImGui::MenuItem(label, shortcut, p_selected, enabled);
}

// Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely declare your own within the ImGui namespace!)
CIMGUI_API void imguiValueBool(CONST char *prefix, bool b) {
    ImGui::Value(prefix, b);
}

CIMGUI_API void imguiValueInt(CONST char *prefix, int v) {
    ImGui::Value(prefix, v);
}

CIMGUI_API void imguiValueUInt(CONST char *prefix, unsigned int v) {
    ImGui::Value(prefix, v);
}

CIMGUI_API void imguiValueFloat(CONST char *prefix, float v, CONST char *float_format) {
    ImGui::Value(prefix, v, float_format);
}

CIMGUI_API void imguiValueColor(CONST char *prefix, CONST ImVec4 v) {
    ImGui::ValueColor(prefix, v);
}

CIMGUI_API void imguiValueColor2(CONST char *prefix, unsigned int v) {
    ImGui::ValueColor(prefix, v);
}

// Logging: all text output from interface is redirected to tty/file/clipboard. Tree nodes are automatically opened.
CIMGUI_API void imguiLogToTTY(int max_depth) {
    ImGui::LogToTTY(max_depth);
}

CIMGUI_API void imguiLogToFile(int max_depth, CONST char *filename) {
    ImGui::LogToFile(max_depth, filename);
}

CIMGUI_API void imguiLogToClipboard(int max_depth) {
    ImGui::LogToClipboard(max_depth);
}

CIMGUI_API void imguiLogFinish() {
    ImGui::LogFinish();
}

CIMGUI_API void imguiLogButtons() {
    ImGui::LogButtons();
}

CIMGUI_API void imguiLogText(CONST char *fmt, ...) {
    char buffer[256];
    va_list args;
    va_start(args, fmt);
    snprintf(buffer, 256, fmt, args);
    va_end(args);

    ImGui::LogText("%s", buffer);
}

CIMGUI_API void imguiPushClipRect(CONST struct ImVec2 clip_rect_min, CONST struct ImVec2 clip_rect_max,
                               bool intersect_with_current_clip_rect) {
    return ImGui::PushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect);
}

CIMGUI_API void imguiPopClipRect() {
    return ImGui::PopClipRect();
}

// Utilities
CIMGUI_API bool imguiIsItemHovered() {
    return ImGui::IsItemHovered();
}

CIMGUI_API bool imguiIsItemHoveredRect() {
    return ImGui::IsItemHoveredRect();
}

CIMGUI_API bool imguiIsItemActive() {
    return ImGui::IsItemActive();
}

CIMGUI_API bool imguiIsItemClicked(int mouse_button) {
    return ImGui::IsItemClicked(mouse_button);
}

CIMGUI_API bool imguiIsItemVisible() {
    return ImGui::IsItemVisible();
}

CIMGUI_API bool imguiIsAnyItemHovered() {
    return ImGui::IsAnyItemHovered();
}

CIMGUI_API bool imguiIsAnyItemActive() {
    return ImGui::IsAnyItemActive();
}

CIMGUI_API void imguiGetItemRectMin(ImVec2 *pOut) {
    *pOut = ImGui::GetItemRectMin();
}

CIMGUI_API void imguiGetItemRectMax(ImVec2 *pOut) {
    *pOut = ImGui::GetItemRectMax();
}

CIMGUI_API void imguiGetItemRectSize(ImVec2 *pOut) {
    *pOut = ImGui::GetItemRectSize();
}

CIMGUI_API void imguiSetItemAllowOverlap() {
    ImGui::SetItemAllowOverlap();
}

CIMGUI_API bool imguiIsWindowHovered() {
    return ImGui::IsWindowHovered();
}

CIMGUI_API bool imguiIsWindowFocused() {
    return ImGui::IsWindowFocused();
}

CIMGUI_API bool imguiIsRootWindowFocused() {
    return ImGui::IsRootWindowFocused();
}

CIMGUI_API bool imguiIsRootWindowOrAnyChildFocused() {
    return ImGui::IsRootWindowOrAnyChildFocused();
}

CIMGUI_API bool imguiIsRootWindowOrAnyChildHovered() {
    return ImGui::IsRootWindowOrAnyChildHovered();
}

CIMGUI_API bool imguiIsRectVisible(CONST ImVec2 item_size) {
    return ImGui::IsRectVisible(item_size);
}

CIMGUI_API int imguiGetKeyIndex(ImGuiKey key) {
    return ImGui::GetKeyIndex(key);
}

CIMGUI_API bool imguiIsKeyDown(int key_index) {
    return ImGui::IsKeyDown(key_index);
}

CIMGUI_API bool imguiIsKeyPressed(int key_index, bool repeat) {
    return ImGui::IsKeyPressed(key_index, repeat);
}

CIMGUI_API bool imguiIsKeyReleased(int key_index) {
    return ImGui::IsKeyReleased(key_index);
}

CIMGUI_API bool imguiIsMouseDown(int button) {
    return ImGui::IsMouseDown(button);
}

CIMGUI_API bool imguiIsMouseClicked(int button, bool repeat) {
    return ImGui::IsMouseClicked(button, repeat);
}

CIMGUI_API bool imguiIsMouseDoubleClicked(int button) {
    return ImGui::IsMouseDoubleClicked(button);
}

CIMGUI_API bool imguiIsMouseReleased(int button) {
    return ImGui::IsMouseReleased(button);
}

CIMGUI_API bool imguiIsMouseHoveringWindow() {
    return ImGui::IsMouseHoveringWindow();
}

CIMGUI_API bool imguiIsMouseHoveringAnyWindow() {
    return ImGui::IsMouseHoveringAnyWindow();
}

CIMGUI_API bool imguiIsMouseHoveringRect(CONST ImVec2 r_min, CONST ImVec2 r_max, bool clip) {
    return ImGui::IsMouseHoveringRect(r_min, r_max, clip);
}

CIMGUI_API bool imguiIsMouseDragging(int button, float lock_threshold) {
    return ImGui::IsMouseDragging(button, lock_threshold);
}
CIMGUI_API bool imguiIsPosHoveringAnyWindow(CONST ImVec2 pos) {
    return ImGui::IsPosHoveringAnyWindow(pos);
}

CIMGUI_API void imguiGetMousePos(ImVec2 *pOut) {
    *pOut = ImGui::GetMousePos();
}

CIMGUI_API void imguiGetMousePosOnOpeningCurrentPopup(ImVec2 *pOut) {
    *pOut = ImGui::GetMousePosOnOpeningCurrentPopup();
}

CIMGUI_API void imguiGetMouseDragDelta(ImVec2 *pOut, int button, float lock_threshold) {
    *pOut = ImGui::GetMouseDragDelta(button, lock_threshold);
}

CIMGUI_API void imguiResetMouseDragDelta(int button) {
    ImGui::ResetMouseDragDelta(button);
}

CIMGUI_API ImGuiMouseCursor imguiGetMouseCursor() {
    return ImGui::GetMouseCursor();
}

CIMGUI_API void imguiSetMouseCursor(ImGuiMouseCursor type) {
    ImGui::SetMouseCursor(type);
}

CIMGUI_API void imguiCaptureKeyboardFromApp(bool capture) {
    return ImGui::CaptureKeyboardFromApp(capture);
}

CIMGUI_API void imguiCaptureMouseFromApp(bool capture) {
    return ImGui::CaptureMouseFromApp(capture);
}

CIMGUI_API void *imguiMemAlloc(size_t sz) {
    return ImGui::MemAlloc(sz);
}

CIMGUI_API void imguiMemFree(void *ptr) {
    return ImGui::MemFree(ptr);
}

CIMGUI_API CONST char *imguiGetClipboardText() {
    return ImGui::GetClipboardText();
}

CIMGUI_API void imguiSetClipboardText(CONST char *text) {
    return ImGui::SetClipboardText(text);
}

CIMGUI_API float imguiGetTime() {
    return ImGui::GetTime();
}

CIMGUI_API int imguiGetFrameCount() {
    return ImGui::GetFrameCount();
}

CIMGUI_API CONST char *imguiGetStyleColName(ImGuiCol idx) {
    return ImGui::GetStyleColName(idx);
}

CIMGUI_API void imguiCalcItemRectClosestPoint(ImVec2 *pOut, CONST ImVec2 pos, bool on_edge,
                                           float outward) {
    *pOut = ImGui::CalcItemRectClosestPoint(pos, on_edge, outward);
}

CIMGUI_API void imguiCalcTextSize(ImVec2 *pOut, CONST char *text, CONST char *text_end,
                               bool hide_text_after_double_hash, float wrap_width) {
    *pOut = ImGui::CalcTextSize(text, text_end, hide_text_after_double_hash, wrap_width);
}

CIMGUI_API void imguiCalcListClipping(int items_count, float items_height,
                                   int *out_items_display_start, int *out_items_display_end) {
    ImGui::CalcListClipping(items_count, items_height, out_items_display_start,
                            out_items_display_end);
}

CIMGUI_API bool imguiBeginChildFrame(ImGuiID id, CONST ImVec2 size, ImGuiWindowFlags extra_flags) {
    return ImGui::BeginChildFrame(id, size, extra_flags);
}

CIMGUI_API void imguiEndChildFrame() {
    ImGui::EndChildFrame();
}

CIMGUI_API void imguiColorConvertU32ToFloat4(ImVec4 *pOut, ImU32 in) {
    *pOut = ImGui::ColorConvertU32ToFloat4(in);
}

CIMGUI_API ImU32 imguiColorConvertFloat4ToU32(CONST ImVec4 in) {
    return ImGui::ColorConvertFloat4ToU32(in);
}

CIMGUI_API void imguiColorConvertRGBtoHSV(float r, float g, float b, float *out_h, float *out_s,
                                       float *out_v) {
    ImGui::ColorConvertRGBtoHSV(r, g, b, *out_h, *out_s, *out_v);
}

CIMGUI_API void imguiColorConvertHSVtoRGB(float h, float s, float v, float *out_r, float *out_g,
                                       float *out_b) {
    ImGui::ColorConvertHSVtoRGB(h, s, v, *out_r, *out_g, *out_b);
}

CIMGUI_API CONST char *imguiGetVersion() {
    return ImGui::GetVersion();
}

CIMGUI_API ImGuiContext *imguiCreateContext(void *(*malloc_fn)(size_t), void (*free_fn)(void *)) {
    return ImGui::CreateContext(malloc_fn, free_fn);
}

CIMGUI_API void imguiDestroyContext(ImGuiContext *ctx) {
    return ImGui::DestroyContext(ctx);
}

CIMGUI_API ImGuiContext *imguiGetCurrentContext() {
    return ImGui::GetCurrentContext();
}

CIMGUI_API void imguiSetCurrentContext(ImGuiContext *ctx) {
    return ImGui::SetCurrentContext(ctx);
}

CIMGUI_API void ImGuiIO_AddInputCharacter(unsigned short c) {
    ImGui::GetIO().AddInputCharacter(c);
}

CIMGUI_API void ImGuiIO_AddInputCharactersUTF8(CONST char *utf8_chars) {
    return ImGui::GetIO().AddInputCharactersUTF8(utf8_chars);
}

CIMGUI_API void ImGuiIO_ClearInputCharacters() {
    return ImGui::GetIO().ClearInputCharacters();
}

#ifdef __cplusplus
}
#endif