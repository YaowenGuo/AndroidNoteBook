# 本地回环

WebRtc 实现 P2P 链接，但是建立连接的过程需要服务器。在服务器还没有搭建的情况下，可以通过本地的连接来测试本地环境是通畅的。恰好手机一般后前后连个摄像头，就通过同一手机的前后摄像头建立虚拟视频连接。

[参考地址](https://webrtc.github.io/webrtc-org/native-code/native-apis/)
[新文档地址](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/index.md)

![](images/WebRTCNativeAPIsDocument.png)

Calling Sequences

> Set up a call

![](images/WebRTCNativeAPIs_call.png)

> Receive a Call

![](images/WebRTCNativeAPIs_receive.png)

> Close Down a Call

![](images/WebRTCNativeAPIs_close.png)

