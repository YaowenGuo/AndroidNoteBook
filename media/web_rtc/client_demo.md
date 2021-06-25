# 客户端 Demo

## Android demo

由与下载需要谷歌，也可以使用国内的镜像:

声网镜像：https://webrtc.org.cn/mirror/#depotools%E2%80%8B

### 1. 前提

- android 的开发官方只提供了 Linux 平台编译，其它平台编译难以保证，作为入门来说，尽快编译通过上手才是第一要素，如果在为了整各个平台上的编译而花费大量时间，恐怕是得不偿失。

- webrtc 由于牵涉到各个平台相关的代码，而现有的项目 `chromium` 浏览器用于挂平台已经积累了一些库，webrtc 也统一放在了这个代码管理平台上。需要先下载 `dept_tools` 用来下载和管理代码依赖，构建项目。

  - fetch 是一个 python 脚本，用于从 chromium 仓库下载对应的项目。可以使用 `fetch -h` 查看都有哪些项目可供使用。例如 webrtc 的安卓平台的 webrtc_android.



[详细的安装文档](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/android/index.md)

根据文档里的步骤，可以生成一个 gradle 的安卓客户端的 demo 项目，可以拷贝到 Mac 等系统上，使用 Android Studio 导入查看。

这里做一些遇到问题的补充。

1. 由于是 google 的东西，还是需要代理才能访问。


2. 执行 `gclient sync` 配置环境的时候，google fonts 下载不下来。

```
 File "./build/linux/install-chromeos-fonts.py", line 120, in <module>
    sys.exit(main(sys.argv[1:]))
  File "./build/linux/install-chromeos-fonts.py", line 67, in main
    subprocess.check_call(['curl', '-L', url, '-o', tarball])
  File "/usr/lib/python2.7/subprocess.py", line 185, in check_call
    retcode = call(*popenargs, **kwargs)
  File "/usr/lib/python2.7/subprocess.py", line 172, in call
    return Popen(*popenargs, **kwargs).wait()
  File "/usr/lib/python2.7/subprocess.py", line 1099, in wait
    pid, sts = _eintr_retry_call(os.waitpid, self.pid, 0)
  File "/usr/lib/python2.7/subprocess.py", line 125, in _eintr_retry_call
    return func(*args)
```

可以单独执行 google font 安装脚本，再继续执行原脚本。

```
python ./build/linux/install-chromeos-fonts.py
```

2. cipd 下载失败

```
________ running 'cipd ensure -log-level error -root /opt/webertc/linux_android -ensure-file /tmp/tmpw_u4qbbw.ensure' in '.'
Errors:
  failed to resolve gn/gn/linux-amd64@git_revision:e002e68a48d1c82648eadde2f6aafa20d08c36f2 (line 4): prpc: when sending request: Post "https://chrome-infra-packages.appspot.com/prpc/cipd.Repository/ResolveVersion": net/http: TLS handshake timeout
```

可以设置不升级

```
export DEPOT_TOOLS_UPDATE=0
```

3. 

```
Failed to install chromium/third_party/turbine:O_jNDJ4VdwYKBSDbd2BJ3mknaTFoVkvE7Po8XIiKy8sC - prpc: when sending request: Post "https://chrome-infra-packages.appspot.com/prpc/cipd.Repository/GetInstanceURL": x509: certificate is valid for *.facebook.com, *.facebook.net, *.fbcdn.net, *.fbsbx.com, *.m.facebook.com, *.messenger.com, *.xx.fbc
```

应该是代理问题，检查代理访问是否正常使用，然后设置

```shell
# 将端口号改为你自己的代理端口
export http_proxy=http://127.0.0.1:1087
export https_proxy=http://127.0.0.1:1087
```

4. tar 包解压问题

```
nstalling Debian sid amd64 root image: /opt/webrtc/linux_android/src/build/linux/debian_sid_amd64-sysroot
Downloading https://commondatastorage.googleapis.com/chrome-linux-sysroot/toolchain/5f64b417e1018dcf8fcc81dc2714e0f264b9b911/debian_sid_amd64_sysroot.tar.xz
tar: ./lib/x86_64-linux-gnu/libexpat.so.1: Cannot utime: No such file or directory
tar: ./lib/x86_64-linux-gnu/libutil.so.1: Cannot utime: No such file or directory
tar: ./lib/x86_64-linux-gnu/libcap.so.2: Cannot utime: No such file or directory
tar: ./lib/x86_64-linux-gnu/libpthread.so.0: Cannot utime: No such file or directory
...
```
如果你在是在 Mac 的 docker 中下载，并且下载目录是挂载在 mac 的目录中，那这个方法可能适合你。这个错误应该是文件系统导致的，有两种方法解决：

