/********************************************************
* Copyright 2016-2080 evilbinary.
*作者:evilbinary on 12/24/16.
*邮箱:rootdebug@163.com
********************************************************/


#include "imgui_impl_gl.h"
#include <sys/time.h>
#include "keyboard.h"
#include <stdio.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

// Data
static double g_Time = 0.0f;
static bool g_MousePressed[3] = {false, false, false};
static float g_MouseWheel = 0.0f;
static GLuint g_FontTexture = 0;


static bool gTextureFilteringHintMagFilterNearest = false;  // These internal values can be used by ImImpl_GenerateOrUpdateTexture(...) implementations
static bool gTextureFilteringHintMinFilterNearest = false;


#ifdef ANDROID
static ImVec2 g_Scale = ImVec2(2.5f, 2.5f);
#else
static ImVec2 g_Scale = ImVec2(1.0f, 1.0f);
#endif

#ifdef ANDROID
// This is the main rendering function that you have to implement and provide to ImGui (via setting up 'RenderDrawListsFn' in the ImGuiIO structure)
// If text or lines are blurry when integrating ImGui in your engine:
// - in your Render function, try translating your projection matrix by (0.5f,0.5f) or (0.375f,0.375f)
void ImGui_ImplGL_RenderDrawLists(ImDrawData *draw_data) {
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    ImGuiIO& io = ImGui::GetIO();
    int fb_width = (int)(io.DisplaySize.x * io.DisplayFramebufferScale.x);
    int fb_height = (int)(io.DisplaySize.y * io.DisplayFramebufferScale.y);
    if (fb_width == 0 || fb_height == 0)
        return;
    draw_data->ScaleClipRects(io.DisplayFramebufferScale);

    // We are using the OpenGL fixed pipeline to make the example code simpler to read!
    // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, vertex/texcoord/color pointers.
    // Backup GL state
//    GLint last_program; glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
    GLint last_texture; glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    //GLint last_active_texture; glGetIntegerv(GL_ACTIVE_TEXTURE, &last_active_texture);

//    GLint last_array_buffer; glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
//    GLint last_element_array_buffer; glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &last_element_array_buffer);
    //GLint last_vertex_array; glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);
//    GLint last_blend_src; glGetIntegerv(GL_BLEND_SRC_ALPHA, &last_blend_src);
//    GLint last_blend_dst; glGetIntegerv(GL_BLEND_DST_ALPHA, &last_blend_dst);
//    GLint last_blend_equation_rgb; glGetIntegerv(GL_BLEND_EQUATION_RGB, &last_blend_equation_rgb);
//    GLint last_blend_equation_alpha; glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &last_blend_equation_alpha);
    GLint last_viewport[4]; glGetIntegerv(GL_VIEWPORT, last_viewport);
//    GLboolean last_enable_blend = glIsEnabled(GL_BLEND);
//    GLboolean last_enable_cull_face = glIsEnabled(GL_CULL_FACE);
//    GLboolean last_enable_depth_test = glIsEnabled(GL_DEPTH_TEST);
//    GLboolean last_enable_scissor_test = glIsEnabled(GL_SCISSOR_TEST);
    GLint last_scissor_box[4];
    glGetIntegerv(GL_SCISSOR_BOX, last_scissor_box);

    // glPushAttrib(GL_ENABLE_BIT | GL_COLOR_BUFFER_BIT | GL_TRANSFORM_BIT);
    glEnable(GL_BLEND);
    //glBlendEquation(GL_FUNC_ADD);

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
    for (int n = 0; n < draw_data->CmdListsCount; n++){
        const ImDrawList* cmd_list = draw_data->CmdLists[n];
        const unsigned char* vtx_buffer = (const unsigned char*)&cmd_list->VtxBuffer.front();
        const ImDrawIdx* idx_buffer = &cmd_list->IdxBuffer.front();
        glVertexPointer(2, GL_FLOAT, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, pos)));
        glTexCoordPointer(2, GL_FLOAT, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, uv)));
        glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, col)));

        for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.size(); cmd_i++){
            const ImDrawCmd* pcmd = &cmd_list->CmdBuffer[cmd_i];
            if (pcmd->UserCallback){
                pcmd->UserCallback(cmd_list, pcmd);
            }
            else{
                glBindTexture(GL_TEXTURE_2D, (GLuint)(intptr_t)pcmd->TextureId);
                glScissor((int)pcmd->ClipRect.x, (int)(fb_height - pcmd->ClipRect.w), (int)(pcmd->ClipRect.z - pcmd->ClipRect.x), (int)(pcmd->ClipRect.w - pcmd->ClipRect.y));
                glDrawElements(GL_TRIANGLES, (GLsizei)pcmd->ElemCount, sizeof(ImDrawIdx) == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT, idx_buffer);
            }
            idx_buffer += pcmd->ElemCount;
        }
    }
    #undef OFFSETOF

    // Restore modified state
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glBindTexture(GL_TEXTURE_2D, (GLuint)last_texture);
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    //glPopAttrib();

    // Restore modified GL state
