/********************************************************
* Copyright 2016-2080 evilbinary.
*作者:evilbinary on 12/24/16.
*邮箱:rootdebug@163.com
********************************************************/

#include <imgui.h>
#include "imgui_impl_android.h"
#include <sys/time.h>
#include "keyboard.h"


// Data
static double g_Time = 0.0f;
static bool g_MousePressed[3] = {false, false, false};
static float g_MouseWheel = 0.0f;
static GLuint g_FontTexture = 0;
static ImVec2 g_Scale = ImVec2(2.0f, 2.0f);


// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
// If text or lines are blurry when integrating ImGui in your engine:
// - in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)
void ImGui_ImplAndroid_RenderDrawLists(ImDrawData *draw_data) {
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    ImGuiIO &io = ImGui::GetIO();
    int fb_width = (int) (io.DisplaySize.x * io.DisplayFramebufferScale.x);
    int fb_height = (int) (io.DisplaySize.y * io.DisplayFramebufferScale.y);
    if (fb_width == 0 || fb_height == 0)
        return;
    draw_data->ScaleClipRects(io.DisplayFramebufferScale);

    // We are using the OpenGL fixed pipeline to make the example code simpler to read!
    // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, vertex/texcoord/color pointers.
    GLint last_texture;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    GLint last_viewport[4];
    glGetIntegerv(GL_VIEWPORT, last_viewport);
    GLint last_scissor_box[4];
    glGetIntegerv(GL_SCISSOR_BOX, last_scissor_box);
//    glPushAttrib(GL_ENABLE_BIT | GL_COLOR_BUFFER_BIT | GL_TRANSFORM_BIT);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_SCISSOR_TEST);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnable(GL_TEXTURE_2D);
    //glUseProgram(0); // You may want this if using this code in an OpenGL 3+ context

    // Setup viewport, orthographic projection matrix
    glViewport(0, 0, (GLsizei) fb_width, (GLsizei) fb_height);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

    glOrthof(0.0f, io.DisplaySize.x, io.DisplaySize.y, 0.0f, -1.0f, +1.0f);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    // Render command lists
#define OFFSETOF(TYPE, ELEMENT) ((size_t)&(((TYPE *)0)->ELEMENT))
    for (int n = 0; n < draw_data->CmdListsCount; n++) {
        const ImDrawList *cmd_list = draw_data->CmdLists[n];
        const ImDrawVert *vtx_buffer = cmd_list->VtxBuffer.Data;
        const ImDrawIdx *idx_buffer = cmd_list->IdxBuffer.Data;
        glVertexPointer(2, GL_FLOAT, sizeof(ImDrawVert),
                        (const GLvoid *) ((const char *) vtx_buffer + OFFSETOF(ImDrawVert, pos)));
        glTexCoordPointer(2, GL_FLOAT, sizeof(ImDrawVert),
                          (const GLvoid *) ((const char *) vtx_buffer + OFFSETOF(ImDrawVert, uv)));
        glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(ImDrawVert),
                       (const GLvoid *) ((const char *) vtx_buffer + OFFSETOF(ImDrawVert, col)));

        for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.Size; cmd_i++) {
            const ImDrawCmd *pcmd = &cmd_list->CmdBuffer[cmd_i];
            if (pcmd->UserCallback) {
                pcmd->UserCallback(cmd_list, pcmd);
            }
            else {
                glBindTexture(GL_TEXTURE_2D, (GLuint) (intptr_t) pcmd->TextureId);
                glScissor((int) pcmd->ClipRect.x, (int) (fb_height - pcmd->ClipRect.w),
                          (int) (pcmd->ClipRect.z - pcmd->ClipRect.x),
                          (int) (pcmd->ClipRect.w - pcmd->ClipRect.y));

                glDrawElements(GL_TRIANGLES, (GLsizei) pcmd->ElemCount,
                               sizeof(ImDrawIdx) == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT,
                               idx_buffer);
            }
            idx_buffer += pcmd->ElemCount;
        }
    }
