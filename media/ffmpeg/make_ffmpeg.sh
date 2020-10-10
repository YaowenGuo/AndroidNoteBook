#!/bin/bash

source ./base_function.sh

# 当前目录下x264源文件目录
if [ ! -d "ffmpeg" ]
then
    echo "下载 ffmpeg ..."
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
fi

dir=$(pwd)
x264_lib=$dir/x264_build

cd ./ffmpeg

extra_ldflags="-nostdlib -lc"

for((i=0; i<size; i++))
do
    configEnv ${targets[i]} ${compiler[i]} ${CPUS[i]} ${ARCHS[i]} ${extra_cflags_arr[i]}

    BUILD_DIR=$dir/ffmpeg_build/$CPU

    extra_include="-I${x264_lib}/${CPU}/include"
    extra_lib="-L${x264_lib}/${CPU}/lib"

    extra_cflags="-Os -fpic ${extra_cflags} ${extra_include}"
    extra_ldflags="${extra_ldflags} ${extra_lib}"

    echo "extra_configure: ${extra_configure}"
    echo "BUILD_DIR: ${BUILD_DIR}"
    echo "CROSS_PREFIX: ${CROSS_PREFIX}"
    echo "SYSROOT: ${SYSROOT}"
    echo "extra_cflags: ${extra_cflags}"
    echo "TARGET_AL: ${TARGET_AL}"


    ./configure \
    --prefix=$BUILD_DIR \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --arch=$ARCH \
    --extra-cflags="${extra_cflags}" \
    --extra-ldflags="${extra_ldflags}" \
    --ar=$AR \
    --as=$AS \
    --cc=$CC \
    --cxx=$CXX \
    --nm=$NM \
    --ranlib=$RANLIB \
    --strip=$STRIP \
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
    

    # --extra-cflags="-I /home/albert/ffmpeg/x264-master/android/arm/include" \
    # --extra-ldflags="-L/home/albert/ffmpeg/x264-master/android/arm/lib" \

    make clean
    make -j4
    make install
done
