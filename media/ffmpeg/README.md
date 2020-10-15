# FFmpeg (Fast Forward Moving Picture Expert Group 动态图像专家组)

开源跨平台多媒体库，提供录制、转换、以及流化视频的完整解决方案。既可以作为音视频处理工具使用，由于开发源代码，也可以作为音视频处理的开发组件。

FFmpeg 的历史：

FFmpeg 最初由法国程序员 Fabrice Bellard 在 2000 年的时开发出初版。2004 年 Michael Niedermayer 开始接手项目，并未其添加路径子系统 libavfilter，使得项目功能更加完善。

FFmpeg 包含几部分：

av: audio 和 video 的缩写。

- 组件
- 开发库
    - libavformat： 实现了绝大多数多媒体格式的封装、解封装。如 MP4、FLV、KV、TS等文件格式封装，RTMP,RTSP,MMS,HLS等网络协议封装格式。具体可以在编译是配置，还可以扩展自己的封装格式。
    - libavutil: 其它库用到的工具库。
    - libswscale：图像缩放或者像素格式转换。
    - libswresample：允许操作音频重采样，音频通道布局转换、布局调整。
    - libavcodec：实现了绝大多数的编解码格式，如 MPEG4,JPG,MJPEG,三方编码 H.264(AVC), H.265(HEVC), mp3(mp2lame)。一些具有版权的编解码没有支持，但是得益于良好的封装，可以快速添加扩展，一些具有版权的编解码厂商也会实现用于 ffmpeg 的插件。
    - libavdevice：输入设备，操作摄像头等视频设备 , Android 中是不支持该操作, 需要手动关闭; 输出设备，如屏幕，如果要编译播放视频的 ffplay 工具，就需要依赖该模块。该设备模块播放声音和视频都又依赖 libsdl 模块。
    - libavfilter: 通用的音频、视频、字幕滤镜处理系统。
    - libpostproc: 该模块用于进行后期处理，当我们使用filter的时候，需要打开这个模块，filter会用到这个模块的一些基础函数。

- 命令行工具: 开发库之上构建的应用。
    - ffmpeg: 转封装，转码
    - ffplay：播放器（使用的是 avformat,avcodec）
    - ffprob: 多媒体分析工具。可以获取音视频的参数，媒体容器的参数等，媒体时长，符合码率等。


## 编译

C/C++ 的编译分为编译，链接两部分。如果是作为函数调用，编译为 `.so` 动态链接库就可以了，但是如果想要运行，需要链接为相应的可运行程序。

### 主机编译

要在当前平台编辑并使用 ffmpeg. 可以编译生成最新版本的应用。C/C++ 开源库都会提供一个 configure 的 shell 脚本, 用于生成编译的 Makefile文件。该脚本的配置非常复杂, 但一般都提供一个帮助选项。

常规的安装只需要执行

```bash
./configure
make
make install
``` 
即可完成安装。但是仅包含基础的功能，有一些功能并没有默认开启，要做一些定制，需要使用 configure 进行配置。

```bash
./configure --help
```

```
Help options: 帮助指令
...
Standard options: 标准配置
...
Configuration options:
...

Program options: 不生成命令行应用
...

Documentation options: 不生成文档
...

Component options: 不生成组件
...

Individual component options: 关闭默认开启的一些编码、封装或者协议。

External library support: 扩展库
...
```

支持或者屏蔽这些功能的方法很简单，只需要将 help 列出的关键字以空格分割的形式列到指令的后面即可。

```
./configure --disable-encoders --enable-libx264
```

### 交叉编译

交叉编译是在一个平台上生成另一个平台上的可执行代码。很显然，要在 linux 编译在 android 系统使用的 so 库就属于交叉编译。虽然安卓也是 linux 内核，但是平台是 ARM，要编译成 ARM 指令的可执行二进制文件。

交叉编译主要配置使用的编译器，连接器，编译链接的目标平台（CPU架构）依赖库等。

