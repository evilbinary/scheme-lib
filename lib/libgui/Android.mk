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

LOCAL_MODULE    := gui
LOCAL_SRC_FILES :=   edit.c  fontstash.c  graphic.c mat4.c  shader.c stb_truetype.c utf8-utils.c

LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := $(SCM)

LOCAL_CFLAGS += -I$(SCHEME_TARGET)/ -I. -I./c/ -I$(SCM) -I$(LOCAL_PATH)/../libgl/
LOCAL_CFLAGS += -g -Wall -DANDROID  -DINLINES -DGC_MACROS -fPIC -Wno-unused-parameter -std=c99  -pie -fPIE #-DGLAD
LOCAL_LDLIBS += -ldl -llog -lz -lEGL -lGLESv1_CM -lGLESv2

LOCAL_SHARED_LIBRARIES :=libscm libgles
# LOCAL_MULTILIB := 32

#include $(BUILD_EXECUTABLE)
include $(BUILD_SHARED_LIBRARY)





