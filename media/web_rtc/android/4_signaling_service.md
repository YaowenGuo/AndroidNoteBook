# RTCPeerConnection API plus servers


WebRTC 是为了建立点对点通信，为了设置和维持 WebRTC 呼叫，WebRTC 客户端（对等段）需要交换元数据。这些数据用于协调沟通。因此这个过程就成为”媒体协商。

- Candidate (network) information.
- Offer 和 answer 信息提供了媒体信息，例如分辨率和编解码。

也就说，在音视频或数据流可以发出之前，需要交换元数据。这个过程称为信令。这些信息包括：

- 候选（网络）信息

- 提供媒体信息（例如分辨率和编解码）的 Offer 和 Answer.

也就是说，在 audio、video 或者数据传输的 P2P 流建立之前， 必须完成 metadata 的数据交换。这个过程叫做发信令。


之前的步骤中，发送和接收 RTCPeerConnection 对象都在一个页面，因此，“信号传递”简化为只是在对象之间传递元数据。

在真实的应用中，链接是在不同的设备之间发生的，就需要一种方法传递这些 metadata。因此，就需要信令服务器：一个在不同 WebRTC 客户端之间传递信息的服务器。真实的信息就是 json 格式文本数据。

由此，你需要信令服务器：可以在 WebRTC 客户端（对等端）之间传输信息的服务器。实际的消息就是纯文本:字符串化的JavaScript对象。

WebRTC 没有标准没有规定信令传输的标准，可以使用任何协议/机制进行传输这些信息。由于 WebRTC 是开源的，并且2017 年制定了国际标准。因此基于标准，有很多信令服务器实现。


为了避免冗余和最大化与已建立技术的兼容性（不限制使用何种技术），发信令方法和协议没有在WebRTC标准中指定。JavaScript会话建立协议(JSEP)描述了连接的大纲。

> WebRTC 呼叫建立的思考是对媒体层完全的定义和控制，但要尽可能将信号层留给应用。原因是不同的应用程序可能更喜欢使用不同的协议，例如现有的 `SIP` 或 `Jingle` 呼叫信令协议，或针对特定应用使用自定义协议，特别是新颖的用例。 在这种方式中，需要交换的关键信息是多媒体会话描述信息，它指定了建立媒体层所需的必要传输（transport）和媒体配置信息。


![](images/signaling.png)

1. app 端首先连接到信令服务器，并提交各自的会话描述信息。
2. 服务器将客户端发送火来的消息发送给另外客户端。
3. 客户端在获取到会话信息后，直接和对方建立连接。（对等方连接）

这种结构也避免了客户端（特别是web应用，http 请求是无状态的）保存状态信息，即，充当信令状态机。相反，如果应用端保存状态，但网页刷新或者应用退出都丢失状态信息，就会有问题。将信令状态保存在服务器上则可以避免这些问题。

JSEP 要求在对等段交换 offer 和 answer ，即上述的媒体元数据信息。这些信息使用 `Session Description Protocol (SDP)` 格式。

