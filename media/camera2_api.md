# Camera2

Android 摄像头使用 CS 设计，有一个专门的服务(服务端)用于拍摄。客户端（app）通过发送请求获取数据。

获取 CameraManager

```Kotlin
fun cameraManager(context: Context): CameraManager {
    return context.applicationContext.getSystemService(Context.CAMERA_SERVICE) as CameraManager
}

```

使用摄像机要在 `AndroidManifest.xml` 中添加权限

```xml
<!-- A camera with (optional) RAW capability is required to use this application -->

<uses-feature android:name="android.hardware.camera.any" />
<uses-feature android:name="android.hardware.camera.raw" android:required="false" />
```
**Any 表示有摄像头就可以使用。否则在有些没有后置摄像头的设备上无法使用，如 ChromeBook**

声明仅用于安装 app 时，使用摄像头需要在代码中申请权限

```Kotlin
private val PERMISSIONS_REQUIRED = arrayOf(Manifest.permission.CAMERA)
private const val PERMISSIONS_REQUEST_CODE = 10

// Request camera-related permissions
requestPermissions(PERMISSIONS_REQUIRED, PERMISSIONS_REQUEST_CODE)

override fun onRequestPermissionsResult(
   requestCode: Int, permissions: Array<String>, grantResults:
   IntArray) {
   super.onRequestPermissionsResult(requestCode, permissions, grantResults)
   if (requestCode == REQUEST_CODE_PERMISSIONS) {
       if (allPermissionsGranted()) {
           startCamera()
       } else {
           Toast.makeText(this,
               "Permissions not granted by the user.",
               Toast.LENGTH_SHORT).show()
           finish()
       }
   }
}

```


## 查询摄像头数据

> 查询摄像头

需要先获取摄像头 ID 数组，然后分别通过 ID 判断是前置还是后置，以及支持的共能。

> 所有摄像头 ID

```Kotlin
cameraManager.cameraIdList // 所有相机 id 数组

cameraManager.concurrentCameraIds // Android R (10+,30) 同时开启的摄像头。
```

> 摄像头具有的功能

一个摄像头具有的功能由硬件本身和底层的系统版本决定。 `CameraCharacteristics` 定义了摄像头功能的一个超集，摄像头支持的功能一定在这个集合中。

- 曝光补偿（Exposure compensation）
- 自动曝光/自动对焦/自动白平衡模式（AE / AF / AWB mode）
- 自动曝光/自动白平衡锁（AE / AWB lock）
- 自动对焦触发器（AF trigger）
- 拍摄前自动曝光触发器（Precapture AE trigger）
- 测量区域（Metering regions）
- 闪光灯触发器（Flash trigger）
- 曝光时间（Exposure time）
- 感光度（ISO Sensitivity）
- 帧间隔（Frame duration）
- 镜头对焦距离（Lens focus distance）
- 色彩校正矩阵（Color correction matrix）
- JPEG 元数据（JPEG metadata）
- 色调映射曲线（Tonemap curve）
- 裁剪区域（Crop region）
- 目标 FPS 范围（Target FPS range）
- 拍摄意图（Capture intent）
- 硬件视频防抖（Video stabilization）等。


通过上一步获取到的 ID 获取对应摄像头支持的功能

```Kotlin
val characteristics = cameraManager.getCameraCharacteristics(camera_id)
```

在 characteristics 查询某项功能

```Kotlin
val capabilities = characteristics.get(CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES)
```

但是该查询的结果可能为空，因为摄像头可能不支持该功能。要想查询摄像头支持的功能的 Key，可以使用。

```Kotlin
val keys = characteristics.keys
```

查询出的 key 用于查询该功能的类型能够保证结果不为空。

对查询的功能获取是否支持该功能的某种类型，例如支持输出格式，但是不一定具有具有某种格式。

``` Kotlin
capabilities?.contains(
            CameraMetadata.REQUEST_AVAILABLE_CAPABILITIES_BACKWARD_COMPATIBLE) ?: false
```


#### get 支持的查询，查询的类型及可能的值

这些值都在 CameraCharacteristics 中定义的常量。属性的类别高达 78 个，更不用说详细的属性值。真是一个庞杂的系统。

##### INFO_SUPPORTED_HARDWARE_LEVEL

由于 Camera1 的历史原因，手机厂商向 Camera2 有个过渡期，所以 Camera2 根据摄像头的支持的功能，划分了不同的等级。功能从弱到强是：

- INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY :向后兼容的级别，处于该级别的设备意味着它只支持 Camera1 的功能，不具备任何 Camera2 高级特性。

- INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED: 除了支持 Camera1 的基础功能之外，还支持部分 Camera2 高级特性的级别。

- INFO_SUPPORTED_HARDWARE_LEVEL_FULL: 支持所有 Camera2 的高级特性。如传感器，闪光灯，镜头和后处理设置进行逐帧手动控制，以及高速率的图像捕获。

- INFO_SUPPORTED_HARDWARE_LEVEL_3: 新增更多 Camera2 高级特性，例如 YUV 数据的后处理以及RAW图像捕获等。

- INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL: API 28 加入，外接摄像头，功能类似于 LIMITED 的设备，但有例外，如一些传感器或镜头信息没有报告或不太稳定的帧率。


LEGACY < LIMITED / EXTERNAL < FULL < LEVEL_3 < （注意值大小并不是按顺序的。）

有一些特殊特性并不能划分的任何一个 Level 中，需要单独查询。它们包括：

校准时间戳：CameraCharacteristics#SENSOR_INFO_TIMESTAMP_SOURCE == REALTIME

精密的镜头控制：CameraCharacteristics#LENS_INFO_FOCUS_DISTANCE_CALIBRATION == CALIBRATED

人脸检测：CameraCharacteristics#STATISTICS_INFO_AVAILABLE_FACE_DETECT_MODES

光学或电子防抖：CameraCharacteristics#LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION, CameraCharacteristics#CONTROL_AVAILABLE_VIDEO_STABILIZATION_MODES

可见，单纯的判断 Level 并没有太大作用，具体到功能上，仍旧需要单独查询是否支持该功能。因此该属性并没有太多用处。

##### REQUEST_AVAILABLE_CAPABILITIES

该相机支持的全部功能，该 key 在所有设备上均可用。

不同的相机可能提供了不同的功能子集，为了得到支持的功能，可以通过该值查询。该查询其实是 ` android.request.availableRequestKeys`， `android.request.availableResultKeys` 和 `android.request.availableCharacteristicsKeys` 查询结果的和。

在 `CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL == FULL` 的设备上以下功能确定可用：

- MANUAL_SENSOR
- MANUAL_POST_PROCESSING

可能的值：

- BACKWARD_COMPATIBLE: 每个摄像头都应该支持的最小功能集。表示满足旧版 API 基准要求的功能集。
    具有 DEPTH_OUTPUT 功能的设备可能未列出此功能，表明它们仅支持深度测量，不支持标准颜色输出。(可能意思是距离测量摄像头，无法输出图像)

- MANUAL_SENSOR: 

- MANUAL_POST_PROCESSING

- RAW: 摄像头设备支持输出RAW缓冲区和用于解释它们的元数据。支持 RAW 输出的设备既可以保存 DNG 文件，也可以直接对原始图像应用图像处理。
    RAW_SENSOR 输出流的最大可用分辨率仅能为以下类别中支持的尺寸：

    - SENSOR_INFO_PIXEL_ARRAY_SIZE

    - SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE

    相机设备将提供有关 DNG 可用元数据的所有类型。
    
- PRIVATE_REPROCESSING: 

- READ_SENSOR_SETTINGS

- BURST_CAPTURE

- YUV_REPROCESSING

- DEPTH_OUTPUT: 相机设备可以从其视场产生深度测量。
    此功能需要摄像头设备支持以下功能：

    - 支持ImageFormat.DEPTH16作为输出格式。

    - 可能支持 ImageFormat.DEPTH_POINT_CLOUD 作为输出格式。

    - 该相机设备以及所有具有相同 CameraCharacteristics＃LENS_FACING 的相机设备将在 CameraCharacteristics 和 CaptureResult 中列出以下校准元数据条目
        - CameraCharacteristics#LENS_POSE_TRANSLATION
        - CameraCharacteristics#LENS_POSE_ROTATION
        - CameraCharacteristics#LENS_INTRINSIC_CALIBRATION
        - CameraCharacteristics#LENS_DISTORTION
    
    - 该设备列出了 CameraCharacteristics#DEPTH_DEPTH_IS_EXCLUSIVE 条目。

    - 从Android P开始，此设备列出了CameraCharacteristics#LENS_POSE_REFERENCE条目。

    - 仅具有 DEPTH_OUTPUT 功能的 LIMITED 级别摄像机不必支持常规的YUV_420_888，Y8，JPEG和PRIV格式的输出。它只需要支持DEPTH16格式。

    通常，深度输出的帧速率比标准颜色捕获的帧速率慢，因此DEPTH16和DEPTH_POINT_CLOUD格式通常具有应考虑的停顿持续时间（请参见StreamConfigurationMap.getOutputStallDuration（int，Size））。 在同时支持基于深度和基于颜色的输出的设备上，为了实现平滑的预览，建议使用重复脉冲，其中每N帧仅包含一次深度输出目标，其中N是预览输出速率与深度之间的比率 输出速率，包括深度失速时间。

