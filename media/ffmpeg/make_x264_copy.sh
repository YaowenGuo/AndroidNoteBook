#!/bin/sh

# 当前目录下x264源文件目录
if [ ! -d "x264" ]
then
    echo "下载x264源文件"
    git clone https://code.videolan.org/videolan/x264.git
fi


NDK=$NDK_HOME

# NDK 编译环境，不同 OS 上要下载不同的 NDK，而这个文件夹是不同的。需要根据下载的 NDK 是运行在 Linux, Mac OS, Windows 上而配置不同的文件夹。例如 mac 上是：
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

# 该库使用到 arm-linux-androideabi-strings，可以通过在环境变量里添加查找路径让其能够找到命令。
PATH=$TOOLCHAIN/bin:$PATH


# Configure and build.
export AR=$TOOLCHAIN/bin/$TARGET_AL-ar
export AS=$TOOLCHAIN/bin/$TARGET_AL-as
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/$TARGET_AL-ld
export RANLIB=$TOOLCHAIN/bin/$TARGET_AL-ranlib
export STRIP=$TOOLCHAIN/bin/$TARGET_AL-strip



# 不使用 $NDK_HOME 下的 /sysroot/
SYSROOT=$TOOLCHAIN/sysroot/
# 可以不设置，但是设置必须是对应架构的，例如 arm-linux-androideabi-
CROSS_PREFIX=arm-linux-androideabi-

INSTALL_DIR=$(pwd)/x264-$TARGET

extra_configure="--disable-asm"

#优化编译项
extra_cflags="-march=armv7-a -mfloat-abi=softfp -mfpu=neon -mthumb -D__ANDROID__ -D__ARM_ARCH_7__ -D__ARM_ARCH_7A__ -D__ARM_ARCH_7R__ -D__ARM_ARCH_7M__ -D__ARM_ARCH_7S__"
extra_ldflags="-nostdlib -lc"

cd ./x264

echo $CC
echo $CXX
echo "extra_configure: ${extra_configure}"
echo "BUILD_DIR: ${BUILD_DIR}"
echo "CROSS_PREFIX: ${CROSS_PREFIX}"
echo "SYSROOT: ${SYSROOT}"
echo "extra_cflags: ${extra_cflags}"
echo "TARGET_AL: ${TARGET_AL}"

./configure ${extra_configure} \
    --prefix=$INSTALL_DIR \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --extra-cflags="${extra_cflags}" \
    --host=$TARGET_AL
# --host 指定成 armv7a-linux-androideabi 和 arm-linux-androideabi 都不出问题，应该是不设置也行。具体什么目录有关还没搞清楚。

# this link flage whill cause linker error.
# --extra-ldflags="$extra_ldflags" \
make clean
make -j4
make install
