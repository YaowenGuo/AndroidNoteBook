# Notification

通知功能是把利刃，使用得当，能够增加用户的活跃度和使用app的时间；使用不当会伤害用户体验，引起用户的反感，甚至引起用户卸载 app。

想象一下，如果你正在睡觉，一个通知响声将你吵醒，或者你正在专心工作，又或开会，一系列通知轰炸向你袭来，你还会喜欢给你提醒的 app 吗。通常我们会将手机调成静音，但是并不是每个人都会这样做，因为有些工作需要即时的回应通知和电话，垃圾通知对这些用户有着更大的伤害。

![Uninstall app reason](images/uninstall_app_reason.png)

有些文章会把应用内的提醒称为应用内通知。这里只是把它当做提醒。不归为通知类型。
## 用户体验设计

通知设计原则：
1. 通知内容必须是对用户来说是有价值的
2. 让用户知道推送的目的
3. 不要连续发送通知
4. 让用户更容易的关闭通知



通知有两种主要类型：
- 必需的操作
- 被动的。

如标签所示，操作所需的通知要求用户根据通知中收到的信息进行操作。被动通知只是提供信息。大多数推送通知都是被动的。

### 良好用户体验的推送守则

#### 0. 为用户提供价值

良好的通知是相关的、及时的和上下文相关的。通知设计者的最佳建议是尊重用户的时间和注意力，少花点时间做更多的事情。

#### 1. 个性化定制

个性化的激励、愉悦的通知内容是一很好的实践。有时，即使是一个小的细节，例如添加接收者的名字，也可以帮助推送通知更好地执行（在某些情况下，甚至可以提高4倍）。当然，个性化并不意味着只需在消息中添加用户的名字。个性化消息内容可确保用户收到与他们相关且有价值的信息。正如陈德鲁所说：

“关注于您的服务的价值用户的价值，并根据他们的独特需求和兴趣定制您的信息。你会看到推动力飙升，你的用户会变成狂热的拥护者。”

一个典型的事例是。Netflix不会在新节目或剧集发布时向每个用户发送通知，而是跟踪每个用户一直观看的特定节目，并且只在他们最喜欢的节目之一有新剧集可用时向用户发送通知。

![](images/notification_persionalize.png)

个性化还包括通知的语言，时间等。

- 除非你的通知非常紧急（例如聊天），否则不要在夜里和工作时间发送通知，根据陈德鲁的研究，最好在晚上6点到8点之间发送推送通知，这时参与度达到最高。别忘了，应该是用户的时区下午6-8点！在他们下班之后，看电视的休息时间。

![](images/notification_push_time.png)

注：下午6点至8点仅作为经验法则。推送通知的时间安排还应考虑消息的紧急性。好的时机应该同时考虑用户行为和紧迫性。无论出于何种目的，不合时宜的通知对用户来说就是噪音。

- 克服不合时宜的通知的第一步是让用户感受到控制权。给用户设置的机会让他们对收到的邮件的频率和内容发表意见，为通知做好准备。


#### 保持通知清晰易懂

无论通知的内容是什么，都要确保它与用户使用相同的语言（字面上和比喻上）。例如 给不会说德语的人发送德语推送通知是极其不好的用户体验。

![](images/notification_unreadable.png)

清晰、准确和简洁的文本使通知消息更可用，更容易获得用户的信赖。不要用不完整的消息来挫伤用户。通知文本应在通知块中完全呈现。

![](images/notification_uncomplate_content.png)


#### 跳转到有价值的页面

大多数通知都与产品体验断裂；它们通常会引入应用程序。点击它们只会让用户进入导航菜单，而不是开始有价值的操作。


#### 严格测试

想做一个更好的推送通知吗？先测试！A/B测试对于发现什么消息对用户最有效非常有用。

一个实例是，临近情人节，1800-Flowers 应用准备了两条截然不同的信息用于 A/B 对比测试。他们对一个小样本的用户测试了两个版本的消息，这些用户在购物车上添加了一个商品，但没有完成购买。

第一条消息是一个简单的提醒：
![](images/notification_test_a.png)

第二个版本有15%的折扣促销码。
![](images/notification_test_b.png)

