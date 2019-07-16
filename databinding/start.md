# DataBinding

Aspect Oriented Programming(AOP)，面向切面编程，

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


## 可观察对象

Databinding 提供了一组用于数据观察的对象，能够在数据更改时，自动绑定最新数据到 View。但是，由于 LiveData 出现，这部分可以不用看，直接跳过。 LiveData 除了提供数据观察之外，提供了更好的生命周期管理，提供更好的安全性。
关于这些提供相同功能的内容，我们只需要了解一种最好的方式即可，不必掌握各种方法，毕竟这不是创造性的工作。这点有两个语言的特性值得思考: python 的设计思想，对每种实现方式，仅提供一种最好的解决方法，这使得 python 的语法简介，每个人写的代码实现方式相同，非常好理解。而 lisp 则不然，提供各种花样来实现一个问题的解决方案，满足各种人的偏好，反而让人感到疑惑。

对于这种没有什么技术含量的实现方案，别人已经做好了比较。选了一种，熟练使用即可。


## 生成绑定类

编译器会为每个绑定布局文件生成一个绑定类，默认情况下类名由布局文件名的 Pascal 格式加 Binding 后缀。有多重方法获取到对应文件的绑定类，这里给出一些使用的建议。

在 Activity 中，在 onCreate 中 super.onCreate 之后就可以初始化 Binding 类了

```
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val binding: ActivityMainBinding =
            DataBindingUtil.setContentView(this, R.layout.activity_main)
    // 使用如上的方法，而不是使用下面的简写
    // val binding: ActivityMainBinding = ActivityMainBinding.inflate(layoutInflater)
}
```

建议使用如上的方法，它能很好的关联类和布局文件，并且保证在自动清理 layout 文件的时候，layout 文件不被清除。实际上我确实遇到过 xml 布局文件被清除的情况。

它跟如下的方式是等价的。

```
setContentView(R.layout.activity_main)
val binding: ActivityMainBinding =
    DataBindingUtil.inflate(layoutInflater, R.layout.activity_main, null, false)
```

有时不能预先知道绑定类型。在这种情况下，可以使用databindingutil类创建绑定，如下代码段所示：

```
val viewRoot = LayoutInflater.from(this).inflate(layoutId, parent, attachToParent)
val binding: ViewDataBinding? = DataBindingUtil.bind(viewRoot)
```

### 即时绑定

当一个变量或可观察到的对象发生变化时，绑定被安排在下一帧之前发生变化。但是，有时绑定必须立即执行。要强制执行，请使用ExecutePendingBindings（）方法。‘

在下面的示例中，RecyclerView绑定到的所有布局都有一个item变量。`bindingholder` 对象有一个 getbinding() 方法，返回viewDatabinding基类。

### 动态变量

有时，特定的绑定类是未知的。例如，针对任意布局操作的recyclerview.adapter不知道特定的绑定类。在调用onBindViewHolder（）方法期间，它仍然必须分配绑定值。

在下面的示例中，RecyclerView绑定到的所有布局都有一个item变量。bindingholder对象有一个getbinding（）方法，返回viewDatabinding基类。

```
override fun onBindViewHolder(holder: BindingHolder, position: Int) {
    item: T = items.get(position)
    holder.binding.setVariable(BR.item, item);
    holder.binding.executePendingBindings();
}

```

注意：数据绑定库在模块包中生成一个名为 `BR` 的类，该类包含用于数据绑定的资源的ID。在上面的示例中，库自动生成 `BR.item` 变量。动态变量提供了根据绑定 View 进行自动类型转换的操作，省去了类型转换的麻烦。


如果使用的是 Kotlin 编写代码，还需要在 app 的 build 文件中配置

```
kapt {
    generateStubs = true
}

dependencies {
    ...
}
```

否则会找不到生成的 `BR` 类。


### 后台线程

只要数据不是集合类型，就可以在后台线程中更改它。数据绑定在计算期间本地化了每个变量/字段，以避免任何并发问题。

### 自定义绑定类名

除非特殊需要（命名冲突或者团队约定好名字规则），否则我不建议更改绑定类名，这样会使他人查找绑定类和布局文件的关系变得麻烦。

