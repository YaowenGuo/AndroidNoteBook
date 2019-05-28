# 状态改变动画

## StateListAnimator 动画
指定的视图状态（例如“pressed”或“focused”）发生变化，就会调用 `StateListAnimator` 动画。

StateListAnimator 可以在XML资源中定义，其中包含根 <selector>元素和子 <item>元素，每个元素都指定由StateListAnimator类定义的不同视图状态。每个<item>包含属性动画集的定义。


例如，以下文件创建一个状态列表动画，它在按下时更改视图的x和y比例：

```xml
<!-- res/xml/animate_scale.xml -->
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- the pressed state; increase x and y size to 150% -->
    <item android:state_pressed="true">
        <set>
            <objectAnimator android:propertyName="scaleX"
                android:duration="@android:integer/config_shortAnimTime"
                android:valueTo="1.5"
                android:valueType="floatType"/>
            <objectAnimator android:propertyName="scaleY"
                android:duration="@android:integer/config_shortAnimTime"
                android:valueTo="1.5"
                android:valueType="floatType"/>
        </set>
    </item>
    <!-- the default, non-pressed state; set x and y size to 100% -->
    <item android:state_pressed="false">
        <set>
            <objectAnimator android:propertyName="scaleX"
                android:duration="@android:integer/config_shortAnimTime"
                android:valueTo="1"
                android:valueType="floatType"/>
            <objectAnimator android:propertyName="scaleY"
                android:duration="@android:integer/config_shortAnimTime"
                android:valueTo="1"
                android:valueType="floatType"/>
        </set>
    </item>
</selector>
```

应用动画

```
<Button android:stateListAnimator="@xml/animate_scale"
        ... />
```


或者，可以在状态更改之间播放 drawable 动画，而不是属性动画

## AnimatedStateListDrawable

Android 5.0中的某些系统小部件默认使用这些动画。
以下示例显示如何将AnimatedStateListDrawable定义为XML资源

```
<!-- res/drawable/myanimstatedrawable.xml -->
<animated-selector
    xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- provide a different drawable for each state-->
    <item android:id="@+id/pressed" android:drawable="@drawable/drawableP"
        android:state_pressed="true"/>
    <item android:id="@+id/focused" android:drawable="@drawable/drawableF"
        android:state_focused="true"/>
    <item android:id="@id/default"
        android:drawable="@drawable/drawableD"/>

    <!-- specify a transition -->
    <transition android:fromId="@+id/default" android:toId="@+id/pressed">
        <animation-list>
            <item android:duration="15" android:drawable="@drawable/dt1"/>
            <item android:duration="15" android:drawable="@drawable/dt2"/>
            ...
        </animation-list>
    </transition>
    ...
</animated-selector>
```

