# Notification

- Android 的通知会先分配给App, App 再控制通知显示的样式：是否现在状态栏，是否在屏幕悬浮显示，图标，样式，只是灯等。
- Android8.0 (API26)开始，增加了分类（channel）功能，用户可以自定义分类来分别设置通知，以及将不同通知放到一个分类中，设置将对该组通知同时生效。



## 前提条件

- target API 必须是26或者更高，否则会显示的跟26之前版本一样。

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
- 分类可以设置各种通知效果

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
Priority is an integer value from PRIORITY_MIN (-2) to PRIORITY_MAX (2). Notifications with a higher priority are sorted above lower priority ones in the notification drawer. HIGH or MAX priority notifications are delivered as "heads up"（就是弹屏通知） notifications, which drop down on top of the user's active screen. It's not a good practice to set all your notifications to MAX priority, so use MAX sparingly.




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