```
v=0
o=- 2319080246114730604 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0
a=extmap-allow-mixed
a=msid-semantic: WMS 6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 121 127 120 125 107 108 109 124 119 123 118 114 115 116
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:mbrR
a=ice-pwd:BNpY+m9tnvGeBGPso+M2l7Fi
a=ice-options:trickle
a=fingerprint:sha-256 E4:68:AF:CC:12:18:A6:F9:E8:0F:1B:BD:28:E6:37:C5:87:2C:18:C0:DD:B1:70:DE:E0:74:1A:60:54:28:F0:EA
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:toffset
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 urn:3gpp:video-orientation
a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=extmap:5 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay
a=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type
a=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-timing
a=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/color-space
a=extmap:9 urn:ietf:params:rtp-hdrext:sdes:mid
a=extmap:10 urn:ietf:params:rtp-hdrext:sdes:rtp-stream-id
a=extmap:11 urn:ietf:params:rtp-hdrext:sdes:repaired-rtp-stream-id
a=sendrecv
a=msid:6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J 3809c8ce-d0a2-4093-aa48-12ed85395d8e
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 transport-cc
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 transport-cc
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=fmtp:98 profile-id=0
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 VP9/90000
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 transport-cc
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=fmtp:100 profile-id=2
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=rtpmap:102 H264/90000
a=rtcp-fb:102 goog-remb
a=rtcp-fb:102 transport-cc
a=rtcp-fb:102 ccm fir
a=rtcp-fb:102 nack
a=rtcp-fb:102 nack pli
a=fmtp:102 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f
a=rtpmap:121 rtx/90000
a=fmtp:121 apt=102
a=rtpmap:127 H264/90000
a=rtcp-fb:127 goog-remb
a=rtcp-fb:127 transport-cc
a=rtcp-fb:127 ccm fir
a=rtcp-fb:127 nack
a=rtcp-fb:127 nack pli
a=fmtp:127 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42001f
a=rtpmap:120 rtx/90000
a=fmtp:120 apt=127
a=rtpmap:125 H264/90000
a=rtcp-fb:125 goog-remb
a=rtcp-fb:125 transport-cc
a=rtcp-fb:125 ccm fir
a=rtcp-fb:125 nack
a=rtcp-fb:125 nack pli
a=fmtp:125 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:107 rtx/90000
a=fmtp:107 apt=125
a=rtpmap:108 H264/90000
a=rtcp-fb:108 goog-remb
a=rtcp-fb:108 transport-cc
a=rtcp-fb:108 ccm fir
a=rtcp-fb:108 nack
a=rtcp-fb:108 nack pli
a=fmtp:108 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42e01f
a=rtpmap:109 rtx/90000
a=fmtp:109 apt=108
a=rtpmap:124 H264/90000
a=rtcp-fb:124 goog-remb
a=rtcp-fb:124 transport-cc
a=rtcp-fb:124 ccm fir
a=rtcp-fb:124 nack
a=rtcp-fb:124 nack pli
a=fmtp:124 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d0032
a=rtpmap:119 rtx/90000
a=fmtp:119 apt=124
a=rtpmap:123 H264/90000
a=rtcp-fb:123 goog-remb
a=rtcp-fb:123 transport-cc
a=rtcp-fb:123 ccm fir
a=rtcp-fb:123 nack
a=rtcp-fb:123 nack pli
a=fmtp:123 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=640032
a=rtpmap:118 rtx/90000
a=fmtp:118 apt=123
a=rtpmap:114 red/90000
a=rtpmap:115 rtx/90000
a=fmtp:115 apt=114
a=rtpmap:116 ulpfec/90000
a=ssrc-group:FID 3069108705 4016905269
a=ssrc:3069108705 cname:3Yc30Or4EPpL4rK4
a=ssrc:3069108705 msid:6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J 3809c8ce-d0a2-4093-aa48-12ed85395d8e
a=ssrc:3069108705 mslabel:6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J
a=ssrc:3069108705 label:3809c8ce-d0a2-4093-aa48-12ed85395d8e
a=ssrc:4016905269 cname:3Yc30Or4EPpL4rK4
a=ssrc:4016905269 msid:6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J 3809c8ce-d0a2-4093-aa48-12ed85395d8e
a=ssrc:4016905269 mslabel:6INMjdJ8pgbaTN5CcEr4ZIVVTFcgl0hs7r1J
a=ssrc:4016905269 label:3809c8ce-d0a2-4093-aa48-12ed85395d8e

```

## WebRTC 功能


真实应用中，WebRTC 需要使用服务器。无论多简单的应用，都需要如下的过程。

- 用户发现彼此并交换真实世界的信息，例如名字。
- Get streaming audio, video, or other data.
- Get network information, such as IP addresses and ports, and exchange it with other WebRTC clients (known as peers) to enable connection, even through NATs and firewalls.
- Coordinate signaling communication to report errors and initiate or close sessions.
- Exchange information about media and client capability, such as resolution and codecs.
- Communicate streaming audio, video, or data.

- 用户发现彼此并交换真实世界中的信息，例如名字。

- WebRTC 客户端应用（对等端）交换网络信息。

