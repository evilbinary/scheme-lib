#include "imgui.h"
#include "imgui_impl_android.h"
#include <stdio.h>
#include <stdlib.h>
#include "cimgui/cimgui.h"
#include "scm.h"
#include <functional>


#ifdef __cplusplus
extern "C" {
#endif

static void error_callback(int error, const char *description) {
    fprintf(stderr, "Error %d: %s\n", error, description);
}

void imgui_exit() {
    ImGui_ImplAndroid_Shutdown();
}
void imgui_init() {
    // Setup ImGui binding
    ImGui_ImplAndroid_Init();

    // Load Fonts
    // (there is a default font, this is only if you want to change it. see extra_fonts/README.txt for more details)
    ImGuiIO& io = ImGui::GetIO();
    //io.Fonts->AddFontDefault();
//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/Cousine-Regular.ttf", 15.0f);
//    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSans.ttf", 16.0f);

    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSansFallback.ttf", 18.0f,NULL,io.Fonts->GetGlyphRangesChinese() );
//    io.Fonts->AddFontFromFileTTF("ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());


//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/ProggyClean.ttf", 13.0f);
//    io.Fonts->AddFontFromFileTTF("../../extra_fonts/ProggyTiny.ttf", 10.0f);
//    io.Fonts->AddFontFromFileTTF("/system/fonts/DroidSans.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());

}
void imgui_touch_event(int type, int x, int y) {

    ImGui_ImplAndroid_TouchCallback(type, x, y);
}
void imgui_key_event(int type, int key,int ch,char* chars) {

    ImGui_ImplAndroid_KeyCallback(type,key,ch,chars);
}
void imgui_resize(int w, int h) {
    ImGui_ImplAndroid_ResizeCallback(w, h);
}
void imgui_render_start() {
    ImGui_ImplAndroid_NewFrame();
}
void imgui_scale(float x, float y) {
    ImGui_ImplAndroid_SetScale(x, y);
}
int is_enable_default_color=1;
ImVec4 default_clear_color=ImColor(114, 144, 154);

void imgui_disable_default_color(){
    is_enable_default_color==0;
}
void imgui_enable_default_color(){
    is_enable_default_color==1;
}
void imgui_set_default_color(int r,int g,int b){
    default_clear_color=ImColor(r, g, b);
}
ImVec4* imgui_get_default_color(){
    return &default_clear_color;
}

void imgui_render_end(){
    if(is_enable_default_color==1) {
        glClearColor(default_clear_color.x, default_clear_color.y, default_clear_color.z, default_clear_color.w);
    }
    glClear(GL_COLOR_BUFFER_BIT);
    ImGui::Render();
}
ImVec2 imgui_make_vec2(float x,float y){
    return  ImVec2(x,y);
}
//ImVec2* imgui_make_vec2(float x,float y){
//    return  &ImVec2(x,y);
//}
ImVec4 imgui_make_vec4(float x,float y,float z,float w){
    return  ImVec4(x,y,z,w);
}


//scheme callback

static int test_callback(ImGuiTextEditCallbackData* data){
    LOGI("test_callback======================>");

}

ImGuiTextEditCallback  imgui_make_text_edit_callback(iptr fobj){
    static std::function<int (struct ImGuiTextEditCallbackData *)> tt;
    auto a_lambda_func = [](struct ImGuiTextEditCallbackData *data)->int {
        return tt(data);
    };
    tt=[&](struct ImGuiTextEditCallbackData * data)->int{
        //LOGI("dd======================>");
        if (scm_procedurep(fobj)) {
            iptr ret = scm_call1(fobj, data);
            //LOGI("call=%d", scm_fixnum_value(ret));
            return scm_fixnum_value(ret);
        }
    };
    ImGuiTextEditCallback callback= a_lambda_func;

    return callback;
//    return [](struct ImGuiTextEditCallbackData *data)->int {
//        LOGI("dd========dd==============>");
//        return -1;
//    };
}

//scheme callback end


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

void imgui_test() {

    bool show_test_window = true;
    bool show_another_window = false;
    ImVec4 clear_color = ImColor(114, 144, 154);

    //ImGui_ImplAndroid_NewFrame();

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

//        ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(0,0));
//        ImGui::Checkbox("Read-only", &read_only);
//        ImGui::PopStyleVar();
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

    // 3. Show the ImGui test window. Most of the sample code is in ImGui::ShowTestWindow()
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

#ifdef __cplusplus
}
#endif
