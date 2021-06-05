# Capture

## 引入依赖库

```
dependencies {
    implementation "org.webrtc:google-webrtc:$webrtc_version"
}
```
在网站查看该库的最新版本号 https://mvnrepository.com/artifact/org.webrtc/google-webrtc?repo=bt-google-webrtc

## 申请权限

AndroidManifest.xml 中声明要使用相机和录音。

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

动态申请权限。

```kotlin
private const val PERMISSIONS_REQUEST_CODE = 10
private val PERMISSIONS_REQUIRED = arrayOf(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)

if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            requestPermissions(PERMISSIONS_REQUIRED, PERMISSIONS_REQUEST_CODE)
} else {
    Toast.makeText(this, "Android Api must not less 23", Toast.LENGTH_LONG).show()
}

```

## 获取相机

![](images/WebRTCNativeAPIsDocument.png)


WebRTC 标准定义了 MediaStream 对象。用于抽象媒体流。数据的源头可能是摄像头、话筒、屏幕截图、甚至是文件。虽然各中平台因为语言和编程哲学的不一而创建方法不一，但是只要符合标准，都有 MediaStram。 

WebRTC implements these three APIs:

```
MediaStream (also known as getUserMedia)
RTCPeerConnection
RTCDataChannel

```

由于 WebRTC 主要还是用于音视频通话，这里以视频采集为例。WebRTC 对 Android 的相机接口进行了封装，提供了 Camera1 和 Camera2 类使用。由于 Camera2 才是主流应用，这里使用 Camera2 做示例。

1. 为例创建一个摄像头的 VideoTrack, 由于牵涉到硬件，各个端实现的方式不一样。安卓端使用 Capture 来描述这一概念。

```kotlin
public fun createCameraCapturer(
    context: Context,
    lensFacing: Int = CameraMetadata.LENS_FACING_FRONT
): VideoCapturer? {
    val enumerator = Camera2Enumerator(context)
    val deviceNames = enumerator.deviceNames

    var videoCapturer: VideoCapturer? = null
    for (deviceName in deviceNames) {
        when (lensFacing) {
            CameraMetadata.LENS_FACING_FRONT -> {
                if (enumerator.isFrontFacing(deviceName)) {
                    videoCapturer = enumerator.createCapturer(deviceName, null)
                }
            }
            CameraMetadata.LENS_FACING_BACK -> {
                if (enumerator.isBackFacing(deviceName)) {
                    videoCapturer = enumerator.createCapturer(deviceName, null)
                }
            }

            CameraMetadata.LENS_FACING_EXTERNAL -> {
                if (!enumerator.isFrontFacing(deviceName) && !enumerator.isBackFacing(deviceName)) {
                    videoCapturer = enumerator.createCapturer(deviceName, null)
                }
            }
            else -> {
                videoCapturer = enumerator.createCapturer(deviceName, null)
            }
        }

        if (videoCapturer != null) {
            break
        }
    }
    return videoCapturer
}
```

## 2. 创建 PeerConnectionFactory

```kotlin
 public fun createPeerConnection(eglBaseContext: EglBase.Context, applicationContext: Context): PeerConnectionFactory {
    val initializationOptions = PeerConnectionFactory.InitializationOptions
        .builder(applicationContext)
        .createInitializationOptions()
    PeerConnectionFactory.initialize(initializationOptions);

    val options = PeerConnectionFactory.Options()
    val defaultVideoEncoderFactory = DefaultVideoEncoderFactory(eglBaseContext, true, true)
    val defaultVideoDecoderFactory = DefaultVideoDecoderFactory(eglBaseContext)

    return PeerConnectionFactory.builder()
        .setOptions(options)
        .setVideoEncoderFactory(defaultVideoEncoderFactory)
        .setVideoDecoderFactory(defaultVideoDecoderFactory)
        .createPeerConnectionFactory()
}
```

## 3. 创建 Video/Audio Track.

`Track` 原意是铁轨的意思，两条铁轨并行向前，永远也不相交。音轨和视频也是类似的，或者多条音视频轨，随着时间的推进，音轨和视频同时录制和采样，但是数据却是分别记录的，没有任何交集。两者只有时间上的同步，数据本身没有任何瓜葛。


```
// create VideoTrack
fun createVideoTrack(
    peerConnectionFactory: PeerConnectionFactory,
    id: String,
    videoCapturer: VideoCapturer,
    applicationContext: Context,
    eglBaseContext: EglBase.Context,
    captureThread: String = "CaptureThread"
): VideoTrack {

    val videoSource: VideoSource = peerConnectionFactory.createVideoSource(videoCapturer.isScreencast)
    val videoTrack: VideoTrack = peerConnectionFactory.createVideoTrack(id, videoSource)

    val surfaceTextureHelper = SurfaceTextureHelper.create(captureThread, eglBaseContext)

    videoCapturer.initialize(
        surfaceTextureHelper,
        applicationContext,
        videoSource.capturerObserver
    )
    // 开启摄像头。
    videoCapturer.startCapture(480, 640, 30)
    return videoTrack
}
```

## 显示

```kotlin
public fun displayVideo(
    videoTrack: VideoTrack,
    displayView: SurfaceViewRenderer,
    eglBaseContext: EglBase.Context
) {
    // display
    displayView.init(eglBaseContext, null)
    displayView.setMirror(true)
    // display in localView
    videoTrack.addSink(displayView)
}
```

## 完整调用。

```
val videoCapturer = RtcEngine.INSTANCE.createCameraCapturer(this, CameraMetadata.LENS_FACING_FRONT)
videoCapturer?.let {
    val captureId = "1"
    // Must use save eglContext
    val eglBaseContext = EglBase.create().eglBaseContext

    val peerConnection = RtcEngine.INSTANCE.createPeerConnection(this)
    val videoTrack = RtcEngine.INSTANCE.createVideoTrack(peerConnection, captureId, it, this, eglBaseContext)
    val audeoTrack = RtcEngine.INSTANCE.createAudioTrack(peerConnection, captureId)
    RtcEngine.INSTANCE.displayVideo(videoTrack, findViewById(R.id.localView), eglBaseContext)
}
```

API 的很小一部分创建图像捕获就包含如此多的代码，可见视频捕获的复杂性。而之所以有如此多的步骤 API 暴露出来，而不是封装起来只保留少数几个函数，其实是因为相机设置参数的复杂。有过相机开发经验的同学一定对此感触颇深。
