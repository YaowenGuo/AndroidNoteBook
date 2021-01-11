# Server

WebRTC 的通话是 P2P 的，但是建立连接过程需要一个媒介，这个媒介就是信令服务器。由于 WebRTC 是开源的，并且2017 年制定了国际标准。因此基于标准，有很多信令服务器实现。在现有的网络中实现 P2P 通信，客户端应用程序需要通过NAT网关和防火墙。并且如果直接连接失败，对等连接网络需要回退。在此过程中，WebRTC API使用STUN服务器获取计算机的IP地址，并在对等通信失败的情况下使用TURN服务器充当中继服务器。 （真实世界中的WebRTC进行了详细说明。）

- NAT: （Network Address Translation，网络地址转换）是1994年提出的。当在专用网内部的一些主机本来已经分配到了本地IP地址（即仅在本专用网内使用的专用地址），但现在又想和因特网上的主机通信（并不需要加密）时，可使用NAT方法。

    是1994年提出的。当在专用网内部的一些主机本来已经分配到了本地IP地址（即仅在本专用网内使用的专用地址），但现在又想和因特网上的主机通信（并不需要加密）时，可使用NAT方法。


- STUN:（Session Traversal Utilities for NAT，NAT会话穿越应用程序）是一种网络协议，它允许位于NAT（或多重NAT）后的客户端找出自己的公网地址，查出自己位于哪种类型的NAT之后以及NAT为某一个本地端口所绑定的Internet端端口。这些信息被用来在两个同时处于NAT路由器之后的主机之间创建UDP通信。该协议由RFC 5389定义。


- turn:（Traversal Using Relay NAT，即通过Relay方式穿越NAT）TURN应用模型通过分配TURNServer的地址和端口作为客户端对外的接受地址和端口，即私网用户发出的报文都要经过TURNServer进行Relay转发，这种方式应用模型除了具有STUN方式的优点外，还解决了STUN应用无法穿透对称NAT（SymmetricNAT）以及类似的Firewall设备的缺陷，即无论企业网/驻地网出口为哪种类型的NAT/FW，都可以实现NAT的穿透，同时TURN支持基于TCP的应用，如H323协议。此外TURNServer控制分配地址和端口，能分配RTP/RTCP地址对（RTCP端口号为RTP端口号加1）作为本端客户的接受地址，避免了STUN应用模型下出口NAT对RTP/RTCP地址端口号的任意分配，使得客户端无法收到对端发过来的RTCP报文（对端发RTCP报文时，目的端口号缺省按RTP端口号加1发送）

    TURN的局限性在于所有报文都必须经过TURNServer转发，增大了包的延迟和丢包的可能性。


所有WebRTC组件都必须进行加密，并且只能从安全来源（HTTPS或本地主机）使用其JavaScript API。 信令机制不是WebRTC标准定义的，因此要确保使用安全协议。


[信令服务器的选择](https://blog.csdn.net/qq_28880087/article/details/106604113)：socket 简单和直接，并且易于理解。但是生产中有更多优秀的信令服务器供选择。 


https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/#how-can-i-build-a-signaling-service

https://bloggeek.me/siganling-protocol-webrtc/


P2P 建立连接


## 搭建服务器

为了更好的在多个平台运行，而不是配个多个平台，这里使用 Docker 配置服务器。

这里以 Google 给出的 `Socket.IO` 作为服务器。

WebRTC 建立一条 P2P 连接需要交换一些元数据，包括：

- 候选（网络）信息

- 提供媒体信息（例如分辨率和编解码）的 Offer 和 Answer.

也就是说，在 audio、video 或者数据传输的 P2P 流建立之前， 必须完成 metadata 的数据交换。这个过程叫做发信令。

之前的步骤中，发送和接收 RTCPeerConnection 对象都在统一个页面，因此，“信号传递”简化为只是在对象之间传递元数据。

在真实的应用中，链接是在不同的设备之间发生的，就需要一种方法传递这些 metadata。因此，就需要信令服务器：一个在不同 WebRTC 客户端之间传递信息的服务器。真实的信息就是 json 格式文本数据。

