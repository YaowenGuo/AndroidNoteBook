# WebRTC

WebRTC 是一个包括所有主流平台和服务器的项目，将其放在这里不太合适。既然主要关注于 Android 的 多媒体开发，暂且放在这里。

## WebRTC or RTMP

虽然 RTMP 历史较早，文档可能更多一些，但WebRTC 是主流趋势。


## 安装 git 扩展 depot_tools

depot_tools 是一个用于和 google 开源库管理平台 Chromium 对接的 git 扩展程序。由于 git 的提交是不具名的，所以为了加强开源项目的管理，google 开发了一套 git 扩展程序用于管理提交。

[安装](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)

## 下载 WebRTC 客户端 Native 代码

通常所说的的 WebRTC 是用于 Web 前端的。想要在 Android、ios、Linux、Windos、MaxOS 系统上直接使用 WebRTC，而不是通过浏览器，则只需要下载 Native 部分。因为调用系统硬件需要平台支持，所以 WebRTC 项目开发的时候将将通用的部分使用 Native 代码，web 上使用的指示对 Native 代码的一层封装而已。

[各个平台 native 链接](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/index.md)


## 服务器端

虽然语音通话可以通过建立对等链接（Peer Connection）而直接连接，但是在对等链接之前，建立连接的过程必须有一个中间服务器用于管理。这就是服务器的作用。这个中间服务器也叫信令服务器，负责管理房间，长连接等功能。

- WebRTC 的使用分为三种模式：
P2P(Peer to Peer) 模式：客户端之间建立对等连接（Peer Connection）

- SFU(Selective Forwarding Unit 选择性转发单元)模式:

- MCU(Multi-point Control Unit Multi-point Control Unit)

P2P 模式会尽量在客户端直接建立媒体数据连接，避免使用服务器转发媒体数据（控制，连接等仍要通过服务器）。

SFU 和 MCU 模式则一定会由服务器转发媒体数据。

> 猜测，待继续学习验证：
P2P 适合于音视频通话。
SFU 适合直播，只有一个人录视频，其他人都看。
MCU 适合视频会议，多人视频同时上传和接手。



作为信令服务器的的服务有多种实现，Google 给出的一个 demo 是 AppRTC。 


https://www.sohu.com/a/306564954_120122487
https://blog.csdn.net/ai2000ai/article/details/80705410
https://www.jianshu.com/p/43957ee18f1a
https://blog.csdn.net/lingshengxueyuan/article/details/100519054
https://blog.csdn.net/xiaojax/article/details/105372833

https://blog.csdn.net/momo0853/article/details/85157775

https://blog.csdn.net/tifentan/article/details/53462535
https://rtcdeveloper.com/t/topic/13341

https://blog.csdn.net/jieqiang3/article/details/89604025

https://github.com/webrtc/apprtc