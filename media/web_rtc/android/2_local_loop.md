# 本地回环

WebRtc 实现 P2P 链接，但是建立连接的过程需要服务器。在服务器还没有搭建的情况下，可以通过本地的连接来测试本地环境是通畅的。大部分手机都只能同时开启一个摄像头。因此这里将两个连接端的数据源使用同一个摄像头。两端收到的将是同样的视频数据。

![](images/WebRTCNativeAPIsDocument.png)


对于建立连接，发送端和接收端的流程是：
> Set up a call

![](images/WebRTCNativeAPIs_call.png)

First, Alice and Bob exchange network information. (The expression finding candidates refers to the process of finding network interfaces and ports using the ICE framework.)

- Alice creates an RTCPeerConnection object with an onicecandidate handler, which runs when network candidates become available.
- Alice sends serialized candidate data to Bob through whatever signaling channel they are using, such as WebSocket or some other mechanism.
- When Bob gets a candidate message from Alice, he calls addIceCandidate to add the candidate to the remote peer description.

WebRTC clients (also known as peers, or Alice and Bob in this example) also need to ascertain and exchange local and remote audio and video media information, such as resolution and codec capabilities. Signaling to exchange media configuration information proceeds by exchanging an offer and an answer using the Session Description Protocol (SDP):

- Alice runs the RTCPeerConnection createOffer() method. The return from this is passed an RTCSessionDescription—Alice's local session description.
- In the callback, Alice sets the local description using setLocalDescription() and then sends this session description to Bob through their signaling channel. Note that RTCPeerConnection won't start gathering candidates until setLocalDescription() is called. This is codified in the JSEP IETF draft.
- Bob sets the description Alice sent him as the remote description using setRemoteDescription().
- Bob runs the RTCPeerConnection createAnswer() method, passing it the remote description he got from Alice so a local session can be generated that is compatible with hers. The createAnswer() callback is passed an RTCSessionDescription. Bob sets that as the local description and sends it to Alice.
When Alice gets Bob's session description, she sets that as the remote description with setRemoteDescription.
Ping!


> Receive a Call

![](images/WebRTCNativeAPIs_receive.png)

4. Add Stream

在创建了 MeidaTrack 后，就可以创建 PeerConnection 了.

```kotlin
public fun connection(
    videoTrack: VideoTrack?,
    sdp: SessionDescription?,
    observer: DspAndIdeObserver
): PeerConnection {
    // server 参数传空列表，将创建本地连接。
    val iceServers: List<PeerConnection.IceServer> = ArrayList()
    // 创建 PeerConnection 对象。
    val peerConnection = peerConnectionFactory.createPeerConnection(
        iceServers,
        object : PeerConnection.Observer {
            override fun onSignalingChange(signalingState: PeerConnection.SignalingState) {}
            override fun onIceConnectionChange(iceConnectionState: PeerConnection.IceConnectionState) {}
            override fun onIceConnectionReceivingChange(b: Boolean) {}
            override fun onIceGatheringChange(iceGatheringState: PeerConnection.IceGatheringState) {}
            override fun onIceCandidate(iceCandidate: IceCandidate) {
                observer.onIceCreate(iceCandidate) // 通过 singling 服务器发送 ice。
            }

            override fun onIceCandidatesRemoved(iceCandidates: Array<IceCandidate>) {}
            override fun onAddStream(mediaStream: MediaStream) {
                observer.onAddMediaStream(mediaStream) // 连接之后收到的数据流。
            }

            override fun onRemoveStream(mediaStream: MediaStream) {
                observer.onRemoveMediaStream(mediaStream)
            }
            override fun onDataChannel(dataChannel: DataChannel) {}
            override fun onRenegotiationNeeded() {}
            override fun onAddTrack(
                rtpReceiver: RtpReceiver,
                mediaStreams: Array<MediaStream>
            ) {
            }
        })!!

    // 创建 MediaStream 对象。
    val mediaStream = peerConnectionFactory.createLocalMediaStream(if (sdp == null)  "offerMediaStream" else "answerMediaStream")
    mediaStream.addTrack(videoTrack)
    // 添加 MediaStream. 
    peerConnection.addStream(mediaStream)
    // 用户创建 Offer 或者 Answer 的回调。
    val sdpObserver = object : SdpObserver {
        override fun onCreateSuccess(sdp: SessionDescription) {
            // 使用 createOffer 创建的是 offer, 使用 createAnswer 创建的是 answer.
            // 太蠢了，自己的 description 为什么还要设置一次?
            peerConnection.setLocalDescription(this, sdp)
            observer.onDspCreate(sdp)
        }

        override fun onSetSuccess() {}
        override fun onCreateFailure(s: String) {}
        override fun onSetFailure(s: String) {}
    }

    // 如果是连接发起者，要创建 offer.
    if (sdp == null) {
        peerConnection.createOffer(sdpObserver, MediaConstraints())
    } else {
        // 如果是响应者，需要先设置 `offer`, 然后才能根据 `offer` 和本地支持的情况，创建 `answer`。 
        peerConnection.setRemoteDescription(sdpObserver, sdp)
        // 创建 answer。
        peerConnection.createAnswer(sdpObserver, MediaConstraints())
    }
    return peerConnection;
}
```

