
> android ImageView 宽度设定，高度自适应

首先，需要给你的ImageView布局加上android:adjustViewBounds="true"

```
<ImageView android:id="@+id/test_image"
android:layout_width="wrap_content"
android:layout_height="match_parent"
android:scaleType="fitXY"
android:adjustViewBounds="true"
android:layout_gravity="center"
android:contentDescription="@string/app_name"
android:src="@drawable/ic_launcher" />
```