方法 1: 只需要下载到 docker 内部的文件目录里就行了。
方法 2: 在 mac 主机中执行响应的指令，例如 `python2 src/build/linux/sysroot_scripts/install-sysroot.py --arch=amd64`

linux 使用的是 ext 文件系统，跟 mac 不一致。很奇怪的是，我单独执行 tar 命令解压或者单独执行以下的 Python 脚本都不会出问题。很可能是 `src/build/linux/sysroot_scripts/install-sysroot.py` 脚本环境有问题。

```python
import subprocess
subprocess.check_call(['tar', 'xf', u'/opt/webrtc/linux_android/src/build/linux/debian_sid_amd64-sysroot/debian_sid_amd64_sysroot.tar.xz', '-C',  u'/opt/webrtc/linux_android/src/build/linux/debian_sid_amd64-sysroot'])
```

5. 运行生成的 Android 包

需要注意的是，生成的是一个 gradle 项目，而不是 Android Studio 项目。应该使用 Android Studio 的 import 的方式，而不是直接打开。另外生成的 demo 项目，依赖引用了项目之外的其他路径的文件。移动目录应该将整个 WebRtc 一起移动，而不是仅移动生成的 demo 目录。

6. 

> 缺少 pkg-config
生成 Android Studio 项目错误。

```
gn gen out/Debug --args='target_os="android" target_cpu="arm"'
```

```
Traceback (most recent call last):
  File "/opt/webrtc/linux_android/src/build/config/linux/pkg-config.py", line 248, in <module>
    sys.exit(main())
  File "/opt/webrtc/linux_android/src/build/config/linux/pkg-config.py", line 143, in main
    prefix = GetPkgConfigPrefixToStrip(options, args)
  File "/opt/webrtc/linux_android/src/build/config/linux/pkg-config.py", line 82, in GetPkgConfigPrefixToStrip
    "--variable=prefix"] + args, env=os.environ).decode('utf-8')
  File "/usr/lib/python2.7/subprocess.py", line 216, in check_output
    process = Popen(stdout=PIPE, *popenargs, **kwargs)
  File "/usr/lib/python2.7/subprocess.py", line 394, in __init__
    errread, errwrite)
  File "/usr/lib/python2.7/subprocess.py", line 1047, in _execute_child
    raise child_exception
OSError: [Errno 2] No such file or directory
```

缺少 `pkg-config` 指令。 `subprocess.check_output` 就是执行一个 linux 指令，获得输出。只需要安装 `pkg-config`:

```shell
$ apt install pkg-config
```


> 缺少 gcc

```
FAILED: gen/examples/AppRTCMobile__build_config_srcjar/java_cpp_template/org/chromium/base/BuildConfig.java
python ../../build/android/gyp/gcc_preprocess.py --depfile gen/examples/AppRTCMobile__build_config_srcjar_BuildConfig.d --include-path ../../ --output gen/examples/AppRTCMobile__build_config_srcjar/java_cpp_template/org/chromium/base/BuildConfig.java --template=../../base/android/java/templates/BuildConfig.template --defines _DCHECK_IS_ON --defines USE_FINAL --defines ENABLE_MULTIDEX --defines _MIN_SDK_VERSION=21
Traceback (most recent call last):
  File "../../build/android/gyp/gcc_preprocess.py", line 54, in <module>
    sys.exit(main(sys.argv[1:]))
  File "../../build/android/gyp/gcc_preprocess.py", line 47, in main
    DoGcc(options)
  File "../../build/android/gyp/gcc_preprocess.py", line 31, in DoGcc
    build_utils.CheckOutput(gcc_cmd)
  File "/opt/webrtc/linux_android/src/build/android/gyp/util/build_utils.py", line 257, in CheckOutput
    stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=cwd, env=env)
  File "/usr/lib/python2.7/subprocess.py", line 394, in __init__
    errread, errwrite)
  File "/usr/lib/python2.7/subprocess.py", line 1047, in _execute_child
    raise child_exception
```

```
$ apt install gcc
```

