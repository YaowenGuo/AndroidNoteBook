```
            ┌--------Sink
Source --> Track --> Sink
            ├--------Sink
            ├         ...
```

- 一个 Track 对应一个音频或者视频流，是流就有输入和输出， Source 是输入，Sink 是输出。一个 Track 只能一个输入，但是有多个输出，比如，一个摄像头的输出既要发送到到远端，又要显示的屏幕预览，则一个 Sink 对应于发送，一个 Sink 对应于屏幕预览。

- 多个媒体对应多个 Track, 例如音频和视频各都应一个 Track。

            
Source 作为数据源，可以有摄像头、麦克风、文件、屏幕采集、远端接收等。以 P2P 通话为例，一个 Souce 用于屏幕采集用于发送，发送方发送的一个 track，在接收端也一定表现为一个 track。

一个 Souce 接收数据。给 track 加 sink 实际上都是给 track 的 source 加 sink。

音频和视频时独立的 Track, 同一个同步的音视频 Track 抽象为 Stream. 一个 track 可以归属于一个或多个 stream，通过 stream id 区分，如果接收端尚不存在对应 stream，则会被创建。

加一个 stream 是为了更灵活的控制本地和远端的 track 组合，比如本地有音视频，但只发送音频。其实直接指定发送哪些 track 也能达到这个效果，但是有多个音视频发送时，如何区分哪个音频对应哪个视频呢？对应的音频和视频也就是 Stream 的概念。

PC 是 PeerConnection 的简称，它表示了终端之间的 P2P 连接，用来传输数据。PC 是 WebRTC 的门面，我们直接使用的都是 PC 的接口。

总结下这四个概念的关系：PC - 一到多个 stream - 零到多个 track - 一个 source和一到多个Sink。




https://xiaozhuanlan.com/topic/2803564197