- 对等端交换有关媒体的信息，例如视频格式和分辨率。

- WebRTC客户端应用程序穿越NAT(Network Address Translation，网络地址转换)网关和防火墙。


也就是说 WebRTC 需要四种类型的 服务器端功能：
- 用户的发现交流
- 信令
- NAT /防火墙穿越
- 对等通信失败时使用中继服务器

To acquire and communicate streaming data, WebRTC implements the following APIs:

三个主要任务：

- 获取 Audio 和 Video
- 传输 Audio 和 Video
- 传输任意数据

由于这三个范畴，因此有了三个主要对象.

- MediaStream gets access to data streams, such as from the user's camera and microphone.
- RTCPeerConnection enables audio or video calling with facilities for encryption and bandwidth management.
- RTCDataChannel enables peer-to-peer communication of generic data.


MediaStream

- MediaStream 代表一个独立且同步的 audio/video 的源或两者都有。
- 每个 MediaStream 包含一个或多个 MediaStream tracks.

![](images/mediaStream.png)

MediaStream 不仅可以从摄像头获取数据，还能从屏幕获取数据流。也能用户视频流分析或者截取图片。

RTCPeerConnection

RTCPeerConnection是WebRTC应用程序用于在对等方之间创建连接，并进行音频和视频通信的API。

要初始化此过程，RTCPeerConnection有两个任务：

- 确定本地媒体情况，例如分辨率和编解码器功能。 这是用于“报价与答”机制的元数据。
- 获取应用程序主机的潜在网络地址，即候选地址。



RTCPeerConnection 将 MediaStream 获得的流作为输入，将 audio 和 video 发送到另一端。当另一端接收到数据流后，将作为一个 MediaStream 输出。另一端即可将其接入到一个 Video 组件中显示或者存储下来。

在底层 RTCPeerConnection 做了很多事情

- 信号处理: 降噪，回音消除
- 编解码选择以及压缩和解压。
- 对等端交流要处理 NAT/防火请穿越，或者在连接失败时使用中继。
- 安全
- 带宽管理



### SDP