6. 解决AndroidStudio编译出现"Could not resolve all files for configuration ':library:_internal_aapt2_binary'"

再项目Gradle的allprojects中添加google()：

```
allprojects {
    repositories {
        google()
        jcenter()
    }
}
```

7. 生成的项目根目录没有 `gradlew`，可以自己生成一个。

```
gradle wrapper


```
就可以使用了。

To specify a Gradle version use --gradle-version on the command-line. Just execute the command:
```
gradle wrapper --gradle-version <your gradle version>
```


#### [IOS app 编译](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/ios/index.md)



`gn gen out/ios --args='target_os="ios" target_cpu="arm64"' --ide=xcode` 生成 ios 项目时报签名证书找不到的错误：

```
Current dir: /Users/albert/project/webrtc/ios_mac/src/out/ios/
Command: python /Users/albert/project/webrtc/ios_mac/src/build/config/ios/find_signing_identity.py --matching-pattern Apple Development
Returned 1 and printed out:

Automatic code signing identity selection was enabled but could not
find exactly one codesigning identity matching "Apple Development".

Check that the keychain is accessible and that there is exactly one
valid codesigning identity matching the pattern. Here is the parsed
output of `xcrun security find-identity -v -p codesigning`:

    0 valid identities found

See //build/config/sysroot.gni:74:5: whence it was imported.
    import("//build/config/ios/ios_sdk.gni")
    ^--------------------------------------
```

这是因为默认查找 ios APP 打包签名证书。如果没有在主机上安装过苹果的 app 打包签名证书，就会报错。只需要设置为不签名就可以了。

```shell
gn gen out/ios --args='target_os="ios" target_cpu="arm64" is_component_build=false ios_enable_code_signing=false' --ide=xcode
```

> 打开项目好像也不对

使用

```shell
open -a Xcode.app out/ios/all.xcodeproj/project.xcworkspace
```

替换

```
$ open -a Xcode.app out/ios/all.xcworkspace
```

> M1 电脑执行 gclient sync 报错

```
[E2021-03-20T07:20:22.374578+08:00 69470 0 annotate.go:266] original error: exit status 100

goroutine 1:
#0 go.chromium.org/luci/vpython/venv/venv.go:615 - venv.(*Env).installVirtualEnv()
  reason: failed to create VirtualEnv

#1 go.chromium.org/luci/vpython/venv/venv.go:529 - venv.(*Env).createLocked.func2()
  reason: failed to install VirtualEnv

#2 go.chromium.org/luci/common/system/filesystem/tempdir.go:55 - filesystem.(*TempDir).With()
#3 go.chromium.org/luci/vpython/venv/venv.go:103 - venv.withTempDir()
#4 go.chromium.org/luci/vpython/venv/venv.go:515 - venv.(*Env).createLocked()
#5 go.chromium.org/luci/vpython/venv/venv.go:272 - venv.(*Env).ensure.func1()
  reason: failed to create new VirtualEnv

#6 go.chromium.org/luci/vpython/venv/venv.go:995 - venv.mustReleaseLock()
#7 go.chromium.org/luci/vpython/venv/venv.go:258 - venv.(*Env).ensure()
#8 go.chromium.org/luci/vpython/venv/venv.go:154 - venv.With()
  reason: failed to create empty probe environment

#9 go.chromium.org/luci/vpython/run.go:62 - vpython.Run()
#10 go.chromium.org/luci/vpython/application/application.go:320 - application.(*application).mainImpl()
#11 go.chromium.org/luci/vpython/application/application.go:408 - application.(*Config).Main.func1()
#12 go.chromium.org/luci/vpython/application/support.go:46 - application.run()
#13 go.chromium.org/luci/vpython/application/application.go:407 - application.(*Config).Main()
#14 vpython/main.go:110 - main.mainImpl()
#15 vpython/main.go:116 - main.main()
#16 runtime/proc.go:204 - runtime.main()
#17 runtime/asm_amd64.s:1374 - runtime.goexit()
Error: Command 'vpython src/build/landmines.py --landmine-scripts src/tools_webrtc/get_landmines.py --src-dir src' returned non-zero exit status 1 in /Users/a21/project/webrtc/webrtc-checkout
```

更新系统和 golang 版本就好了。


## Mac 编译 android so

https://blog.csdn.net/liuwenchang1234/article/details/107559530

1. 替换 ndk 和 llvm

