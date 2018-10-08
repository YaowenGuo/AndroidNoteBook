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
