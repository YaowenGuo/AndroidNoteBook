#!/bin/sh

. ./base_function.sh

# 当前目录下x264源文件目录
if [ ! -d "x264" ]
then
    echo "下载x264源文件..."
    git clone https://code.videolan.org/videolan/x264.git
fi

dir=$(pwd)
cd ./x264

extra_configure="--disable-asm"
extra_ldflags="-nostdlib -c"

for((i=0; i<size; i++))
do
    configEnv ${targets[i]} ${compiler[i]} ${CPUS[i]} ${ARCHS[i]} "${extra_cflags_arr[i]}"
    BUILD_DIR=$dir/x264_build/$CPU

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

    echo $CC
    echo $CXX
    echo "extra_configure: ${extra_configure}"
    echo "BUILD_DIR: ${BUILD_DIR}"
    echo "CROSS_PREFIX: ${CROSS_PREFIX}"
    echo "SYSROOT: ${SYSROOT}"
    echo "extra_cflags: ${extra_cflags}"
    echo "TARGET_AL: ${TARGET_AL}"
    
    

    ./configure ${configure} \
        ${extra_configure} \
        --prefix=$BUILD_DIR \
        --cross-prefix=$CROSS_PREFIX \
        --sysroot=$SYSROOT \
        --host=$TARGET_AL
        --cc=$CC \
        --cxx=$CXX \
        --extra-cflags="${extra_cflags}" \
        --extra-ldflags="${extra_ldflags}" \
        --ar=$AR \
        --as=$AS \
        --nm=$NM \
        --ranlib=$RANLIB \
        --strip=$STRIP
        

    # --host 指定成 armv7a-linux-androideabi 和 arm-linux-androideabi 都不出问题，用于指定运行目标的系统。


    make clean
    make -j4
    make install
done