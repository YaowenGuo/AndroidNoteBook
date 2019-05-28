# 摩擦力动画

基于Fling的动画使用与物体速度成比例的摩擦力。使用它来设置对象属性的动画，并希望逐渐结束动画。它有一个初始动量，主要是从手势速度接收，并逐渐减慢。当动画的速度足够低以至于在设备屏幕上没有可见的变化时，动画结束。

![](images/fling-animation.gif)

要基于物理的动画(Fling, Spring)在支持库中添加，必须将支持库添加到项目中，如下所示：

```
dependencies {
    implementation 'androidx.dynamicanimation:dynamicanimation:1.0.0'
}
```

## 创建动画

FlingAnimation类允许您为对象创建一个动画动画。
要构建一个fling动画，请创建一个FlingAnimation类的实例，并提供一个对象和要设置动画的对象属性。

```
val fling = FlingAnimation(view, DynamicAnimation.SCROLL_X)
```

