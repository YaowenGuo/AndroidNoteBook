# Shape

圆，长方形，环形，

过渡色

```XML
<shape>
    <!--设置圆角大小-->
    <corners android:radius="10dp"/>
    <!--设置背景颜色渐变-->
    <gradient
        android:startColor="#ffabb8c9"
        android:endColor="#ff6f84a3"
        android:centerColor="#ff00ffff"
        android:centerX="0.5"
        android:centerY="0.5"
        android:angle="90"/>
</shape>
```

gradient节点主要配置起点颜色、终点颜色及中间点的颜色、坐标、渐变效果（0，90，180从左到右渐变，270从上到下渐变）默认从左到右。
注意：设置的角度只能是45度的倍数，否则会抛异常！

- android:angle	设置渐变颜色的角度，必须是45的整数倍.
- android:startColor	颜色渐变的开始颜色
- android:endColor	颜色渐变的结束颜色
- android:centerColor	颜色渐变的中间颜色
- android:centerX	Float.(0 - 1.0) 相对X的渐变位置。
- android:centerY	Float.(0 - 1.0) 相对Y的渐变位置。
- android:gradientRadius	Float. 渐变颜色的半径，单位是像素点. 需要 android:type=”radial”.
- android:type
    - `linear` 线性渐变.可以理解为 y=kx+b.
    - `radial` 圆形渐变，起始颜色从 cenralX, centralY 点开始。
    - `sweep` 以图像中心为圆点，顺时针旋转一周颜色渐变
