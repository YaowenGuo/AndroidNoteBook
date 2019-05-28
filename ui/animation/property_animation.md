[TOC]

属性动画可以定义动画以随时间更改任何对象属性，无论它是否绘制到屏幕上。

属性动画在指定的时间长度内更改属性（对象中的字段）值。要为某些内容设置动画，请指定要设置动画的对象属性，例如对象在屏幕上的位置，要为其设置动画的时间长度以及要在其间设置动画的值。

属性动画系统可配置的内容有：

- 时长：默认是 300 ms
- 时间插值器
- 重复次数和表现
- 动画组合集合
- 帧刷新延迟：默认 10 ms 刷新一次，但是应用程序刷新帧的速度最终取决于系统整体的繁忙程度以及系统为底层计时器提供服务的速度。







# 属性动画

View 自带的属性动画有: translation, rotate

使用时需要注意 属性动画位于 `android.animation` 包，而 View 动画位于 `android.view.animation` 包，他们又很多名字非常相似，注意包名，以防使用错误。

## View 自带动画 ViewPropertyAnimator

```
imageView.animate()
    .translationX(100f)
    .setStartDelay(1000)
    .start()
```


![方法表](images/animation_function.jpg)

从图中可以看到， View 的每个方法都对应了 ViewPropertyAnimator 的两个方法，其中一个是带有 -By 后缀的，例如，View.setTranslationX() 对应了 ViewPropertyAnimator.translationX() 和  ViewPropertyAnimator.translationXBy() 这两个方法。其中带有 -By() 后缀的是增量版本的方法，例如，translationX(100) 表示用动画把 View 的 translationX 值渐变为 100，而  translationXBy(100) 则表示用动画把 View 的 translationX 值渐变地增加 100。

以上方法可以同时使用。

除此之外，还能设置动画的属性有

- 延时执行  setStartDelay(miliSeconds)
- 时长 setDuration()
- 动画插值器 setInterpolator()，用于控制动画的时间和完成度关系

ViewPropertyAnimator 只实现了基本的几个功能，想要更多和更复杂的造作，需要用到 Animator 的子类。

## Animator 的复杂操作

ViewPropertyAnimator 是对 ValueAnimator 的封装。它是 Animator 的子类， 我们通常不会使用 Animator，而是使用它的子类 ValueAnimator（对基本数据类型做渐变）、 ObjectAnimator（对对象的属性做渐变）、AnimatorSet（对多个动画做组合）。


### ObjectAnimator

ObjectAnimator 是设置 View 的属性进行动画

```
val objAnim = ObjectAnimator.ofFloat(imageAnim, "x", 100.dpToPx())
objAnim.startDelay = 1000
objAnim.start()
```

- 其中 x 参数表示， 使用 setX(int x) 来修改属性值，具体修改内容它不关心。必须与 setX 方法。 ofFloat 后面可以提供两个值，起始值和结束值，如果只给一个，表示是结束值，则此时必须有 getX 方法获取起始值。

- get 和 set 的参数类型，必须和 `ofXXX` 的类型相同。

- 如果想要动画自动更新 view，需要在 set 方法中调用 `invalidate()`。 `invalidate()` 标记需要刷新 View， 这样才能在下次 UI 绘制到来时，绘制新的内容个。否则由于 UI 优化的问题，会使用缓存的久数据绘制。

由于 ObjectAnimator 只能修改单个属性，要想修改多个属性，就不得不使用 AnimatorSet

> 组合动画

当要同时执行多个动画的时候，ViewPropertyAnimator 已经提供了同时实行的方法。

```
imageView.animate()
    .translationX(100f)
    .setStartDelay(1000)
    .start()
```
但是对于增加的属性设置方式，由于动画要使用 ObjectAnimator 来做，这是由想要同时执行多个动画，就需要使用 PropertyValuesHolder 来同时执行多个动画。

```kotlin
val pvhX = PropertyValuesHolder.ofFloat("x", 50f)
val pvhY = PropertyValuesHolder.ofFloat("y", 100f)
ObjectAnimator.ofPropertyValuesHolder(myView, pvhX, pvhY).start()
```

### AnimatorSet

PropertyValuesHolder 虽然能够执行多个动画，但是不能控制动画之间的循序和时间，因为这些属性是放在同一个动画中执行的。。