- CONSTRAINED_HIGH_SPEED_VIDEO

- MOTION_TRACKING

- LOGICAL_MULTI_CAMERA

- MONOCHROME

- SECURE_IMAGE_DATA

- SYSTEM_CAMERA

- OFFLINE_PROCESSING

##### * SCALER_STREAM_CONFIGURATION_MAP

该摄像头设备支持的可用流配置；还包括每种格式/尺寸组合的最小帧持续时间和停顿持续时间。

所有摄像头都支持 JPEG 格式的传感器支持的最大分辨率（在 SENSOR_INFO_ACTIVE_ARRAY_SIZE 中定义）。

对于给定的摄像头，实际最大支持的分辨率可能低于此处列出的分辨率，具体取决于图像数据的目标Surface。 例如，对于记录视频，所选择的视频编码器的最大限制（例如1080p）可能小于摄像机可以提供的最大限制（例如，最大分辨率为3264x2448）。

Please reference the documentation for the （image data destination）？ to check if it limits the maximum size for image data.

下表列出了要输出最低输出流的配置，这些配置依赖于硬件级别（INFO_SUPPORTED_HARDWARE_LEVEL）

| Format | Size | Hardware Level | Notes |
| ------ | ---- | -------------- | ----- |
| ImageFormat.JPEG | CameraCharacteristics#SENSOR_INFO_ACTIVE_ARRAY_SIZE (*1) | Any |   |	
| ImageFormat.JPEG | 1920x1080 (1080p) | Any | if 1080p <= activeArraySize |
| ImageFormat.JPEG | 1280x720 (720p)   | Any | if 720p <= activeArraySize |
| ImageFormat.JPEG | 640x480 (480p)	   | Any | if 480p <= activeArraySize |
| ImageFormat.JPEG | 320x240 (240p)    | Any |if 240p <= activeArraySize  |
| ImageFormat.YUV_420_888 | all output sizes available for JPEG	| FULL	|  |
| ImageFormat.YUV_420_888 | all output sizes available for JPEG, up to the maximum video size | LIMITED	|    |
| ImageFormat.PRIVATE | same as YUV_420_888	| Any |    |


对于JPEG格式，尺寸可能受到以下条件的限制
    
- HAL 可能将Jpeg尺寸选择为长宽比常见的尺寸（例如4：3、16：9、3：2等）。 如果传感器的最大分辨率（由CameraCharacteristics＃SENSOR_INFO_ACTIVE_ARRAY_SIZE定义）的宽高比不是这些，则其将不被包含在受支持的 JPEG 尺寸中。

- 一些硬件JPEG编码器可能具有像素边界对齐要求，例如尺寸是16的倍数。因此，最大JPEG大小可能小于传感器的最大分辨率。 但是，最大JPEG尺寸将尽可能接近上述限制所给出的传感器最大分辨率。 要求调整宽高比后，由于其他问题而导致的其他尺寸减小必须小于3％。 例如，如果传感器的最大分辨率为3280x2464，如果最大JPEG尺寸的宽高比为4：3，并且JPEG编码器对齐要求为16，则最大JPEG尺寸将为3264x2448

176x144（QCIF）分辨率的例外：摄像头设备通常具有将分辨率从较大的分辨率缩小到较小的图像的固定功能，并且由于对具有高分辨率图像传感器的设备的限制，有时无法完全支持QCIF分辨率。 因此，可能不支持尝试将QCIF分辨率流与任何其他大于1920x1080分辨率（宽度或高度）的流配置在一起，否则，捕获会话创建将失败。


可能的值 ImageFormat 中定义的格式，如 ImageFormat.JPEG，ImageFormat.RAW_SENSOR 等。

##### LENS_FACING

摄像头相对于屏幕的方向

- LENS_FACING_BACK  后置摄像头
- LENS_FACING_FRONT 前置摄像头
- LENS_FACING_EXTERNAL 外接摄像头




https://blog.csdn.net/afei__/article/details/85960343
https://blog.csdn.net/haiping1224746757/article/details/106406400/

https://blog.csdn.net/sjy0118/article/details/78748941