# ViewModel

ViewModel 并不具有回调和观察值功能，而是用于保存页面数据和处理页面更新逻辑的一个容器类，它不随着页面因配置改变(包括旋转和更改语言等)销毁重新创建而新建，而是直到页面出栈销毁才销毁。也就是它具有 View 声明周期感知能力。

Android 面临的问题：

1. 当系统销毁并重新创建 UI 界面时，所有在 UI 组件内的数据都会丢失，为了能够正常显示，你将不得不从新加载数据。这是重复且繁杂的操作。对于简单且少量的数据，还能够通过 `onSaveInstanceState() ` 方法存储起来，并且需要序列化和反序列化。但对于大量数据，并不合适。
2. 另一个问题是，UI控制器经常需要进行异步调用，这可能需要一些时间才能返回。用户界面控制器需要管理这些调用，并确保系统在界面被销毁后将这些调用清除，以避免潜在的内存泄漏。这种管理需要大量的维护，并且在为配置更改而重新创建对象的情况下，这是浪费资源的，因为对象可能必须重新发出它已经发出的调用。

3. 将所有工作放在 UI 组件中，会是但个类的代码迅速膨胀，不仅难以维护，也难以复用。更增加了测试的困难。


ViewModel 就是为了将数据所有权和 UI 组件进行分离，将处理变得更简单而高效。

> 警告：ViewModel不得引用视图、生命周期或任何可能包含对 Activity context 的引用的类。

- ViewModel 是一个抽象类，有需要使用 `Context` 的，例如，查找系统服务。可以使用它的子类 `AndroidViewModel(application)` ，它有一个参数，用于提供 Application 的引用。

- ViewModel 仅实现了声明周期的管理和复用，数据的任何使用都需要自定义来实现。

- ViewModel对象可以包含生命周期观察器，例如LiveData对象。然而，ViewModel对象绝不能观察生命周期感知的可观察到的变化，例如LiveData对象。


## ViewModel 的生命周期

当获取ViewModel后，ViewModel对象的作用域是传递给ViewModelProvider的生命周期。viewModel将一直保留在内存中，直到生命周期的作用域永久消失：对于 Activity，在它结束时，对于 fragment，在它分离(detached)时。

ViewModel 能够在不同 Activity 之间复用，而同样会创建。它的实例个数仅和页面的创建个数有关。而和创建次数无关。例如，一个 Activity 启动了它自身，创建了第二个页面，绑定的 ViewModel 也会创建。


## Fragment 之间共享数据

一个 `Activity` 中的两个或多个 `Fragment` 需要相互通信是很常见的。设想一个主-从 Fragment 的常见情况，用户从一个 `Fragment` 列表中选择一个项目，另一个 `Fragment` 显示所选的内容。这种情况永远都不简单，因为两个片段都需要定义一些接口，并且所有者 `Activity` 必须将这两个 `Fragment` 绑定在一起。此外，两个片段都必须处理另一个 `Activity` 尚未创建或可见的场景。

使用 ViewModel 对象可以解决这个常见的痛点。这些片段可以使用其 Activity 范围共享一个 ViewModel 来处理此通信，如下面的示例代码所示：

虽然传入 Fragment 的生命周期，但是获取的 ViewModel 的生命周期将和 Fragment 所在的 Activity 的生命周期相同。

这种方法提供了以下好处：
- 该 Activity 不需要做任何事情，也不需要知道任何有关此通信的信息。
- 除了sharedview模型契约之外，Fragment 不需要互相了解。如果其中一个 Fragment 消失了，另一个仍然像往常一样工作。
- 每个 Fragment 都有自己的生命周期，并且不受另一个 Fragment 生命周期的影响。如果一个 Fragment 替换另一个 fragment，那么UI将继续工作而不会出现任何问题。


> ViewMoodel 仅仅处理分离 UI 数据和 UI 显示和事件处理。如何将数据显示到 UI 以及观察数据的变化，需要用到 [LiveData](live_data.md)，这正遵循了单功能的设计思想。方便任意单个或组合使用各个组件。