```kotlin
val animX = ObjectAnimator.ofFloat(myView, "x", 50f)
val animY = ObjectAnimator.ofFloat(myView, "y", 100f)
AnimatorSet().apply {
    playTogether(animX, animY)
    start()
}

```

### 指定关键帧

以上都是对多个属性的同时动画。对于一个动画的整个流程有不同的速度变化，例如有多个段，每一段按照不同的速度变化，这时候使用上面的动画先后执行也不是不行，就是显得比较麻烦，这时候可以用 Keyframe。

Keyframe对象由时间/值对组成，可让您在动画的特定时间定义特定状态。
每个关键帧也可以有自己的插值器来控制动画在前一个关键帧的时间和该关键帧的时间之间的间隔。

要实例化Keyframe对象，必须使用其中一个工厂方法ofInt（），ofFloat（）或ofObject（）来获取相应类型的Keyframe。然后，调用ofKeyframe（）工厂方法以获取PropertyValuesHolder对象。获得对象后，可以通过传入PropertyValuesHolder对象和对象来获取动画来获取动画。以下代码段演示了如何执行此操作：

```kotlin
val kf0 = Keyframe.ofFloat(0f, 0f)
val kf1 = Keyframe.ofFloat(.5f, 360f)
val kf2 = Keyframe.ofFloat(1f, 0f)
val pvhRotation = PropertyValuesHolder.ofKeyframe("rotation", kf0, kf1, kf2)
ObjectAnimator.ofPropertyValuesHolder(target, pvhRotation).apply {
    duration = 5000
}
```



### ValueAnimator

动画属性有两个部分：
- 计算动画值
- 和设置动画的对象的这些属性值。

ValueAnimator不执行第二部分，因此您必须侦听ValueAnimator计算的值的更新，并使用您自己的逻辑修改要设置动画的对象。因此我们通常不适用这个方法，而是使用 ObjectAnimator 来实现。

### 估值器 (TypeEvaluator)

安卓体用的默认动画只能生成 int(IntEvaluator)，float(FloatEvaluator)，color(ArgbEvaluator) 源和目标之间的过渡数据，用于动画。如果想要渐变的内容不在这些范围之内，就需要通过实现 `TypeEvaluator` 接口来自定义估值器。

唯一要实现的方法就是 `evaluate`， 它传入动画进度，起始值，结束值。需要计算出当前进度的值，返回

```Kotlin
    override fun evaluate(fraction: Float, startValue: Any, endValue: Any): Any {
        return (startValue as Number).toFloat().let { startFloat ->
            startFloat + fraction * ((endValue as Number).toFloat() - startFloat)
        }
    }

```


### 插值器 (Interpolators)

插值器是根据动画时间完成度计算动画完成度的方法。例如，当使用线性插值器时，时间过了 0.25，则动画也完成0.25，它们是正比的。然而当使用先加速，后减速的动画时，时间过了 0.25，可能动画只有 0.2。插值器就是计算这个时间完成度到动画完成度的映射的。

`android.view.animation package.` 包已经提供了一组常用的插值器，可以以 `AccelerateDecelerateInterpolator` 和 `LinearInterpolator` 来查看如何计算映射的。

AccelerateDecelerateInterpolator

```kotlin
override fun getInterpolation(input: Float): Float =
        (Math.cos((input + 1) * Math.PI) / 2.0f).toFloat() + 0.5f
```

LinearInterpolator

```
override fun getInterpolation(input: Float): Float = input
```

#### 自定义插值器

Android 已经提供了很多现有的插值器供使用，如果你有特殊的需求 Android 5.0 之后提供了更加直观的 `PathInterpolator` 来实现动画完成度的控制。

PathInterpolator 只需要提供一个 Path 对象，但是 Path 的纵坐标不再表示曲线，而是表示动画的完成度。

它基于Bézier曲线或Path对象。此插值器指定1x1平方的运动曲线，锚点位于（0,0）和（1,1），控制点使用构造函数参数指定。创建 `PathInterpolator` 的一种方法是创建Path对象并将其提供给PathInterpolator：

