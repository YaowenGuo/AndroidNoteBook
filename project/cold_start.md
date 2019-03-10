# Cold Start

冷启动是在 app 完全杀死的情况下，点击桌面图标到第一屏能够显示的时间，这其中包括：

1. 用户点击 icon
2. 系统开始加载和启动应用
3. 应用启动：开启空白(黑色)窗口
4. 创建应用进程
5. 初始化Application
6. 启动 UI 线程
7. 创建第一个 Activity
8. 解析(Inflater)和加载内容视图
9. 布局(Layout)
10. 绘制(Draw)

其中在 3 ~ 10 之间会形成短暂的空白屏，一般的做法是在app的主题中增加一个北京图，使其在 3 这个地方就能显示。从而使空白屏不那么难看。

## 现有的做法

许多厂商为了增加品牌宣传，会单独使用一个页面作为启动屏（Splash），用于品牌宣传和广告。

但是，广泛形成的共识是，启动页并不能增加用户体验，反而会影响用户的体验。除非你是一个广告商为了靠启动页赚取利润，否则不要使用启动屏。为此有了一系列的优化问题。

we should avoid using Splash Screens on Android, arguing that they hurt the user experience, increase the size of the application, etc.

1. 使用启动屏，从第一个页面向第二个页面的跳转也会增加大约 300ms 的时间。


## 影响冷启动时间的因素

1. 应用的功能越复杂
2. 使用了重写的 Application 类，用于初始化用户分析和错误上报。


## 优化方向

1. 珍惜主题背景
2. 减少甚至避免在 application 中和第一屏之前舒适化任何
3. 数据本地化，优先显示本地数据，加载网络后，再更新本地数据和页面。

### 珍惜主题背景

1. 主题背景设置为和第一页一样的颜色
2. 使用 `<layer-list>` 作为占位符
3. 如果首页有占位图片，将其放到 `<layer-list>` 中，使其在 app 启动时就能加载到内存中，从而减少在第一屏显示时，从外存加载的时间。 23 开始能够使用 svg 图，之前必须使用 png 图。

### 避免在 Application 中初始化数据

### 第一屏优先显示本地数据

数据本地化

详细可查看。

http://saulmm.github.io/avoding-android-cold-starts
