# SurfaceView

SurfaceView 继承自 View，常用与对 UI 绘制频率较高，或者绘制较复杂的内容。例如摄像头拍摄，视频播放，游戏。用于 OpenGL 操作的 子类 `GLSurfaceView`, 视频播放的子类 `VideoView`。

该类实现了双缓冲技术，用于高速刷新界面。内部的 holder 用于管理刷新同步。holder 的 surface 用于缓存数据。

SurfaceView 的

