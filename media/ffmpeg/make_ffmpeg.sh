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

# extra_ldflags="-nostdlib -lc"

for((i=0; i<1; i++))
do
    configEnv ${targets[i]} ${compiler[i]} ${CPUS[i]} ${ARCHS[i]} "${extra_cflags_arr[i]}"

    BUILD_DIR=$dir/ffmpeg_build/$CPU
    rm -rf $BUILD_DIR

    extra_include="-I${x264_lib}/${CPU}/include"
    extra_lib="-L${x264_lib}/${CPU}/lib"

    extra_cflags="-Os -fpic ${extra_cflags} "
    # extra_cflags="-Os -fpic ${extra_cflags} ${extra_include}"
    # extra_ldflags="${extra_ldflags} ${extra_lib}"

    echo "PREFIX: ${BUILD_DIR}"
    echo "CROSS_PREFIX: ${CROSS_PREFIX}"
    echo "SYSROOT: ${SYSROOT}"
    echo "ARCH: ${ARCH}"
    echo "CPU: ${CPU}"
    echo "CC: ${CC}"
    echo "CXX: ${CXX}"
    echo "OPTIMIZE_CFLAGS: ${extra_cflags}"
    echo "ADDI_LDFLAGS: ${extra_ldflags}"
    echo "AR: ${AR}"
    echo "AS: ${AS}"
    echo "NM: ${NM}"
    echo "RANLIB: ${RANLIB}"
    echo "STRIP: ${STRIP}"

    ./configure --prefix=$BUILD_DIR \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT \
    --arch=$ARCH \
    --cc=$CC \
    --cxx=$CXX \
    --extra-cflags="${extra_cflags}" \
    --extra-ldflags="${extra_ldflags}" \
    --ar=$AR \
    --as=$AS \
    --nm=$NM \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --target-os=android \
    --enable-cross-compile \
    --enable-gpl \
    --enable-mediacodec \
    --enable-decoder=h264_mediacodec \
    --enable-jni \
    --enable-neon \
    --enable-shared \
    --enable-small \
    --disable-static \
    --disable-ffprobe \
    --disable-ffplay \
    --disable-debug \
    --disable-avdevice \
    --disable-doc \
    --disable-symver \
    --enable-hwaccels  \
    --enable-postproc \
    --disable-stripping \
    --enable-ffmpeg

    #  --enable-ffmpeg  这个没有实际使用，但是可以在编译的过程中验证链接是否有问题，如果不加这个，只有到安卓应用的 `.so` 库运行的时候才能发现以下错误。 

    # --extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
    # --extra-ldflags="$ADDI_LDFLAGS"

    make clean
    make -j4
    make install
done