```
编译 llvm.
./src/tools/clang/scripts/build.py --without-fuchsia
# 或者下面这个复制
# ln -s  /usr/local/Cellar/llvm/<对应版本> third_party/llvm-build/Release+Asserts

```


> fatal error: ‘features.h‘ file not found

替换 ndk.

2. find-bad-constructs'

```
error: unable to find plugin 'find-bad-constructs'
1 error generated.
[44/11084] CXX obj/api/transport/stun_unittest/stun_unittest.o
ninja: build stopped: subcommand failed.
```

[For the clang plugins, add `clang_use_chrome_plugins = false` to your args.gn to disable them.](https://groups.google.com/a/chromium.org/g/blink-dev/c/Ep4GJJHFNYI)

或者使用 `./src/tools/clang/scripts/build.py --without-fuchsia` 编译的 llvm，而不是使用  Mac 系统的。

> jdk

```
  File "/usr/local/Cellar/python@3.9/3.9.4/Frameworks/Python.framework/Versions/3.9/lib/python3.9/subprocess.py", line 1821, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: '/Users/albert/project/webrtc/android_on_mac/src/third_party/jdk/current/bin/javap'
```

java11.4 放到 `third_part/jdk/current/` 目录下。
java8 放到 `third_part/jdk/extras/java_8/` 目录下。


> aapt2

```
[5984/9904] ACTION //examples:AppRTCMobile__compile_resources(//build/toolchain/android:android_clang_arm)
FAILED: gen/examples/AppRTCMobile__compile_resources.srcjar obj/examples/AppRTCMobile.ap_ obj/examples/AppRTCMobile.ap_.info gen/examples/AppRTCMobile__compile_resources_R.txt obj/examples/AppRTCMobile/AppRTCMobile.resources.proguard.txt gen/examples/AppRTCMobile__compile_resources.resource_ids
python3 ../../build/android/gyp/compile_resources.py --include-resources=@FileArg\(gen/examples/AppRTCMobile.build_config:android:sdk_jars\) --aapt2-path ../../third_party/android_build_tools/aapt2/aapt2 --dependencies-res-zips=@FileArg\(gen/examples/AppRTCMobile.build_config:deps_info:dependency_zips\) --extra-res-packages=@FileArg\(gen/examples/AppRTCMobile.build_config:deps_info:extra_package_names\) --extra-main-r-text-files=@FileArg\(gen/examples/AppRTCMobile.build_config:deps_info:extra_main_r_text_files\) --min-sdk-version=21 --target-sdk-version=29 --webp-cache-dir=obj/android-webp-cache --android-manifest gen/examples/AppRTCMobile_manifest/AndroidManifest.xml --srcjar-out gen/examples/AppRTCMobile__compile_resources.srcjar --version-code 1 --version-name Developer\ Build --arsc-path obj/examples/AppRTCMobile.ap_ --info-path obj/examples/AppRTCMobile.ap_.info --debuggable --r-text-out gen/examples/AppRTCMobile__compile_resources_R.txt --dependencies-res-zip-overlays=@FileArg\(gen/examples/AppRTCMobile.build_config:deps_info:dependency_zips\) --proguard-file obj/examples/AppRTCMobile/AppRTCMobile.resources.proguard.txt --emit-ids-out=gen/examples/AppRTCMobile__compile_resources.resource_ids --depfile gen/examples/AppRTCMobile__compile_resources.d
E 54650    906 Subprocess raised an exception:
Traceback (most recent call last):
  File "/Users/albert/project/webrtc/android_on_mac/src/build/android/gyp/util/parallel.py", line 70, in __call__
    return self._func(*_fork_params[index], **_fork_kwargs)
TypeError: 'NoneType' object is not subscriptable

[5993/9904] CXX obj/p2p/rtc_p2p_unittests/basic_port_allocator_unittest.o
```

4. Socket 连接失败

```
python3 ../../build/android/gyp/compile_java.py --depfile=gen/build/android/bytecode/bytecode_processor__errorprone.d --generated-dir=gen/build/android/bytecode/bytecode_processor/generated_java --jar-path=obj/build/android/bytecode/bytecode_processor__errorprone.errorprone.stamp --java-srcjars=\[\"gen/build/android/bytecode/bytecode_processor.generated.srcjar\"\] --header-jar obj/build/android/bytecode/bytecode_processor.turbine.jar --classpath=\[\"obj/build/android/bytecode/bytecode_processor.turbine.jar\"\] --classpath=@FileArg\(gen/build/android/bytecode/bytecode_processor.build_config:deps_info:javac_full_interface_classpath\) --chromium-code=1 --warnings-as-errors --target-name //build/android/bytecode/bytecode_processor__errorprone:bytecode_processor__errorprone --processorpath=@FileArg\(gen/tools/android/errorprone_plugin/errorprone_plugin.build_config:deps_info:host_classpath\) --enable-errorprone @gen/build/android/bytecode/bytecode_processor.sources
Traceback (most recent call last):
  File "/Users/albert/project/webrtc/webrtc-checkout/src/out/arm/../../build/android/gyp/compile_java.py", line 756, in <module>
    sys.exit(main(sys.argv[1:]))
  File "/Users/albert/project/webrtc/webrtc-checkout/src/out/arm/../../build/android/gyp/compile_java.py", line 645, in main
    and server_utils.MaybeRunCommand(name=options.target_name,
  File "/Users/albert/project/webrtc/webrtc-checkout/src/build/android/gyp/util/server_utils.py", line 40, in MaybeRunCommand
    raise e
  File "/Users/albert/project/webrtc/webrtc-checkout/src/build/android/gyp/util/server_utils.py", line 27, in MaybeRunCommand
    sock.connect(SOCKET_ADDRESS)
FileNotFoundError: [Errno 2] No such file or directory
```

在 Mac 上编译一直报错，原来是 `server_utils.py` 连接 socket 和 linux 上运行的结果不一样。 在 `server_utils.py` 的代码

```python
def MaybeRunCommand(name, argv, stamp_file):
  """Returns True if the command was successfully sent to the build server."""

  # When the build server runs a command, it sets this environment variable.
  # This prevents infinite recursion where the script sends a request to the
  # build server, then the build server runs the script, and then the script
  # sends another request to the build server.
  if BUILD_SERVER_ENV_VARIABLE in os.environ:
    return False
  with contextlib.closing(socket.socket(socket.AF_UNIX)) as sock:
    try:
      sock.connect(SOCKET_ADDRESS)
      sock.sendall(
          json.dumps({
              'name': name,
              'cmd': argv,
              'cwd': os.getcwd(),
              'stamp_file': stamp_file,
          }).encode('utf8'))
    except socket.error as e:
      # [Errno 111] Connection refused. Either the server has not been started
      #             or the server is not currently accepting new connections.
      if e.errno == 111:
        return False
      raise e
  return True
```

[`socket.AF_UNIX` 用于同一台机器上的进程间通信](https://blog.csdn.net/ccwwff/article/details/45693253)，是 UNIX 的基本协议。webrtc 编译根本不会启动这个服务，在 Linux 上运行会连接被拒绝，走 `if e.errno == 111:` 这一行，返回 `False` 可以接续执行。而在 Mac 上，会找 `SOCKET_ADDRESS` 所指的文件报：

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
FileNotFoundError: [Errno 2] No such file or directory
```
因为根本没有程序启动这个服务，可以用 `grep -r "chromium_build_server_socket"  <webrtc source dir>` 查找 webrtc 整个源码验证。

为了正常编译，可以修改代码，以忽略这个错误

```
def MaybeRunCommand(name, argv, stamp_file):
  """Returns True if the command was successfully sent to the build server."""

  # When the build server runs a command, it sets this environment variable.
  # This prevents infinite recursion where the script sends a request to the
  # build server, then the build server runs the script, and then the script
  # sends another request to the build server.
  if BUILD_SERVER_ENV_VARIABLE in os.environ:
    return False
  with contextlib.closing(socket.socket(socket.AF_UNIX)) as sock:
    try:
      sock.connect(SOCKET_ADDRESS)
      sock.sendall(
          json.dumps({
              'name': name,
              'cmd': argv,
              'cwd': os.getcwd(),
              'stamp_file': stamp_file,
          }).encode('utf8'))
    except socket.error as e:
      # [Errno 111] Connection refused. Either the server has not been started
      #             or the server is not currently accepting new connections.
      return False
  return True
```

## 编译 so 文件

debug

```shell
gn gen out/arm --args='target_os="android" target_cpu="arm" use_custom_libcxx=false'
```

编译

```shell
ninja -C out/debug
# 或者指定编译目标，更快编译。
# ninja -C out/debug webrtc
cp out/debug/obj/libwebrtc.a <dir>
```

> 链接问题

无法找到 `CreatePeerConnectionFactory`

```
C/C++: ld: error: undefined symbol: webrtc::CreatePeerConnectionFactory(rtc::Thread*, rtc::Thread*, rtc::Thread*, rtc::scoped_refptr<webrtc::AudioDeviceModule>, rtc::scoped_refptr<webrtc::AudioEncoderFactory>, rtc::scoped_refptr<webrtc::AudioDecoderFactory>, std::__ndk1::unique_ptr<webrtc::VideoEncoderFactory, std::__ndk1::default_delete<webrtc::VideoEncoderFactory> >, std::__ndk1::unique_ptr<webrtc::VideoDecoderFactory, std::__ndk1::default_delete<webrtc::VideoDecoderFactory> >, rtc::scoped_refptr<webrtc::AudioMixer>, rtc::scoped_refptr<webrtc::AudioProcessing>, webrtc::AudioFrameProcessor*)
```

通过 nm 工具查看 `libwebrtc.a` 中是否包含该函数

```
$ nm --demangle out/arm64/libwebrtc.a | grep -i webrtc::CreatePeerConnectionFactory

webrtc::CreatePeerConnectionFactory(rtc::Thread*, rtc::Thread*, rtc::Thread*, rtc::scoped_refptr<webrtc::AudioDeviceModule>, rtc::scoped_refptr<webrtc::AudioEncoderFactory>, rtc::scoped_refptr<webrtc::AudioDecoderFactory>, std::__1::unique_ptr<webrtc::VideoEncoderFactory, std::__1::default_delete<webrtc::VideoEncoderFactory> >, std::__1::unique_ptr<webrtc::VideoDecoderFactory, std::__1::default_delete<webrtc::VideoDecoderFactory> >, rtc::scoped_refptr<webrtc::AudioMixer>, rtc::scoped_refptr<webrtc::AudioProcessing>, webrtc::AudioFrameProcessor*)
```
发现确实有，不过其中的的参数是 `std::__1`，而不是 `std::__ndk1`，webrtc 从 M74 版本开始默认的编译变成了 `std::__1`。可以增加 `use_custom_libcxx=false` 参数使 webrtc 构建使用 `std::__ndk1` 命名空间。
```
gn gen out/arm --args='target_os="android" target_cpu="arm" use_custom_libcxx=false'
```

安卓 NDK 已将libc++的内联命名空间更改为std::__ ndk1，以防止平台libc++发生ODR问题。
```
https://groups.google.com/g/discuss-webrtc/c/6s1Tk99Z9Pw/m/4Gs-9VVZAgAJ
https://chromium.googlesource.com/chromium/src/+/refs/heads/main/build/config/c++/c++.gni
```


> 缺少 `OpenSLES`

```
ld: error: undefined symbol: SL_IID_RECORD
>>> referenced by opensles_recorder.cc:287 (../../modules/audio_device/android/opensles_recorder.cc:287)
>>>               opensles_recorder.o:(webrtc::OpenSLESRecorder::CreateAudioRecorder()) in archive /Users/albert/project/android/AndroidTest/app/rtc_demo_native/src/main/cpp/lib/arm64-v8a/libwebrtc.a
>>> referenced by opensles_recorder.cc:287 (../../modules/audio_device/android/opensles_recorder.cc:287)
>>>               opensles_recorder.o:(webrtc::OpenSLESRecorder::CreateAudioRecorder()) in archive /Users/albert/project/android/AndroidTest/app/rtc_demo_native/src/main/cpp/lib/arm64-v8a/libwebrtc.a
clang++: error: linker command failed with exit code 1 (use -v to see invocation)
ninja: build stopped: subcommand failed.
```

在链接配置 `target_link_libraries` 中添加 `OpenSLES`

```
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.
target_link_libraries( # Specifies the target library.
        rtc_demo
        ${OPENGL_LIB}
        android
        native_app_glue
        webrtc
        EGL
        GLESv3
        OpenSLES
        ${camera-lib}
        ${media-lib}
        ${log-lib})
```

> 缺少 rtc_bash 中的 json 格式化函数

修改 src/BUILD.gn
```gn
if (!build_with_chromium) {
  # Target to build all the WebRTC production code.
  rtc_static_library("webrtc") {
    ...
    deps = [
      ...
      "rtc_base:rtc_json", # 添加依赖
    ]
    ... 
  }
}

```