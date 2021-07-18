# 作为组件使用时遇到的问题。

> 链接问题

无法找到 `CreatePeerConnectionFactory`

```
C/C++: ld: error: undefined symbol: webrtc::CreatePeerConnectionFactory(rtc::Thread*, rtc::Thread*, rtc::Thread*, rtc::scoped_refptr<webrtc::AudioDeviceModule>, rtc::scoped_refptr<webrtc::AudioEncoderFactory>, rtc::scoped_refptr<webrtc::AudioDecoderFactory>, std::__ndk1::unique_ptr<webrtc::VideoEncoderFactory, std::__ndk1::default_delete<webrtc::VideoEncoderFactory> >, std::__ndk1::unique_ptr<webrtc::VideoDecoderFactory, std::__ndk1::default_delete<webrtc::VideoDecoderFactory> >, rtc::scoped_refptr<webrtc::AudioMixer>, rtc::scoped_refptr<webrtc::AudioProcessing>, webrtc::AudioFrameProcessor*)
```

通过 nm 工具查看 `libwebrtc.a` 中是否包含该函数

```
$ nm --demangle out/arm64/libwebrtc.a | grep -i webrtc::CreatePeerConnectionFactory

webrtc::CreatePeerConnectionFactory(rtc::Thread*, rtc::Thread*, rtc::Thread*, rtc::scoped_refptr<webrtc::AudioDeviceModule>, rtc::scoped_refptr<webrtc::AudioEncoderFactory>, rtc::scoped_refptr<webrtc::AudioDecoderFactory>, std::__1::unique_ptr<webrtc::VideoEncoderFactory, std::__1::default_delete<webrtc::VideoEncoderFactory> >, std::__1::unique_ptr<webrtc::VideoDecoderFactory, std::__1::default_delete<webrtc::VideoDecoderFactory> >, rtc::scoped_refptr<webrtc::AudioMixer>, rtc::scoped_refptr<webrtc::AudioProcessing>, webrtc::AudioFrameProcessor*)
```
发现确实有，不过其中的的参数是 `std::__1`，而不是 `std::__ndk1`，webrtc 从 M74 版本开始默认的编译变成了 `std::__1`。可以增加 `use_custom_libcxx=false` 参数使 webrtc 构建使用 `std::__ndk1` 命名空间。
```
gn gen out/arm --args='target_os="android" target_cpu="arm" use_custom_libcxx=false'
```

安卓 NDK 已将libc++的内联命名空间更改为std::__ ndk1，以防止平台libc++发生ODR问题。
```
https://groups.google.com/g/discuss-webrtc/c/6s1Tk99Z9Pw/m/4Gs-9VVZAgAJ
https://chromium.googlesource.com/chromium/src/+/refs/heads/main/build/config/c++/c++.gni
```


> 缺少 `OpenSLES`

```
ld: error: undefined symbol: SL_IID_RECORD
>>> referenced by opensles_recorder.cc:287 (../../modules/audio_device/android/opensles_recorder.cc:287)
>>>               opensles_recorder.o:(webrtc::OpenSLESRecorder::CreateAudioRecorder()) in archive /Users/albert/project/android/AndroidTest/app/rtc_demo_native/src/main/cpp/lib/arm64-v8a/libwebrtc.a
>>> referenced by opensles_recorder.cc:287 (../../modules/audio_device/android/opensles_recorder.cc:287)
>>>               opensles_recorder.o:(webrtc::OpenSLESRecorder::CreateAudioRecorder()) in archive /Users/albert/project/android/AndroidTest/app/rtc_demo_native/src/main/cpp/lib/arm64-v8a/libwebrtc.a
clang++: error: linker command failed with exit code 1 (use -v to see invocation)
ninja: build stopped: subcommand failed.
```

在链接配置 `target_link_libraries` 中添加 `OpenSLES`

```
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.
target_link_libraries( # Specifies the target library.
        rtc_demo
        ${OPENGL_LIB}
        android
        native_app_glue
        webrtc
        EGL
        GLESv3
        OpenSLES
        ${camera-lib}
        ${media-lib}
        ${log-lib})
```

> 缺少 rtc_bash 中的 json 格式化函数

修改 src/BUILD.gn
```gn
if (!build_with_chromium) {
  # Target to build all the WebRTC production code.
  rtc_static_library("webrtc") {
    ...
    deps = [
      ...
      "rtc_base:rtc_json", # 添加依赖
    ]
    ...
  }
}

```

或者也可以打开 webrtc 的 `RTTI` 功能，在 gn 中增加参数 `use_rtti=true` 。

```
use_rtti
    Current value (from the default) = false
      From //build/config/compiler/BUILD.gn:74

    Build with C++ RTTI enabled. Chromium builds without RTTI by default,
    but some sanitizers are known to require it, like CFI diagnostics
    and UBsan variants.
```

```
gn gen out/arm64 --args='target_os="android" target_cpu="arm64" use_custom_libcxx=false  android_full_debug=true symbol_level=2 use_rtti=true'
```

> 带调试信息

```
gn gen out/arm64 --args='target_os="android" target_cpu="arm64" use_custom_libcxx=false  android_full_debug=true symbol_level=2'
```

>  undefined reference to `typeinfo for XXX`

```
CMakeFiles/rtc_demo.dir/peer/android_video_frame_buffer.cpp.o:(.data.rel.ro._ZTIN8rtc_demo23AndroidVideoFrameBufferE+0x10): undefined reference to `typeinfo for webrtc::VideoFrameBuffer'
...
```

这是由于 webrtc 部分组件使用 `-fno-rtti` 禁用了 rtti，我们无法使用这些运行时信息，为了避免错误，添加编译参数。


```
android {
    defaultConfig {
        externalNativeBuild {
            cmake {
                cppFlags '-fno-rtti'
            }
        }
    }
    ...
}
```


> [C++ 17 中 std::string_view 赋值给 absl::string_view 错误](https://github.com/envoyproxy/envoy/issues/12341)


```C++
undefined reference to `rtc::PlatformThread::PlatformThread(void (*)(void*), void*, std::__ndk1::basic_string_view<char, std::__ndk1::char_traits<char> >, rtc::ThreadAttributes)
```

配置不生效，应该是 Webrtc 还没有给出配置接口，将自己项目中的 C++ 版本由 17 降为 14 就好了。

## 最终

```
gn gen out/arm64 --args='target_os="android" target_cpu="arm64" use_custom_libcxx=false  android_full_debug=true symbol_level=2 use_rtti=true'
```