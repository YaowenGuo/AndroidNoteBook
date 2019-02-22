# LiveData

LiveData是一个可观察的数据持有者类。与常规的可观察数据不同，LiveData具有生命周期感知能力，这意味着它尊重其他应用程序组件的生命周期，如 Activity、Fragment 或 Service。这种感知确保 LiveData 只更新处于活动生命周期状态的应用程序组件观察器。

- 当将 LiveData 注册给实现了 `LifecycleOwner` 接口的对象后，LiveData只通知活动状态(in the STARTED or RESUMED state)的观察者更新有关的信息，非活动状态的将不会收到信息。
- 观察注册将会在相应对象生命周期的状态更改为 `DESTROYED` 时删除观察者。这对 `Activity` 和 `Fragment` 特别有用，因为它们可以安全地观察 `LiveData` 对象，而不必担心泄漏，当它们的生命周期被销毁时，`Activity` 和 `Fragment` 会立即取消订阅。


> 优点

- 确保用户界面与数据状态匹配
   使用观察者模式，任何数据更改都能及时更新 UI
- 解决内存泄漏
  当观察者销毁时，自动解绑。
- 不会因为 Activity 停止而 crash
  停止也不会收到更新通知
- 不再需要手动处理声明周期
  UI组件只观察相关数据，不停止或继续观察。LiveData自动管理所有这一切，因为它在观察时知道相关的生命周期状态变化。
- 更新数据及时
  如果生命周期变为非活动状态，它将在再次变为活动状态时接收最新数据。例如，Activity 位于后台时，数据更新了，在返回前台后立即接收最新数据。
- 正确的配置更改
  如果由于配置更改（如设备旋转）而重新创建活动或片段，则它会立即接收最新的可用数据。
- 共享资源
  您可以使用 `singleton` 模式扩展一个 `livedata` 对象来存放系统服务，以便在您的应用程序中共享它们。`LiveData` 对象连接到系统服务一次，然后任何需要该资源的观察者都可以只观察LiveData对象。有关更多信息，请参阅[扩展LiveData](https://developer.android.com/topic/libraries/architecture/livedata#extend_livedata)。
