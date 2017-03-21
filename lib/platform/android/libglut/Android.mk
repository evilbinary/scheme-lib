##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
include Optimizations.mk

ifeq ($(TARGET_ARCH),x86)
PLATFORM := androidx86
else
PLATFORM := android
endif


LOCAL_MODULE :=glut

LOCAL_SRC_FILES := libglut.so
LOCAL_SHARED_LIBRARIES :=libscm

#include $(BUILD_MULTI_PREBUILT)
#include $(BUILD_EXECUTABLE)
#include $(BUILD_SHARED_LIBRARY)
include $(PREBUILT_SHARED_LIBRARY)





