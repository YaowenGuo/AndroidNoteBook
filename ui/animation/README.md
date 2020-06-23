# 动画

## Animation

- 补间动画
- [Drawable 动画]
    - [逐帧动画](frame_animation.md): 将图片顺序播放，就先电影的帧一样，形成动画。
    - [矢量动画](vector_animation.md): 使用属性动画实现矢量时间的变化
- View 动画。只能改变限定的几个 View 属性，如缩放、旋转，而不能改变背景色或者非 View 内容。 2. 只改变了 View 的绘制，而没有改变实际的 View 属性，例如点击位置。
- [属性动画](property_animation.md)
    - [Animate layout change](animate_layout.md) 添加/移除，隐藏/显示子 View.
    - [Status Change Animate](animate_state_change.md) pressed、focused 等状态改变时应用动画
    - [Fling Animate](fling_animate.md) 类似于带有摩擦力的运动，动画会逐渐减慢并停止。适用于滑动视图。
    - [Spring Animate](spring_animate.md) 类弹簧动画，能以弹性的运行，再回到原点。
- 过度动画




## transitions

是一种在应用程序中描述不同场景切换的方法，既可以是应用中预选设置的布局资源文件，也可以动态地变化的东西。

It's a way to describe the different sences in application, either beforehand as layout resources files or dynamically as things change in the application.

过渡框架提供了如下的特性：
- 组级动画：将一个或多个动画效果应用于视图层次结构中的所有视图。
- 内置动画：使用预定义动画来实现淡出或移动等常见效果。
- 资源文件支持：从布局资源文件加载视图层次结构和内置动画。
- 生命周期回调：接收回调，提供对动画和层次结构更改过程的控制。

根据场景不同，可以细分为：

- [layout 内部变化](layout_transition.md)
- Activity 之间变化
- viewpager 之间的变化


用于不同屏幕之间动画的转场
