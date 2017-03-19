/********************************************************
* Copyright 2016-2080 evilbinary.
*作者:evilbinary on 12/24/16.
*邮箱:rootdebug@163.com
********************************************************/
#ifdef GLAD
  #include "glad/glad.h"
  #include "glfw.h"
  #include "glut.h"
#else

#include <GLES/gl.h>
#include <GLES2/gl2.h>

#include <GLES/glext.h>
#include <GLES2/gl2ext.h>

#endif
#include <imgui.h>


#if ANDROID

#ifndef  LOG_TAG
#define  LOG_TAG    "native-scm"
#endif

#include <android/log.h>

#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO,LOG_TAG , __VA_ARGS__))
#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define LOGV(...) ((void)__android_log_print(ANDROID_LOG_VERBOSE, LOG_TAG, __VA_ARGS__))
#else

#define LOGI(...)  fprintf(stdout,__VA_ARGS__);fprintf(stdout, "\n");fflush(stdout)
#define LOGW(...)  fprintf(stdout,__VA_ARGS__);fprintf(stdout, "\n");fflush(stdout)
#define LOGE(...)  fprintf(stdout,__VA_ARGS__);fprintf(stdout, "\n");fflush(stdout)


#endif

IMGUI_API bool        ImGui_ImplGL_Init();
IMGUI_API void        ImGui_ImplGL_Shutdown();
IMGUI_API void        ImGui_ImplGL_NewFrame();

// Use if you want to reset your rendering device without losing ImGui state.
IMGUI_API void        ImGui_ImplGL_InvalidateDeviceObjects();
IMGUI_API bool        ImGui_ImplGL_CreateDeviceObjects();

// Provided here if you want to chain callbacks.
// You can also handle inputs yourself and use those as a reference.

IMGUI_API void        ImGui_ImplGL_MouseButtonCallback(int button, int action);
IMGUI_API void        ImGui_ImplGL_TouchCallback(int type, int x, int y);
IMGUI_API void        ImGui_ImplGL_ResizeCallback(int w, int h);
IMGUI_API void        ImGui_ImplGL_SetScale(float x,float y);

IMGUI_API void        ImGui_ImplGL_MouseMotionCallback(int x,int y);

IMGUI_API void        ImGui_ImplGL_ScrollCallback( double xoffset, double yoffset);
IMGUI_API void        ImGui_ImplGL_KeyCallback( int type, int key,int ch,char* chars);
IMGUI_API void        ImGui_ImplGL_CharCallback( unsigned int c);


IMGUI_API ImTextureID ImImpl_LoadTexture(const char* filename,int req_comp=0,bool useMipmapsIfPossible=false,bool wraps=true,bool wrapt=true);

