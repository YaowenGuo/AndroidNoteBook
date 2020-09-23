# Theme, Style

Style 是属性值值的集合。用于单个 View。Style 是 View 属性和值的映射`Map<view attribute, resource>`。

Theme 是一系列有名字的资源的集合，可以稍后在 Style 和 Layout 中使用。Theme 是 theme 属性和值的集合 `Map<theme attribute, resource>`。



[TOC]

## Theme

合理的构建 Theme 能够减少布局文件中重复的代码，而且可以动态的修改 Theme 来做到夜间模式的切换。构建 theme 就是在 `res/values` 下创建 `themes.xml`。如果要构建夜间模式，在 `res` 下创建 `values-night/themes.xml`　文件。

创建项目时仅生成了 `styles.xml` 文件，用于定义样式。虽然里面也可以定义主题，显然将主题放到 `theme.xml` 文件中更规范一些。`styles.xml` 主要定义一些局部样式，例如 button 和 TextView　的样式。也就是说 style 定义组件的样式，Theme 则是用于定义整个项目，另外 `styles.xml` 中定义的内容，也可以在 `themes.xml` 中使用。

另外，对于不同版本支持了不同文件。如果编译器提醒时可以添加不同安卓版本的支持。

安卓样式现在有四类

1. 早期的框架样式（已近过时，不建议再使用）
2. material 样式，随 5.0 推出
3. support 库样式（现在应用最广泛的，能够支持 API14）
4. material design 基于 androidx 的样式（现在在推的，也是以后的发展方向，但是需要整个项目使用 androidx 和 Material Design 组件，而且是和 support 库时冲突的）

1. 安卓默认的

```xml
<style name="GreenText" parent="@android:style/TextAppearance">
    <item name="android:textColor">#00FF00</item>
</style>
```

2. material 样式随着5.0版本推出，谷歌也提出来材料化设计。然而这组样式应用并不广泛，不兼容 5.0 之前版本，推广困难。

```
Theme.Material

```

3. 为了兼容 5.0 之前版本，安卓推出了支持库的样式和主题，样式名字后加了 `AppCompat` 区分源库，并且不使用 `@android:style/` 父样式前缀。

```xml
<style name="GreenText" parent="TextAppearance.AppCompat">
    <item name="android:textColor">#00FF00</item>
</style>
```

4. material design 的样式，以 `MaterialComponents` 区分。由于 support 跟安卓版本绑定，随着安卓版本不断推出，support 库的版本越来越多，难以维护，并且，support 库和安卓版本绑定必须同时升级安卓支持版本和 support 版本，阻碍了开发者升级最新版本库。因此安卓推出来 androidx 库，同时配以 `MaterialComponents` 主题。

其中 `Theme.MaterialComponents` 是使用的，前缀表示了它的类型。
`Base.xxx.MaterialComponents` 和 `Base.V14.xxx.MaterialComponents` 是继承的父层级。应该使用最底层的，避免层级混乱，除非没有这个样式主题。

> Beginning with Android 5.0 (API level 21) and Android Support Library v22.1, you can also specify the android:theme attribute to a view in your layout file. This modifies the theme for that view and any child views, which is useful for altering theme color palettes in a specific portion of your interface.

### 创建样式

> 创建样式需要继承一个已有的样式。

```xml
<resources>
    <!-- Base application theme. -->
    <style name="AppTheme" parent="Theme.MaterialComponents.NoActionBar">
        <!--Customize your theme here.-->
    </style>
</resources>

```

> 扩展继承

也可以使用点表示法来扩展式的继承样式，使用要继承的样式作为样式名前缀。这种方式应该仅用于扩展自己的样式，是用来为同一种组件样式添加不同细微差别的。禁止继承其他库的样式。 例如扩展上面的 `GreenText`

```xml
<style name="GreenText.Large">
    <item name="android:textSize">22dp</item>
</style>
```

**Note: If you use the dot notation to extend a style, and you also include the parent attribute, then the parent styles override any styles inheritted through the dot notation.**

### 使用

可以在具有 context 的组件中使用主题，例如 Activity,View 或 ViewGroup：

```xml

<!-- Copyright 2019 Google LLC.	
   SPDX-License-Identifier: Apache-2.0 -->

<!-- AndroidManifest.xml -->
<application …
  android:theme="@style/Theme.Plaid">
<activity …
  android:theme="@style/Theme.Plaid.About"/>

<!-- layout/foo.xml -->
<ConstraintLayout …
  android:theme="@style/Theme.Plaid.Foo">
```


### 自带的几种 Theme 

以 Theme 开头的是应用于整个 App 或 Activity 的 主题，

```
Theme.MaterialComponents // 标准主题
Theme.MaterialComponents.Light // 浅色主题
Theme.MaterialComponents.DayNight // 夜间模式  和 Theme.MaterialComponents.Light 一样？

Theme.MaterialComponents.NoActionBar // 没有Topbar的主题，需要使用 toolbar 自己定义 Topbar
Theme.MaterialComponents.Light.NoActionBar // 浅色，没有 Toolbar 的主题
Theme.MaterialComponents.DayNight.NoActionBar //

Theme.MaterialComponents.Light.DarkActionBar // 白色背景，深色 Topbar 的主题。

Theme.MaterialComponents.DayNight.DarkActionBar //

```

