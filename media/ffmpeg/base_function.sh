#!/bin/bash

NDK=$NDK_HOME

# NDK 编译环境，不同 OS 上要下载不同的 NDK，而这个文件夹是不同的。需要根据下载的 NDK 是运行在 Linux, Mac OS, Windows 上而配置不同的文件夹。
# Mac
HOST_TAG=darwin-x86_64
# Linux
# HOST_TAG=linux-x86_64
# windows
# HOST_TAG=windows-x86_64

# 从 NDK 17 开始，仅支持 armv7a, arch64, i686 和 x86_64 四种架构，arm 用于实际的机器，x86 用于模拟器或者特殊的 x86 平板。
# 以下 target 对应于 $NDK/toolchains/llvm/prebuilt/$HOST_TAG 目录下的编译器程序。
# armv7a 和 i686 可以支持到 Android 16， 而 arch64、x86_64 仅能支持到 Android 21.

# 支持的 Android CUP 架构
ARCHS=(
    arm
    arm64
    x86
    x86_64
)

# 重要，跟 Android studio 的 jni 目录名称不完全一致，不可随意更改。
CPUS=(
    armv7-a
    armv8-a
    x86
    x86_64
)

# TARGET_AL=arm-linux-androideabi
# TARGET=armv7a-linux-androideabi
# TARGET=aarch64-linux-android
# TARGET=i686-linux-android
# TARGET=x86_64-linux-android

targets=(
    "arm-linux-androideabi"
    "aarch64-linux-android"
    "i686-linux-android"
    "x86_64-linux-android"
)

compiler=(
    "armv7a-linux-androideabi16"
    "${targets[1]}21"
    "${targets[2]}16"
    "${targets[3]}21"
)

#优化编译项
extra_cflags_arr=(
   "-mfloat-abi=softfp -mfpu=vfp -marm -march=armv7-a"
   "-march=armv8-a"
   "-march=i686 -m32 -mmmx -msse2 -msse3 -mssse3 -D__ANDROID__ -D__i686__"
   "-march=core-avx-i -mtune=core-avx-i -m64 -mmmx -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mpopcnt -D__ANDROID__ -D__x86_64__"
)

size=${#ARCHS[@]}

# Set this to your minSdkVersion.
# 支持的最次版本
API=16

TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG
# 该库使用到 arm-linux-androideabi-strings，可以通过在环境变量里添加查找路径让其能够找到命令。
PATH=$TOOLCHAIN/bin:$PATH
function configEnv()
{
    export TARGET_AL=$1
    export CROSS_PREFIX=$TOOLCHAIN/bin/$1-

    export AR=${CROSS_PREFIX}ar
    export AS=${CROSS_PREFIX}as
    export LD=${CROSS_PREFIX}ld
    export NM=${CROSS_PREFIX}nm
    export RANLIB=${CROSS_PREFIX}ranlib
    export STRIP=${CROSS_PREFIX}strip
    # Configure and build.
    export CC=$TOOLCHAIN/bin/$2-clang
    export CXX=$TOOLCHAIN/bin/$2-clang++

    # 不使用 $NDK 目录下的 /sysroot/
    export SYSROOT=$TOOLCHAIN/sysroot
    # 可以不设置，但是设置必须是对应架构的，例如 arm-linux-androideabi-
    export CPU=$3
    export ARCH=$4
    
    #优化编译项
    export extra_cflags=$5
}