RTCSessionDescription objects are blobs that conform to the [Session Description Protocol](https://en.wikipedia.org/wiki/Session_Description_Protocol), SDP. Serialized, an SDP object looks like this:


```sample

```

The acquisition and exchange of network and media information can be done simultaneously, but both processes must have completed before audio and video streaming between peers can begin.


### 信令陷阱

- 在调用setLocalDescription（）之前，RTCPeerConnection不会开始收集候选对象。 这是[JSEP IETF草案中规定的](https://tools.ietf.org/html/draft-ietf-rtcweb-jsep-03#section-4.2.4)。

- 为利用 Trickle ICE 的优势，应该在获得 `candidates` 后立即调用 addIceCandidate();

### Readymade signaling servers

If you don't want to roll your own, there are several WebRTC signaling servers available, which use Socket.IO like the previous example and are integrated with WebRTC client JavaScript libraries:

- webRTC.io is one of the first abstraction libraries for WebRTC.
- Signalmaster is a signaling server created for use with the SimpleWebRTC JavaScript client library.

If you don't want to write any code at all, complete commercial WebRTC platforms are available from companies, such as vLine, OpenTok, and Asterisk.






## ICE 

对等端也需要交换网络信息，“寻找候选对象（finding candidates）” 是指使用ICE框架查找网络接口和端口的过程。

JSEP支持ICE Candidate Trickling，它允许呼叫者在初始报价之后向被呼叫者逐步提供候选者，并使被呼叫者开始对呼叫采取行动并建立连接，而不必等待所有候选者到达。

ICE框架使用STUN协议及其扩展，TURN，使RTCPeerConnection能够处理NAT穿越和其他网络变化。

ICE是一个连接对等体的框架,比如两个视频聊天客户端。ICE 首先尝试通过 UDP 以可能的最低延迟直接连接对等体。在此过程中，STUN服务器只有一项任务：使NAT之后的对等方能够找到其公共地址和端口。 (有关STUN和TURN的更多信息，请参阅[构建WebRTC应用程序所需的后端服务。](https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/))


![STUN](images/stun.png)

由于 Peer 没有公共的 IP 地址，使用 NAT 协议分配一个 IP 地址。但是由于 NAT 协议仅存在于网关上，Peer 并不知道 NAT 转关的共有 IP。而只知道自习的私有 IP。但是如果请求发送到服务器，由于 NAT 公布的是共有 IP 地址。一次服务器知道 NAT 的共有 IP. 

1. Peer 向 SRUM 发送请求，询问 NAT 分配各自己的共有 IP 地址。

2. STUN 服务器将 Peer 的公开 IP 地址返回给 Peer。

3. 此时将 IP 地址发送给网络

如果 UPD 失败，ICE 尝试 TCP。如果由于企业NAT穿透和防火墙的原因导致直接连接失败，ICE使用一个中介(中继)转换服务器（TURN）。表述 ”查找候选（finding candidates）“ 就是指这整个查找网络接口和端口的过程。


For testing, Google runs a public STUN server, stun.l.google.com:19302, as used by appr.tc.

For a production STUN/TURN service, use the coturn https://github.com/coturn/coturn

restund https://github.com/otalk/restund


## 多点连接

WebRTC 当前仅实现了点对点通信。但也可用于更复杂的网络场景，如多个对等体之间直接通信或通过[多点控制单元(MCU, Multipoint Control Unit)](https://en.wikipedia.org/wiki/Multipoint_control_unit)进行通信。可以处理大量参与者并进行选择性流转发以及音频和视频混合或录制的服务器。

but gateway servers can enable a WebRTC app running on a browser to interact with devices, such as telephones (also known as PSTN) and with VOIP systems. 



## 信令服务器搭建


这里以 Google 给出的 `Socket.IO` 作为服务器。Socket.IO 虽然在真实应用中使用并不对，但是因为其简单，作为演示程序非常适合。通过socket.io连接信令服务器, 然后收发数据. 把SDP和IceCandidate转换成json.

socket 服务器端版本和客户端版本有对应，不同版本之间有部分接口不兼容。例如 0.8 版本的信令连接是 `GET` 请求，而 `2.0` 变成了 `POST` 请求。请根据下面文档选择 app 和 服务器端 socker.io 的版本，否则会出现访问不了的问题。

[查看版本对应关系](https://github.com/socketio/socket.io-client-java)

socker.io 可以使用 http，反而配置秘钥更加麻烦。

完整代码在 `./server` 目录下。node 作为服务器启动很简单，只需要在其目录下执行

```shell
num install
node index.js
```

- 启动后，可以现在浏览器验证其连通性。注意输入的地址是否包含 `https` 和端口号。因为服务器没有设置自动跳转，即便是 `80` 端口，在 HTTPS 连接时也需要输入。

- 如果使用自签名证书，不要忘记将自签名证书添加到浏览器所在的电脑信任证书中。因为自签名证书没有根证书的认证链，无法识别。

- 注意 socket 监听(listen)的端口, 要设置为 `0.0.0.0`，否则仅能使用 `127.0.0.1` 访问，其他设备无法通过 IP 地址访问。

```
var fs = require('fs');
var options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};
var app = http.createServer(options, function(req, res) {
  fileServer.serve(req, res);
}).listen(80, "0.0.0.0");
```

### android 7.0 支持 http 连接

从 安卓 7.0 开始，默认不支持 http 连接，必须使用 https。 为了在高版本手机上也能使用 http 连接，需要添加 xml 配置。

在 res/xml 目录下添加资源文件 `network_security_config.xml`，并在此文件中添加。

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
```
在 AndroidManitest.xml 中添加此文件的配置。

```xml
<application
      android:networkSecurityConfig="@xml/network_security_config"
      ...
```

### HTTPS 支持

socket.io 可以使用 HTTP 连接，如果想要使用 HTTPS 连接，尽量使用公共机构签发的证书，也有免费的可以使用。自己生成 SSL 证书验证失败，比较麻烦。还需要自己添加代码，始终信任。多此一举，得不偿失。

***需要使用 HTTPS 的地方主要是浏览器的摄像头获取，如果不使用 HTTPS，通过 ip 地址打开网页将无法调用 `getUserMedia` 获取摄像头，只能通过 `127.0.0.1` 访问。***



## 问题

> ERR_SSL_PROTOCOL_ERROR

检查 HTTPS 设置是否正确

```
const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};
const http = require('https'); // 这里需要设置 `https`，如果是 http 就会出现 ERR_SSL_PROTOCOL_ERROR 错误。
const app = http.createServer(options, function(req, res) {
  fileServer.serve(req, res);
}).listen(80, "0.0.0.0");
```

> 3. https 访问不了。

docker 开放 443 端口用于 TLS 连接。

```
docker run -d -p 80:80 -p 443:443 --name webrtc_server_2 -v /Users/albert/project/webrtc/:/opt/webrtc -it webrtc_server_1 /bin/bash
```

`-p 443:443` 端口开放是必须的。

> 4. 生成 key 和 证书

```
Shortest way. Tested on MacOS, but may work similarly on other OS.

Generate pem

> openssl req -x509 -newkey rsa:2048 -keyout keytmp.pem -out cert.pem -days 365

> openssl rsa -in keytmp.pem -out key.pem
```

> 5. 无法访问 ERR_CONNECTION_REFUSED

可能是端口号问题，不知道是不是 node.js 的问题，即便是 80 端口也需要加上 `https:127.0.0.1:80`。

> 6. ERR_CONNECTION_CLOSED

node 如果没有设置自动跳转，http 必须用 http 地址，https 也必须用 https 的地址访问。


自签名：
https://blog.csdn.net/weixin_30531261/article/details/80891360

https://www.jianshu.com/p/81dbcde4fd7c

https://www.cnblogs.com/aaron-agu/p/10560659.html

https://blog.csdn.net/qq285744011/article/details/103425147

[信令服务器的选择](https://blog.csdn.net/qq_28880087/article/details/106604113)：socket 简单和直接，并且易于理解。但是生产中有更多优秀的信令服务器供选择。 


https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/#how-can-i-build-a-signaling-service

https://bloggeek.me/siganling-protocol-webrtc/


## Select Singling Server

信令消息很小，并且大多在通话开始时进行交换。 在使用 `appr.tc` 进行视频聊天会话的测试中，信令服务处理了大约30-45条消息，所有消息的总大小约为10KB。

WebRTC信令服务在带宽方面相对要求不高，因为它们只需要中继消息和保留少量的会话状态数据(如连接哪些客户端)，所以不会消耗太多的处理或内存。


用于信令的消息服务必须是双向的：客户端到服务器以及服务器到客户端。 双向通信违背HTTP客户端/服务器请求/响应模型，但是为了将数据从Web服务器上运行的服务推送到Web浏览器上运行的Web应用程序，多年来已经开发出各种黑客手段，例如长轮询。



即使建立了会话之后，在其他对等方更改或终止会话的情况下，对等方也需要轮询信令消息。显然轮询不是一个好的选择。

### 可伸缩服务

尽管信令服务在每个客户机上消耗的带宽和CPU相对较少，但一个流行应用程序的信令服务器可能必须处理来自不同位置的大量消息，并且具有较高的并发性。获得大量流量的 WebRTC 应用程序需要信号服务器能够处理相当大的负载。

这里不详细介绍，但是有许多用于高容量、高性能消息传递的选项，包括以下几种：


### 协议选择

[原文](https://bloggeek.me/siganling-protocol-webrtc/)

有五种不同类型的方案可供选择：

| 协议                 |     用户     |  原因   |
| ------------------- | ----------- | ------- |
| XHR/ Comet          | 追求最广泛兼容性 | 因为 WebSockets 还无法在任何地方都得到支持 （只有 Opera Mini 不支持 https://caniuse.com/websockets） |
| WebSockets          | 时尚者       | WebSockets 最新也是最适用于 客户-服务器端通信的 |
| SIP over WebSockets | VoIP顽固派   | 连接现有的后端 | 
| XMPP/Jingle         | XMPP 狂者这  | 能够使用 XMPP |
| Data Channel        | 追求极限和创新的 | 能在建立连接之后用于信令，由于 WebRTC 能够建立 P2P 连接，能够最大限度降低服务器压力。 |



####  Comet / XHR / SSE

从本质上讲，这是一种使Web服务器能够向客户端发送消息的黑技术-在处理通过服务器运行的两个用户/浏览器之间的会话之类的事情时，您需要执行此操作。这种技术有最广泛的支持。

缺点： 

- 伸缩性。 因为它们本质上是黑技术，所以它们倾向于在服务器端占用更多资源，这意味着连接到服务器的浏览器更少，这转化为运营成本。

- 该技术仍然需要您定义自己的专有信令消息。


#### WebSockets

WebSocket是一种更为自然的解决方案，专为全双工客户端与服务器之间的通信而设计，这些消息可以同时在两个方向上流动。 使用纯WebSocket或服务器发送的事件（EventSource）构建的信令服务的一个优势是，这些API的后端可以在大多数Web托管程序包通用的各种Web框架上实现，这些语言支持PHP，Python和 Ruby。

更重要的是，所有支持WebRTC的浏览器在台式机和移动设备上也都支持WebSocket。

2020 年了, WebSockets 不能算新的技术了，但是依旧有 Opera Mini 不支持 WebSocket，想必不支持是因为用户量不值得花费这么多开发人力吧。

优点：

- 快速，服务器有很好的伸缩性。
- 既能传输文本，又能传输二进制数据。有最大的兼容性。

缺点：

- 并非所有的Web服务器和代理都支持它们，因此取决于您的体系结构和网络部署

对于上述缺点，可以考虑使用混合解决方案，例如socket.io或SockJS，如果WebSocket不可用，它们可以自动“降级”到COMET机制。

- 该技术仍然需要您定义自己的专有信令消息。

#### SIP over WebSocket

有预定义好的 SIP 消息，不必自定义消息。

SIP 可以说是糟糕透顶，但是可以完成工作——除非你要将 WebRTC 连接到现有电话后端 IMS 或 RCS 的应用程序，需要“网关”进入SIP。
除非您已经有 SIP 的应用，并且您的用例的主要部分包括呼叫 PSTN，否则请不要使用它。 即使你是VoIP 和 SIP 开发的人员。

#### XMPP(eXtensible Messaging and Presence Protocol )/Jingle

可扩展消息传递和到场协议(eXtensible Messaging and Presence Protocol, XMPP)，最初称为Jabber，这是一种为即时消息传递开发的协议，可用于信令(服务器实现包括ejabberd和Openfire)。JavaScript客户端，比如Strophe.js，使用BOSH来模拟双向流，但是由于各种原因，BOSH可能不如WebSocket那么高效，同样的原因，也可能不能很好地扩展。WebRTC项目使用了来自libjingle库(一个Jingle的c++实现)的网络和传输组件。)

与SIP类似，但是这次使用另一个称为XMPP的标准信令协议。

如果您采用这种方法，则可能是因为您已经安装了XMPP，或者需要XMPP附带的现成功能（以及易于使用的服务器端实现）。

我不是XMPP的拥护者，但是对于这种方法，真说不出什么不好的。 如果你喜欢 XMPP，那就去做吧。


#### Data Channel

Data Channel 是 WebRTC 中用于数据传输的部分。 一旦在两个“端点”之间建立了初始连接，您就可以使用数据通道进行通信并传输你的信令，而无需通过服务器。

优点：

- 信令消息的延迟更低，因为中间没有服务器需要解析和理解它们
- 由于不涉及服务器，因此服务器的可扩展性得到了提高——它处理来自每个已连接浏览器的消息的数量减少了
- 改进了隐私性，仅因为进入服务器可为您提供更少的信息

#### 为什么它如此重要？

选择信令协议将决定某些功能所需的开发工作以及您为此付出的成本–在会话的建立时间，服务器性能等方面。
这个决定不应该掉以轻心。


