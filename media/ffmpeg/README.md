# FFmpeg (Fast Forward Moving Picture Expert Group 动态图像专家组)

开源跨平台多媒体库，提供录制、转换、以及流化视频的完整解决方案。

FFmpeg 包含几部分：


- 组件
- 开发库
    - libavformat： 实现了绝大多数多媒体格式的封装、解封装。如 MP4、FLV、KV、TS等文件格式封装，RTMP,RTSP,MMS,HLS等网络协议封装格式。具体可以在编译是配置，还可以扩展自己的封装格式。
    - libavutil: 其它库用到的工具库。
    - libswscale：图像缩放或者像素格式转换
    - libswresample：允许操作音频采样，音频通道布局转换、布局调整。
    - libavcodec：实现了绝大多数的编解码格式，如 MPEG4,JPG,MJPEG,三方编码 H.264(AVC), H.265(HEVC), mp3(mp2lame),
    - libavdevice：操作摄像头等视频设备 , Android 中是不支持该操作, 需要手动关闭;
    - libavfilter: 通用的音频、视频、字幕滤镜处理系统。

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

    - 从 NDK 19 开始，NDK 中默认带有 `toolchains` 可供使用，与任意构建系统进行交互时不再需要使用 make_standalone_toolchain.py 脚本。如果是 NDK 19 之前的版本，请查看 [NDK 18 及之前编译](https://developer.android.com/ndk/guides/standalone_toolchain)。
    
    - NDK 17 开始默认使用 clang 作为编译器， NDK18 删除了 gcc, 只提供了 clang 的编译器。

    - 综上，现在编译三方库的最佳方式是使用 NDK `toolchain` 目录中的编译器工具链和平台库。使用 `gcc` 和 `make_standalone_toolchain.py` 等生成编译链的做法都是较陈旧的做法。

- 配置：
    - 常用的配置方法


配置编译过程不同的项目有不同的做法，流程的做法是使用 `autoconf` 的 configure 配置，或者配置环境变量，执行 `Makefile`。 FFmpeg 是使用 `autoconf` 进行配置，但是由于要配置的 `configure` 参数比较多，一不小心就会配置错误，或者需要多次修改，更方便的做法是再编写一个 shell 脚本文件，制定调用 configure 的参数并执行。

调整 configure 的参数主要用于对编译进行调整，例如对编译器的优化等级进行配置，对运行目标平台进行设置，对编辑软件进行剪裁，只包含使用到的部分，其他功能的模块不编译，从而减小包体积。对于 ffmpeg 来说，如果想要使用 lib 库，可以只编译 lib 开发库，如果想要使用指令的方式运行，就不能屏蔽 `ffmpeg`, `fplay` 等命令行工具。

可参考 https://blog.csdn.net/thezprogram/article/details/100029831

ffmpeg参数讲解 https://blog.csdn.net/shulianghan/article/details/104351312
https://blog.csdn.net/yu540135101/article/details/105183294/

### 编译 x264

创建 `.sh` 结尾的脚本文件，添加执行权限。

```shell
#!/bin/sh

NDK=$NDK_HOME

# NDK 编译环境，不同 OS 上要下载不同的 NDK，而这个文件夹是不同的。需要根据下载的 NDK 是运行在 Linux, Mac OS, Windows 上而配置不同的文件夹。
HOST_TAG=darwin-x86_64

TARGET=armv7a-linux-androideabi
TARGET_AL=arm-linux-androideabi
# export TARGET=aarch64-linux-android
# export TARGET=i686-linux-android
# export TARGET=x86_64-linux-android

# Set this to your minSdkVersion.
# 支持的最次版本
export API=16

export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

# Configure and build.
export AR=$TOOLCHAIN/bin/$TARGET_AL-ar
export AS=$TOOLCHAIN/bin/$TARGET_AL-as
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/$TARGET_AL-ld
export RANLIB=$TOOLCHAIN/bin/$TARGET_AL-ranlib
export STRIP=$TOOLCHAIN/bin/$TARGET_AL-strip
echo $CC
echo $CXX

# 该库使用到 arm-linux-androideabi-strings，可以通过在环境变量里添加查找路径让其能够找到命令。
PATH=$TOOLCHAIN/bin:$PATH


# 不使用 $NDK_HOME 下的 /sysroot/
SYSROOT=$TOOLCHAIN/sysroot/
# 可以不设置，但是设置必须是对应架构的，例如 arm-linux-androideabi-
CROSS_PREFIX=arm-linux-androideabi-

INSTALL_DIR=$(pwd)/x264-$TARGET

configure="--disable-cli \
           --enable-static \
           --enable-shared \
           --disable-opencl \
           --enable-strip \
           --disable-cli \
           --disable-win32thread \
           --disable-avs \
           --disable-swscale \
           --disable-lavf \
           --disable-ffms \
           --disable-gpac \
           --disable-lsmash"

extra_configure="--disable-asm"

#优化编译项
extra_cflags="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb -D__ANDROID__ -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -D__ARM_ARCH_7R__ -D__ARM_ARCH_7M__ -D__ARM_ARCH_7S__"
extra_ldflags="-nostdlib -lc"

cd ./x264

./configure    ${extra_configure} \
    --prefix=$INSTALL_DIR \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="${extra_cflags}" \
    --host=$TARGET_AL
# --host 指定成 armv7a-linux-androideabi 和 arm-linux-androideabi 都不出问题，应该是不设置也行。具体什么目录有关还没搞清楚。

# this link flage whill cause linker error.
#    --extra-ldflags="$extra_ldflags" \
make clean
make -j4
make install
```

```bash
#!/bin/bash

#!/bin/bash
export NDK=<ndk path>
# 当前系统
export HOST_TAG=linux-x86_64
# 支持的 Android CUP 架构
# export ARCH=aarch64
# export CPU=armv8-a
export ARCH=armv7a
export CPU=armv7-a
# 支持的 Android 最低系统版本
export MIN=21
export ANDROID_NDK_PLATFORM=android-21

export PREFIX=$(pwd)/android/$CPU

export MIN_PLATFORM=$NDK/platforms/android-$MIN
export SYSROOT=$NDK/sysroot
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
export AR=$TOOLCHAIN/bin/arm-linux-androideabi-ar
export AS=$TOOLCHAIN/bin/arm-linux-androideabi-as
export CC=$TOOLCHAIN/bin/$ARCH-linux-androideabi$MIN-clang
echo "-----------------------------"
echo $CC
export CXX=$TOOLCHAIN/bin/$ARCH-linux-androideabi$MIN-clang++
export LD=$TOOLCHAIN/bin/arm-linux-androideabi-ld
export NM=$TOOLCHAIN/bin/arm-linux-androideabi-nm
export RANLIB=$TOOLCHAIN/bin/arm-linux-androideabi-ranlib
export STRIP=$TOOLCHAIN/bin/arm-linux-androideabi-strip

OPTIMIZE_CFLAGS="-I/home/albert/ffmpeg/x264-master/android/arm/include -DANDROID -I$NDK/sysroot/usr/include/arm-linux-androideabi/"
ADDI_LDFLAGS="-Wl,-rpath-link=$MIN_PLATFORM/arch-arm/usr/lib -L/home/albert/ffmpeg/x264-master/android/arm/lib -L$MIN_PLATFORM/arch-arm/usr/lib -nostdlib"

sed  -i "" "s/SLIBNAME_WITH_MAJOR='\$(SLIBNAME).\$(LIBMAJOR)'/SLIBNAME_WITH_MAJOR='\$(SLIBPREF)\$(FULLNAME)-\$(LIBMAJOR)\$(SLIBSUF)'/" configure
sed  -i "" "s/LIB_INSTALL_EXTRA_CMD='\$\$(RANLIB) \"\$(LIBDIR)\\/\$(LIBNAME)\"'/LIB_INSTALL_EXTRA_CMD='\$\$(RANLIB) \"\$(LIBDIR)\\/\$(LIBNAME)\"'/" configure
sed  -i "" "s/SLIB_INSTALL_NAME='\$(SLIBNAME_WITH_VERSION)'/SLIB_INSTALL_NAME='\$(SLIBNAME_WITH_MAJOR)'/" configure
sed  -i "" "s/SLIB_INSTALL_LINKS='\$(SLIBNAME_WITH_MAJOR) \$(SLIBNAME)'/SLIB_INSTALL_LINKS='\$(SLIBNAME)'/" configure
sed -i -e 's/#define getenv(x) NULL/\/\*#define getenv(x) NULL\*\//g' config.h
# sed  -i "" "s/SHFLAGS='-shared -Wl,-soname,\$(SLIBNAME)'/SHFLAGS='-shared -soname \$(SLIBNAME)'/" configure
# sed  -i "" "s/-Wl//g" configure

./configure \
--prefix=$PREFIX \
--ar=$AR \
--as=$AS \
--cc=$CC \
--cxx=$CXX \
--nm=$NM \
--ranlib=$RANLIB \
--strip=$STRIP \
--arch=$ARCH \
--target-os=android \
--enable-cross-compile \
--disable-asm \
--enable-gpl \
--enable-libx264 \
--enable-encoder=libx264 \
--enable-jni \
--enable-neon \
--enable-mediacodec \
--enable-shared \
--disable-static \
--disable-ffprobe \
--disable-ffplay \
--disable-ffmpeg \
--disable-debug \
--disable-symver \
--disable-stripping \
--extra-cflags="-I/home/albert/ffmpeg/x264-master/android/arm/include" \
--extra-ldflags="-L/home/albert/ffmpeg/x264-master/android/arm/lib" \

sed  -i "" "s/#define HAVE_TRUNC 0/#define HAVE_TRUNC 1/" config.h
sed  -i "" "s/#define HAVE_TRUNCF 0/#define HAVE_TRUNCF 1/" config.h
sed  -i "" "s/#define HAVE_RINT 0/#define HAVE_RINT 1/" config.h
sed  -i "" "s/#define HAVE_LRINT 0/#define HAVE_LRINT 1/" config.h
sed  -i "" "s/#define HAVE_LRINTF 0/#define HAVE_LRINTF 1/" config.h
sed  -i "" "s/#define HAVE_ROUND 0/#define HAVE_ROUND 1/" config.h
sed  -i "" "s/#define HAVE_ROUNDF 0/#define HAVE_ROUNDF 1/" config.h
sed  -i "" "s/#define HAVE_CBRT 0/#define HAVE_CBRT 1/" config.h
sed  -i "" "s/#define HAVE_CBRTF 0/#define HAVE_CBRTF 1/" config.h
sed  -i "" "s/#define HAVE_COPYSIGN 0/#define HAVE_COPYSIGN 1/" config.h
sed  -i "" "s/#define HAVE_ERF 0/#define HAVE_ERF 1/" config.h
sed  -i "" "s/#define HAVE_HYPOT 0/#define HAVE_HYPOT 1/" config.h
sed  -i "" "s/#define HAVE_ISNAN 0/#define HAVE_ISNAN 1/" config.h
sed  -i "" "s/#define HAVE_ISFINITE 0/#define HAVE_ISFINITE 1/" config.h
sed  -i "" "s/#define HAVE_INET_ATON 0/#define HAVE_INET_ATON 1/" config.h
sed  -i "" "s/#define getenv(x) NULL/\\/\\/ #define getenv(x) NULL/" config.h
```


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

