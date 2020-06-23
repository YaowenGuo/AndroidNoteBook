[TOC]

# 消息/事件（发布-订阅设计模式）

不同页面甚至应用之间的消息（事件）传递，事件响应至关重要，因为在一个页面的事件处理，可能响应的要更新另一页面的显示效果，或者作出响应的响应。例如在首页显示的消息数量，在进入一个消息后，首页的消息数量应该减少或者消失。


## 系统自带 Broadcasts 和 Broadcast receivers

 Broadcasts are messaging components used for communicating across different apps, and also with the Android system, when an event of interest occurs. Broadcast receivers are the components in your Android app that listen for these events and respond accordingly.

从名字就可以看出，这是一对消息处理组件。一个用于发送，一个用户接收。

Broadcasts 是Android系统和Android应用在发生可能影响其他应用功能的事件时发送的消息（Broadcasts 是消息）。通常，广播是用于在感兴趣的事件发生时跨应用进行通信的消息传递组件。

### 广播

广播有两种类型：
- 系统广播由系统提供。
- 自定义广播由您的应用提供。

> 系统广播，系统发出的

- 系统广播必须注册进行监听才能收到。
- 从Android 7.0开始，不支持系统广播操作ACTION_NEW_PICTURE和ACTION_NEW_VIDEO。
- 要获取系统可以为特定SDK版本发送的完整广播操作列表，请检查SDK文件夹中的 `broadcast_actions.txt` 文件，位于以下路径：`Android/sdk/platforms/android-xx/data`，其中 `xx` 是
SDK版本。

> 自定义广播

自定义广播是您的应用发送的广播。
如果希望应用在不启动活动的情况下执行操作，请使用自定义广播。
例如，当您希望让其他应用知道数据已下载到设备并可供他们使用时，请使用自定义广播。
可以注册多个广播接收器来接收您的广播。

注意：为Intent指定操作时，请使用您的唯一包名称（例如com.example.myproject）以确保您的意图不会与从其他应用程序或Android系统广播的意图冲突

提供自定义广播有三种方式：
- 普通广播，将 Intent 传递给sendBroadcast（）。
- 有序广播，将 Intent 传递给sendOrderedBroadcast（）。
- 本地广播，将 Intent 传递给LocalBroadcastManager.sendBroadcast（）。

#### 普通广播

sendBroadcast（）方法以未定义的顺序同时向所有已注册的接收器发送广播。这称为普通广播。普通广播是发送广播的最有效方式。对于普通广播，接收器不能在它们之间传播结果，并且它们不能取消广播。

#### 有序广播
要一次向一个接收器发送广播，请使用sendOrderedBroadcast（）方法：
- 在intent过滤器中指定的android：priority 属性确定广播的发送顺序。
- 如果存在多个具有相同优先级的接收器，则发送顺序是随机的。
- Intent 从一个接收器传播到下一个接收器。
- 在轮流期间，接收器可以更新 Intent ，或者它可以取消广播。（如果接收方取消广播，则 Intent 无法进一步传播。）

```java
public void sendOrderedBroadcast() {
   Intent intent = new Intent();

   // Set a unique action string prefixed by your app package name.
   intent.setAction("com.example.myproject.ACTION_NOTIFY");
   // Deliver the Intent.
   sendOrderedBroadcast(intent);
}
```

#### 本地广播

如果您不需要将广播发送到其他应用程序，请用 LocalBroadcastManager.sendBroadcast() 方法，该方法将广播发送到应用程序中的接收方。此方法很有效，因为它不涉及进程间通信。此外，使用本地广播可以保护您的应用免受某些安全问题的影响

```java
 LocalBroadcastManager.getInstance(this).sendBroadcast(customBroadcastIntent);
```


### 广播接收器

广播接收器是可以接收系统事件或应用事件的应用程序组件。当事件发生时，通过 Intent 通知已注册的广播接收器。例如，如果您正在开发媒体应用程序并且您想知道用户何时连接或断开耳机，请注册 ACTION_HEADSET_PLUG Intent 操作。

使用广播接收器来响应从应用程序或Android系统广播的消息。
要创建广播接收器：

1. 定义BroadcastReceiver类的子类并实现onReceive（）方法。
2. 静态或动态注册广播接收器。

#### 创建广播接收器

当您的应用收到已注册的Intent广播时，将调用onReceive（）方法。onReceive（）方法在主线程上运行，除非明确要求它在registerReceiver（）方法中的另一个线程上运行。

