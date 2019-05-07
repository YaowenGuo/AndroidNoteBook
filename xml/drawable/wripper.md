# 水波纹效果

android中的水波纹效果是5.0以后即API Level 21以后出现的，因此minSdkVersion必须设置在21及以上才可以使用此效果。

***elevation 属性只有在设置了背景色的时候才生效***

***组件一定是可点击的，即clickable="true"***

***Ripple 内部的的 shape 必须设置 solid 内填充色属性，否则会没有水波纹***

## 默认的

Android 资源中定义了两个水波纹，都是浅灰色的。一个是有边界的，一个是无边界的。所谓无边界就是波纹能够超出组件的边界，继续向外扩散。

// 系统提供的水波纹效果(有界/不能改颜色)
android:background="?android:selectableItemBackground"
// 系统提供的水波纹效果(无界/不能改颜色)
android:background="?android:selectableItemBackgroundBorderless"


## 自定义

在 drawable 下创建一个 xml 文件，添加如下代码

```
<?xml version="1.0" encoding="utf-8"?>
<ripple xmlns:android="http://schemas.android.com/apk/res/android"
    android:color="@color/colorAccent">
</ripple>
```

在 layout 文件中，将组件的背景设为上面的 `drawable` 文件，并且设置为可点击的。
```
android:background="@drawable/ripple_test"
android:clickable="true"
```

这时候就添加了一个无边界的水波纹效果。wripper 中定义的颜色，就是水波纹扩散后的颜色。扩散的范围是view 的对角线为直径的圆。

### 添加默认背景色

这时候的组件是没有默认颜色的，而平时我们都使用 background 属性来设置背景色，现在可以写在 ripper 中.

```
<?xml version="1.0" encoding="utf-8"?>
<ripple xmlns:android="http://schemas.android.com/apk/res/android"
    android:color="@color/colorAccent">
    <!--添加默认背景颜色-->
    <item android:drawable="@color/colorPrimaryDark"/>
</ripple>
```

***加一个 item 和 item 中加 shape 都会引起 ripper 变成有界的。***

### item 中可以自定义 shape

效果和单独加 item 一样，都是

```
<item>
	<!--item中可以自定义shape-->
    <shape android:innerRadius="5dp"
        android:shape="rectangle">
      <solid android:color="@color/colorPrimary" />  // ！！！！！！原色一定要定义，不然无法计算过渡，所以不会有水波纹效果 ！！！！！！！！即便是白色
      <corners android:radius="5dp" />
    </shape>
</item>
```

### 使用： 带 ripper 的下划线

```
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/devideLineGray"
        android:left="15dp"
        android:right="15dp"/>
    <item
        android:drawable="@color/white"
        android:bottom="0.5dp" />

    <item android:bottom="0.5dp">
        <ripple xmlns:android="http://schemas.android.com/apk/res/android"
            android:color="@color/colorAccent">
            <!--添加默认颜色-->
            <item android:drawable="@color/white"/>
        </ripple>
    </item>
</layer-list>
```

## 5.0 之下的适配

在 drawable-v21 中添加 ripper, 在 drawable 中使用 select 创建同名的文件。

```
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 没有焦点时的背景颜色 -->
    <item android:drawable="@color/white" android:state_window_focused="false" />
    <!-- 非触摸模式下获得焦点并单击时的背景颜色 -->
    <item android:drawable="@color/ripple" android:state_focused="true" android:state_pressed="true" />
    <!-- 触摸模式下单击时的背景颜色 -->
    <item android:drawable="@color/ripple" android:state_focused="false" android:state_pressed="true" />
    <!-- 选中时的背景颜色 -->
    <item android:drawable="@color/ripple" android:state_selected="true" />
    <!-- 获得焦点时的背景  颜色 -->
    <item android:drawable="@color/ripple" android:state_focused="true" />
</selector>
```
