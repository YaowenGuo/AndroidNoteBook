# Capture

## 引入依赖库

```
dependencies {
    implementation "org.webrtc:google-webrtc:$webrtc_version"
}
```

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

WebRTC 对 Android 的 相机接口进行了封装，提供了 Camera1 和 Camera2 类使用。由于 Camera2 才是主流应用，这里使用 Camera2 做示例。

```kotlin
// 2. Create a VideoCapturer instance which uses the camera of the device
private fun createCameraCapturer(): VideoCapturer? {
    val enumerator = Camera2Enumerator(this)
    val deviceNames = enumerator.deviceNames

    // First, try to find front facing camera
    for (deviceName in deviceNames) {
        if (enumerator.isFrontFacing(deviceName)) {
            val videoCapturer: VideoCapturer? = enumerator.createCapturer(deviceName, null)
            if (videoCapturer != null) {
                return videoCapturer
            }
        }
    }

    // Front facing camera not found, try something else
    for (deviceName in deviceNames) {
        if (!enumerator.isFrontFacing(deviceName)) {
            val videoCapturer: VideoCapturer? = enumerator.createCapturer(deviceName, null)
            if (videoCapturer != null) {
                return videoCapturer
            }
        }
    }
    return null
}
```

## 开启摄像头

WebRTC 是专门用于实时通信的，并没有独立开启摄像头的 API，我们使用对等连接的方式，开启摄像头。

```kotlin
private fun openTrack(videoCapturer: VideoCapturer) {
    // 1. Create and initialize PeerConnectionFactory
    val initializationOptions = InitializationOptions.builder(this).createInitializationOptions()
    PeerConnectionFactory.initialize(initializationOptions)
    val peerConnectionFactory = PeerConnectionFactory.builder().createPeerConnectionFactory()


    val eglBaseContext = EglBase.create().eglBaseContext
    val localView: SurfaceViewRenderer = findViewById(R.id.localView)
    localView.setMirror(true)
    localView.init(eglBaseContext, null)

    // 3. Create a VideoSource from the Capturer
    val videoSource: VideoSource = peerConnectionFactory.createVideoSource(videoCapturer.isScreencast)
    val videoTrack: VideoTrack = peerConnectionFactory.createVideoTrack("101", videoSource)

     // 4. Create a VideoTrack from the source
     val audioSource: AudioSource = peerConnectionFactory.createAudioSource(MediaConstraints())
    val audioTrack: AudioTrack = peerConnectionFactory.createAudioTrack("101", audioSource)

    // 5. Create a video renderer using a SurfaceViewRenderer view and add it to the VideoTrack instance
    videoTrack.addSink(localView)

    // 6. 开启摄像头。
    val surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", eglBaseContext)
    videoCapturer.initialize(
        surfaceTextureHelper,
        applicationContext,
        videoSource.capturerObserver
    )
    videoCapturer.startCapture(480, 640, 30)

}

// 连接相机获取和开启

val videoCapturer: VideoCapturer? = createCameraCapturer()
videoCapturer?.let {
    openTrack(it)
}
```

