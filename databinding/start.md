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


#### 绑定参数

适配器的第一个参数是目标 View 的实例本身。后面的参数，如果设置类型的绑定适配器，例如 `android:text`, `android:background` ，则参数类型是 xml 绑定表达式转换之后的类型。

```
@BindingAdapter("imageUrl", "error")
fun loadImage(view: ImageView, url: String, error: Drawable) {
    Picasso.get().load(url).error(error).into(view)
}

<ImageView app:imageUrl="@{venue.imageUrl}" app:error="@{@drawable/venueError}" />
```

`app:imageUrl="@{venue.imageUrl}"` 的类型是 String 类型， 而 `app:error="@{@drawable/venueError}"` 类型是 `@drawable/venueError`。


对于监听类型的适配器，参数是 Databingding 构造的监听器本身。例如，

```
const val CLICK_FILTER_MILLISECONDS = 1000

@BindingAdapter("android:onClick")
fun setOnClick(view: View, clickListener: View.OnClickListener) {
    var mHits = 0L
    view.setOnClickListener {
        if (mHits < (SystemClock.uptimeMillis() - CLICK_FILTER_MILLISECONDS)) {
            mHits = SystemClock.uptimeMillis()
            clickListener.onClick(it)
        }
    }
}

android:onClick="@{() -> listener.anonymousLogin()}"
```

`listener.anonymousLogin()` 被 Databinding 生成的监听器调用， 而监听器的生成类型由是适配器的其后的参数决定 `setOnClick(view: View, clickListener: View.OnClickListener)`。


#### 获取旧值

绑定适配器可以选择使用旧值，只要在声明适配器时增加参数数量，所有旧值会在前面，新值在后面传入。

```
@BindingAdapter("android:paddingLeft")
fun setPaddingLeft(view: View, oldPadding: Int, newPadding: Int) {
    if (oldPadding != newPadding) {
        view.setPadding(padding,
                    view.getPaddingTop(),
                    view.getPaddingRight(),
                    view.getPaddingBottom())
    }
}
```

#### 事件监听

事件处理程序绑定只能用于只有一个抽象方法的监听器接口或者抽象类。

```
@BindingAdapter("android:onLayoutChange")
fun setOnLayoutChangeListener(
        view: View,
        oldValue: View.OnLayoutChangeListener?,
        newValue: View.OnLayoutChangeListener?
) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
        if (oldValue != null) {
            view.removeOnLayoutChangeListener(oldValue)
        }
        if (newValue != null) {
            view.addOnLayoutChangeListener(newValue)
        }
    }
}

<View android:onLayoutChange="@{() -> handler.layoutChanged()}"/>
```

当一个监听器有多个方法时，必须将其拆分为多个监听器。例如，View.OnAttachStateChangeListener有两种方法：OnViewAttachedToWindow(View) 和OnViewDetachedFromWindow(View)。 数据绑定库提供两个接口来区分属性和处理程序：

```
// Translation from provided interfaces in Java:
@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
interface OnViewDetachedFromWindow {
    fun onViewDetachedFromWindow(v: View)
}

@TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
interface OnViewAttachedToWindow {
    fun onViewAttachedToWindow(v: View)
}
```

因为更改一个监听器也会影响另一个监听器，所以需要一个适用于任一属性或同时适用于两个属性的适配器。可以在注释中将RequireAll设置为false，以指定并非每个属性都必须分配绑定表达式，如下例所示：

```
@BindingAdapter(
        "android:onViewDetachedFromWindow",
        "android:onViewAttachedToWindow",
        requireAll = false
)
fun setListener(view: View, detach: OnViewDetachedFromWindow?, attach: OnViewAttachedToWindow?) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR1) {
        val newListener: View.OnAttachStateChangeListener?
        newListener = if (detach == null && attach == null) {
            null
        } else {
            object : View.OnAttachStateChangeListener {
                override fun onViewAttachedToWindow(v: View) {
                    attach.onViewAttachedToWindow(v)
                }

                override fun onViewDetachedFromWindow(v: View) {
                    detach.onViewDetachedFromWindow(v)
                }
            }
        }

        val oldListener: View.OnAttachStateChangeListener? =
                ListenerUtil.trackListener(view, newListener, R.id.onAttachStateChangeListener)
        if (oldListener != null) {
            view.removeOnAttachStateChangeListener(oldListener)
        }
        if (newListener != null) {
            view.addOnAttachStateChangeListener(newListener)
        }
    }
}
```