#undef OFFSETOF

    // Restore modified state
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glBindTexture(GL_TEXTURE_2D, (GLuint) last_texture);
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
//    glPopAttrib();
    glViewport(last_viewport[0], last_viewport[1], (GLsizei) last_viewport[2],
               (GLsizei) last_viewport[3]);
    glScissor(last_scissor_box[0], last_scissor_box[1], (GLsizei) last_scissor_box[2],
              (GLsizei) last_scissor_box[3]);
}

static const char *ImGui_ImplAndroid_GetClipboardText(void *user_data) {
    //return glfwGetClipboardString((GLFWwindow*)user_data);
    return NULL;
}

static void ImGui_ImplAndroid_SetClipboardText(void *user_data, const char *text) {
    //glfwSetClipboardString((GLFWwindow*)user_data, text);
}

void ImGui_ImplAndroid_MouseButtonCallback(int button, int action, int /*mods*/) {

}

void ImGui_ImplAndroid_ScrollCallback(double /*xoffset*/, double yoffset) {
    g_MouseWheel += (float) yoffset; // Use fractional mouse wheel, 1.0 unit 5 lines.
}

void ImGui_ImplAndroid_KeyCallback(int type, int keycode, int ch, char *chars) {
    ImGuiIO &io = ImGui::GetIO();

    //LOGI("ImGui_ImplAndroid_KeyCallback=type=%d keycode=%d ch=%c chars=%s", type,keycode,ch,chars);

    if (type == 0) {//key down
        io.KeysDown[keycode] = true;
    } else if (type == 1) {//key up
        if (ch > 0 && ch < 0x10000) {
            io.AddInputCharacter((unsigned short) ch);
        } else {
            int chh=getLabelByValue(keycode);
            if (strcmp("SHIFT_LEFT", chh) == 0 || strcmp("SHIFT_RIGHT", chh) == 0) {
                io.KeyShift = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("ALT_LEFT", chh) == 0 || strcmp("ALT_RIGHT", chh) == 0) {
                io.KeyAlt = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("CTRL_LEFT", chh) == 0 || strcmp("CTRL_RIGHT", chh) == 0) {
                io.KeyCtrl = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("DEL", chh) == 0) {

            }
        }

        io.KeysDown[keycode] = false;
    } else if (type == 2) {//multi inputs
        for (int i = 0; chars[i] != 0; i++) {
            io.AddInputCharacter((unsigned short) chars[i]);
        }
    }

}

void ImGui_ImplAndroid_CharCallback(unsigned int c) {
    ImGuiIO &io = ImGui::GetIO();
    if (c > 0 && c < 0x10000)
        io.AddInputCharacter((unsigned short) c);
}

