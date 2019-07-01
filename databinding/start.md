# DataBinding

- 减少重复性代码，让整个代码更简洁，专注于业务逻辑
- 灵活而且广泛兼容，Android平台最低能到Android 2.1（API等级7+）

## 环境搭建

gradle.properties 文件添加

```
android.databinding.enableV2=true
```

app 的 gradel 中添加

```
dependencies {
    annotationProcessor 'com.android.databinding:compiler:3.1.4'
    // 如果使用 Kotline 语言，增加
    kapt "com.android.databinding:compiler:$android_plugin_version"
}
```


## 使用

### 布局文件修改

DataBinding 是根据布局文件生成响应的绑定类的，要想对某个布局使用数据绑定，要修改布局文件，使用 layout 作为根布局，这样就会生成一个以布局文件名 + Banding 的类，内部包含了布局文件中 View 元素对应的变量。 以 activity_main.xml 为例

```xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    tools:context=".home.MainActivity" >

    <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent">

        <com.example.yaowen.basil.wegit.VerticalViewPager
            android:id="@+id/main_view_pager"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            />

        <!--<include-->
        <!--layout="@layout/main_menu"-->
        <!--android:layout_width="match_parent"-->
        <!--android:layout_height="match_parent" />-->
        <!--<include-->
        <!--layout="@layout/glide_image_test" />-->
    </FrameLayout>
</layout>

```

此时将生成一个名为 `ActivityMainBanding` 的 数据绑定类，并且含有名为 `mainViewPager` 的 VerticalViewPager 变量，你可以对其进行和 findViewById 方法得到的变量一样的任何操作。

### 使用生成的变量

在 Activity 中使用

```Kotlin
@Override
protected void onCreate(Bundle savedInstanceState) {
   super.onCreate(savedInstanceState);
   val binding : ActivityMainBinding = DataBindingUtil.setContentView(this, R.layout.activity_main) // 代替了原有的 setContentView 方法
   binding.mainViewPager.adapter = MainPagerAdapter()
}
```

在 Fragment 中使用与上面类似

```Kotlin
DataBindingUtil.inflate(LayoutInflater inflater, int layoutId,@Nullable ViewGroup parent, boolean attachToParent);
```


但是有些 View 是作为页面的一部分，在 View 创建的时候，使用 LayoutInflater 动态实例化的。例如 RecycleView 的 Item。这时候就要使用另一种方式了。

```Kotlin
val view = inflater.inflate(R.layout.main_recipe_list, container, false)
val binding: MainRecipeListBinding? = DataBindingUtil.bind(view)

```

这时候其实就将布局文件的组件和变量绑定好了，我们不需要再使用 `findViewById` 方法查找组件，他们已经在生成的绑定类中了，我们可以直接使用

```
val binding: MainRecipeListBinding? = DataBindingUtil.bind(view)

// 使用
binding?.recipeListRv?.layoutManager = LinearLayoutManager(container.context,
LinearLayoutManager.HORIZONTAL, false)
binding?.recipeListRv?.adapter = RecipeRecycleAdapter()
```

### 绑定数据

处理绑定组件，数据绑定，当然最关注的还是数据。


### 运算符转换

```
'&' --> '&amp;'

'<' --> '&lt;'

'>' --> '&gt;'

android:visibility="@{age &lt; 13 ? View.GONE : View.VISIBLE}"
```

HTML Character entities often used in Android:


| Symbol | Equivalent HTML Entity      |  |  |  |
| :----- | :-------------------------- |:-|:-|:-|
| >      | `&gt;`                      |  |  |  |
| <      | `&lt;`                      |  |  |  |
| "      | `&quot;, &ldquo; or &rdquo;`|  |  |  |
| '      | `&apos;, &lsquo; or &rsquo;`|  |  |  |
| }      | `&#125;`                    |  |  |  |
| &      | `&amp;`                     |  |  |  |
| space  | `&#160;`                    |  |  |  |



### 格式化字符换

244

You can do this even simplier:
```XML
android:text= "@{@string/generic_text(profile.name)}"
```
you string should be like this:
```XML
<string name="generic_text">My Name is %s</string>
```
Edit:

Of course you can use as many variables as you need:
```XML
android:text= "@{@string/generic_text(profile.firstName, profile.secondName)}"

<string name="generic_text">My Name is %1$s %2$s</string>
```