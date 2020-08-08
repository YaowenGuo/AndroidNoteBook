Rxjava
> [Rxjava基础]() 基本概念和使用
> [线程控制](./threadScheduling.md)
> [变换](./translate.md)　事件流的拦截和处理
> [RxAndroid]()
> [原理]()


[TOC]


> RxJava 是什么

RxJava 是由大名鼎鼎的 Netflix 公司在开发软件过程中应用 Rx.NET 思想解决实际问题，并最总提炼出来的一套应用于 Java 的 Rx 框架。

**官方的解释是：** RxJava是 ReactiveX 在JVM上的一个实现，一个在 Java VM 上使用可观测的序列来组成异步的、基于事件的程序的库。
其实， RxJava 的本质可以压缩为异步这一个词。说到根上，它就是一个实现异步操作的库，而别的定语都是基于这之上的。
RxJava采用的是响应式编程，它和传统的命令行编程有区别。

> Rx 是一个多语言实现

Rxjava支持Java 6或者更新的版本，以及其它的JVM语言如 Groovy, Clojure, JRuby, Kotlin 和 Scala。RxJava 可用于更多的语言环境，而不仅是Java和Scala，而且它致力于尊重每一种JVM语言的习惯。

> 为什么要使用 RxJava

- 函数式风格：对可观察数据流使用无副作用的输入输出函数，避免了程序里错综复杂的状态
- 简化代码：Rx的操作符通常可以将复杂的难题简化为很少的几行代码
- 异步错误处理：传统的try/catch没办法处理异步计算，Rx提供了合适的错误处理机制
- 轻松使用并发：Rx的Observables和Schedulers让开发者可以摆脱底层的线程同步和各种并发问题

