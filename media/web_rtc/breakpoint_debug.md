# Android Studio 断点调试 Webrtc

WebRTC 的项目非常庞大，由于使用 gn，导致跟主流 IDE 集成性较差，这就导致通常是使用场景是先编译出静态库或动态库，然后使用静态库/动态库进行二次开发。

我在使用完全通同步的项目作为放在项目目录下时，就出现 Android Sudio 卡死的情况，只能仅拉取 webrtc 的主仓库的代码。可见项目 AS 做的还是不够支持大型项目。

设置支持断点调试的方法很简单，仅仅演示我的设置用不了太多文字。然而不同人使用 webrtc 的场景不同，如果稍微不同，设置后仍然不能打断点，却束手无策。因此这里讲解如何诊断断点不生效的原因，从而即使有问题时，也能找到方案解决。此谓：“授人以渔”。

## 确定包含了 debug 信息

首先要编译包含 `debug symbol` 信息的库，这些信息用于在调试打断点，以及对应源代码用。要包含这些 symbol info，只需要在 gn 参数中添加 `android_full_debug=true symbol_level=2`

```shell
gn gen out/arm64 --args='target_os="android" target_cpu="arm64" use_custom_libcxx=false  android_full_debug=true symbol_level=2 use_rtti=true'
```

验证 webrtc 库包含了 `symbol info`。能查看的信息的工具很多，例如

```
$ objdump -h a.out
# 或
$ readelf -S a.out
# 或 
$ nm --demangle libwebrtc.a
```

阅读性最好的是 `dwarfdump`，例如：

```shell
$ dwarfdump libwebrtc.a
libwebrtc.a(create_peerconnection_factory.o):	file format elf64-littleaarch64
0x0000002a:   DW_TAG_namespace
                DW_AT_name	("std")

0x0000002f:     DW_TAG_namespace
                  DW_AT_name	("__ndk1")
                  DW_AT_export_symbols	(true)

0x00000034:       DW_TAG_class_type
                    DW_AT_calling_convention	(DW_CC_pass_by_reference)
                    DW_AT_name	("unique_ptr<webrtc::RtcEventLogFactory, std::default_delete<webrtc::RtcEventLogFactory> >")
                    DW_AT_byte_size	(0x08)
                    DW_AT_decl_file	("./../../third_party/android_ndk/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/c++/v1/memory")
                    DW_AT_decl_line	(2485)

...
```
- DW_AT_name: 就是函数名、类名、或者变量名。
- DW_AT_decl_file: 所在的文件
- DW_AT_decl_line: 所在文件的行数

有了调试信息，再看一下 Android Studio 打断点的流程

## Android Stduio 断点调试流程

Android app 的断点调试在 IDE 上看起来很简单，点一下按钮就能调试了。其实却做了很多工作，已经设计到`远程调试`了，所谓远程调试，就是程序运行的机器和调试断点的机器不是同一天机器。这就需要 server-client 的配合。得益于优秀的设计，其实远程调试并没有太复杂。

### 远程调试的命令流程
远程调试的流程有总体上分三步:

1. start lldb server
2. attaching to the app
3. loaded modile: LLVM module

#### 1. 启动 debug server.

通过 adb 在手机上启动 debug_server，首先要获取 lldb-server。

如果已经使用 AS 调试过程序，在手机的 /data/local/tmp 已经有了 lldb-server，不用再往手机添加。没有的话，可以在下载的 ndk 的 `toolchains/llvm/prebuilt/<平台类型，如darwin-x86_64>/lib64/clang/9.0.8/` 目录下找到。然后 push 到手机上。

```
$ adb push lldb-server /data/local/tmp/
$ adb shell
cd /data/local/tmp
chmod 755 lldb-server
# 进入 app 的沙盒
$ run-as <app 的包名>
```

> 启动 lldb-server

继续在 adb shell 中执行
```
./lldb-server p --server --listen unix-abstract:///data/local/tmp/debug.sock
```

`unix-abstract:///data/local/tmp/debug.sock` 是启动 Socket 的一种启动方式，这种方式监听文件。这种方式必须使用 USB 连接手机。如果网络连接的远程调试，则需要使用 `ip:port` 的方式。如：

