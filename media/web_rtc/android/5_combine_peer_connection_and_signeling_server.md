RTCPeerConnection API plus servers

WebRTC 建立连接需要交换“会话信息”，这些信息包括

- 本端支持何种格式，以及想还要发送什么信息
- 建立网络连接需要的网络信息。


这些消息的传输可以使用任何消息传递机制，可以使用任何消息协议。甚至连接顺序，WebRTC 对这部分内容没有任何定义。因此可以根据业务逻辑，自己定义连接顺序。



## STUN and TURN

需要服务器做的另一件事是获取对等段回话的全部路由。早互联网的早起，这是一个很简单的事情，因为早期的网络每个设备都有一个公开的 IP 地址。将各自端的 IP 地址通过服务发送给对方即可直接在对等端建立连接。

![](images/noSTUNorTURN.png)

自动有了 NAT，事情变得复杂了。NATs 分发一个私有的 IP 地址，私有 IP 仅用于内部网络定位，对于公共互联网并没有作用。

![](images/firewall.png)

不知道对等端的真实公共 IP 便无法建立对等端连接。这就需要 STUN 服务。

- Tell me what my public IP address is.
- Simple server, cheap to run.
- Data flows peer-to-peer.

STUN 的功能极其简单，WebRTC 向 STUN 发送请求，STUN 接到请求后，就知道请求的来源 IP, 它将此 IP 返回给 WebRTC.


![](images/stun.png)

在图片中，每个 WebRTC 端从 STUN 获取到自己的公共 IP, 将 IP 发送给对方后，即可建立对等连接进行数据传输。

对等连接通常是有效的(例如你的网络受限，或者使用了代理)，但不是所有情况都能成功，此时，我们需要一个中继服务器进行转化，这就是 TURN 。在对等连接不可用时，向云端的中继询问，给我一个公共 IP, 因为该公共 IP 在云端。任何人都可以连接，即可保证通话总是成功。

![](images/STUNandTURN.png)

为了尽可能减少服务器的运行成本，优先使用 STUN 连接，失败后才使用 TURN 服务器。所有这些通过 ICE 自动完成。

![](images/icestats.png)

