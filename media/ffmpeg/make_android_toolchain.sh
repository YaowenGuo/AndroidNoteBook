#!/bin/bash
#NDK目录,你要改成自己的ndk解压缩后所在的目录
# set NDK_HOME environment path first.

#生成交叉编译链工具
toolchain=${NDK_HOME}/build/tools/make_standalone_toolchain.py

#生成交叉编译链保存在当前目录子文件夹android-toolchain
install_root=`pwd`/android-toolchain-py

#生成32位库最低支持到android4.3，64位库最低支持到android5.0
platforms=(
  "16"
  "21"
  "16"
  "21"
)

#支持以下5种cpu框架
archs=(
  "arm"
  "arm64"
  "x86"
  "x86_64"
)

#cpu型号
abis=(
  "armeabi-v7a"
  "arm64-v8a"
  "x86"
  "x86_64"
)

echo $NDK_HOME
echo "安装在目录:$install_root"

num=${#abis[@]}

for ((i=0; i<num; i++))
do
   python $toolchain --arch=${archs[i]} --api=${platforms[i]}  --install-dir=$install_root/${abis[i]}
done
