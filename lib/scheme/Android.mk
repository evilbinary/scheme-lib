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

#cmd-strip = $(TOOLCHAIN_PREFIX)strip $1
#cmd-strip = $(TOOLCHAIN_PREFIX)strip --strip-debug -x $1


SCHEME_TARGET=arm32le
SCHEME_LIB=$(LOCAL_PATH)/../libchez

LOCAL_MODULE    := scheme
#LOCAL_PATH := $(LOCAL_PATH)
LOCAL_SRC_FILES :=   main.c

LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := $(SCHEME_LIB)/$(SCHEME_TARGET)/

LOCAL_CFLAGS += -I$(SCHEME_TARGET)/ -I. -I./c/
LOCAL_CFLAGS += -g -Wall -DANDROID    -DINLINES -DGC_MACROS   -Wno-unused-parameter -pie -fPIE   -fPIC

LOCAL_LDLIBS += -ldl -llog -lz


LOCAL_STATIC_LIBRARIES := chez



#include $(BUILD_EXECUTABLE)
#include $(BUILD_SHARED_LIBRARY)





