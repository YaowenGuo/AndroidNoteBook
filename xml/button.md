安卓开发——安卓5.0以上版本如何去除Button自带阴影效果
https://blog.csdn.net/qq_28484355/article/details/70243924
去除阴影效果，只需给Button添加属性：

style=”?android:attr/borderlessButtonStyle”
即：
<Button
android:layout_width="wrap_content"
android:layout_height="wrap_content"
android:text="按钮"
