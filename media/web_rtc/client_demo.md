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