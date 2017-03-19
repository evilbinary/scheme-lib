/********************************************************
* Copyright 2016-2080 evilbinary.
*作者:evilbinary on 12/24/16.
*邮箱:rootdebug@163.com
********************************************************/
#ifdef GLAD

#include "glut.h"
#include "glad/glad.h"
#include "glfw.h"

#else
#include <GL/glut.h>
#endif

#include <imgui.h>
#include "imgui_impl_gl.h"
#include <stdio.h>

extern double g_Time ;
extern bool g_MousePressed[3] = {false, false, false};
extern GLuint g_FontTexture ;


void Imgui_ImplGLUT_KeyMap(ImGuiIO& io){
    io.KeyMap[ImGuiKey_Tab]        = 9;    // tab
    // io.KeyMap[ImGuiKey_LeftArrow]  = GLUT_KEY_LEFT;    // Left
    // io.KeyMap[ImGuiKey_RightArrow] = GLUT_KEY_RIGHT;   // Right
    // io.KeyMap[ImGuiKey_UpArrow]    = GLUT_KEY_UP;      // Up
    // io.KeyMap[ImGuiKey_DownArrow]  = GLUT_KEY_DOWN;    // Down
    // io.KeyMap[ImGuiKey_Home]       = GLUT_KEY_HOME;    // Home
    // io.KeyMap[ImGuiKey_End]        = GLUT_KEY_END;     // End
    // io.KeyMap[ImGuiKey_Delete]     = 127;  // Delete
    io.KeyMap[ImGuiKey_Backspace]  = 8;    // Backspace
    io.KeyMap[ImGuiKey_Enter]      = 13;   // Enter
    // io.KeyMap[ImGuiKey_Escape]     = 27;  // Escape
    // io.KeyMap[11]                  = 1;   // ctrl-A
    // io.KeyMap[12]                  = 3;   // ctrl-C
    // io.KeyMap[13]                  = 22;  // ctrl-V
    // io.KeyMap[14]                  = 24;  // ctrl-X
    // io.KeyMap[15]                  = 25;  // ctrl-Y
    // io.KeyMap[16]                  = 26;  // ctrl-Z
}

void ImGui_ImplGlut_SpecialCallback(int key){
  printf("ImGui_ImplGlut_SpecialCallback\n");
   ImGuiIO& io = ImGui::GetIO();
   io.KeysDown[key] = true;

   int mods = glutGetModifiers();
   io.KeyCtrl = (mods & GLUT_ACTIVE_CTRL) != 0;
   io.KeyShift = (mods & GLUT_ACTIVE_SHIFT) != 0;
   io.KeyAlt = (mods & GLUT_ACTIVE_ALT) != 0;
}

void ImGui_ImplGlut_SpecialUpCallback(int key){
   ImGuiIO& io = ImGui::GetIO();
   io.KeysDown[key] = false;
  printf("ImGui_ImplGlut_SpecialUpCallback\n");

   int mods = glutGetModifiers();
   io.KeyCtrl = (mods & GLUT_ACTIVE_CTRL) != 0;
   io.KeyShift = (mods & GLUT_ACTIVE_SHIFT) != 0;
   io.KeyAlt = (mods & GLUT_ACTIVE_ALT) != 0;
}

void ImGui_ImplGLUT_MouseButtonCallback(int button, int state){
   ImGuiIO& io = ImGui::GetIO();
   if (state == GLUT_DOWN && button >= 0 && button < 3)
   {
      g_MousePressed[button] = true;
      io.MouseDown[button] = true;
   }

   if (state == GLUT_UP && button >= 0 && button < 3)
   {
      g_MousePressed[button] = false;
      io.MouseDown[button] = false;
   }

   //freeglut is mapping mousewheel to buttons 3 and 4
   if(state == GLUT_DOWN && button == 3){
      ImGui_ImplGL_ScrollCallback(0,+1.0f);
   }

   if(state == GLUT_DOWN && button == 4)
   {
      ImGui_ImplGL_ScrollCallback(0,-1.0f);
   }
}

void ImGui_ImplGLUT_RenderDrawLists(ImDrawData* draw_data)
{
    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    ImGuiIO& io = ImGui::GetIO();
    int fb_width = (int)(io.DisplaySize.x * io.DisplayFramebufferScale.x);
    int fb_height = (int)(io.DisplaySize.y * io.DisplayFramebufferScale.y);
    if (fb_width == 0 || fb_height == 0)
        return;
    draw_data->ScaleClipRects(io.DisplayFramebufferScale);


    // We are using the OpenGL fixed pipeline to make the example code simpler to read!
    // Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, vertex/texcoord/color pointers.
    GLint last_texture; glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
    GLint last_viewport[4]; glGetIntegerv(GL_VIEWPORT, last_viewport);


    //glEnable(GL_MULTISAMPLE);
    glPushAttrib(GL_ENABLE_BIT | GL_COLOR_BUFFER_BIT | GL_TRANSFORM_BIT);

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


    //printf("ImGui_ImplGLUT_RenderDrawLists6 %d %d\n",fb_width,fb_height);

    // Setup viewport, orthographic projection matrix
    glViewport(0, 0, (GLsizei)fb_width, (GLsizei)fb_height);
    glMatrixMode(GL_PROJECTION);


    glPushMatrix();
    
    //printf("ImGui_ImplGLUT_RenderDrawLists8 %f %f\n",io.DisplaySize.x,io.DisplaySize.y);

    glLoadIdentity();

    glOrtho( 0.0 , io.DisplaySize.x,io.DisplaySize.y,0.0f, - 1.0 , 1.0 );
    // glOrthof(0.0f, io.DisplaySize.x,io.DisplaySize.y, 0.0f, -1.0f, +1.0f);

    glMatrixMode(GL_MODELVIEW);

    glPushMatrix();
    glLoadIdentity();

    // Render command lists
    #define OFFSETOF(TYPE, ELEMENT) ((size_t)&(((TYPE *)0)->ELEMENT))
    for (int n = 0; n < draw_data->CmdListsCount; n++)
    {
        const ImDrawList* cmd_list = draw_data->CmdLists[n];
        const unsigned char* vtx_buffer = (const unsigned char*)&cmd_list->VtxBuffer.front();
        const ImDrawIdx* idx_buffer = &cmd_list->IdxBuffer.front();
        glVertexPointer(2, GL_FLOAT, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, pos)));
        glTexCoordPointer(2, GL_FLOAT, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, uv)));
        glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(ImDrawVert), (void*)(vtx_buffer + OFFSETOF(ImDrawVert, col)));

        for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.size(); cmd_i++)
        {
            const ImDrawCmd* pcmd = &cmd_list->CmdBuffer[cmd_i];
            if (pcmd->UserCallback)
            {
                pcmd->UserCallback(cmd_list, pcmd);
            }
            else
            {
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
    glPopAttrib();
    glViewport(last_viewport[0], last_viewport[1], (GLsizei)last_viewport[2], (GLsizei)last_viewport[3]);
}