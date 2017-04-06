#include "imgui.h"
#include "imgui_impl_gl.h"
#include <stdio.h>
#include <stdlib.h>
#include "cimgui/cimgui.h"
#include "scm.h"
#include <functional>
#include "imgui_user.h"


#ifdef __cplusplus
extern "C" {
#endif


static void error_callback(int error, const char *description) {
    fprintf(stderr, "Error %d: %s\n", error, description);
}

SCM_API void imgui_exit() {
    ImGui_ImplGL_Shutdown();
}
SCM_API void imgui_init() {
    // Setup ImGui binding
    ImGui_ImplGL_Init();

    // Load Fonts
    // (there is a default font, this is only if you want to change it. see extra_fonts/README.txt for more details)
    ImGuiIO& io = ImGui::GetIO();
    //io.Fonts->AddFontDefault();
//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/Cousine-Regular.ttf", 15.0f);
//    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSans.ttf", 16.0f);
#ifdef ANDROID
    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSansFallback.ttf", 18.0f,NULL,io.Fonts->GetGlyphRangesChinese() );

   io.Fonts->AddFontFromFileTTF("ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
#endif

//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/ProggyClean.ttf", 13.0f);
//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/ProggyTiny.ttf", 10.0f);
//    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSans.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());

}
SCM_API void imgui_mouse_event(int button, int state) {

    ImGui_ImplGL_MouseButtonCallback(button,state);
}
SCM_API void imgui_motion_event(int x, int y) {

    ImGui_ImplGL_MouseMotionCallback(x, y);
}
SCM_API void imgui_touch_event(int type, int x, int y) {

    ImGui_ImplGL_TouchCallback(type, x, y);
}
SCM_API void imgui_key_event(int type, int key,int ch,char* chars) {
    //LOGI("imgui_key_event type=%d key=%d",type,key);

    ImGui_ImplGL_KeyCallback(type,key,ch,chars);
}
SCM_API void imgui_resize(int w, int h) {
    ImGui_ImplGL_ResizeCallback(w, h);
}
SCM_API void imgui_render_start() {
    ImGui_ImplGL_NewFrame();
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

}
SCM_API void imgui_scale(float x, float y) {
    ImGui_ImplGL_SetScale(x, y);
}
SCM_API int is_enable_default_color=1;
ImVec4 default_clear_color=ImColor(114, 144, 154);

SCM_API void imgui_disable_default_color(){
    is_enable_default_color=0;
}
SCM_API void imgui_enable_default_color(){
    is_enable_default_color=1;
}
SCM_API void imgui_set_default_color(int r,int g,int b){
    default_clear_color=ImColor(r, g, b);
}
SCM_API ImVec4* imgui_get_default_color(){
    return &default_clear_color;
}

SCM_API void imgui_render_end(){
    if(is_enable_default_color==1) {
        glClearColor(default_clear_color.x, default_clear_color.y, default_clear_color.z, default_clear_color.w);
    }
    ImGui::Render();
}
SCM_API ImVec2 imgui_make_vec2(float x,float y){
    return  ImVec2(x,y);
}
SCM_API ImVec2* imgui_pvec2(float x,float y){
   return  new ImVec2(x,y);
}
SCM_API void imgui_uvec2(ImVec2* v){
    if(v!=NULL)
     delete v;
}
SCM_API ImVec4 imgui_make_vec4(float x,float y,float z,float w){
    return  ImVec4(x,y,z,w);
}

SCM_API ImTextureID imgui_load_texture(char* filename){

    ImTextureID imageTextureId = ImImpl_LoadTexture(filename);
    //LOGI("imgui_load_texture %s imageTextureId=%d",filename,imageTextureId);
    return imageTextureId;
}

//scheme callback

SCM_API void test_texture(char* filename,  ImVec2& size,  ImVec2& uv0 ,  ImVec2& uv1){
    LOGI("test_texture");
    ImTextureID imageTextureId = ImImpl_LoadTexture(filename);
    ImGui::Image(imageTextureId, size, uv0, uv1);

}

SCM_API ImGuiTextEditCallback  imgui_make_text_edit_callback(ptr fobj){
    static std::function<int (struct ImGuiTextEditCallbackData *)> tt;
    auto a_lambda_func = [](struct ImGuiTextEditCallbackData *data)->int {
        return tt(data);
    };
    tt=[&](struct ImGuiTextEditCallbackData * data)->int{
        //LOGI("dd======================>");
        if (scm_procedurep(fobj)) {
            ptr ret = scm_call1_proc(fobj, data);
            //LOGI("call=%d", scm_fixnum_value(ret));
            return scm_fixnum_value(ret);
        }
    };
    ImGuiTextEditCallback callback= a_lambda_func;

    return callback;
}
//scheme callback end


//addons interface
SCM_API bool imgui_load_style(const char* style){
    return ImGui::LoadStyle(style,ImGui::GetStyle());
}
SCM_API bool imgui_save_style(const char* style){
    return ImGui::SaveStyle(style,ImGui::GetStyle());
}
SCM_API bool imgui_reset_style(int stylenum){
    return ImGui::ResetStyle(stylenum,ImGui::GetStyle());
}



//test begin
#define IM_ARRAYSIZE(_ARR)  ((int)(sizeof(_ARR)/sizeof(*_ARR)))
void imgui_test3(){
    // if (ImGui::TreeNode("Basic Horizontal Layout"))
    //     {
            // ImGui::TextWrapped("(Use ImGui::SameLine() to keep adding items to the right of the preceding item)");

            // // Text
            // ImGui::Text("Two items: Hello"); ImGui::SameLine();
            // ImGui::TextColored(ImVec4(1,1,0,1), "Sailor");

            // // Adjust spacing
            // ImGui::Text("More spacing: Hello"); ImGui::SameLine(0, 20);
            // ImGui::TextColored(ImVec4(1,1,0,1), "Sailor");

            // // Button
            // //ImGui::AlignFirstTextHeightToWidgets();
            // ImGui::Text("Normal buttons"); ImGui::SameLine();
            ImGui::Button("1",ImVec2(30,30)); ImGui::SameLine();
            ImGui::Button("2",ImVec2(30,30)); ImGui::SameLine();
            ImGui::Button("3",ImVec2(30,30));

            // Button
            // ImGui::Text("Small buttons"); ImGui::SameLine();
            // ImGui::SmallButton("Like this one"); ImGui::SameLine();
            // ImGui::Text("can fit within a text block.");

            // // Aligned to arbitrary position. Easy/cheap column.
            // ImGui::Text("Aligned");
            // ImGui::SameLine(150); ImGui::Text("x=150");
            // ImGui::SameLine(300); ImGui::Text("x=300");
            // ImGui::Text("Aligned");
            // ImGui::SameLine(150); ImGui::SmallButton("x=150");
            // ImGui::SameLine(300); ImGui::SmallButton("x=300");

            // // Checkbox
            // static bool c1=false,c2=false,c3=false,c4=false;
            // ImGui::Checkbox("My", &c1); ImGui::SameLine();
            // ImGui::Checkbox("Tailor", &c2); ImGui::SameLine();
            // ImGui::Checkbox("Is", &c3); ImGui::SameLine();
            // ImGui::Checkbox("Rich", &c4);

            // // Various
            // static float f0=1.0f, f1=2.0f, f2=3.0f;
            // ImGui::PushItemWidth(80);
            // const char* items[] = { "AAAA", "BBBB", "CCCC", "DDDD" };
            // static int item = -1;
            // ImGui::Combo("Combo", &item, items, IM_ARRAYSIZE(items)); ImGui::SameLine();
            // ImGui::SliderFloat("X", &f0, 0.0f,5.0f); ImGui::SameLine();
            // ImGui::SliderFloat("Y", &f1, 0.0f,5.0f); ImGui::SameLine();
            // ImGui::SliderFloat("Z", &f2, 0.0f,5.0f);
            // ImGui::PopItemWidth();

            // ImGui::PushItemWidth(80);
            // ImGui::Text("Lists:");
            // static int selection[4] = { 0, 1, 2, 3 };
            // for (int i = 0; i < 4; i++)
            // {
            //     if (i > 0) ImGui::SameLine();
            //     ImGui::PushID(i);
            //     ImGui::ListBox("", &selection[i], items, IM_ARRAYSIZE(items));
            //     ImGui::PopID();
            //     //if (ImGui::IsItemHovered()) ImGui::SetTooltip("ListBox %d hovered", i);
            // }
            // ImGui::PopItemWidth();

            // // Dummy
            // ImVec2 sz(30,30);
            // ImGui::Button("A", sz); ImGui::SameLine();
            // ImGui::Dummy(sz); ImGui::SameLine();
            // ImGui::Button("B", sz);

            //ImGui::TreePop();
        // }
}

void imgui_test2( CONST char *label, char *buf, size_t buf_size,
                  ImGuiInputTextFlags f,
                  ImGuiTextEditCallback callback, void *user_data, CONST ImVec2 size){ //
//    LOGI("flags=%d size_t=%d  ImVec2=%d int=%d long=%d callback=%p user_data=%p",f, sizeof(size_t), sizeof(ImVec2),sizeof(int),sizeof(long),callback,user_data );

    static bool read_only = false;
    static char text[1024*16] =
            "/*\n"
                    " The Pentium F00F bug, shorthand for F0 0F C7 C8,\n"
                    " the hexadecimal encoding of one offending instruction,\n"
                    " more formally, the invalid operand with locked CMPXCHG8B\n"
                    " instruction bug, is a design flaw in the majority of\n"
                    " Intel Pentium, Pentium MMX, and Pentium OverDrive\n"
                    " processors (all in the P5 microarchitecture).\n"
                    "*/\n\n"
                    "label:\n"
                    "\tlock cmpxchg8b eax\n";
#define IM_ARRAYSIZE(_ARR)  ((int)(sizeof(_ARR)/sizeof(*_ARR)))


    imguiInputTextMultiline(label, buf, buf_size,  f,callback,user_data,size  );
    ImGui::Text("eeeee!");

}

SCM_API void imgui_test() {

    bool show_test_window = true;
    bool show_another_window = false;
    ImVec4 clear_color = ImColor(114, 144, 154);

    //ImGui_ImplGL_NewFrame();

    // 1. Show a simple window
    // Tip: if we don't call ImGui::Begin()/ImGui::End() the widgets appears in a window automatically called "Debug"
    {
        static float f = 0.0f;
        ImGui::Text("嘎嘎Hello, world!");
        ImGui::SliderFloat("float", &f, 0.0f, 1.0f);
        ImGui::ColorEdit3("clear color", (float *) &clear_color);
        if (ImGui::Button("Test Window")) show_test_window ^= 1;
        if (ImGui::Button("Another Window")) show_another_window ^= 1;
        ImGui::Text("Application average %.3f ms/frame (%.1f FPS)",
                    1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);

        static bool read_only = false;
        static char text[1024*16] =
                "/*\n"
                        " The Pentium F00F bug, shorthand for F0 0F C7 C8,\n"
                        " the hexadecimal encoding of one offending instruction,\n"
                        " more formally, the invalid operand with locked CMPXCHG8B\n"
                        " instruction bug, is a design flaw in the majority of\n"
                        " Intel Pentium, Pentium MMX, and Pentium OverDrive\n"
                        " processors (all in the P5 microarchitecture).\n"
                        "*/\n\n"
                        "label:\n"
                        "\tlock cmpxchg8b eax\n";

       ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(0,0));
       ImGui::Checkbox("Read-only", &read_only);
       ImGui::PopStyleVar();
#define IM_ARRAYSIZE(_ARR)  ((int)(sizeof(_ARR)/sizeof(*_ARR)))

        ImGui::InputTextMultiline("##source", text, IM_ARRAYSIZE(text), ImVec2(-1.0f, ImGui::GetTextLineHeight() * 16), ImGuiInputTextFlags_AllowTabInput | (read_only ? ImGuiInputTextFlags_ReadOnly : 0));

    }

    // 2. Show another simple window, this time using an explicit Begin/End pair
    if (show_another_window) {
        ImGui::SetNextWindowSize(ImVec2(200, 100), ImGuiSetCond_FirstUseEver);
        ImGui::Begin("Another Window", &show_another_window);
        ImGui::Text("Hello");

        ImGui::End();
    }

    //3. Show the ImGui test window. Most of the sample code is in ImGui::ShowTestWindow()
    if (show_test_window) {
        ImGui::SetNextWindowPos(ImVec2(20, 20), ImGuiSetCond_FirstUseEver);
        ImGui::ShowTestWindow(&show_test_window);
    }



// Rendering
//        int display_w, display_h;
//        glfwGetFramebufferSize(window, &display_w, &display_h);
//        glViewport(0, 0, display_w, display_h);
//glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
//glClear(GL_COLOR_BUFFER_BIT);
//ImGui::Render();

}
//test end



#ifdef __cplusplus
}
#endif
