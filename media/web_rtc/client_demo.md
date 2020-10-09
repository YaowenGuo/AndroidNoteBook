# 客户端 Demo

## Android demo

### 1. 前提

- android 的开发官方只提供了 Linux 平台编译，其它平台编译难以保证，作为入门来说，尽快编译通过上手才是第一要素，如果在为了整各个平台上的编译而花费大量时间，恐怕是意见


[详细的安装文档](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/android/index.md)

这里做一些遇到问题的补充。

1. 由于是 google 的东西，还是需要代理才能访问。

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

```
export http_proxy=http://127.0.0.1:1087
export https_proxy=http://127.0.0.1:1087
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