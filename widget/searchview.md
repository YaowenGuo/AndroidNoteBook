# SearchView

https://www.jianshu.com/p/16f9e995e454

## 去掉下划线

```
binding.searchView.findViewById<View>(R.id.search_plate).background = null
        binding.searchView.findViewById<View>(R.id.submit_area).background = null
```

## 去掉搜索图标和背景图标

```
app:searchIcon="@null"
app:searchHintIcon="@null"
app:submitBackground="@null"
app:closeIcon="@drawable/ic_clear"
android:focusable="true"
```

## 左右图标的边距

```
android:paddingLeft="-16dp"
android:paddingStart="-16dp"
```

## 防止自动获取焦点

在外层 Layout 中添加

```
android:focusable="true"
android:focusableInTouchMode="true"
```         
