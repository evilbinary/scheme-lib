LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
include Optimizations.mk

ifeq ($(TARGET_ARCH),x86)
PLATFORM := androidx86
else
PLATFORM := android
endif

LOCAL_MODULE    := scm

LOCAL_SRC_FILES := libscm.so

#include $(BUILD_EXECUTABLE)
#include $(BUILD_SHARED_LIBRARY)
#include $(BUILD_MULTI_PREBUILT)
include $(PREBUILT_SHARED_LIBRARY)