**传统的调用方法** (此例子来自: https://gank.io/post/560e15be2dca930e00da1083#toc_32)
```java
new Thread() {
    @Override
    public void run() {
        super.run();
        for (File folder : folders) {
            File[] files = folder.listFiles();
            for (File file : files) {
                if (file.getName().endsWith(".png")) {
                    final Bitmap bitmap = getBitmapFromFile(file);
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            imageCollectorView.addImage(bitmap);
                        }
                    });
                }
            }
        }
    }
}.start();
```
此例子就是异步遍历文件，如果是以png结尾的就转换成位图，然后在主线程中显示。

如果我们换成RxJava来写呢
```java
Observable.fromIterable(array)
        .flatMap(new Function<File, Observable<File>>() {
                @Override
                public Observable<File> apply(@NonNull File file) throws Exception {
                      return Observable.fromArray(file.listFiles());
            }
        })
        .filter(new Function<File, Boolean>() {
            @Override
            public Boolean apply(@NonNull File file) throws Exception {
                return file.getName().endsWith(".png");
            }

            @Override
            public Boolean call(File file) {
                return file.getName().endsWith(".png");
            }
        })
        .map(new Function<File, Bitmap>() {
            @Override
            public Bitmap apply(@NonNull File file) throws Exception {
                return getBitmapFromFile(file);
            }
        })
        .subscribeOn(Schedulers.io())
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe(new Consumer<Bitmap>() {
            @Override
            public void accept(Bitmap bitmap) throws Exception {
                imageCollectorView.addImage(bitmap);
            }
        });
```
是不是这样子写逻辑清晰多了。其实上面的例子还是简单的遍历筛选显示，如果再加上更加复杂的逻辑的话，代码将变得十分混乱，大家都是程序员，这种复杂的逻辑算加了注释，隔几天不看，回头再来，也有可能看不懂。
# 引入Rxjava2
RxJava 2.x 已经按照 Reactive-Streams specification 规范完全的重写了，maven也被放在了io.reactivex.rxjava2:rxjava:2.x.y 下，所以 RxJava 2.x 独立于 RxJava 1.x 而存在，而随后官方宣布的将在一段时间后终止对 RxJava 1.x 的维护。
要想使用Rxjava，必须先在Gradle中引入。Rxjava2的路径有了变化，不要只更改一下版本号
> 引入Rxjava
```java
// 在Rxjava1中使用的是：
compile 'io.reactivex:rxjava:1.x.y'
// 然而到了版本2
compile "io.reactivex.rxjava2:rxjava:2.x.y"
```
可以在https://github.com/ReactiveX/RxJava查看具体的版本。就是仓库的tag号

1. 概念：扩展的观察者模式

RxJava 的异步实现，是通过一种扩展的观察者模式来实现的。

观察者模式

先简述一下观察者模式，已经熟悉的可以跳过这一段。

观察者模式面向的需求是：A 对象（观察者）对 B 对象（被观察者）的某种变化高度敏感，需要在 B 变化的一瞬间做出反应。举个例子，
新闻里喜闻乐见的警察抓小偷，警察需要在小偷伸手作案的时候实施抓捕。在这个例子里，警察是观察者，小偷是被观察者，警察需要时刻
盯着小偷的一举一动，才能保证不会漏过任何瞬间。程序的观察者模式和这种真正的『观察』略有不同，观察者不需要时刻盯着被观察者
（例如 A 不需要每过 2ms 就检查一次 B 的状态），而是采用注册(Register)或者称为订阅(Subscribe)的方式，告诉被观察者：
我需要你的某某状态，你要在它变化的时候通知我。 Android 开发中一个比较典型的例子是点击监听器 OnClickListener 。对设置
OnClickListener 来说， View 是被观察者， OnClickListener 是观察者，二者通过 setOnClickListener() 方法达成订阅
关系。订阅之后用户点击按钮的瞬间，Android Framework 就会将点击事件发送给已经注册的 OnClickListener 。采取这样被动的
观察方式，既省去了反复检索状态的资源消耗，也能够得到最高的反馈速度。当然，这也得益于我们可以随意定制自己程序中的观察者和被
观察者，而警察叔叔明显无法要求小偷『你在作案的时候务必通知我』。

OnClickListener 的模式大致如下图：

![监听器的绑定](./image/onClickBundle.jpg)

如图所示，通过 setOnClickListener() 方法，Button 持有 OnClickListener 的引用（这一过程没有在图上画出）；当用户点击
时，Button 自动调用 OnClickListener 的 onClick() 方法。另外，如果把这张图中的概念抽象出来（Button -> 被观察者、
OnClickListener -> 观察者、setOnClickListener() -> 订阅，onClick() -> 事件），就由专用的观察者模式（例如只用于监
听控件点击）转变成了通用的观察者模式。

# 使用

> 操作符
为了与事件相对应，Rxjava中将函数称为操作，而函数名称为操作符。在读到不同作者对于操作符和函数名的不同称呼时，应当知道他们就是一个概念。

## 创建被观察者
Observable有几种创建方法，使用create函数是最基本的一个。需要在此添加要订阅后要处理的事件和触发规则（顺序和时机）。
```java
Observable observable = Observable.create(
        // Rxjava2.x的接口变成了这样。
        new ObservableOnSubscribe() {
            @Override
            public void subscribe(@NonNull ObservableEmitter e) throws Exception {
                e.onNext(1);
                e.onNext(2);
                e.onComplete();
                e.onNext(3);
            }
        }
);

// Rxjava2还支持另一种形式的观察者。支持背压（我感觉叫反馈更合适)。
Flowable flowable = Flowable.create(
        // Rxjava2.x的接口变成了这样。
        new FlowableOnSubscribe() {
            @Override
            public void subscribe(@NonNull FlowableEmitter e) throws Exception {
                e.onNext(1);
                e.onNext(2);
                e.onComplete();
                e.onNext(3);
            }
        }, BackpressureStrategy.BUFFER
);
```
可以看到，这里传入了一个 ObservableOnSubscribe 对象作为参数。ObservableOnSubscribe 会被存储在返回的 Observable 对象中，它的作用相当于一个计划表，当 Observable 被订阅的时候，XXXOnSubscribe 的 subscribe() 方法会自动被调用，事件序列就会依照设定依次发送事件（对于上面的代码，将会发送两次 onNext() 和一次 onCompleted()和一次onNext())。

***发射的内容不允许为null***,否则将引起异常。


create() 方法是 RxJava 最基本的创造事件序列的方法。基于这个方法， RxJava 还提供了一些方法用来快捷创建事件队列，例如：
> 依次发送

```java
Observable observable = Observable.just(1, 2, 3);
// 将会依次调用：
// onNext(1);
// onNext(2);
// onNext(3);
// onCompleted();
```
此外，由于数据的组织方式不同，例如数字，列表，Future
> 按序发送事件：fromArray，fromIterable, fromFuture

