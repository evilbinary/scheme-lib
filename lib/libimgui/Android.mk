##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
include $(LOCAL_PATH)/../Optimizations.mk

ifeq ($(TARGET_ARCH),x86)
PLATFORM := androidx86
else
PLATFORM := android
endif


#cmd-strip :=

IMGUI= $(LOCAL_PATH)/imgui
CIMGUI= $(LOCAL_PATH)/cimgui
SCM=$(LOCAL_PATH)/../libscm

LOCAL_MODULE    := imgui
LOCAL_SRC_FILES := imgui_impl_gl.cpp \
    $(IMGUI)/imgui.cpp \
    $(IMGUI)/imgui_draw.cpp \
    $(IMGUI)/imgui_demo.cpp \
    $(CIMGUI)/cimgui.cpp \
    $(CIMGUI)/drawList.cpp \
    $(CIMGUI)/fontAtlas.cpp \
    main.cpp    \
    keyboard.cpp \
    addons/imguistyleserializer/imguistyleserializer.cpp \




LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := imgui -I$(SCM) addons


LOCAL_CFLAGS +=  -I. -I./c/ -I$(IMGUI)  -I$(SCM) -Iaddons -I$(LOCAL_PATH)/addons/imguistyleserializer 
LOCAL_CXXFLAGS+= -I. -I./c/ -I$(IMGUI) -I$(SCM) -DANDROID -std=c++11 \
    -I$(LOCAL_PATH)/addons/ -I$(LOCAL_PATH)/addons/imguistyleserializer

LOCAL_CFLAGS += -g -Wall -DANDROID   -DINLINES -DGC_MACROS -fPIC -Wno-unused-parameter -pie -fPIE  -fpermissive -std=c++11

LOCAL_LDLIBS += -ldl -llog -lz  -lGLESv1_CM -lGLESv2

LOCAL_SHARED_LIBRARIES :=libscm


include $(BUILD_SHARED_LIBRARY)





