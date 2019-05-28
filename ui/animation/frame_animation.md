# Frame Animation

AnimationDrawable 是逐帧动画基础类。 由于是图片逐帧播放，所以数据量比较大，比较影响包体积。除非个别特殊需求，应尽量减少使用这种方式。

在 `res/drawable/` 目录下建立 xml 文件

```XML
<animation-list xmlns:android="http://schemas.android.com/apk/res/android"
    android:oneshot="true"> 
    <!-- android:oneshot attribute of the list to true, it will cycle just once then stop and hold on the last frame.If it is set false then the animation will loop. -->
    <item android:drawable="@drawable/rocket_thrust1" android:duration="200" />
    <item android:drawable="@drawable/rocket_thrust2" android:duration="200" />
    <item android:drawable="@drawable/rocket_thrust3" android:duration="200" />
</animation-list>
```

播放动画

```
val rocketImage = findViewById<ImageView>(R.id.rocket_image).apply {
    setBackgroundResource(R.drawable.rocket_thrust)
    rocketAnimation = background as AnimationDrawable
}

rocketImage.setOnClickListener({ rocketAnimation.start() })
```

重要的是要注意，在Activity的onCreate（）方法中，无法调用在AnimationDrawable上调用的start（）方法，因为AnimationDrawable尚未完全附加到窗口。如果您想立即播放动画而不需要交互，那么您可能希望从Activity中的onStart（）方法调用它，当Android使视图在屏幕上可见时将调用它。


