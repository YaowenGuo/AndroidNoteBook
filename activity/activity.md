# Add a Activity

1. Modify the Android manifest
Open manifests/AndroidManifest.xml.
Find the <activity> element that Android Studio created for the second activity.
```
<activity android:name=".SecondActivity"></activity>
```

2. Add these attributes to the <activity> element:

| Attribute     | Value     |
|:------------- | :------------- |
| android:label  | "Second Activity"      |
| android:parentActivityName | ".MainActivity" |


The label attribute adds the title of the activity to the action bar.

The parentActivityName attribute indicates that the main activity is the parent of the second activity. This parent activity relationship is used for "upward" navigation within your app. By defining this attribute, the action bar for the second activity will appear with a left-facing arrow to enable the user to navigate "upward" to the main activity.




## SaveInstanceState


> When you rotate the device (before you implement onSaveInstanceState()), the counter is reset to 0 but the contents of the edit text is preserved. Why?

In addition, you may notice that in both activities, any text you typed into message or reply EditTexts is retained even when the device is rotated. This is because the state information of some of the views in your layout are automatically saved across configuration changes, and the current value of an EditText is one of those cases

> What is the difference between restoring your activity state in onCreate() versus in onRestoreInstanceState()?

Once you've saved the activity instance state, you also need to restore it when the activity is recreated. You can do this either in onCreate(), or by implementing the onRestoreInstanceState() callback, which is called after onStart() after the activity is created.

Most of the time the better place to restore the activity state is in onCreate(), to ensure that your user interface including the state is available as soon as possible. It is sometimes convenient to do it in onRestoreInstanceState() after all of the initialization has been done, or to allow subclasses to decide whether to use your default implementation.

## Up Button

```
<activity android:name="com.example.android.droidcafeinput.OrderActivity"
    android:label="Order Activity"
    android:parentActivityName=".MainActivity"> // android 16（4.1） 才支持。
    <meta-data android:name="android.support.PARENT_ACTIVITY"
        android:value=".MainActivity"/> // 兼容4.1之前的版本。
</activity>
```
该方法只对 ActionBar 有效，Toorbar 需要另外设置。

设置了这个之后，返回会先调用父 Activity 的 onDestroy 方法，从新创建。解决方案参考
https://blog.csdn.net/mengweiqi33/article/details/41285699

#### 第二种：设置使用系统自带的返回按钮样式
```
getSupportActionBar().setDisplayHomeAsUpEnabled(true);//左侧添加一个默认的返回图标
getSupportActionBar().setHomeButtonEnabled(true); //设置返回键可用
```
添加之后，如果发现图标的颜色是 黑色 ，则需要在 style.xml 中添加如下属性：
```
<!-- 溢出菜单图标颜色，可以自己设置成任意的颜色-->
<item name="colorControlNormal">@android:color/white</item>
```


#### 使用 context 启动 app crash

Calling startActivity() from outside of an Activity context

add - FLAG_ACTIVITY_NEW_TASK flag to your intent:

```
myIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
```

#### 点击图标会闪屏页启动

https://www.jianshu.com/p/b202690b7d96
