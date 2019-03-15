使用单个 Activity，多个Fragment 的模式发现的一些问题：

1. Activity 的启动模式不容易精细化控制。因为安卓系统页面切换都是以 Acitivity 为基础的，关于Activity 的细节设置提供的方法更完善和多样。多个Activty 可以根据业务逻辑的需要，精细的控制 每个 activity 启动方式的 standard, singleTask....不能灵活的控制每个Activity 的创建、压栈、弹栈的方式。

2. Activity 的 Theme 需要增加额外的控制代码，而不是简单的 AndroidMinifest.xml 配置就可以了。虽然大多数页面的主题都是一样的。但是总会有奇怪的设计和需求：不要这个，要那个。通过 Activity 设置这些主题、状态栏、导航栏都更成熟的方便。

3. 返回父页面的 (Up Button) 的返回按钮（Back Button）逻辑更繁琐和难以理清。靠销毁，发 Intent 的方式新建页面来控制这个跳转逻辑。繁琐而且降低了效率。使用 Activity 的话，AndroidMinifest.xml 的  `android:parentActivityName=".MainActivity"
` 就能很好的控制 `Up Button` 逻辑。

4. xml 的 onClick 属性不能直接和 Activity 的响应方法进行关联。

5. 最进发现 getActivity 为 null 时的安全判断增加了代码繁琐判断，并且 actiity 切换也引起一些很奇怪的问题。

6. 最严重的问题是，跳转流程，例如，需求通常有这种需求，连续跳入几个页面，返回的时候直接返回到一个第一个页面。如果是多个Activity，可以根据Activity 的启动模式，设置为单例的，就能实现，但是单Activity需要自己控制。还有一个案例是通知跳转流程，常常是非正常的。单Activity自己控制也很
