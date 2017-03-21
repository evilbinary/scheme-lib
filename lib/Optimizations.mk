##########################################################
# Copyright 2016-2080 evilbinary.
#作者:evilbinary on 12/24/16.
#邮箱:rootdebug@163.com
##########################################################
$(info "############Optimizations###########")
$(info $(TARGET_ARCH) $(APP_PLATFORM))

ifeq ($(TARGET_ARCH),arm)
    #LOCAL_CFLAGS +=  -mfpu=vfp -mfloat-abi=softfp -O2 -Os -fno-strict-aliasing -fno-fast-math   #-fno-short-enums -O3 -Os
    #-O3 -mfloat-abi=softfp -mfpu=neon -ftree-vectorize
    #LOCAL_CFLAGS+=  -mfloat-abi=softfp
    #LOCAL_CFLAGS += -mfloat-abi=hard  #-mfpu=vfp
    #LOCAL_ARM_NEON := true
    #LOCAL_CFLAGS+=   -march=armv7-a -mfloat-abi=hard -mfpu=neon -marm -mthumb-interwork

    $(info "target arch is arm")
else ifeq ($(TARGET_ARCH),armeabi-v7a)
    #LOCAL_CFLAGS += -mfpu=neon -mfloat-abi=softfp  #-O3 -Os  -fno-short-enums
    #LOCAL_CFLAGS += -mfloat-abi=hard #-mfpu=vfp
    #LOCAL_ARM_NEON := true

endif