```
$ # ./lldb-server platform --server --listen "<incoming-ip>:<port>"
$ # Example: allow any ip on port 9999
$ ./lldb-server platform --server --listen "*:9999"
```


#### 2. 启动 lldb 作为客户端

在调试机的另一个终端执行

```
$ lldb
platform list # 查看支持连接平台的插件
platform select remote-android # 选择连接安卓设备
platform status # 查看连接状态
platform connect unix-abstract-connect:///data/local/tmp/debug.sock # 连接远程
```
对于使用 `ip:port` 启动的，使用 `platform connect connect://<ip>:<port>` 进行连接。


#### 3. 关联到调试程序

> 方式一：启动程序
```
file <target_binary> # 指定将要调试的二进制文件,注意是相对于WorkingDir的路径
br set -f app_core.cpp -l 128 # 意思就是在app_core.cpp的128行处打个断点
run # 运行程序
```
> 方式二：关联到已经运行着的程序

```
file  <target_binary> # 指定将要调试的二进制文件,注意是相对于WorkingDir的路径
platform process list # 查看一直远端的进程, 找到目标进程pid, 或者名称
attach <pid>
```

也可以送 `$ adb shell ps | grep "<package name>"` 查看进程 id。然后就可以执行 lldb 的各种调试命令了。

### 在 Android Studio 调试

了解了远程调试的流程，我们来看 Android Studio 的调试，这样如果不能正确得打断点，我们就能很方便地进行诊断问题出在那里。




## Build ID

build id 是用于唯一标识一个编译目标，广泛应用于可执行文件，lib，可制成程序以及 debuginfo 文件等。

通常是二级制文件特定部分的校验和（hash）

 This allows two builds of the same program on the same host to always produce consistent build-ids and binary content.

SHA-1 build id 是 160 bits/20 bytes 的字符串。

 There are a couple of conventions in place to use this information to identify “currently running” or “distro installed” builds. This helps with identifying what was being run and match it to the corresponding package, sources and debuginfo for tools that want to help the user show what is going on (at the moment mostly when things break). We would like to extend this to a more universial approach, that helps people identify historical, local, non- or cross-distro or organisational builds. So that Build-IDs become useful outside the current “static” setup and retain information over time and across upgrades.

## Build-ID background


The main idea behind Build-IDs is to make elf files “self-identifying”. This means that when you have a Build-ID it should uniquely identify a final executable or shared library. The default Build-ID calculation (done through ld –build-id, see the ld manual) calculates a sha1 hash (160 bits/20 bytes) based on all the ELF header bits and section contents in the file. Which means that it is unique among the set of meaningful contents for ELF files and identical when the output file would otherwise have been identical. GCC now passes –build-id to the linker by default.

When an executable or shared library is loaded into memory the Build-ID will also be loaded into memory, a core dump of a process will also have the Build-IDs of the executable and the shared libraries embedded. And when separating debuginfo from the main executable or shared library into .debug files the original Build-ID will also be copied over. This means it is easy to match a core file or a running process to the original executable and shared library builds. And that matching those against the debuginfo files that provide more information for introspection and debugging should be trivial.




查看是否有 `build id` 可以使用 `readelf` 指令 

```
$ readelf -n libwebrtc.a
[...]
Note section [ 3] '.note.gnu.build-id' of 36 bytes at offset 0x274:
  Owner		Data size    Type
  GNU		       20    GNU_BUILD_ID
    Build ID: efdd0b5e69b0742fa5e5bad0771df4d1df2459d1
```
mac 上没有 `readelf` 工具，需要额外安装，最简单的方式是用 file 查看 file info，虽然不够准确，却是最简单的方法。

```
$ file libwebrtc.a
ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, with debug_info, not stripped
```

`stripped` 是指不包含 symbol，已经使用 `strip` 命令去掉了 debug symbol。而包含 build id 的输出信息为：
```
$ file libwebrtc.a
ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, BuildID[sha1]=fa8ffd39fcb7c0443af3667c2175de2af633721e, with debug_info, not stripped
```

![lldb 为什么需要 build id](images/build_id.png)
https://github.com/android/ndk/issues/885