//    glUseProgram(last_program);
    //glActiveTexture(last_active_texture);
    //glBindTexture(GL_TEXTURE_2D, last_texture);
    // glBindVertexArray(last_vertex_array);


//    glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, last_element_array_buffer);

//    glBlendEquationSeparate(last_blend_equation_rgb, last_blend_equation_alpha);
//    glBlendFunc(last_blend_src, last_blend_dst);
//    if (last_enable_blend) glEnable(GL_BLEND); else glDisable(GL_BLEND);
//    if (last_enable_cull_face) glEnable(GL_CULL_FACE); else glDisable(GL_CULL_FACE);
//    if (last_enable_depth_test) glEnable(GL_DEPTH_TEST); else glDisable(GL_DEPTH_TEST);
//    if (last_enable_scissor_test) glEnable(GL_SCISSOR_TEST); else glDisable(GL_SCISSOR_TEST);

    glViewport(last_viewport[0], last_viewport[1], (GLsizei)last_viewport[2], (GLsizei)last_viewport[3]);
 glScissor(last_scissor_box[0], last_scissor_box[1], (GLsizei) last_scissor_box[2],
              (GLsizei) last_scissor_box[3]);
}
#endif

static const char *ImGui_ImplGL_GetClipboardText(void *user_data) {
    //return glfwGetClipboardString((GLFWwindow*)user_data);
    return NULL;
}

static void ImGui_ImplGL_SetClipboardText(void *user_data, const char *text) {
    //glfwSetClipboardString((GLFWwindow*)user_data, text);
}


void ImGui_ImplGL_ScrollCallback(double xoffset, double yoffset) {
    g_MouseWheel += (float) yoffset; // Use fractional mouse wheel, 1.0 unit 5 lines.
}

void ImGui_ImplGL_KeyCallback(int type, int keycode, int ch, char *chars) {
    ImGuiIO &io = ImGui::GetIO();
    //LOGI("ImGui_ImplGL_KeyCallback=type=%d keycode=%d ch=%c chars=%s", type,keycode,ch,chars);
#ifdef ANDROID
#else    
    //   int mods = glutGetModifiers();
    // io.KeyCtrl = (mods&GLUT_ACTIVE_CTRL) != 0;
    // io.KeyShift = (mods&GLUT_ACTIVE_SHIFT) != 0;
    // io.KeyAlt = (mods&GLUT_ACTIVE_ALT) != 0;

#endif
    if (type == 0) {//key down
        io.KeysDown[keycode] = true;
    } else if (type == 1) {//key up
        if (ch > 0 && ch < 0x10000) {
            io.AddInputCharacter((unsigned short) ch);
        } else {
#ifdef ANDROID            
            int chh=getLabelByValue(keycode);
            if (strcmp("SHIFT_LEFT", chh) == 0 || strcmp("SHIFT_RIGHT", chh) == 0) {
                io.KeyShift = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("ALT_LEFT", chh) == 0 || strcmp("ALT_RIGHT", chh) == 0) {
                io.KeyAlt = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("CTRL_LEFT", chh) == 0 || strcmp("CTRL_RIGHT", chh) == 0) {
                io.KeyCtrl = io.KeysDown[keycode] || io.KeysDown[keycode];
            } else if (strcmp("DEL", chh) == 0) {

            }
#endif            
        }

        io.KeysDown[keycode] = false;
    } else if (type == 2) {//multi inputs
        for (int i = 0; chars[i] != 0; i++) {
            io.AddInputCharacter((unsigned short) chars[i]);
        }
    }else if (type==3){//specialkey down
#ifdef ANDROID

#else
        extern void ImGui_ImplGlut_SpecialCallback(int key);
        ImGui_ImplGlut_SpecialCallback(keycode);
#endif        

    }else if (type==4){//specialkey up
#ifdef ANDROID

#else
        extern void ImGui_ImplGlut_SpecialUpCallback(int key);
        ImGui_ImplGlut_SpecialUpCallback(keycode);
#endif  
    }

}

void ImGui_ImplGL_CharCallback(unsigned int c) {
    ImGuiIO &io = ImGui::GetIO();
    if (c > 0 && c < 0x10000)
        io.AddInputCharacter((unsigned short) c);
}

