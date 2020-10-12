#!/bin/bash

echo ">>>>>>>>> 编译硬件解码版本 <<<<<<<<"
echo ">>>>>>>>> 注意：该编译环境目前只在 NDK20b + ffmpeg4.2.2 测试过 <<<<<<<<"
echo ">>>>>>>>> 注意：该编译环境目前只在 NDK20b + ffmpeg4.2.2 测试过 <<<<<<<<"

#你自己的NDK路径.
export NDK=$NDK_HOME
HOST_TAG=darwin-x86_64
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

function build_android
{

# --arch=$ARCH \
# --cpu=$CPU \
# --cc=$CC \
# --cxx=$CXX \
# --sysroot=$SYSROOT \
# --extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
# --extra-ldflags="$ADDI_LDFLAGS"



echo "开始编译 $CPU"

echo "PREFIX: ${PREFIX}"
echo "CROSS_PREFIX: ${CROSS_PREFIX}"
echo "SYSROOT: ${SYSROOT}"
echo "ARCH: ${ARCH}"
echo "CPU: ${CPU}"
echo "CC: ${CC}"
echo "CXX: ${CXX}"
echo "OPTIMIZE_CFLAGS: ${OPTIMIZE_CFLAGS}"
echo "ADDI_LDFLAGS: ${ADDI_LDFLAGS}"
echo "AR: ${AR}"
echo "AS: ${AS}"
echo "NM: ${NM}"
echo "RANLIB: ${RANLIB}"
echo "STRIP: ${STRIP}"

./configure \
--prefix=$PREFIX \
--sysroot=$SYSROOT \
--cross-prefix=$CROSS_PREFIX \
--arch=$ARCH \
--cpu=$CPU \
--cc=$CC \
--cxx=$CXX \
--extra-cflags="$OPTIMIZE_CFLAGS" \
--extra-ldflags="$ADDI_LDFLAGS" \
--ar=$AR \
--as=$AS \
--nm=$NM \
--ranlib=$RANLIB \
--strip=$STRIP \
--enable-neon  \
--enable-hwaccels  \
--enable-gpl   \
--enable-postproc \
--enable-shared \
--disable-debug \
--enable-small \
--enable-jni \
--disable-asm \
--enable-mediacodec \
--enable-decoder=h264_mediacodec \
--disable-static \
--enable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-avdevice \
--disable-doc \
--disable-symver \
--enable-cross-compile \
--target-os=android \

    

    # --extra-cflags="${extra_cflags}" \
    # --extra-ldflags="${extra_ldflags}" \
    # --ar=$AR \
    # --as=$AS \
    # --cc=$CC \
    # --cxx=$CXX \
    # --nm=$NM \
    # --ranlib=$RANLIB \
    # --strip=$STRIP \

make clean
make
make install

echo "编译成功 $CPU"

}

dir=$(pwd)
#armv8-a
ARCH=arm64
CPU=armv8-a
API=21
CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
SYSROOT=$TOOLCHAIN/sysroot
export AR=$TOOLCHAIN/bin/aarch64-linux-android-ar
export AS=$TOOLCHAIN/bin/aarch64-linux-android-as
export LD=$TOOLCHAIN/bin/aarch64-linux-android-ld
export NM=$TOOLCHAIN/bin/aarch64-linux-android-nm
export RANLIB=$TOOLCHAIN/bin/aarch64-linux-android-ranlib
export STRIP=$TOOLCHAIN/bin/aarch64-linux-android-strip
CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-
PREFIX=$dir/ffmpeg_build_test/$CPU
OPTIMIZE_CFLAGS="-Os -fpic -march=$CPU"

cd ./ffmpeg
# build_android

#armv7-a
ARCH=arm
CPU=armv7-a
API=16
CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang
CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++
SYSROOT=$TOOLCHAIN/sysroot
export AR=$TOOLCHAIN/bin/arm-linux-androideabi-ar
export AS=$TOOLCHAIN/bin/arm-linux-androideabi-as
export LD=$TOOLCHAIN/bin/arm-linux-androideabi-ld
export NM=$TOOLCHAIN/bin/arm-linux-androideabi-nm
export RANLIB=$TOOLCHAIN/bin/arm-linux-androideabi-ranlib
export STRIP=$TOOLCHAIN/bin/arm-linux-androideabi-strip
CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-
PREFIX=$dir/ffmpeg_build_test/$CPU
OPTIMIZE_CFLAGS="-Os -fpic -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "

build_android