**onReceive() 方法的超时时间为10秒。10秒后，Android系统会认为您的接收器被阻塞，系统可能会向用户显示“应用程序未响应”错误。因此，您不应在onReceive（）中实现长时间运行的操作。**

> 要点：不要在onReceive() 实现中使用异步操作来运行长时间运行的操作，因为一旦您的代码从onReceive() 返回，系统就会认为 BroadcastReceiver 组件已完成。
如果onReceive() 启动了异步操作，系统将在异步操作有机会完成之前停止 BroadcastReceiver 进程。

特别是：
- 不要尝试在 BroadcastReceiver 中显示对话框。而是使用 NotificationManager API显示通知。
- 不要尝试从 BroadcastReceiver 中绑定到 service。而是使用Context.startService（）向 service 发送命令。

如果需要在 BroadcastReceiver 中执行长时间运行的操作，请使用 WorkManager 管理调度任务。使用 WorkManager 调度任务时，能够保证任务运行。WorkManager 根据设备API级别和应用程序状态等因素选择适当的方式来运行任务。

#### 注册您的广播接收器并设置意图过滤器

有两种类型的广播接收器：
- 静态接收器，您在Android清单文件中注册。安装应用程序时，系统包管理器会注册接收器。然后接收器将成为应用程序的单独入口点，这意味着如果应用程序当前未运行，系统可以启动应用程序并发送广播。
- 动态接收器，使用上下文注册。Context 注册的接收器只要其注册Context有效，就会接收广播。例如，如果您在 Activity Context 注册，那么只要 Activity 没有被破坏，您就会收到广播。如果您注册 Application 的 Context，那么只要应用程序运行，您就会收到广播。

AndroidManifest.xml
```xml
<receiver
    android:name="广播接收器的全路径名"
    android:exported (optional)="是否接收外部广播，如果为 false，则不接收外部广播，其他app无法向你的APP发送广播，在安全性上有甚好的实践。"
    >
    <intent-filter>
        <action android:name=    
            "com.example.myproject.intent.action.ACTION_SHOW_TOAST"/>
    </intent-filter>
</receiver>
```

> 注意：对于Android 8.0（API级别26）及更高版本，静态接收器无法接收大多数隐式广播。（系统发出的与应用无关的广播 broadcasts that do not target your app specifically。）即使您在清单中注册这些广播，Android系统也不会将它们传送到您的应用。但是，您仍然可以使用动态接收器注册这些广播。


### 取消注册接收器

要节省系统资源并避免泄漏，请在应用程序不再需要时或 Context 被销毁之前取消注册动态接收器。对于本地广播接收器也是如此，因为它们是动态注册的。
1. 取消注册普通广播接收器：

调用unregisterReceiver（）并传入BroadcastReceiver对象：
```
unregisterReceiver（mReceiver）;
```
2. 要取消注册本地广播接收器：
获取LocalBroadcastManager的实例。调用LocalBroadcastManager.unregisterReceiver（）并传入BroadcastReceiver对象：
```
LocalBroadcastManager.getInstance（本）
.unregisterReceiver（mReceiver）;
```

何时调用这些unregisterReceiver（）方法取决于您的BroadcastReceiver对象的所需生命周期：有时只有在您的活动可见时才需要接收器，例如在网络不可用时禁用网络功能。
在这些情况下，在onResume（）中注册接收器并在onPause（）中取消注册接收器。
如果它们更适合您的用例，您还可以使用onStart() / onStop() 或 onCreate() / onDestroy() 方法对。不要在onSaveInstanceState（Bundle）中取消注册，因为如果用户在历史堆栈中向后移动，则不会调用此方法。

### 限制广播

不受限制的广播可能会造成安全威胁，因为任何已注册的接收者都可以接收它。例如，如果您的应用使用普通广播发送包含敏感信息的隐式Intent，则包含恶意软件的应用可以接收该广播。强烈建议限制广播。

> 限制广播的方法：

- 如果可能，请使用 LocalBroadcastManager，它将数据保留在您的应用程序中，避免任何安全漏洞。如果您不需要进程间通信或与其他应用程序通信，则只能使用LocalBroadcastManager。

- 使用setPackage（）方法并传入包名称。您的广播仅限于与指定包名称匹配的应用。

- 在发送方，接收方或两者上实施访问权限。

> 在发送广播时强制执行权限：

- 为sendBroadcast() 提供一个非null权限参数。只有使用AndroidManifest.xml文件中的<uses-permission>标记请求此权限的接收者才能接收广播。

> 在接收广播时强制执行权限：

- 如果动态注册接收器，则为registerReceiver（）提供非空权限。