- fromArray(T[]) / from(Iterable<? extends T>) : 将传入的数组或 Iterable 拆分成具体对象后，依次发送出来。
- 使用fromIterable()，遍历集合，发送每个item。
注意：Collection接口是Iterable接口的子接口，所以所有Collection接口的实现类都可以作为Iterable对象直接传入fromIterable()方法。

Rxjava根据不同的需要，有许多创建的方法，查看所有的创建方式：
[全部的创建操作](createOperate.md)


## 观察者
Observer 即观察者，它决定事件触发的时候将有怎样的行为。 RxJava 中的 Observer 是接口或抽象类的形式存在的，这样我们只需要实现接口，
在其中写我们想要的处理方式，就会按照我们的方式处理事件。
```java
// 2.x的实现
Observer<String> observer = new Observer<String>() {
        @Override
        public void onSubscribe(@NonNull Disposable d) {
        }

        @Override
        public void onNext(String s) {
            Log.d("Rxjava", "Item: " + s);
        }

        @Override
        public void onComplete() {
            Log.d("Rxjava", "Completed!");
        }

        @Override
        public void onError(Throwable e) {
            Log.d("Rxjava", "Error!");
        }
    };
```
- ObservableEmitter被称为发射器，被观察者就像一个事件源，它使用发射器按照一定的规则和时机发送事件。其中发动的规则和顺序和内容就
ObservableEmitter中我们实现的方法。
- 直接 throws Exception,这样我们就不用再写过多的try-catch代码了。
- 也多了一个回调方法：onSubscribe，传递参数为Disposable，Disposable 相当于 RxJava 1.x 中的 Subscription， 用于解除订阅。
我们可以直接在此处解除订阅。解除订阅后，发射器能够继续发送数据，但观察者不再接收。

如果是使用支持背压的Flowable,则需要创建名为 Subscriber 的消费者。
```java
Subscriber<String> subscriber = new Subscriber<String>() {
        @Override
        public void onSubscribe(Subscription s) {

        }

        @Override
        public void onNext(String s) {
            Log.d("Rxjava", "Item: " + s);
        }

        @Override
        public void onError(Throwable e) {
            Log.d("Rxjava", "Error!");
        }

        @Override
        public void onComplete() {
            Log.d("Rxjava", "Completed!");
        }
    };
```

## 订阅subscribe
创建了 Observable 和 Observer 之后，再用 subscribe() 方法将它们联结起来，整条链子就可以工作了。代码形式很简单：
```java
observable.subscribe(observer);

// 如果是支持　Flowable 和 Subscriber　也是一样的
 flowable.subscribe(subscriber);
```
> 有人可能会注意到， subscribe() 这个方法有点怪：它看起来是『observalbe 订阅了 observer / subscriber』而不是『observer / subscriber 订阅了 observalbe』，这看起来就像『杂志订阅了读者』一样颠倒了对象关系。这让人读起来有点别扭，不过如果把 API 设计成 observer.subscribe(observable) / subscriber.subscribe(observable) ，虽然更加符合思维逻辑，但对流式 API 的设计就造成影响了，比较起来明显是得不偿失的。


除了 subscribe(Observer) 和 subscribe(Subscriber) ，subscribe() 还支持不完整定义的回调，RxJava 会自动根据定义创建出 Subscriber 。
当使用不完整的定义时，主要使用 Consumer 和 Action 两个类。其中 onNext, onError, onSubscribe 在 Consumer 中处理，这得益于它的泛型定义。
```java
public interface Consumer<T> {
    /**
     * Consume the given value.
     * @param t the value
     * @throws Exception on error
     */
    void accept(T t) throws Exception;
}
```
使得它能够接收多种类型

Consumer即消费者，用于接收单个值，BiConsumer则是接收两个值，Function 用于变换对象，Predicate 用于判断。这些接口命名大多参照了 Java 8 。

形式如下：
```java
Observable.just("hello").subscribe(new Consumer<String>() {
    @Override public void accept(String s) throws Exception {
        System.out.println(s);
        }
   });
```
同是 subscribe 对不完整的定义进行了重载支持，它能够接受不同数量的 Consumer:
```java
public final Disposable subscribe(Consumer<? super T> onNext)
public final Disposable subscribe(Consumer<? super T> onNext, Consumer<? super Throwable> onError)
public final Disposable subscribe(Consumer<? super T> onNext, Consumer<? super Throwable> onError, Action onComplete)
public final Disposable subscribe(Consumer<? super T> onNext, Consumer<? super Throwable> onError, Action onComplete, Consumer<? super Disposable> onSubscribe)
```
此时可以看到泛型用好了，能有多大的用处。

