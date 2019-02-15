# MVVM

Android操作系统为构建在各种设备和外形尺寸上运行良好的应用程序提供了坚实的基础。但是，复杂的生命周期和缺乏推荐的应用程序架构等问题使编写强大的应用程序变得具有挑战性。Android体系结构组件为生命周期管理和数据持久性等常见任务提供库，以便更轻松地实现推荐的体系结构。

架构组件可帮助您以更少的样板代码以可靠，可测试和可维护的方式构建应用程序

M-V-VM 是受 WPF 架构的启发，架构 MVP 架构进行演化，将两者糅合得出一个架构。

MVP 向 MVVM 的变迁

| MVP            | MVVM           |  变化         |
| :------------- | :------------- | :----------- |
| M              | M              | Model 层并没有什么理论上的变化。主要是谷歌为了支持 MVVM 架构，添加了一些能够感知生命周期的组件。|
| V              | V              | View 层也是一一对应的，但是 VVVM 中将更过的逻辑操作和生命周期管理向下移动，放在了 VM 层。 |
| P              | VM             | 该层是变化最大的，在 MVP 架构中，Presenter 仅作为 View 和 Model 的中间代理，将逻辑上下传递，而到了 MVVM 架构中，VM 作为了 View 层测数据容器，管理着数据的更新和维护，感知View 层的声明周期，在合适的时机装载数据。|

该体系结构由 UI controller，由 ViewModel 提供 LiveData，Repository 和 Room 数据库组成。

![MVVM 结构](images/mvvm.png)

其实划分为三层：

- V : UI controller 主要是安卓的 UI 组件。
- VM : ViewModel + LiveData，LiveData 大部分由 Model 层创建，由 VM 维护。
- Model : 包含一个 Repository 负责管理本地数据，远程数据，缓存的调度。其中本地数据的架构有： Room, DAO(Data Access Object)。

[Model](model.md)
[ViewModel](viewmodel.md)