http://abcdxyzk.github.io/blog/2014/09/12/compiler-build-id/


```shell
(lldb) target create --no-dependents '9.0/Symbols/Library/Application Support/WatchKit/WK'
Current executable set to '9.0/Symbols/Library/Application Support/WatchKit/WK' (armv7k).
(lldb) image list
[  0] 675ED1EB-BAA0-3453-B7B1-3E69310F40FD 0x00004000 9.0/Symbols/Library/Application Support/WatchKit/WK
(lldb) image dump symtab
Dumping symbol table for 1 modules.
Symtab, file = 9.0/Symbols/Library/Application Support/WatchKit/WK, num_symbols = 6:
               Debug symbol
               |Synthetic symbol
               ||Externally Visible
               |||
Index   UserID DSX Type            File Address/Value Load Address       Size               Flags      Name
------- ------ --- --------------- ------------------ ------------------ ------------------ ---------- ----------------------------------
[    0]      0     Code            0x0000000000007fcc                    0x0000000000000030 0x001e0000  stub helpers
[    1]      1   X Data            0x0000000000004000                    0x0000000000003fcc 0x000f0010 _mh_execute_header
[    2]      2   X ReExported                                                               0x000b0000 main -> /System/Library/PrivateFrameworks/SockPuppetGizmo.framework/SockPuppetGizmo`_SPApplicationMain
[    3]      3   X Undefined       0x0000000000000000                    0x0000000000000000 0x00010100 _SPApplicationMain
[    4]      4   X Undefined       0x0000000000000000                    0x0000000000000000 0x00010500 dyld_stub_binder
[    5]      5  S  Trampoline      0x0000000000007ffc                    0x0000000000000004 0x00000000 main
```


> 查看某个函数或者类信息 lookup

```
image lookup -vn <SomeFunctionNameThatShouldHaveDebugInfo>
```

函数或者类名不一定写全限定，例如 `truman::TrumanEngine::SetAndroidObjects` 可以写成 `SetAndroidObjects`

```s
lldb> f
frame #0: 0xb400caac libengine.so`truman::TrumanEngine::SetAndroidObjects(javaVM=0x00000000) at truman_engine_impl.cc:206:5
lldb> image lookup -vn SetAndroidObjects
1 match found in /Users/albert/project/android/work/webrtc_branch/module/video/libs/armeabi-v7a/libengine.so:
        Address: libengine.so[0x001c4a94] (libengine.so.PT_LOAD[0]..text + 137812)
        Summary: libengine.so`truman::TrumanEngine::SetAndroidObjects(void*) at truman_engine_impl.cc:201
         Module: file = "/Users/albert/project/android/work/webrtc_branch/module/video/libs/armeabi-v7a/libengine.so", arch = "arm"
    CompileUnit: id = {0x00000005}, file = "/data/truman/new/webrtc/src/truman_live/engine/truman_engine_impl.cc", language = "c++"
       Function: id = {0x7fffffff000dfb1a}, name = "truman::TrumanEngine::SetAndroidObjects(void*)", mangled = "_ZN6truman12TrumanEngine17SetAndroidObjectsEPv", range = [0xb400ca94-0xb400cab8)
       FuncType: id = {0x7fffffff000dfb1a}, byte-size = 0, decl = truman_engine.h:25, compiler_type = "int (void *)"
         Blocks: id = {0x7fffffff000dfb1a}, range = [0xb400ca94-0xb400cab8)
      LineEntry: [0xb400ca94-0xb400ca9c): /data/truman/new/webrtc/src/truman_live/engine/truman_engine_impl.cc:201
         Symbol: id = {0x0003ef38}, range = [0xb400ca94-0xb400cab8), name="truman::TrumanEngine::SetAndroidObjects(void*)", mangled="_ZN6truman12TrumanEngine17SetAndroidObjectsEPv"
       Variable: id = {0x7fffffff000dfb2c}, name = "javaVM", type = "void *", location = DW_OP_fbreg +4, decl = truman_engine_impl.cc:201
```


> 参考文档

[build id](http://abcdxyzk.github.io/blog/2014/09/12/compiler-build-id/)
[Remot debug](https://www.cnblogs.com/ciml/p/14154668.html)