其中 `onIceCandidate` 用于在连接的后，交换 `iceCandidate`。`observer` 是自己定义的 `DspAndIdeObserver` 对象，由于 `PeerConnection.Observer` 回调函数比较多，我们自己创建一个 `DspAndIdeObserver` 来简化回调数量。

```kotlin
interface DspAndIdeObserver {
    fun onDspCreate(sessionDescription: SessionDescription) {};

    fun onIceCreate(iceCandidate: IceCandidate)

    fun onAddMediaStream(mediaStream: MediaStream) {}

    fun onRemoveMediaStream(mediaStream: MediaStream) {}
}
```
发起连接

```kotlin

lateinit var peerConnectionRemote: PeerConnection
lateinit var peerConnectionLocal: PeerConnection
val sdpObserver = object : SdpObserver {
    override fun onSetFailure(msg: String?) {
    }

    override fun onSetSuccess() {
    }

    override fun onCreateSuccess(sdp: SessionDescription?) {
    }

    override fun onCreateFailure(msg: String?) {
    }
}

private fun call(videoTrack: VideoTrack) {
    peerConnectionLocal = RtcEngine.INSTANCE.connection(videoTrack, null, object :
        RtcEngine.DspAndIdeObserver {
        override fun onDspCreate(sdp: SessionDescription) {
            // 通过 Singling 服务器发送 offer。对方接收到后设置。
            answer(videoTrack, sdp)
        }

        override fun onIceCreate(iceCandidate: IceCandidate) {
            // 通过 Singling 服务器发送 ice。对方接收到后设置。
            peerConnectionRemote.addIceCandidate(iceCandidate)
        }

        override fun onAddMediaStream(mediaStream: MediaStream) {
            // 接收数据流
            runOnUiThread {
                val video = mediaStream.videoTracks[0]
                RtcEngine.INSTANCE.displayVideo(
                    video,
                    findViewById(R.id.localView),
                    eglBaseContext
                )
            }
        }
    })
}

// 接收端在接收到 offser（SessionDescription）后。创建 `PeerConnection`，并发送 `answer` 给对方。
private fun answer(videoTrack: VideoTrack, sdp: SessionDescription) {
    peerConnectionRemote = RtcEngine.INSTANCE.connection(videoTrack, sdp, object :
        RtcEngine.DspAndIdeObserver {
        override fun onDspCreate(sdp: SessionDescription) {
            // 应答方通过 Singling 服务器发送 answer。对方接收到后设置。
            peerConnectionLocal.setRemoteDescription(sdpObserver, sdp)
        }

        override fun onIceCreate(iceCandidate: IceCandidate) {
            // 通过 Singling 服务器发送 ice。对方接收到后设置。
            peerConnectionLocal.addIceCandidate(iceCandidate)
        }

        override fun onAddMediaStream(mediaStream: MediaStream) {
            // 接收数据流
            runOnUiThread {
                val video = mediaStream.videoTracks[0]
                RtcEngine.INSTANCE.displayVideo(
                    video!!,
                    findViewById(R.id.remoteView),
                    eglBaseContext
                )
            }
        }
    })
}
```


> Close Down a Call

![](images/WebRTCNativeAPIs_close.png)


[参考地址](https://webrtc.github.io/webrtc-org/native-code/native-apis/)
[新文档地址](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/index.md)