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

3RD=$(LOCAL_PATH)/../3rdparty-arm/

LOCAL_MODULE    := cc
LOCAL_SRC_FILES :=   c.c

LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := $(SCM)  $(3RD)/include -L$(3RD)/lib/

LOCAL_CFLAGS += -g -Wall -DANDROID   -DINLINES -DGC_MACROS -fPIC -Wno-unused-parameter -pie -fPIE
LOCAL_LDLIBS += -ldl -llog -lz

include $(BUILD_SHARED_LIBRARY)