上面的示例比普通的稍微复杂一些，因为视图类使用 `addOnAttachStateChangeListener()` 和`removeOnAttachStateChangeListener()` 方法，而不是 `OnAttachStateChangeListener` 的 setter 方法。android.databinding.adapters.listenerUtil 类帮助跟踪以前的侦听器，以便在绑定适配器中删除它们。

通过用 `@TargetApi(VERSION_CODES.HONEYCOMB_MR1)` 注释 `viewDetachedFromWindow` 和`onviewAttachedToWindow` 的接口，数据绑定代码生成器知道只有在android 3.1（api级别12）及更高版本上运行时才应生成侦听器，该版本与 `addOnAttachStateChangestener()` 方法支持的版本相同。


### 类型转换

#### 自动类型转换

当从绑定表达式返回对象时，绑定库选择用于设置属性值的方法。对象被强制转换为所选方法的参数类型。这种行为在使用ObservableMap类存储数据的应用程序中很方便，如下例所示：

```

```

注意：您也可以使用object.key表示法引用映射中的值。例如，上面示例中的 `@{usermap[“lastname”]}` 可以替换为 `@{usermap.lastname}`。


#### 自定义转换

在某些情况下，需要在特定类型之间进行自定义转换。例如，视图的android:background属性需要可绘制，但指定的颜色值是整数。下面的示例显示了一个需要可绘制的属性，但提供了一个整数：

```
<View
   android:background="@{isError ? @color/red : @color/white}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```

每当需要 drawable 但是返回整数时，int应转换为colordrawable。可以使用带有bindingConversion注释的静态方法进行转换，如下所示：

```
@BindingConversion
fun convertColorToDrawable(color: Int) = ColorDrawable(color)
```

但是，绑定表达式中提供的值类型必须一致。不能在同一表达式中使用不同的类型，如下例所示：

```
<View
   android:background="@{isError ? @drawable/error : @color/white}"
   android:layout_width="wrap_content"
   android:layout_height="wrap_content"/>
```

## 将布局视图绑定到架构组件

Databinding 能够与架构组件无缝衔接，以简化 UI 开发流程。

### 在数据更改时 使用 LiveData 更新 UI

LiveData 可以直接用于设局绑定，当数据内容改变时自动跟新 UI。 LiveData 对象了解订阅数据更改的观察者的生命周期，这种技术有很多好处。在android studio 3.1及更高版本中，您可以用数据绑定代码中的livedata对象替换可观察字段。

要将 LiveData 对象与绑定类一起使用，需要 `binding.setLifecycleOwner(LifecycleOwner)` 指定生命周期所有者来定义 LiveData 对象的范围。 证明周期所有者即为 LiveData 的 `observer()` 方法接受的类型，用于生成观察方法。

```Kotlin
class BindingFragment : Fragment() {

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.binding_fragment, container, false)
        binding.lifecycleOwner = this
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(requireActivity()).get(BindingViewModel::class.java)
        
        // Assign the component to a property in the binding class.
        binding.viewModel = viewModel

    }
}
```

在 ViewModel 中声明 LiveData 对象

```
class BindingViewModel : ViewModel() {
    var firstName: MutableLiveData<String>


    init {
        firstName = MutableLiveData<String>()
        firstName.value = "Albert"
    }
}
```

在布局中直接使用，即可更新 UI 

```
<TextView
    android:id="@+id/test_change"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="@{viewModel.firstName}" />
```

使用 ViewModel 管理 UI 相关的数据，可以将 UI 逻辑移出布局并移入组件中，这样更易于测试。 数据绑定库确保在需要时将视图从数据源绑定和解除绑定。 关于 ViewModel 的更多好处，可参看 ViewModel 的使用。


### 使用 Observable ViewModel 进行更多绑定控制

类似于使用 LiveData 对象的方式，也可以使用实现 Observable 的 ViewModel 组件来通知 UI 组件数据更改。

