资源drawable文件明明存在，但是报错了

The problem is that you are using ?attr/ in your drawable. Replace that with a @color or @drawable and it should go away. This does unfortunately mean that you have to bundle a drawable for each of your themes, it is a lot cleaner in lollipop.

这是因为安卓 drawable 文件中并不能引用安卓原生的 ?开头的资源。这些资源之后再 layout 中直接使用。不引起报错是个很坑的问题。


解决Android 5.0以上版本Button自带阴影效果的方法

关键一条代码
```
style=”?android:attr/borderlessButtonStyle”
```
属性解释
```
<Button
android:id="@+id/button_send"
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:text="@string/button_send"
android:onClick="sendMessage"
style="?android:attr/borderlessButtonStyle" />
```
