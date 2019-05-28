# 布局改变时执行动画

适用于 ViewGroup 中的 View 在添加或者移除，或者 Visibility 的值改变时自动使用动画

## 启用默认 layout 动画

想要启动默认的 layout 动画，只需要在 xml 中增加一行 `android:animateLayoutChanges="true" `

```
<LinearLayout
    android:orientation="vertical"
    android:layout_width="wrap_content"
    android:layout_height="match_parent"
    android:id="@+id/verticalContainer"
    android:animateLayoutChanges="true" />
```


## 自定义 layout 动画


您可以通过调用LayoutTransition 的 `setAnimator()` 并使用以下常量之一传入Animator对象，在LayoutTransition对象中定义以下动画：

- APPEARING - 指示在容器中出现的 View 上运行的动画。
- CHANGE_APPEARING - 指示由于容器中出现的新 View 而在更改的 View 上运行的动画。
- DISAPPEARING - 指示在从容器中消失的 View 上运行的动画。
- CHANGE_DISAPPEARING - 指示由于 View 从容器中消失而在更改的 View 上运行的动画。

然后使用setLayoutTransition（）方法将其提供给布局。

