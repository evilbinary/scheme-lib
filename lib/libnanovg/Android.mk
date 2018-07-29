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

SCM=$(LOCAL_PATH)/../libscm
3RD=$(LOCAL_PATH)/../3rdparty-arm/
3RD_GLFW=$(LOCAL_PATH)/../3rdparty-arm/glfw-android


LOCAL_MODULE    := nanovg
LOCAL_SRC_FILES :=   nanovg.c nanovg_gl.c

LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := $(SCM) $(3RD_GLFW)/include

LOCAL_CFLAGS += -I$(LOCAL_PATH)/ -I$(LOCAL_PATH)/../libgl/ -I$(3RD)/nanovg/src/
LOCAL_CFLAGS += -g -Wall -DANDROID  -DNANOVG_GLES2_IMPLEMENTATION \
                 -DINLINES  \
                 -DGC_MACROS  \
                 -fPIC -Wno-unused-parameter -pie -fPIE #-DGLAD \
                  #-DNANOVG_GLES2 \

LOCAL_LDLIBS += -ldl -llog -lz -lGLESv1_CM -lGLESv2

LOCAL_SHARED_LIBRARIES :=glfw

include $(BUILD_SHARED_LIBRARY)





