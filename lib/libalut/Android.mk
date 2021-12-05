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
SCM=$(LOCAL_PATH)/../libscm

LOCAL_MODULE    := alut
LOCAL_SRC_FILES :=  al.c alut.c

LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES := $(LOCAL_PATH) \
                    $(LOCAL_PATH)/include $(SCM)  \
                    $(3RD)/include  $(3RD)/openal/openal/ \
                    $(3RD)/freealut/include

LOCAL_CFLAGS += -g -Wall -DANDROID   -DINLINES -DGC_MACROS -fPIC -Wno-unused-parameter -pie -fPIE
LOCAL_LDLIBS += -ldl -llog -lz -lOpenSLES

LOCAL_WHOLE_STATIC_LIBRARIES:= libalut_static


include $(BUILD_SHARED_LIBRARY)