## 绑定适配器

DataBinding 允许在 xml 布局中写 view 的赋值，然后编译成代码。当绑定变量的值变化时，生成的绑定代码会根据绑定表达式调用 View 的 set 方法来设置值。你可以使用默认的方法，或者自己指定设置方法。

#### 默认的设置方法

默认方法根据 xml 的属性名和绑定表达式结果的数据类型确定。例如 `android:text="@{user.name}` 则，会调用 View 的 `setText` 方法，如果 `user.getName()` 返回的是字符串， 则会调用接收字符串的方法 `setText(String args)`。而如果 `user.getName()` 返回的结果是 int 型，则会调用资源设置的方法 `setText(int resId)`。 表达式的类型确定了调用方法的参数类型，必要时甚至可以对表达式进行数据类型转换。

即使没有相应的 xml 属性，只要类有 set 方法，Databinding 就能生成响应的代码。此时需要使用 `app:属性名` 来绑定值。例如 DrawerLayout 有 `setScrimColor(int)` 和 `setDrawerListener(DrawerListener)` 方法。

```xml
<android.support.v4.widget.DrawerLayout
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    app:scrimColor="@{@color/scrim}"
    app:drawerListener="@{fragment.drawerListener}">

```

#### 指定绑定方法

有些类的 set 方法和 xml 属性值不符合命令规则的映射，此时，需要使用 `BindingMethods ` 注解将属性和 set 方法关联起来。 每个 `BindingMethods` 注解用于指定一个关联关系，在一个类中可以申明多个（Kotlin 可以直接声明为全局方法，而不需要类）。（虽然绑定注解可以声明在任何类中，为了方便管理，还是建议声明在一个类中，或者分局模块，有一定的位置约定。）例如 `android:tint` 属性和 `setImageTintList(ColorStateList)` 方法的关联声明为：

```
@BindingMethods(value = [
    BindingMethod(
        type = android.widget.ImageView::class,
        attribute = "android:tint",
        method = "setImageTintList")])

```

大多数情况下你都不需要自己指定关联关系，这些属性已经有自动查找匹配的默认实现。同时，你不应该修改默认的匹配关系，这会让人疑惑。

#### 自定义绑定逻辑

数据绑定允许自己指定设置值时调用的方法，在此方法中编写自己的逻辑，完成一些复杂的显示前处理工作。被指定的方法称为绑定适配器。

有一些属性需要自定义绑定逻辑。例如 `android:paddingLeft` 属性没有对应的 set 方法，但是， 有 `setPadding(left, top, right, bottom)` 方法。 `BindingAdapter ` 注解的方法将在绑定时被调用，用于设置属性值。

DataBinding 框架已经默认实现了一些常用的适配器。例如 `paddingLeft` 的绑定适配器。

```
@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, padding: Int) {
    view.setPadding(padding,
                view.getPaddingTop(),
                view.getPaddingRight(),
                view.getPaddingBottom())
}
```

当自定义适配器和框架的提供的适配器冲突时，自定义的将覆盖掉框架中的适配器。


根据需要，还可以定义新的绑定属性，或者多个属性值的绑定。

```
@BindingAdapter("imageUrl", "error")
fun loadImage(view: ImageView, url: String, error: Drawable) {
    Picasso.get().load(url).error(error).into(view)
}
```

自定义的属性使用 `app` 指定，如上的适配器的使用方法是:

```
<ImageView app:imageUrl="@{venue.imageUrl}" app:error="@{@drawable/venueError}" />
```

默认情况下，适配器是定的所有属性都在定义了才会调用对应的适配器，如上的适配器必须同时指定 `app:imageUrl` 和 `app:error` 属性，如果想要适配器在任何一个属性被声明的时候都被调用，需要将 `requireAll` 设置为 false.

```Kotlin
@BindingAdapter(value = ["imageUrl", "placeholder"], requireAll = false)
fun setImageUrl(imageView: ImageView, url: String?, placeHolder: Drawable?) {
    if (url == null) {
        imageView.setImageDrawable(placeholder);
    } else {
        MyImageLoader.loadInto(imageView, url, placeholder);
    }
}
```







