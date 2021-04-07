# ICE （Interactive Connectivity Establishment, 交互式连接建立）

ICE 是对等端连接的框架，例如两个视频聊天客户端。可以这么说，ICE框架使用 STUN 协议及其扩展、TURN、使 RTCPeerConnection 能够处理NAT穿越和其他变种网络。

![Finding connection candidates](../images/STUN_services.png)


为了尽可能低的延迟 ICE 首先尝试通过 UDP 直接连接对等端。在此过程中，STUN 服务有一个唯一目标：让隐藏在 NAT 网络后的对等端能够找到自己的公共 IP 和端口。

如果 UDP 失败，ICE 尝试 TCP 连接。如果直接连接失败——特别是由于企业NAT穿越和防火墙——ICE 立即使用（中继）TURN 服务器。查找候选(finding candidates)是指查找网络接口和端口的过程。

当