与预期相反，第一条消息没有促销码的版本-效果更好。没有促销码的消息比使用促销码的版本多产生50%的收入，并且导致卸载应用程序的次数更少。这就是为什么测试如此重要的一个很好的例子。

#### 衡量通知活动的实际有效性

传统上，推送通知是通过积极的指标来衡量的，如开放率和点击率。这些都是很好的衡量标准，但它们只反映了一半的情况。他们不会告诉你用户是否得到了他们真正需要的信息。他们也不会帮助找到以下重要问题的答案：
- 用户是否在一系列推送通知之后关闭了通知？
- 通知是否触发了某人卸载应用程序？

最好有一个大局并跟踪所有相应的指标：
- app uninstalls：由于通知活动而生成的app uninstalls数。当您实时测量这个数字时，很容易在为时已晚之前调整或取消任何有害的通知活动。
- 用户参与。基本上，这个指标显示了在收到推送通知后重新使用应用程序的用户数。


#### 不要限制自己在推送通知上

有大量的通知类型和传递方法，如短信息、电子邮件等。创建一个简单的通知映射，它将每个通知与正确的优先级相匹配。

![](images/notification_other_method.png)


### 通知推送中容易出现的错误

1. 在 app 首次安装启动的时候请求用户允许通知
2. 没有告诉用户通知将包含的信息内容
3. 频繁的发送通知
4. 发送无关内容
5. 关闭通知非常困难

#### Mistake1: 在第一次安装启动之后就立即要求用户允许通知

刚下载的用户还没有感觉到 app 能够给他们提供什么价值，app 也没有得到用户的充分信任，就弹窗询问用户是否接收通知。调查显示，很多用户连提示内容就不会读，就会直接点击“不接收”。想要用户授权一些信息，或者整提醒接收通知，app 应该让用户先体验，给用户提供价值。然后才询问用户是否接收通知。

#### Mistake2: 没有告诉用户通知的内容是什么

在询问用户是否接收通知时，最好能够给出通知将会给用户提供什么，而不是仅仅告诉用户信息要求用户授权的内容。毕竟仅说需要什么授权/表现，会让用户觉得，公司将会从用户那得到什么，而不是用户将得到什么信息。详细的说明能够让用户知道他们是否需要这些消息。并提高应用程序可靠性和可信度的用户感知。

告诉用户通知将包含的内容能够增加用户接受的机率。

#### Mistake3：以爆发式发送通知

在短时间内接收到许多通知可能会压倒和激怒用户，导致他们关闭通知（或者更糟的是，删除您的应用程序）。更不用说，重复的通知可能显得草率和不专业，甚至可能是需要的，给您的用户留下持久的负面印象。

避免在短时间内发送大量通知，不要用几个通知填满用户的屏幕，而是用有意义的方式发送更少的通知。如果您有五个以上的通知需要一次发送，请将它们合并为一条消息。把重点转移到质量而不是数量上，你一定会看到用户满意度的提高。


#### Mistake4：共享无用内容

任何通知都会打断用户：这是为了引起我们的注意，并将其引导到通知中。当我们能够从通知中得到的价值大于被中断的工作时，我们并不介意；但当信息与我们无关时，打扰是令人恼火的。有些人喜欢将收件箱保持在零条未读信息，另一些人则喜欢手机的锁屏上没有通知。如果您属于后一组，那么清除不相关的通知就显得特别耗时和麻烦。

向用户发送应用程序中发生的每一件小事的通知都是一个很大的错误。你不想成为一个通过通知让用户而反感的应用程序。你也不应该抱着“好吧，他们可以在设置中关闭他们”的想法来证明这种行为是正当的，相反，提供相关的内容来通知和参与。

- 例如，google 的文档中明确指出，不要发送节日祝贺的通知。一是用户比一定对你推动的节日内容关心（无关内容）；二是，即使用户对那个节日充满热情，那他肯定知道节日的相关内容。这样节日不会给用户带来任何价值，反而打断了用户。
- 不要仅仅为了“吸引用户”而发送推送通知。例如，Facebook通常会发送通知，给用户推送随机推荐的人或“在Facebook上找到更多的朋友”。这是一个糟糕的尝试，诱使用户重新进入应用程序。

![Useless notification](images/notification_facebook_unlesss.png)