其他主题

```

Theme.MaterialComponents.CompactMenu // 菜单的主题

Theme.MaterialComponents.Dialog
Theme.MaterialComponents.Dialog.Alert // 弹窗提醒
Theme.MaterialComponents.DialogWhenLarge // 弹窗
Theme.MaterialComponents.Dialog.MinWidth

Theme.MaterialComponents.BottomSheetDialog // 底部弹窗的主题，继承 Theme.MaterialComponents.Dialog


Theme.MaterialComponents.Light.Dialog
Theme.MaterialComponents.Light.Dialog.Alert // 弹窗提醒
Theme.MaterialComponents.Light.Dialog.MinWidth
Theme.MaterialComponents.Light.DialogWhenLarge // 弹窗

Theme.MaterialComponents.Light.BottomSheetDialog //


Theme.MaterialComponents.DayNight.DialogWhenLarge // 弹窗
```

上面主题名后加 `Bridge` 后缀的一套材料设计的主题是为不愿意切换 support 支持库到 androidx 准备的兼容主题，它们继承自 `AppCompat` 主题。


### ThemeOverlay 相关

> Theme.AppCompat is used to set the global theme for the entire app. ThemeOverlay.AppCompat is used to override (or "overlay") that theme for specific views, especially the Toolbar.

ThemeOverlay 的定义初衷是为了在 xml 覆盖全局 Theme 的一组 style，用于局部修改应用定义样式后的页面。所有它有一下特点

- 非常少的定义，就包括修改部分。

5.0 level 21 之后，可以给view单独设置theme属性了。安卓预订义的 ThemeOverlay 其实就是一组定义好 attribute 的 style，现在多用在action bar上（也可以使用别的控件）；可以覆盖父类定义的theme 的部分属性。

Tool Bar 中PopupTheme属性是用来控制弹出菜单的样式的


### 主题属性说明

```xml
<style name="AppTheme.V19TranslucentStatus" parent="AppTheme.BaseTranslucentTheme">
        <!-- your app branding color for the app bar -->
        <item name="colorPrimary">@color/primary</item>
        <!-- darker variant for the status bar and contextual app bars -->
        <item name="colorPrimaryDark">@color/primary_dark</item>
        <!-- theme UI controls like checkboxes and text fields -->
        <item name="colorAccent">@color/accent</item>
        <!--除了沉浸模式，禁止使用透明度来设置带浅灰色的状态栏，这会导致状态栏覆盖 TopBar, 需要单独设置 AppBar-->
        <!--到屏幕顶部的距离才能弥补。非常繁琐。-->
        <item name="android:windowTranslucentStatus">true</item>
        <!--禁止使用，会使虚拟按键也变成透明，覆盖屏幕底部一部分 View，除非确认修复了引起的问题-->
        <!--<item name="android:windowTranslucentNavigation">true</item>-->
        <!--Android 5.x开始需要把颜色设置透明，否则导航栏会呈现系统默认的浅灰色-->
        <!-- V21可用，单独设置状态栏颜色，而不是使用 colorPrimaryDark -->
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
        <!-- 用户修复 windowTranslucentStatus=true 时引起的状态栏覆盖 Topbar，只能使用在 XML 布局的根 View 中，禁止在整个主题中使用，该属性会引起整个页面的 Pandding 失效, 很奇怪 -->
        <!--<item name="android:fitsSystemWindows">true</item>-->

        <!-- api23 浅色状态栏，字体是黑色 -->
        <item name="android:windowLightStatusBar">true</item>
    </style>
```


## 杂项

> colorPrimary

Generally when choosing a colorPrimary, consider colors from the material color palette around the 500 value.

> colorPrimaryDark

colorPrimaryDark is a darker variant of your primary color, which is used as the background color of the status bar that adorns the top of the screen. This difference in color gives users a clear separation between the system-controlled status bar and your app. Compared to colorPrimary, this should be the 700 color from the color palette of the same shade.

> In fact, many of the built in components already use colorAccent:

- Checked Checkboxes
- RadioButtons
- SwitchCompat
- EditText’s focused underline and cursor
- TextInputLayout’s floating label
- TabLayout’s current tab indicator
- The selected NavigationView item
- The background for the FloatingActionButton

> colorControlNormal controls the ‘normal’ state of components such as an unselected EditText, and unselected Checkboxes and RadioButtons

> colorControlActivated overrides colorAccent as the activated or checked state for Checkboxes and RadioButtons

> colorControlHighlight controls the ripple coloring


### 使用主题中的属性

在 toolbar 中使用主题色

```
<android.support.v7.widget.Toolbar
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  android:background="?attr/colorPrimary" />
```

[theme article](https://medium.com/androiddevelopers/theming-with-appcompat-1a292b754b35)


```
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="GreenText" parent="TextAppearance.AppCompat">
        <item name="android:textColor">#00FF00</item>
    </style>
</resources>
```

定义一个 style 就可以在 组件中应用了，组件会只接受自己有的属性，忽略其它的。

```
<TextView
    style="@style/GreenText"
    ... />
```

使用 style 应用的组价是不继承的，如果想要继承属性，可以使用 `android:theme`