- 如果您静态注册接收器，请使用AndroidManifest.xml中<receiver>标签内的android：permission属性。

### 最佳做法

- 启动广播的 `Intent#action` 参数，将应用程序包名称作为 String 常量的前缀。否则，可能会与其他应用的意图冲突。Intent命名空间是全局的。
- 使用本地接收器
- 如上所述，限制广播接收器。
- 优先使用动态广播替代静态广播接收器。
- 不要从广播接收器启动活动 --- 而是使用通知。如果多个接收器正在侦听相同的广播事件，则从广播接收器开始活动会导致糟糕的用户体验。
- 在onReceive（）之后，系统可以随时终止进程以回收内存，并且这样做会终止在进程中运行的生成线程。要避免这种情况，永远不要在广播接收器的onReceive（Context，Intent）方法中执行长时间运行的操作，因为该方法在主UI线程上运行。请考虑使用JobScheduler或WorkManager.goAsync()。

### 系统限制

但是，您必须小心，不要滥用机会。响应广播并在后台运行可能导致系统性能降低的任务。 安卓系统后台常常有许多服务在运行，为什么如此多的的服务被一次性触发，甚至是为了响应一个隐式广播，隐式广播是定义一个事件，用于替代调用特定 app 的事件触发器，这意味着将一些数据传递给另一个应用程序为您完成任务的合理用例将丢失(meaning that the reasonable use case of passing some date along to another app to da a task for you is lost.)。相反，我们有一个疯狂的应用站起来，大喊它只是做了一些酷的事情, 有谁来看？(Instead, we have the madness of a single app standing up and shouting that it just did something cool. Who wants to come see?)。更糟糕的是，有的很多 app 在 manifest 中声明了静态的广播接收器监听这些广播，即使这些APP从广播中接收到事件后不会运行，因此它仅仅是为了回应而被唤醒。最糟糕的是一个 app 被唤醒去查看然后发现一点也不感兴趣，从而浪费了几个 RAM 周期。这种情况最常见的例子是电源连接改变，在一些设备上，这个广播甚至引起40多个APP被唤醒。当他频繁发生时，几分钟内就有几百次的唤醒，削弱设备的性能。作为解决方案，谷歌移除了电源连接以及几个（NEW_PCITURE, MEW_VIDEO）引起这类问题的广播通知。这些问题不是 App 自身能够解决的，所以安卓平台给出了方案。安卓通知的改变有：
1. Target API N 及以上的 APP 在 manifest 中声明如下广播接收将不会被再被唤醒。 只有在 App 运行着，并且动态注册了该事件的广播，才能接收到改广播。如果你的确有一些工作需要再电源连接状态改变时执行，无论 APP 是否在运行。你需要使用 JobScheduler 创建一个任务或者使用 Firebase 的 JobDispatcher 用户网络连接状态改变监听你真整关心的而不是被动地监听和被唤醒。 然后再去检查电源连接才是正确的方式。当你的 APP 使用 JobScheduler 的时候，其他 App 也在使用它，系统可以批处理这些任务，总体上会使结果更稳定。

2. 另一种情况是 NEW_PCITURE, MEW_VIDEO，这是一个关键的用户体验点，因为唤醒所有的 APP 引起的相机性能下降会毁掉用户的使用体验。 这些广播不是由系统发送的，而是App，例如相机。 这两个通知并不针对特定的App， 所有App 都不会再接收到该事件的广播，无论 Target API 版本是什么。这两个广播在 API 24 （7.0）被废弃掉了。替代方案仍然是 JobScheduler，新的 JobScheduler 包含一个 Content Provider 作为触发器。谷歌正在尽力消除被动的静态接收器。

3. 从android 9（api级别28）开始，NETWORK_STATE_CHANGED_ACTION 广播不会接收到关于用户位置或个人身份数据的信息。

此外，如果您的应用程序安装在运行Android 9或更高版本的设备上，则来自Wi-Fi的系统广播不包含SSID、BSSID、连接信息或扫描结果。要获取此信息，请改为调用getConnectionInfo（）。
4. 如果您的应用程序以Android 8.0或更高版本为目标，则不能使用清单来声明大多数隐式广播（不专门针对您的应用程序的广播）的接收器。当用户正在使用您的应用程序时，您仍然可以使用上下文注册的接收器。

5. 除移除 NEW_PCITURE, MEW_VIDEO 广播外，针对Android 7.0及更高版本的应用程序必须使用RegisterReceiver(BroadcastReceiver，Intentfilter） 动态注册广播。在 Manifest 中声明接收器不起作用。