- 不要推送用户无法使用的信息。成功的推送通知对用户总是有用的。如果您的消息不能帮助您的用户（如下面的spotify示例中所示），则会发送错误的推送通知。

![Useless notification](images/notification_spotify_useless.png)

#### Mistake5：使关闭通知变得困难
用户决定关闭通知的原因有很多：
- 他们收到的通知太多了。
- 你的内容对他们来说没有以前那么重要。
- 他们发现自己分心了。
无论原因是什么，您都不应该试图对用户隐藏此功能。这种做法具有欺骗性，会降低对公司和应用程序的信任，并为用户提供删除应用程序的更多理由。
关闭应用程序通知应该简单快捷。允许用户在应用程序中编辑他们的通知首选项，这样他们就不会被强制转到手机的本地设置。此外，将此功能放在应用程序的“设置”部分，以满足用户的期望并确保可查找性。

为了保证用户真正能控制通知的接收，有些 app 会在发送通知之前询问用户是否接收通知，这种做法最好是在用户使用一段时间 app 之后，在 APP 刚安装时，app还没有获得用户的信任，用户根本不知道通知将会带来什么。极大可能就关闭了通知接收。

> 以上整理自以下文档

[Five Mistakes in Designing Mobile Push Notifications](https://www.nngroup.com/articles/push-notification/)

[Rules For Creating Perfect Push Notifications](https://www.uxbooth.com/articles/rules-for-creating-perfect-push-notifications/)

[The Best Notification I’ve Ever Received](https://www.urbanairship.com/blog/the-best-notification-ive-ever-received)

[Tips, advice and tools to create, run and grow your mobile apps. ](http://blog.inapptics.com/push-notification-best-practices/)

[Notification Overload: Best Practices for Designing Notifications with Respect for Users](https://theblog.adobe.com/notification-overload-best-practices-for-designing-notifications-with-respect-for-users/)





## Android 系统提供的能力

看通知前先了解一下 Android 的一些概念，方便后面说明。状态栏图标，android 收到通知后，可以选择是否在状态栏显示通知标识

> 状态栏

![Notification Status Bar](images/notification_area.png)

> 通知抽屉栏

下拉状态栏

### 优先级

Android 为通知定义了五个不同的优先级，但是 IMPORTANCE_NONE 和 IMPORTANCE_HIGH 看不出任何区别，所以实际上只有四个等级。

| User-visible importance level	Importance    | (Android 8.0 and higher) | Priority (Android 7.1 and lower) |
| :------------- | :------------- | :------------- |
| Urgent Notifications make a sound and appear as heads-up notifications.      | IMPORTANCE_HIGH or  IMPORTANCE_NONE      |  PRIORITY_HIGH or PRIORITY_MAX |  
| High Notifications make a sound. |	IMPORTANCE_DEFAULT (我的华为手机能够有显示在状态栏上，可能跟系统厂商的默认设置有关。)|	PRIORITY_DEFAULT |
| Medium Notifications make no sound. |	IMPORTANCE_LOW | PRIORITY_LOW |
| Low Notifications make no sound and do not appear in the status bar.	 | IMPORTANCE_MIN |	PRIORITY_MIN |


Android 8.0 开始，需要为不同通知绑定一个分类。这个分类称为 channel, 用户能够在 setting 的 app -> permission 中看到改分类的名字，和描述。用于向用户解释该类通知的作用。分类一旦建立，就不能再更改其行为，由用户根据需要，调整设置该分类是否显示，是否有声音等通知属性。

为了用户免收通知轰炸的打扰，8.0 开始，APP 通知每秒钟最多只能响铃一次。其他行为不受影响，通知也能够正常交付。**可见，响铃是一个非常重要的特性，务必谨慎使用，非紧急/实时通知（例如聊天），最好不要响铃**





## 申请

- 必须 8.0 之上才成申请分类(Channel)。
```
mNotifyManager = (NotificationManager)
       getSystemService(NOTIFICATION_SERVICE);
     if (android.os.Build.VERSION.SDK_INT >=
                                  android.os.Build.VERSION_CODES.O) {
     // Create a NotificationChannel
     }
}
```

- 分类是以字符串作为 id 标识的。
```
private static final String PRIMARY_CHANNEL_ID = "primary_notification_channel";

// Create a NotificationChannel
NotificationChannel notificationChannel = new NotificationChannel(PRIMARY_CHANNEL_ID,
       "Mascot Notification", NotificationManager
       .IMPORTANCE_HIGH);
```

- 分类可以设置各种通知效果

```
public void createNotificationChannel(String chanelId, String name, String desc) {
    mNotifyManager = (NotificationManager)
            getSystemService(NOTIFICATION_SERVICE);
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        // Create a NotificationChannel
        NotificationChannel notificationChannel = new NotificationChannel(
                chanelId, name, NotificationManager.IMPORTANCE_HIGH);
        notificationChannel.enableLights(true);
        notificationChannel.setLightColor(Color.RED);
        notificationChannel.enableVibration(true);
        notificationChannel.setDescription(desc);
        mNotifyManager.createNotificationChannel(notificationChannel);
    }
}
```

## 创建一个 Notification

```
private NotificationCompat.Builder getNotificationBuilder() {
    Intent notificationIntent = new Intent(this, MainActivity.class);
    PendingIntent notificationPendingIntent = PendingIntent.getActivity(this,
            NOTIFICATION_ID, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    NotificationCompat.Builder notifyBuilder = new NotificationCompat.Builder(this, PRIMARY_CHANNEL_ID)
            .setContentTitle("You've been notified!")
            .setContentText("This is your notification text.")
            .setSmallIcon(R.drawable.ic_android)
            .setContentIntent(notificationPendingIntent)
            .setAutoCancel(true) // 点击自动消失
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL);
    return notifyBuilder;
}

public void sendNotification(View view) {
    NotificationCompat.Builder notifyBuilder = getNotificationBuilder();
    mNotifyManager.notify(NOTIFICATION_ID, notifyBuilder.build());
}

```

Content intents for notifications are similar to the intents you've used throughout this course. Content intents can be explicit intents to launch an activity, implicit intents to perform an action, or broadcast intents to notify the system of a system event or custom event.

The major difference with an Intent that's used for a notification is that the Intent must be wrapped in a PendingIntent. The PendingIntent allows the Android notification system to perform the assigned action on behalf of your code.


## 8.0 之前显示效果

Priority is an integer value from PRIORITY_MIN (-2) to PRIORITY_MAX (2). Notifications with a higher priority are sorted above lower priority ones in the notification drawer. HIGH or MAX priority notifications are delivered as "heads up"（就是弹屏通知） notifications, which drop down on top of the user's active screen. It's not a good practice to set all your notifications to MAX priority, so use MAX sparingly.



```
final NotificationManager manager =(NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, new Intent(), PendingIntent.FLAG_UPDATE_CURRENT);
Notification notify= null; // 需要注意build()是在API level16及之后增加的，在API11中可以使用getNotificatin()来代替
Notification.Builder builder = new Notification.Builder(this)
        .setSmallIcon(R.drawable.nav_arrow_back) // 设置状态栏中的小图片，尺寸一般建议在24×24， 这里也可以设置大图标
        .setLargeIcon(BitmapFactory.decodeResource(getResources(), R.drawable.ic_launcher))
        .setTicker("12345678912378912356789")// 设置显示的提示文字
        .setContentTitle("12345678912378912356789")// 设置显示的标题
        .setContentText("12345678912378912356789")// 消息的详细内容
        .setContentIntent(pendingIntent) // 关联PendingIntent
//                .setFullScreenIntenmomt(pendingIntent, false)

        .setNumber(1); // 在TextView的右方显示的数字，可以在外部定义一个变量，点击累加setNumber(count),这时显示的和

if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    manager.createNotificationChannel(new NotificationChannel("gholl","gholl", NotificationManager.IMPORTANCE_HIGH));
    notify = builder.setChannelId("gholl").setColor(Color.GREEN).build();
}else {
    notify = builder.getNotification();
}
notify.flags |= Notification.FLAG_AUTO_CANCEL;
manager.notify(1, notify);
//        manager.notify(-1, notify);
//        TimerTask task = new TimerTask() {
//            @Override
//            public void run() {
//                manager.cancel(-1); // 根据之前设置的通知栏 Id 号，让相关通知栏消失掉
//            }
//        };
//        Timer timer = new Timer();
//        timer.schedule( task , 2000);
```