```
// arcTo() and PathInterpolator only available on API 21+
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    val path = Path().apply {
        arcTo(0f, 0f, 1000f, 1000f, 270f, -180f, true)
    }
    val pathInterpolator = PathInterpolator(path)
}


val animation = ObjectAnimator.ofFloat(view, "translationX", 100f).apply {
    interpolator = pathInterpolator
    start()
}

```

并且，新的 ObjectAnimator 提供了构造器来直接实现对多个属性的控制

```
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    val path = Path().apply {
        arcTo(0f, 0f, 1000f, 1000f, 270f, -180f, true)
    }
    val animator = ObjectAnimator.ofFloat(view, View.X, View.Y, path).apply {
        duration = 2000
        start()
    }
} else {
    // Create animator without using curved path
}

```

如果您不想创建自己的时序或路径曲线，系统会为材料设计规范中的三条基本曲线提供XML资源：

```
@interpolator/fast_out_linear_in.xml
@interpolator/fast_out_slow_in.xml
@interpolator/linear_out_slow_in.xml
```

### 设置监听器

设置监听器
给动画设置监听器，可以在关键时刻得到反馈，从而及时做出合适的操作，例如在动画的属性更新时同步更新其他数据，或者在动画结束后回收资源等。

设置监听器的方法， ViewPropertyAnimator 和 ObjectAnimator 略微不一样：  ViewPropertyAnimator 用的是 setListener() 和 setUpdateListener() 方法，可以设置一个监听器，要移除监听器时通过 set[Update]Listener(null) 填 null 值来移除；而 ObjectAnimator 则是用  addListener() 和 addUpdateListener() 来添加一个或多个监听器，移除监听器则是通过  remove[Update]Listener() 来指定移除对象。

另外，由于 ObjectAnimator 支持使用 pause() 方法暂停，所以它还多了一个 addPauseListener() /  removePauseListener() 的支持；而 ViewPropertyAnimator 则独有 withStartAction() 和  withEndAction() 方法，可以设置一次性的动画开始或结束的监听。



#### ViewPropertyAnimator.withStartAction/EndAction()
这两个方法是 ViewPropertyAnimator 的独有方法。它们和 set/addListener() 中回调的  onAnimationStart() / onAnimationEnd() 相比起来的不同主要有两点：

withStartAction() / withEndAction() 是一次性的，在动画执行结束后就自动弃掉了，就算之后再重用 ViewPropertyAnimator 来做别的动画，用它们设置的回调也不会再被调用。而  set/addListener() 所设置的 AnimatorListener 是持续有效的，当动画重复执行时，回调总会被调用。

withEndAction() 设置的回调只有在动画正常结束时才会被调用，而在动画被取消时不会被执行。这点和 AnimatorListener.onAnimationEnd() 的行为是不一致的。

关于监听器，就说到这里。本期内容的讲义部分也到此结束。



### XML 定义动画

属性动画系统允许您使用XML声明属性动画，而不是以编程方式执行。
通过在XML中定义动画，您可以轻松地在多个活动中重复使用动画，并更轻松地编辑动画序列。

为了区分 View 动画，属性动画的定义放在 `res/animator/` 目录下。

类和 `xml` 标签的对应关系。

例如

```xml
<set android:ordering="sequentially">
    <set>
        <objectAnimator
            android:propertyName="x"
            android:duration="500"
            android:valueTo="400"
            android:valueType="intType"/>
        <objectAnimator
            android:propertyName="y"
            android:duration="500"
            android:valueTo="300"
            android:valueType="intType"/>
    </set>
    <objectAnimator
        android:propertyName="alpha"
        android:duration="500"
        android:valueTo="1f"/>
</set>
```

使用

```Kotlin
(AnimatorInflater.loadAnimator(myContext, R.animator.property_animator) as AnimatorSet).apply {
    setTarget(myObject)
    start()
}

```

如果是单个的 `ValueAnimator` 

```XML
<animator xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="1000"
    android:valueType="floatType"
    android:valueFrom="0f"
    android:valueTo="-100f" />
```

需要自己设置监听器并更新 View

```
(AnimatorInflater.loadAnimator(this, R.animator.animator) as ValueAnimator).apply {
    addUpdateListener { updatedAnimation ->
        textView.translationX = updatedAnimation.animatedValue as Float
    }

    start()
}
```