其中Consumer中的accept()方法接收一个来自Observable的单个值。Consumer就是一个观察者。其他函数式接口可以类似应用.

Observable 会持有 Subscriber 的引用，这个引用如果不能及时被释放，将有内存泄露的风险。所以最好保持一个原则：要在不再使用的时候尽快在合适的地方（例如 onPause() onStop() 等方法中）调用 unsubscribe() 来解除引用关系，以避免内存泄露的发生。


#### 发送具体规则：

Observable(被观察者)可以发送无限个onNext, Observer(观察者)也可以接收无限个onNext.

当Observable(被观察者)发送了一个onComplete后, Observable(被观察者)中onComplete之后的事件将会继续发送, 而Observer(观察者)收到onComplete事件之后将不再继续接收事件.

当Observable(被观察者)发送了一个onError后, Observable(被观察者)中onError之后的事件将继续发送, 而Observer(观察者)收到onError事件之后将不再继续接收事件.

Observable(被观察者)可以不发送onComplete或onError.

最为关键的是onComplete和onError必须唯一并且互斥, 即不能发多个onComplete, 也不能发多个onError, 也不能先发一个onComplete, 然后再发一个onError, 反之亦然

注: 关于onComplete和onError唯一并且互斥这一点, 是需要自行在代码中进行控制, 如果你的代码逻辑中违背了这个规则, 并不一定会导致程序崩溃. 比如发送多个onComplete是可以正常运行的, 依然是收到第一个onComplete就不再接收了, 但若是发送多个onError, 则收到第二个onError事件会导致程序会崩溃。

另外一个值得注意的点是，在 RxJava 2.x 中，可以看到发射事件方法相比 1.x 多了一个 throws Excetion，意味着我们做一些特定操作再也不用 try-catch 了。

并且 2.x 中有一个 Disposable 概念，这个东西可以直接调用切断，可以看到，当它的 isDisposed() 返回为 false 的时候，接收器能正常接收事件，但当其为 true 的时候，接收器停止了接收。所以可以通过此参数动态控制接收事件了。


> 背压

大概就是指在异步场景中，被观察者发送事件的速度远快于观察者的处理速度的情况下，一种告诉上游的被观察者降低发送速度的策略。
```java
Observable.create(new ObservableOnSubscribe<Integer>() {
   　      @Override public void subscribe(ObservableEmitter<Integer> e) throws Exception {
               while (true){
                   e.onNext(1);
               }
           }
       })
       .subscribeOn(Schedulers.io())
       .observeOn(AndroidSchedulers.mainThread())
       .subscribe(new Consumer<Integer>() {
               @Override public void accept(Integer integer) throws Exception {
                   Thread.sleep(2000); System.out.println(integer);
              }
      });

```
Flowable就是由此产生，专门用来处理这类问题。
关于上述的问题，有个专有的名词来形容上述现象，即：Backpressure(背压)。所谓背压，即生产者的速度大于消费者的速度带来的问题。
在原来的RxJava 1.x版本中并没有Flowable的存在，Backpressure问题是由Observable来处理的。在RxJava 2.x中对于backpressure
的处理进行了改动，为此将原来的Observable拆分成了新的Observable和Flowable，同时其他相关部分也同时进行了拆分。原先的
Observable已经不具备背压处理能力。

到此，我们便知道了Flowable是为了应对Backpressure而产生的。Flowable是一个被观察者，与Subscriber(观察者)配合使用，解决
Backpressure问题。

下面我们就具体讲解处理Backpressure的策略。
注意：处理Backpressure的策略仅仅是处理Subscriber接收事件的方式，并不影响Flowable发送事件的方法。即使采用了处理Backpressure的策略，Flowable原来以什么样的速度产生事件，现在还是什么样的速度不会变化，主要处理的是Subscriber接收事件的方式。

**如果在生产者与消费者在同一线程，则同时只能执行一个线程，Rxjava中的生产者每发送一个实现，都会通知观察者，观察者消费事件。观察者执行完才会执行被观察者。不会产生OOM的问题。Rxjava中的处理不同步处在生产与消费在不同线程的情况**