- 编译器：
    - NDK17 开始，`make_standalone_toolchain.py` 用于替换之前的 `make-standalone-toolchain.sh` 用于在 windows 不用配置 bash 环境也能编译，但是实际情况是许多使用 `Autoconf` 配置编译的三方库仍旧无法在 Windows 上编译。 

    - 从 NDK 19 开始，NDK 中默认带有 `toolchains` 可供使用，与任意构建系统进行交互时不再需要使用 `make_standalone_toolchain.py` 脚本。如果是 NDK 19 之前的版本，请查看 [NDK 18 及之前编译](https://developer.android.com/ndk/guides/standalone_toolchain)。
    
    - NDK 17 开始默认使用 clang 作为编译器， NDK18 删除了 gcc, 只提供了 clang 的编译器。

    - 综上，现在编译三方库的最佳方式是使用 NDK `toolchain` 目录中的编译器工具链和平台库。使用 `gcc` 和 `make_standalone_toolchain.py` 等生成编译链的做法都是较陈旧的做法。

- 配置：
    - 常用的配置方法


配置编译过程不同的项目有不同的做法，流程的做法是使用 `autoconf` 的 configure 配置，或者配置环境变量，执行 `Makefile`。 FFmpeg 是使用 `autoconf` 进行配置，但是由于要配置的 `configure` 参数比较多，一不小心就会配置错误，或者需要多次修改，更方便的做法是再编写一个 shell 脚本文件，制定调用 configure 的参数并执行。

调整 configure 的参数主要用于对编译进行调整，例如对编译器的优化等级进行配置，对运行目标平台进行设置，对编辑软件进行剪裁，只包含使用到的部分，其他功能的模块不编译，从而减小包体积。对于 ffmpeg 来说，如果想要使用 lib 库，可以只编译 lib 开发库，如果想要使用指令的方式运行，就不能屏蔽 `ffmpeg`, `fplay` 等命令行工具。

### 编译 x264

创建 `.sh` 结尾的脚本文件, 如`make_x264.sh`，添加执行权限。 脚本中已经内置了下载 x264 方式，但是要确保 git 命令可用。

[查看 make_x264.sh](make_x264.sh)

遗留问题：x86 平台编译不成功，会导致 ffmpeg 的对应版本也无法编译 x86 版本。不影响使用，因为该版本主要用于虚拟机。错误信息:

```
/base.o: relocation R_386_GOTOFF against preemptible symbol x264_log_default cannot be used when making a shared object
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

编译 ffmpeg

[查看 make_ffmpeg.sh](make_ffmpeg.sh)

#### 问题处理

```
toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi16-clang is unable to create an executable file.
C compiler test failed.
```

`confiure` 指令要指定 `--cpu=` 参数，并且要严格按照下面的字符串对应，例如，不能将 `armv7-a` 写成 `armabiv7-a`

```
CPUS=(
    armv7-a
    arm64-v8a
    x86
    x86_64
)
```

> GNU assembler not found

```
GNU assembler not found, install/update gas-preprocessor

If you think configure made a mistake, make sure you are using the latest
version from Git.  If the latest version fails, report the problem to the
ffmpeg-user@ffmpeg.org mailing list or IRC #ffmpeg on irc.freenode.net.
Include the log file "ffbuild/config.log" produced by configure as this will help
solve the problem.
```

这是是 `--as=$AS` 参数引起的问题，应该是调用了系统的汇编程序，但是没找到，安装一下就好了。或者给 `./configure` 添加 `--disable-asm` 参数禁用汇编优化。

> error: undefined reference to

```
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_idivmod'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_d2ulz'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_ul2f'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_uidivmod'
libavfilter/libavfilter.so: error: undefined reference to '__aeabi_uidiv'
libavcodec/libavcodec.so: error: undefined reference to '__aeabi_f2ulz'
fftools/cmdutils.o:cmdutils.c:function parse_number_or_die: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function parse_number_or_die: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function write_option: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function opt_timelimit: error: undefined reference to '__aeabi_d2lz'
fftools/cmdutils.o:cmdutils.c:function opt_timelimit: error: undefined reference to '__aeabi_l2d'
fftools/cmdutils.o:cmdutils.c:function grow_array: error: undefined reference to '__aeabi_idiv'
fftools/ffmpeg_opt.o:ffmpeg_opt.c:function open_output_file: error: undefined reference to '__aeabi_f2lz'
fftools/ffmpeg_opt.o:ffmpeg_opt.c:function opt_target: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function main: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function main: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_uldivmod'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function transcode: error: undefined reference to '__aeabi_l2f'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_uldivmod'
fftools/ffmpeg.o:ffmpeg.c:function print_report: error: undefined reference to '__aeabi_ul2d'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
fftools/ffmpeg.o:ffmpeg.c:function process_input_packet: error: undefined reference to '__aeabi_ldivmod'
```

应该是额外的链接参数引起的 `extra_ldflags="-nostdlib -lc"` 并且设置了 `--as=$AS` 但是提示 `GNU assembler not found`。禁用汇编优化就好了 `--disable-asm`。
 
## 集成到 Android Studio

新建一个 Module，选择 Android Library。 然后在新建文件，也可以从新建的 JNI 项目中拷贝过来。

```
# srm/main/cpp/CMakelists.txt

# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
             native-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             native-lib.cpp )

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
              log-lib

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib} )
```

修改 module 的 gradle, 添加

```
android {
        ...
    defaultConfig {
        ...
        externalNativeBuild {
            cmake {
                cppFlags ""
            }
        }
    }

    ...
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.10.2"
        }
    }
    ndkVersion '21.3.6528147'
}

```

参考内容:

https://blog.csdn.net/thezprogram/article/details/100029831
https://juejin.im/post/6844904048303276045#heading-9

ffmpeg参数讲解 https://blog.csdn.net/shulianghan/article/details/104351312
https://blog.csdn.net/yu540135101/article/details/105183294/
