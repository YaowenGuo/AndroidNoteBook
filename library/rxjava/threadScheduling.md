### 线程控制

Rxjava是为异步而生的，但是默认情况下Rxjava遵循的是线程不变的原则，即：在哪个线程调用 subscribe()，就在哪个线程生产事件；也就是说，如果只用上面的方法，实现出来的只是一个同步的观察者模式。观察者模式本身的目的就是『后台处理，前台回调』的异步机制，因此异步对于 RxJava 是至关重要的。而要实现异步，则需要用到 RxJava 的另一个概念： Scheduler 。

Scheduler ，它们已经适合大多数的使用场景。
## Scheduler 的提供的线程
在RxJava 中，Scheduler ——调度器，相当于线程控制器，RxJava 通过它来指定每一段代码应该运行在什么样的线程。RxJava 已经内置了几个 Scheduler ，它们已经适合大多数的使用场景：

- Schedulers.immediate(): 直接在当前线程运行，相当于不指定线程。这是默认的 Scheduler。

- Schedulers.newThread(): 总是启用新线程，并在新线程执行操作。

- Schedulers.io(): I/O 操作（读写文件、读写数据库、网络信息交互等）所使用的 Scheduler。行为模式和 newThread() 差不多，区别在于 io() 的内部实现是用一个无数量上限的线程池，可以重用空闲的线程，因此多数情况下 io() 比 newThread() 更有效率。不要把计算工作放在 io() 中，可以避免创建不必要的线程。

- Schedulers.computation(): 计算所使用的 Scheduler。这个计算指的是 CPU 密集型计算，即不会被 I/O 等操作限制性能的操作，例如图形的计算。这个 Scheduler 使用的固定的线程池，大小为 CPU 核数。不要把 I/O 操作放在 computation() 中，否则 I/O 操作的等待时间会浪费 CPU。

|调度器类型|效果|
|:--:|:--|
|Schedulers.computation()|用于计算任务，如事件循环或和回调处理，不要用于IO操作(IO操作请使用Schedulers.io())；默认线程数等于处理器的数量|
|Schedulers.from(executor)|使用指定的Executor作为调度器|
|Schedulers.immediate()|在当前线程立即开始执行任务|
|Schedulers.io()|用于IO密集型任务，如异步阻塞IO操作，这个调度器的线程池会根据需要增长；对于普通的计算任务，请使用Schedulers.computation()；Schedulers.io()默认是一个CachedThreadScheduler，很像一个有线程缓存的新线程调度器|
|Schedulers.newThread()|为每个任务创建一个新线程|
|Schedulers.trampoline()|当其它排队的任务完成后，在当前线程排队开始执行|



- Android 还有一个专用的 AndroidSchedulers.mainThread()，它指定的操作将在 Android 主线程运行。(需要引入RxAndroid)


## 指定线程
- subscribeOn(): 指定 subscribe() 所发生的线程，即 Observable.OnSubscribe 被激活时所处的线程。或者叫做事件产生的线程。

- observeOn(): 指定 Subscriber 所运行在的线程。或者叫做事件消费的线程。

```java
flowable.subscribeOn(Schedulers.io())
          .observeOn(AndroidSchedulers.mainThread())
          .subscribe(subscriber);
```

上面这段代码中，由于 subscribeOn(Schedulers.io()) 的指定，被创建的事件的内容 1、2、3、4 将会在 IO 线程发出；而由于observeOn(AndroidScheculers.mainThread()) 的指定，因此 subscriber 数字的打印将发生在主线程 。事实上，这种在subscribe() 之前写上两句 subscribeOn(Scheduler.io()) 和 observeOn(AndroidSchedulers.mainThread()) 的使用方式非常常见，它适用于多数的 『后台线程取数据，主线程显示』的程序策略。