在某些情况下，使用 ViewModel 组件来实现 Observable 接口而不是使用 LiveData 对象更方便，即使这样丢失了LiveData的生命周期管理功能。使用实现 Observable 的 ViewModel 组件可以更好地控制应用程序中的绑定适配器。例如，此模式使可以在数据更改时更好地控制通知，还允许指定自定义方法以在双向数据绑定中设置属性的值。

要实现可观察的 ViewModel 组件，必须创建一个继承自 ViewModel 类并实现 Observable 接口的类。当观察者使用addOnPropertyChangedCallback（）和removeOnPropertyChangedCallback（）方法订阅或取消订阅通知时，你可以提供自定义逻辑。还可以提供在 notifyPropertyChanged() 方法中属性更改时运行的自定义逻辑。以下代码示例演示如何实现可观察的ViewModel：

```
class BindingViewModel : ViewModel(), Observable {
    private val callbacks: PropertyChangeRegistry = PropertyChangeRegistry()

    @get:Bindable
    var firstName: String = ""
        set(value) {
            field = value
            notifyPropertyChanged(BR.firstName)
        }

    init {
        firstName = "Albert"
    }

    override fun removeOnPropertyChangedCallback(callback: Observable.OnPropertyChangedCallback?) {
        callbacks.remove(callback)
    }

    override fun addOnPropertyChangedCallback(callback: Observable.OnPropertyChangedCallback?) {
        callbacks.add(callback)
    }


    /**
     * Notifies observers that all properties of this instance have changed.
     */
    fun notifyChange() {
        callbacks.notifyCallbacks(this, 0, null)
    }

    /**
     * Notifies observers that a specific property has changed. The getter for the
     * property that changes should be marked with the @Bindable annotation to
     * generate a field in the BR class to be used as the fieldId parameter.
     *
     * @param fieldId The generated BR id for the Bindable field.
     */
    fun notifyPropertyChanged(fieldId: Int) {
        callbacks.notifyCallbacks(this, fieldId, null)
    }
}
```

此实现不是线程安全的，但对于 LiveData 这种类型的方法对象，确定运行在主线程反而能够加快运行效率。想要使用 线程安全方法，可以使用 DataBinding 提供的 Observable 更加方便。

@get:Bindable 注解回生成位于 BR 类中的字段 ID，该 ID 可以在调用 `callbacks.notifyCallbacks(this, fieldId, null)` 时更新。

关联布局文件

```xml
<data>
    <variable
        name="viewModel"
        type="tech.yaowen.customview.ui.databinding.BindingViewModel" />
</data>

```

使用

```
<TextView
    android:id="@+id/test_change"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="@{viewModel.firstName}" />
```


## 双向绑定

在单向绑定的时候，监听变化和设置 UI 需要单独设置属性

```
<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@{viewModel.rememberMe}"
    android:onCheckedChanged="@{viewModel.rememberMeChanged}"
/>
```

双向绑定提供了这种类型处理的快捷方式
```
<CheckBox
    android:id="@+id/rememberMeCheckBox"
    android:checked="@={viewModel.rememberMe}"
/>
```

`@=` 符号，接收对属性的数据更改并同时侦听用户更新。

为了对数据中的更改做出响应，可以将布局变量设置为 Observable（通常为baseObservable）的实现，并使用 `@bindable` 注释来生成绑定变量，如以下代码段所示：

```Kotlin
class BindingViewModel : BaseObservable {
    private val callbacks: PropertyChangeRegistry = PropertyChangeRegistry()

    var rememberMe = false
        @Bindable get() {
            return field
        }
        set(value) {
            // Avoids infinite loops.
            if (field != value) {
                field = value

                // React to the change.
                // saveData()

                // Notify observers of a new value.
                notifyPropertyChanged(BR.rememberMe)
            }
        }
}

```