bool ImGui_ImplGL_CreateDeviceObjects() {
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

void ImGui_ImplGL_InvalidateDeviceObjects() {
    if (g_FontTexture) {
        glDeleteTextures(1, &g_FontTexture);
        ImGui::GetIO().Fonts->TexID = 0;
        g_FontTexture = 0;
    }
}

bool ImGui_ImplGL_Init() {

    ImGuiIO &io = ImGui::GetIO();
#ifdef ANDROID
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
    io.RenderDrawListsFn = ImGui_ImplGL_RenderDrawLists;      // Alternatively you can set this to NULL and call ImGui::GetDrawData() after ImGui::Render() to get the same ImDrawData pointer.
#else    
    extern void ImGui_ImplGLUT_RenderDrawLists(ImDrawData* draw_data);
    io.RenderDrawListsFn = ImGui_ImplGLUT_RenderDrawLists;      // Alternatively you can set this to NULL and call ImGui::GetDrawData() after ImGui::Render() to get the same ImDrawData pointer.
    extern void Imgui_ImplGLUT_KeyMap(ImGuiIO& io);
    Imgui_ImplGLUT_KeyMap(io);
#endif    
    
    io.SetClipboardTextFn = ImGui_ImplGL_SetClipboardText;
    io.GetClipboardTextFn = ImGui_ImplGL_GetClipboardText;
    //io.ClipboardUserData = g_Window;


    return true;
}

void ImGui_ImplGL_Shutdown() {
    ImGui_ImplGL_InvalidateDeviceObjects();
    ImGui::Shutdown();
}

void ImGui_ImplGL_SetScale(float x, float y) {
    g_Scale = ImVec2(x, y);
}

void ImGui_ImplGL_ResizeCallback(int w, int h) {
    ImGuiIO &io = ImGui::GetIO();
    // Setup display size (every frame to accommodate for window resizing)
    printf("ImGui_ImplGL_ResizeCallback %d,%d\n",w,h);

    int display_w, display_h;
    #ifdef GLAD
        display_w = glutGet(GLUT_WINDOW_FRAMBUFFER_WIDTH);
        display_h = glutGet(GLUT_WINDOW_FRAMBUFFER_HEIGHT);
        printf("ImGui_ImplGL_ResizeCallback display_w=%d,%d\n",display_w,display_h);

    #else
        display_w = w;
        display_h = h;
    #endif

    w = w / (g_Scale.x);
    h = h / (g_Scale.y);
    io.DisplaySize = ImVec2((float) w, (float) h);
    io.DisplayFramebufferScale = ImVec2(w > 0 ? ((float)  display_w/w) : 0,
                                        h > 0 ? ((float)  display_h/h ) : 0);

    // printf("ImGui_ImplGL_ResizeCallback %d,%d\n",w,h);


}

void ImGui_ImplGL_TouchCallback(int type, int x, int y) {
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
void ImGui_ImplGL_MouseMotionCallback(int x, int y){
    // LOGI("ImGui_ImplGL_MouseMotionCallback %d %d",x,y);
    ImGuiIO& io = ImGui::GetIO();
    io.MousePos = ImVec2(x,y); 
}
void ImGui_ImplGL_MouseButtonCallback(int button, int state){
    #ifdef ANDROID

    #else
    // LOGI("ImGui_ImplGL_MouseButtonCallback button=%d state=%d",button,state);
    extern void ImGui_ImplGLUT_MouseButtonCallback(int button, int state);
    ImGui_ImplGLUT_MouseButtonCallback( button,   state);


    #endif
}




double getTime() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (tv.tv_sec + tv.tv_usec / 1000000);
}

void ImGui_ImplGL_NewFrame() {
    if (!g_FontTexture)
        ImGui_ImplGL_CreateDeviceObjects();
    ImGuiIO &io = ImGui::GetIO();

    io.DeltaTime=1.0f/30.0f;
    // Setup time step
    //double current_time = getTime();
    //io.DeltaTime = g_Time > 0.0 ? (float) 1.0f/(current_time - g_Time) : (float) (1.0f / 60.0f);
    // g_Time = current_time;

    //LOGI("g_MouseWheel=%d",g_MouseWheel);

    io.MouseWheel = g_MouseWheel;
    g_MouseWheel = 0.0f;

    // Start the frame
    ImGui::NewFrame();
}


 #include "glad/glad.h"

void ImImpl_FreeTexture(ImTextureID& imtexid) {
    GLuint& texid = reinterpret_cast<GLuint&>(imtexid);
    if (texid) {glDeleteTextures(1,&texid);texid=0;}
}
void ImImpl_GenerateOrUpdateTexture(ImTextureID& imtexid,int width,int height,int channels,const unsigned char* pixels,bool useMipmapsIfPossible,bool wraps,bool wrapt) {
    IM_ASSERT(pixels);
    IM_ASSERT(channels>0 && channels<=4);
    GLuint& texid = reinterpret_cast<GLuint&>(imtexid);
    if (texid==0) glGenTextures(1, &texid);
    glBindTexture(GL_TEXTURE_2D, texid);
    GLenum clampEnum = 0x2900;    // 0x2900 -> GL_CLAMP; 0x812F -> GL_CLAMP_TO_EDGE
#   ifndef GL_CLAMP
#       ifdef GL_CLAMP_TO_EDGE
        clampEnum = GL_CLAMP_TO_EDGE;
#       else //GL_CLAMP_TO_EDGE
        clampEnum = 0x812F;
#       endif // GL_CLAMP_TO_EDGE
#   else //GL_CLAMP
    clampEnum = GL_CLAMP;
#   endif //GL_CLAMP
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,wraps ? GL_REPEAT : clampEnum);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,wrapt ? GL_REPEAT : clampEnum);
    //const GLfloat borderColor[]={0.f,0.f,0.f,1.f};glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,borderColor);
    if (gTextureFilteringHintMagFilterNearest) glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    else glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    if (useMipmapsIfPossible)   {
#       ifdef NO_IMGUI_OPENGL_GLGENERATEMIPMAP
#           ifndef GL_GENERATE_MIPMAP
#               define GL_GENERATE_MIPMAP 0x8191
#           endif //GL_GENERATE_MIPMAP
        // I guess this is compilable, even if it's not supported:
        glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);    // This call must be done before glTexImage2D(...) // GL_GENERATE_MIPMAP can't be used with NPOT if there are not supported by the hardware of GL_ARB_texture_non_power_of_two.
