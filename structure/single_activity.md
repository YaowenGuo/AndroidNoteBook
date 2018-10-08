使用单个 Activity，多个Fragment 的模式发现的一些问题：

1. Activity 的启动模式不容易精细化控制。因为安卓系统页面切换都是以 Acitivity 为基础的，关于Activity 的细节设置提供的方法更完善和多样。多个Activty 可以根据业务逻辑的需要，精细的控制 每个 activity 启动方式的 standard, singleTask....
2. Activity 的 Theme 需要增加额外的控制代码，而不是简单的 AndroidMinifest.xml 配置就可以了。虽然大多数页面的主题都是一样的。但是总会有奇怪的设计和需求：不要这个，要那个。通过 Activity 设置这些主题、状态栏、导航栏都更成熟的方便。
3. 返回父页面的 (Up Button) 的返回按钮（Back Button）逻辑更繁琐和难以理清。靠销毁，发 Intent 的方式新建页面来控制这个跳转逻辑。繁琐而且降低了效率。使用 Activity 的话，AndroidMinifest.xml 的  `android:parentActivityName=".MainActivity"
` 就能很好的控制 `Up Button` 逻辑。
