# Toolbar

[TOC]

[Why use toolbar](https://stackoverflow.com/questions/27238433/when-should-one-use-theme-appcompat-vs-themeoverlay-appcompat)
[]

颜色

> When using a base theme of Theme.AppCompat and the AppCompat-provided app bar, you’ll find the app bar’s background automatically uses your colorPrimary. However, if you’re using a Toolbar (along with a Theme.AppCompat.NoActionBar theme, most likely), you’ll need to manually set the background color.

```xml
<android.support.v7.widget.Toolbar
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  android:background="?attr/colorPrimary" />
```

> the `?attr/` format is how you tell Android that this value should be resolved from your theme rather than directly from a resource.


> 返回按钮

```
<android.support.v7.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            app:elevation="0dp"
            app:navigationIcon="@drawable/nav_arrow_back_white"
            app:title="@string/name_detail_title"
            app:titleTextColor="@color/white"
            app:titleTextAppearance="@style/Toolbar.TitleText">
```

点击

```
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

```


### ToolBar 设置左侧返回按钮

两种方式：
#### 第一种：自定义返回按钮的样式和颜色

在布局文件中添加属性设置
```
app:navigationIcon="@mipmap/title_bar_back"
```
或者使用代码设置：
```
mToolbar.setNavigationIcon();
```

### Title 居中


