[TOC]

### 创建操作
创建操作 create, just, fromArray/fromIterable/fromFuture, defer, empty/never/throw, range, repeat, Start, timer, interval.


##### create 最简单原始的创建方法
create 通过调用观察者的方法使用最原始的方式创建一个Observable。
```java
Observable.create(new Observable.OnSubscribe<String>() {
     　　@Override
     　　public void call(Subscriber<? super String> subscriber) {
    　　     subscriber.onStart();
    　　     subscriber.onNext("hello");
    　　     subscriber.onCompleted();
     　　}
 　　})；
```

##### Just
将对象或者对象集合转换为一个会发射这些对象的Observable
```
Observable.just("hello", "world",)
            .subscribe(new Action1<String>() {
                @Override
                public void call(String s) {
                    LogUtils.LogW(s);
                }
            });
```
```
RxJavaDemo: onStart
RxJavaDemo: onNext(hello)
RxJavaDemo: onNext(world)
RxJavaDemo: onCompleted
```

##### fromArray fromIterable fromFuture 从数据结构中取数据依次发送

将其它的对象或数据结构转换为Observable
```java

Observable<String> observable = Observable.fromArray("Hello");
// 依次发送字符


String[] array = new String[]{"hello", "my", "name", "is", "nichool"};
Observable.from(array).subscribe(new Action1<String>() {
     @Override
     public void call(String string) {
         LogUtils.LogW(string);
     }
});
```
```
RxJavaDemo: onStart
RxJavaDemo: onNext(hello)
RxJavaDemo: onNext(my)
RxJavaDemo: onNext(name)
RxJavaDemo: onNext(is)
RxJavaDemo: onNext(nichool)
RxJavaDemo: onCompleted
```

##### defer — 直到有观察者订阅时才创建Observable，并且为每个观察者创建一个新的Observable
**这个方法不是很常用, 自我理解这个方法主要用于隐藏Observable的具体操作, 分离被观察者与者的设计者**

Defer操作符会一直等待直到有观察者订阅它，然后它使用Observable工厂方法生成一个Observable。它对每个观察者都这样做，因此尽管每个订阅者都以为自己订阅的是同一个Observable，事实上每个订阅者获取的是它们自己的单独的数据序列。

```java
Observable observable = Observable.defer(new Func0<Observable<String>>() {
       @Override
       public Observable<String> call() {
             return Observable.just("hello", "world");
       }
   });

   observable.subscribe(new Subscriber<String>() {

       @Override
       public void onStart() {
           super.onStart();
           LogUtils.LogW("onStart");
       }

       @Override
       public void onCompleted() {
           LogUtils.LogW("onCompleted");
       }

       @Override
       public void onError(Throwable e) {
           LogUtils.LogW("onError");
       }

       @Override
       public void onNext(String s) {
           LogUtils.LogW("onNext("+ s + ")");
       }
   });
```
尽管打印的结果一样，但是它们不是取自同一个Observable的数据

##### empty/never/throw

   - Empty — 创建一个不发射任何数据但是正常终止的Observable
   - Never — 创建一个不发射数据也不终止的Observable
   - Throw — 创建一个不发射数据以一个错误终止的Observable
**以上三个操作符主要用于测试**

##### timer　创建一个定时任务
timer创建一个定时任务，在设置的时间之后触发观察者的接收方法。在1.x中，它还可以执行间隔逻辑，但在2.x中这个功能交给了interval。
需要注意的是，timer和interval默认都在新线程。
```java
Observable.timer(2, TimeUnit.SECONDS)
        .subscribeOn(Schedulers.io())
        .observeOn(AndroidSchedulers.mainThread()) // timer 默认在新线程，所以需要切换回主线程
        .subscribe(new Consumer<Long>() {
            @Override public void accept(@NonNull Long aLong) throws Exception {
                //
            }
        });
```
timer( )方式
```java
Observable<Integer> observable = Observable.timer(2, TimeUnit.SECONDS);
```
创建一个Observable，它在一个给定的延迟后发射一个特殊的值，即表示延迟2秒后，调用onNext()方法。


##### interval 按固定时间间隔发射，可用作定时器

创建一个按固定时间间隔发射整数序列的Observable，可用作定时器。即按照固定2秒一次调用onNext()方法。
```java
 Observable<String> observable = Observable.interval(2, TimeUnit.SECONDS);
```
如同我们上面可说，interval 操作符用于间隔时间执行某个操作，其接受三个参数，分别是第一次发送延迟，间隔时间，时间单位。
```java
Observable.interval(3,2, TimeUnit.SECONDS)；
```
延迟3秒后，每个2秒触发一次。
然而，心细的小伙伴可能会发现，由于我们这个是间隔执行，所以当我们的Activity 都销毁的时候，实际上这个操作还依然在进行，所以，我们得花点小心思让我们在不需要它的时候干掉它。查看源码发现，我们subscribe(Cousumer<? super T> onNext)返回的是Disposable，我们可以在这上面做文章。

##### range 生成整数序列发射
创建一个发射特定整数序列的Observable，第一个参数为起始值，第二个为发送的个数，如果为0则不发送，负数则抛异常。上述表示发射1到20的数。即调用20次nNext()方法，依次传入1-20数字。
range — 创建发射指定范围的整数序列的Observable,第一个参数为起始值，第二个为个数。
```java
Observable<Integer> observable = Observable.range(1,20);
Observable.range(2, 7).subscribe(new Action1<Integer>() {
      @Override
      public void call(Integer integer) {
          // 显示 2 - 8
          LogUtils.LogW(integer + "");
      }
  });
```

##### repeat
Repeat接收一个重复次数的参数 — 创建重复发射特定的数据或数据序列的Observable
repeat( )方式
```java
Observable<Integer> observable = Observable.just(123).repeat();
```
创建一个Observable，该Observable的事件可以重复调用。