- Java 和 Kotlin 是单继承的，但是是多实现的，如果有其他类需要继承，可以自己实现 Observable 代替 BaseObservable。 方法拷贝即可。
- `BR.rememberMe` 是根据 `@Bindable` 标注的方法名生成的，跟变量名无关，甚至可以不存在该变量，而使用数据类中的属性。例如上面的 `getRememberMe` 方法生成变量为 `BR.rememberMe`。
- set 方法也与 `@Bindable` 注解的方法对应。 `getRememberMe` 对应的 setter 方法为 `setRememberMe`。
- 双向绑定仅对一些常用监听进行了实现，[查看全部默认实现](https://developer.android.com/topic/libraries/data-binding/two-way#two-way-attributes)


### 使用自定义属性进行双向数据绑定

如果提供的双向绑定无法满足需要，可以使用 `@InverseBindingAdapter` 和 `@InverseBindingMethod` 注释自定义属性进行双向数据绑定。


例如给一个自定义时间组件 MyView 的时间进行双向绑定。

1. 使用 `@bindingadapter` 注释设置当值被改变时，设置初始值和更新的方法：

```Kotlin
@BindingAdapter("time")
@JvmStatic fun setTime(view: MyView, newValue: Time) {
    // Important to break potential infinite loops.
    if (view.time != newValue) {
        view.time = newValue
    }
}
```

2. 使用 `@inversebindingadapter` 注解从视图中读取值的方法：

```
@InverseBindingAdapter("time")
@JvmStatic fun getTime(view: MyView) : Time {
    return view.getTime()
}
```

此时，数据绑定知道当数据更改时要做什么（调用 @bindingadapter 注解的方法）以及当视图属性更改时要调用什么（调用 InverseBindingListener 注解的方法）。但是，它不知道属性何时或如何更改。

为此，需要在视图上设置一个监听器。可以是与自定义视图关联的自定义侦听器，也可以是常规事件，例如焦点丢失或文本更改。将 `@bindingadapter` 注解添加到为属性的更改设置侦听器的方法中：

```
@BindingAdapter("app:timeAttrChanged")
@JvmStatic fun setListeners(
        view: MyView,
        attrChange: InverseBindingListener
) {
    // Set a listener for click, focus, touch, etc.
}
```

侦听器包含一个反向绑定侦听器作为参数。你可以使用反向绑定侦听器告诉数据绑定系统该属性已更改。然后，系统可以开始调用 `@InverseBindingAdapter` 进行注释的方法。

注意：每个双向绑定都会生成一个合成事件属性。此属性与基属性同名，但它包含后缀 `AttrChanged`。合成事件属性使用 `@bindingadapter` 注释的方法创建方法，以将事件侦听器关联到适当的视图实例。

### 转换器

如果绑定到视图对象的变量在显示前需要格式化、转换或以某种方式更改，则可以使用转换器对象。

例如，以显示日期的EditText对象为例：

```
<EditText
    android:id="@+id/birth_date"
    android:text="@={Converter.dateToString(viewmodel.birthDate)}"
/>
```

viewModel.birthDate属性包含long类型的值，因此需要使用转换器对其进行格式化。

在使用的是双向表达式，还需要有一个反向转换器，让库知道如何将用户提供的字符串转换回支持的数据类型，在本例中是 Long 类型的时间戳。 通过 `@InverseMethod ` 注解声明一个转换器，对应的关联一个反向转换器，并让此注释引用反向转换器。例如：

```
object Converter {
    @InverseMethod("stringToDate")
    fun dateToString(
        view: EditText, oldValue: Long,
        value: Long
    ): String {
        // Converts long to String.
    }

    fun stringToDate(
        view: EditText, oldValue: String,
        value: String
    ): Long {
        // Converts String to long.
    }
}
```

### 避免双向绑定无线循环


使用双向数据绑定时，注意不要引入无限循环。当用户更改属性时，将调用 `@InverseBindingAdapter` 注解的方法，并将该值分配给属性。反过来，这将调用使用 `@BindingAdapter` 注解的方法。这是，又会触发使用`@InverseBindingAdapter` 注解的方法的另一次调用，依此类推。因此，通过比较使用 `@BindingAdapter` 注解的方法中的新值和旧值来打破可能的无限循环是很重要的。

```
@BindingAdapter("time")
@JvmStatic fun setTime(view: MyView, newValue: Time) {
    // Important to break potential infinite loops.
    if (view.time != newValue) {
        view.time = newValue
    }
}
```