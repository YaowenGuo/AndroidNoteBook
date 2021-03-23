The constraint-based layout lets a developer build complex layouts **without having to nest view groups**, which can ***improve the performance of the app***. It is built into the layout editor, so that the constraining tools are accessible from the Design tab without having to edit the XML by hand.


## 包裹但是不超过约束


```xml
android:layout_height="0dp"
app:layout_constraintHeight_default="wrap" 
```

在较新版本的支持库中，使用以下代码：

```xml
android:layout_height="wrap_content" 
app:layout_constrainedHeight="true" 
```


## 限制最大宽度

```xml
android:layout_width="0dp"
android:layout_height="0dp"
app:layout_constraintWidth_max="500dp"
app:layout_constraintHeight_max="489dp"
```

