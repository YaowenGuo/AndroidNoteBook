# Radio & Switch

## Radio

### 自定义图标

其实就是定义一个选择器。对于 CheckBox 和 Switch 也是一样的。

```
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/radiobutton_select" android:state_checked="true"/>

    <item android:drawable="@drawable/radiobutton_unselect" android:state_checked="false"/>
</selector>
```

然后设置属性

```
android:button="@null"
```

### 将图标放在右侧

RadioButton 和 CheckBox 都是继承即 TextView, 将选中图标放到右侧，在每个 RadioButton 中添加属性。并且可以通过 drawablePading 来控制图标和文字的间距。
```
android:button="@null"
android:drawableEnd="@drawable/radiobutton_selector"
```

