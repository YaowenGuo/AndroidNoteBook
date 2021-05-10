# 多点通话服务器选择

WebRTC 需要两种服务器：
- Signaling Server
- TURN 

两人的点对点通话是最简单的模型，然而多人通话在实际场景中很普遍，例如视频会议，小组讨论等。多人通话连接和数据变得复杂起来。在多人视频的场景中，想要任意两个人都能进行视频通话，WebRTC 应用可以创建多个 RTCPeerConnections 对象以进行多点通话。WebRTC 实现多人通话的连接方式有三种：

## MESH(网状)

![Mash](images/mesh.png)

网状连接在任意两个端之间建立一条独立的连接，在通话人数较少时，这能够较好的工作，然而，当人数增多是，连接的数量将呈指数型增长。以 4 人通话为例，每一个用户都要同时将三个对等端发送数据，而且接收三个对等端的数据。连接的数量将是 n(n - 1)/2，呈指数增长。

## SFU(Selective Forwarding Unit 可选择转发单元) 

MESH 的问题是，发送数据要想每个对等端都发送一遍，这显得有点重复。因此想要减少这方面的数据发送。可以选择一个端点，作为中转发送，以星型的方式连接。也可以在服务器上运行WebRTC端点，并构建自己的再分配机制(webrtc.org提供了一个示例客户机应用程序)。

![SFU](images/SFU.png)

从 Chrome 31 和 Opera 18，一个来自一个RTCPeerConnection的MediaStream可以被用作另一个RTCPeerConnection的输入。这可以实现更灵活的架构，因为它使web应用程序能够通过选择连接哪个对等点来处理调用路由。


## MCU (Multipoint Control Unit 多端控制单元) 

MCU 使用专门的设备做中间转发单元，同时将多个数据流混合，负责混流处理和转发流。每个端点只跟数据转发设备建立连接，同时，由于转发设备进行了混流，每个人只需要建立一个连接。这种方案对服务器的要求最高。


![MCU](images/MCU.png)

MCU 作为在大量参与者之间分发媒体的桥梁的服务器，mcu可以在视频会议中处理不同的分辨率、编解码器和帧率;处理代码转换;进行选择性流转发;并混合或录制音频和视频。

https://blog.csdn.net/qq_28880087/article/details/106601309


WebRTC 是一组标准协议，有很多开源的服务器可供选择。

https://blog.csdn.net/ai2000ai/article/details/80705410

https://docs.wire.com/understand/restund.html

https://github.com/coturn/coturn

https://blog.csdn.net/qq_28880087/article/details/106604113