bool ImGui_ImplAndroid_CreateDeviceObjects() {
    // Build texture atlas
    ImGuiIO &io = ImGui::GetIO();
    unsigned char *pixels;
    int width, height;
    io.Fonts->GetTexDataAsRGBA32(&pixels, &width,
                                 &height);   // Load as RGBA 32-bits (75% of the memory is wasted, but default font is so small) because it is more likely to be compatible with user's existing shaders. If your ImTextureId represent a higher-level concept than just a GL texture id, consider calling GetTexDataAsAlpha8() instead to save on GPU memory.

    // Upload texture to graphics system
    GLint last_texture;
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    glGenTextures(1, &g_FontTexture);
    glBindTexture(GL_TEXTURE_2D, g_FontTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

    // Store our identifier
    io.Fonts->TexID = (void *) (intptr_t) g_FontTexture;

    // Restore state
    glBindTexture(GL_TEXTURE_2D, last_texture);

    return true;
}

void ImGui_ImplAndroid_InvalidateDeviceObjects() {
    if (g_FontTexture) {
        glDeleteTextures(1, &g_FontTexture);
        ImGui::GetIO().Fonts->TexID = 0;
        g_FontTexture = 0;
    }
}

bool ImGui_ImplAndroid_Init() {

    ImGuiIO &io = ImGui::GetIO();
//    io.KeyMap[ImGuiKey_Tab] =  ;                     // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
//    io.KeyMap[ImGuiKey_LeftArrow] =  ;
//    io.KeyMap[ImGuiKey_RightArrow] =  ;
//    io.KeyMap[ImGuiKey_UpArrow] =  ;
//    io.KeyMap[ImGuiKey_DownArrow] =  ;
//    io.KeyMap[ImGuiKey_PageUp] =  ;
//    io.KeyMap[ImGuiKey_PageDown] =  ;
//    io.KeyMap[ImGuiKey_Home] =  ;
//    io.KeyMap[ImGuiKey_End] =  ;
    io.KeyMap[ImGuiKey_Delete] = 67;
    io.KeyMap[ImGuiKey_Backspace] = 67;
    io.KeyMap[ImGuiKey_Enter] = 66;

//    io.KeyMap[ImGuiKey_Escape] =  ;
//    io.KeyMap[ImGuiKey_A] = ;
//    io.KeyMap[ImGuiKey_C] = ;
//    io.KeyMap[ImGuiKey_V] = ;
//    io.KeyMap[ImGuiKey_X] = ;
//    io.KeyMap[ImGuiKey_Y] = ;
//    io.KeyMap[ImGuiKey_Z] = ;

    io.RenderDrawListsFn = ImGui_ImplAndroid_RenderDrawLists;      // Alternatively you can set this to NULL and call ImGui::GetDrawData() after ImGui::Render() to get the same ImDrawData pointer.
    io.SetClipboardTextFn = ImGui_ImplAndroid_SetClipboardText;
    io.GetClipboardTextFn = ImGui_ImplAndroid_GetClipboardText;
    //io.ClipboardUserData = g_Window;


    return true;
}

void ImGui_ImplAndroid_Shutdown() {
    ImGui_ImplAndroid_InvalidateDeviceObjects();
    ImGui::Shutdown();
}

void ImGui_ImplAndroid_SetScale(float x, float y) {
    g_Scale = ImVec2(x, y);
}

void ImGui_ImplAndroid_ResizeCallback(int w, int h) {
    ImGuiIO &io = ImGui::GetIO();
    // Setup display size (every frame to accommodate for window resizing)

    int display_w, display_h;

    display_w = w;
    display_h = h;
    w = w / g_Scale.x;
    h = h / g_Scale.y;

    io.DisplaySize = ImVec2((float) w, (float) h);
    io.DisplayFramebufferScale = ImVec2(w > 0 ? ((float) display_w / w) : 0,
                                        h > 0 ? ((float) display_h / h) : 0);
}

void ImGui_ImplAndroid_TouchCallback(int type, int x, int y) {
    ImGuiIO &io = ImGui::GetIO();
    x = x / g_Scale.x;
    y = y / g_Scale.y;
    if (type == 0) {
        io.MousePos = ImVec2(x, y);
        io.MouseDown[0] = true;
    } else if (type == 2) {
        io.MousePos = ImVec2(x, y);
    } else if (type == 1) {
        io.MouseDown[0] = false;
    }

}

double getTime() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000;
}

void ImGui_ImplAndroid_NewFrame() {
    if (!g_FontTexture)
        ImGui_ImplAndroid_CreateDeviceObjects();
    ImGuiIO &io = ImGui::GetIO();



    // Setup time step
    double current_time = getTime();
    io.DeltaTime = g_Time > 0.0 ? (float) (current_time - g_Time) : (float) (1.0f / 60.0f);
    g_Time = current_time;

    io.MouseWheel = g_MouseWheel;
    g_MouseWheel = 0.0f;

    // Start the frame
    ImGui::NewFrame();
}
