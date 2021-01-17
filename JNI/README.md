1. JNI 坑点

[添加多个与构建库。](https://developer.android.com/ndk/guides/prebuilts)

```makefile
LOCAL_PATH := $(call my-dir)

# 每个 so 文件都要独立定义一块，不能一次指定多个文件。
include $(CLEAR_VARS)
LOCAL_MODULE := engine_so # 不能一次指定多个文件。
LOCAL_SRC_FILES := ../../../../../libs/$(TARGET_ARCH_ABI)/libengine.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS) # 重置一些变量，否则路径可能不正确。
LOCAL_MODULE := ffmpeg_so
LOCAL_SRC_FILES := ../../../../../libs/$(TARGET_ARCH_ABI)/libffmpeg.so # 不重置变量会影响这里的路径。
include $(PREBUILT_SHARED_LIBRARY) # 导入
```

**即便声明了 so, 还要在声明依赖该 so 才能被打进包内。否则会被优化排除掉。**

```
LOCAL_SHARED_LIBRARIES := engine_so ffmpeg_so # 添加对与构建库的依赖才能被打进包中。
```

