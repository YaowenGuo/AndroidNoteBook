# 信令服务器

WebRTC 是为了建立点对点通信，为了设置和维持 WebRTC 呼叫，WebRTC 客户端（对等段）需要交换元数据。这些数据用于协调沟通。

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

![](images/signaling.png)



## WebRTC 功能

WebRTC apps need to do several things:

- 用户发现彼此并交换真实世界的信息，例如名字。
- Get streaming audio, video, or other data.
- Get network information, such as IP addresses and ports, and exchange it with other WebRTC clients (known as peers) to enable connection, even through NATs and firewalls.
- Coordinate signaling communication to report errors and initiate or close sessions.
- Exchange information about media and client capability, such as resolution and codecs.
- Communicate streaming audio, video, or data.

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



## SDP

RTCSessionDescription objects are blobs that conform to the [Session Description Protocol](https://en.wikipedia.org/wiki/Session_Description_Protocol), SDP. Serialized, an SDP object looks like this:


```sample

```

The acquisition and exchange of network and media information can be done simultaneously, but both processes must have completed before audio and video streaming between peers can begin.


## RTCPeerConnection API plus servers

真实应用中，WebRTC 需要使用服务器。无论多简单的应用，都需要如下的过程。

- 用户发现彼此并交换真实世界中的信息，例如名字。

- WebRTC 客户端应用（对等端）交换网络信息。

- 对等端交换有关媒体的信息，例如视频格式和分辨率。

- WebRTC客户端应用程序穿越NAT(Network Address Translation，网络地址转换)网关和防火墙。

换而言之，WebRTC 需要四种类型的服务端能力：

In other words, WebRTC needs four types of server-side functionality:

- 用户发现和沟通。
- 信令
- NAT/防火墙穿透
- 对等通信失败时中继服务器

可以这么说，ICE框架使用STUN协议及其扩展TURN，使RTCPeerConnection能够处理NAT穿越和其他网络变化。

ICE是一个连接对等体的框架,比如两个视频聊天客户端。ICE 首先尝试通过 UDP 以可能的最低延迟直接连接对等体。在此过程中，STUN服务器只有一项任务：使NAT之后的对等方能够找到其公共地址和端口。 (有关STUN和TURN的更多信息，请参阅[构建WebRTC应用程序所需的后端服务。](https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/))


![STUN](images/stun.png)

由于 Peer 没有公共的 IP 地址，使用 NAT 协议分配一个 IP 地址。但是由于 NAT 协议仅存在于网关上，Peer 并不知道 NAT 转关的共有 IP。而只知道自习的私有 IP。但是如果请求发送到服务器，由于 NAT 公布的是共有 IP 地址。一次服务器知道 NAT 的共有 IP. 

1. Peer 向 SRUM 发送请求，询问 NAT 分配各自己的共有 IP 地址。

2. STUN 服务器将 Peer 的公开 IP 地址返回给 Peer。

3. 此时将 IP 地址发送给网络

如果 UPD 失败，ICE 尝试 TCP。如果由于企业NAT穿透和防火墙的原因导致直接连接失败，ICE使用一个中介(中继)转换服务器（TURN）。表述 ”查找候选（finding candidates）“ 就是指这整个查找网络接口和端口的过程。


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


