/********************************************************
* Copyright 2016-2080 evilbinary.
*作者:evilbinary on 12/24/16.
*邮箱:rootdebug@163.com
********************************************************/

#include <GLES/gl.h>
#include <GLES2/gl2.h>

#include <GLES/glext.h>
#include <GLES2/gl2ext.h>

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
#define LOGI(...)  fprintf(stdout,__VA_ARGS__)
#define LOGW(...)  fprintf(stdout,__VA_ARGS__)
#define LOGE(...)  fprintf(stdout,__VA_ARGS__)

#endif

IMGUI_API bool        ImGui_ImplAndroid_Init();
IMGUI_API void        ImGui_ImplAndroid_Shutdown();
IMGUI_API void        ImGui_ImplAndroid_NewFrame();

// Use if you want to reset your rendering device without losing ImGui state.
IMGUI_API void        ImGui_ImplAndroid_InvalidateDeviceObjects();
IMGUI_API bool        ImGui_ImplAndroid_CreateDeviceObjects();

// Provided here if you want to chain callbacks.
// You can also handle inputs yourself and use those as a reference.

IMGUI_API void        ImGui_ImplAndroid_MouseButtonCallback(int button, int action, int mods);
IMGUI_API void        ImGui_ImplAndroid_TouchCallback(int type, int x, int y);
IMGUI_API void        ImGui_ImplAndroid_ResizeCallback(int w, int h);
IMGUI_API void        ImGui_ImplAndroid_SetScale(float x,float y);

IMGUI_API void        ImGui_ImplAndroid_ScrollCallback( double xoffset, double yoffset);
IMGUI_API void        ImGui_ImplAndroid_KeyCallback( int type, int key,int ch,char* chars);
IMGUI_API void        ImGui_ImplAndroid_CharCallback( unsigned int c);

