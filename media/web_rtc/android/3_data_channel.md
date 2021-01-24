# 发送文本数据

WebRTC 不仅可以传输音视频数据，还能点对点传输普通数据。而传输普通数据使用的是 `DataChannel`。 WebRTC 传输数据和传输音视频的连接建立流程一样。只不过需要在创建 `offer` 之前创建一个 `DataChannel`。


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
