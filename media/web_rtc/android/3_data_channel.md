# 发送文本数据

WebRTC 不仅可以传输音视频数据，还能点对点传输普通数据。而传输普通数据使用的是 `DataChannel`。 WebRTC 传输数据和传输音视频的连接建立流程一样。只不过需要在创建 `offer` 之前创建一个 `DataChannel`。

该API有很多潜在的用例，包括：

- 游戏

- 远程桌面应用

- 实时文字聊天

- 文件传输

- 分散网络

该API有几个特性可以充分利用RTCPeerConnection，并支持强大而灵活的点对点通信
为了简单，故意将 API 设计为何 WebSocket 类似。

- Multiple simultaneous channels with prioritization
- 可选可靠交付和不可靠交付。
- 内置安全性（DTLS）和拥塞控制
- 可选是否同时有音频或视频
- 尽可能低的延迟。



WebRTC 可以传输音视频，也可以单独传输普通数据。也可以同时传输音视频和普通数据。

## 创建 DataChannel

发起者的 `DataChannel` 需要在 `offer` 创建之前创建，因为 `offer`中需要包含是否需要创建 `DataChannel` 的信息。

```kotlin
// 发起端 创建数据通道,必须在发SDP之前
localDataChannel = peerConnection.createDataChannel("send", DataChannel.Init())
peerConnection.createOffer(sdpObserver, MediaConstraints())
```

WebRTC 的 DataChannel 是单工的。如果发起端想要接收数据，响应端也需要在创建 `Answer` 之前，创建 `DataChannel`。

## 发送数据

发送数据必须在会话建立成功后才可以发送。WebRTC 的 Java SDK 封装使用了 NIO 的 buffer，比较难使用。

创建 Buffer

```kotlin
val byteBuffer: ByteBuffer = ByteBuffer.allocate(1024)
val buffer = DataChannel.Buffer(byteBuffer, false)
```

发送数据

```kotlin
byteBuffer.clear()
byteBuffer.put(editText.text.toString().toByteArray())
buffer.data.flip() // 必须提前转变为读取模式。send 是通过 buffer.data.remaining() 获取数据大小的。
val remaining = buffer.data.remaining()
localDataChannel.send(buffer)
```

## 接收数据

**Java 封装的 WebRTC DataChannel 类似于单工通信。主动创建的 `DataChannel` 不能发送数据。想要接收数据，不能用主动创建的 `DataChannel` 注册监听器。否则会引起崩溃。** 如果另一端创建了 DataChannel，本端就会在 `PeerConnection.Observer` 的 `onDataChannel` 收到一个 DataChannel 对象。该对象可以用于接收数据。

```kotlin
val conObserver = object : PeerConnection.Observer {
        // 链接建立后，如果对方要发送数据，会收到回调。使用该 DataChannel 接收数据。
        override fun onDataChannel(dataChannel: DataChannel) {
            dataChannel.registerObserver(object : DataChannel.Observer {
                override fun onMessage(msg: DataChannel.Buffer?) {
                    val data = ByteArray(msg?.data?.remaining() ?: 0)
                    msg?.data?.get(data)
                    // val value = data.toString() // 返回的是地址。
                    findViewById<TextView>(R.id.responderReceive).text = String(data)
                }

                override fun onBufferedAmountChange(amount: Long) {
                }

                override fun onStateChange() {
                    Log.e("onStateChange", "onStateChange: ${remoteDataChannel.state()}")
                }
            })
        }
    ...
    }
```

如果对方创建了发送数据。 会在 `DataChannel.Observer` 的 `onMessage` 中收到数据。如果连接发生改变。则会在 `onStateChange` 会收到回调。

通信是直接在浏览器之间进行的，因此即使在打孔处理防火墙和NAT失败时需要中继（TURN）服务器，RTCDataChannel也可以比WebSocket快得多。

The syntax of RTCDataChannel is deliberately similar to WebSocket。 DataChannel 可以配置为支持不同类型的数据共享，例如优先考虑可靠的交付而不是性能时。

SCTP 是 DataChannel DataChannel 使用的协议。默认情况下可靠、有序数据交付是开启的。何时 RTCDataChannel 需要提供数据可靠交付，何时性能更重要——即使是丢掉一些数据？

When might RTCDataChannel need to provide reliable delivery of data, and when might performance be more important — even if that means losing some data?


3. 


- What does SDP format look like?

- Take a look at chrome://webrtc-internals. This provides WebRTC stats and debugging data. (A full list of Chrome URLs is at chrome://about.)

- With [SCTP](https://bloggeek.me/sctp-data-channel/), the protocol used by WebRTC data channels, reliable and ordered data delivery is on by default. When might RTCDataChannel need to provide reliable delivery of data, and when might performance be more important — even if that means losing some data?

- What alternative messaging mechanisms might be possible? What problems might you encounter using ‘pure' WebSocket?

- What issues might be involved with scaling this application? Can you develop a method for testing thousands or millions of simultaneous room requests?

- What issues might be involved with scaling this application? Can you develop a method for testing thousands or millions of simultaneous room requests?

- This application supports only one-to-one video chat. How might you change the design to enable more than one person to share the same video chat room?

- The example has the room name foo hard coded. What would be the best way to enable other room names?
    1. 由用户可以创建房间，以存在的房间可以在客户端拉取到，点击已存在的房间，可以直接加入。
    2. 避免不同组织的人，创建同名的房间，应该在用户创建的房间的前添加不同组织前缀。

- How would users share the room name? Try to build an alternative to sharing room names.
    - 好友列表从服务器拉取数据分享
    - url 地址
    - 二维码
 
- How could you change the app
    - 优化房间人数
    - 优化多人同时视频
    - 提供音频和视频聊天不同选择
    - 发送文件
    - 加密
    - 作为其他游戏的辅助功能。




## 延伸：为什么 DataChannel 选择 SCTP

https://bloggeek.me/sctp-data-channel/