#       endif //NO_IMGUI_OPENGL_GLGENERATEMIPMAP
    }
    if (gTextureFilteringHintMinFilterNearest) glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, useMipmapsIfPossible ? GL_LINEAR_MIPMAP_NEAREST : GL_NEAREST);
    else glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, useMipmapsIfPossible ? GL_LINEAR_MIPMAP_LINEAR : GL_LINEAR);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    GLenum luminanceAlphaEnum = 0x190A; // 0x190A -> GL_LUMINANCE_ALPHA [Note that we're FORCING this definition even if when it's not defined! What should we use for 2 channels?]
#   ifdef GL_LUMINANCE_ALPHA
    luminanceAlphaEnum = GL_LUMINANCE_ALPHA;
#   endif //GL_LUMINANCE_ALPHA

    const GLenum ifmt = channels==1 ? GL_ALPHA : channels==2 ? luminanceAlphaEnum : channels==3 ? GL_RGB : GL_RGBA;  // channels == 1 could be GL_LUMINANCE, GL_ALPHA, GL_RED ...
    const GLenum fmt = ifmt;
    glTexImage2D(GL_TEXTURE_2D, 0, ifmt, width, height, 0, fmt, GL_UNSIGNED_BYTE, pixels);

#       ifndef NO_IMGUI_OPENGL_GLGENERATEMIPMAP
    if (useMipmapsIfPossible) glGenerateMipmap(GL_TEXTURE_2D);
#       endif //NO_IMGUI_OPENGL_GLGENERATEMIPMAP
}
void ImImpl_ClearColorBuffer(const ImVec4& bgColor)  {
    glClearColor(bgColor.x,bgColor.y,bgColor.z,bgColor.w);
    glClear(GL_COLOR_BUFFER_BIT);
}

void ImImpl_FlipTexturesVerticallyOnLoad(bool flag_true_if_should_flip)   {
    stbi_set_flip_vertically_on_load(flag_true_if_should_flip);
}

ImTextureID ImImpl_LoadTextureFromMemory(const unsigned char* filenameInMemory,int filenameInMemorySize,int req_comp,bool useMipmapsIfPossible,bool wraps,bool wrapt)  {
    int w,h,n;
    unsigned char* pixels = stbi_load_from_memory(filenameInMemory,filenameInMemorySize,&w,&h,&n,req_comp);
    if (!pixels) {
        fprintf(stderr,"Error: can't load texture from memory\n");
        return 0;
    }
    if (req_comp>0 && req_comp<=4) n = req_comp;

    ImTextureID texId = NULL;
    ImImpl_GenerateOrUpdateTexture(texId,w,h,n,pixels,useMipmapsIfPossible,wraps,wrapt);

    stbi_image_free(pixels);

    return texId;
}

extern void* ImLoadFileToMemory(const char* filename, const char* file_open_mode, int* out_file_size, int padding_bytes);

ImTextureID ImImpl_LoadTexture(const char* filename, int req_comp, bool useMipmapsIfPossible, bool wraps, bool wrapt)  {
    // We avoid using stbi_load(...), because we support UTF8 paths under Windows too.
    int file_size = 0;
    unsigned char* file = (unsigned char*) ImLoadFileToMemory(filename,"rb",&file_size,0);
    ImTextureID texId = NULL;
    if (file)   {
        texId = ImImpl_LoadTextureFromMemory(file,file_size,req_comp,useMipmapsIfPossible,wraps,wrapt);
        ImGui::MemFree(file);file=NULL;
    }
    return texId;
}



