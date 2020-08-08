[TOC]

# Rxjava

## Rxjava被观察者
Single
### Single
Single只会接受一个参数，而观察者也只能调用onError
```java
Single.just(new Random(4).nextInt())
        .subscribe(new SingleObserver<Integer>() {
            @Override public void onSubscribe(@NonNull Disposable d) {

            }
            @Override public void onSuccess(@NonNull Integer integer) {
                Log.e(TAG, "-------------------single : onSuccess : "+integer+"\n" );
            }
            @Override public void onError(@NonNull Throwable e) {
                Log.e(TAG, "-------------------single : onError : "+e.getMessage()+"\n");
            }
        });
```
### Observer


## 创建操作
创建操作用用于创建被观察者，发送数据，也就是事件发生的地方。

创建操作有 create, just, fromArray/fromIterable/fromFuture, defer, empty/never/throw, range, repeat, Start, timer, interval.
[全部的创建操作](createOperate.md)

官方说明文档：https://mcxiaoke.gitbooks.io/rxdocs/content/Operators.html

### timer 延时执行

在指定时间后反射

```Java
Observable.timer(20, TimeUnit.SECONDS)
    .subscribeOn(Schedulers.newThread())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new Consumer<Long>() {
        @Override
        public void accept(Long aLong) throws Exception {
            // Success
        }
    }, new Consumer<Throwable>() {
        @Override
        public void accept(Throwable throwable) throws Exception {
            // Error
        }
    });
```

**请慎重使用自定义操作符，尽量使用下面官方提供的操作符**

创建了被观察者之后，就定义好了实践的发生规则。然而，事件发送的数据并不一定是我们想要的，这就需要在被观察者接受之前进行一些处理。
### 处理操作
RxJava中操作类型分为很多种:

#### 变换操作
变换操作 buffer, FlatMap, GroupBy, Map, Scan和Window, toSortList
#### groupBy
      - groupBy — 将一个Observable分拆为一些Observables集合，它们中的每一个发射原始Observable的一个子序列
        ```
        Observable.just("hello", "my", "name", "is", "nichool")
                .groupBy(new Func1<String, Integer>() {
                    @Override
                    public Integer call(String s) {
                        if(s.equals("my")) {
                            return 1;
                        }

                        return 2;
                    }
                }).subscribe(new Action1<GroupedObservable<Integer, String>>() {
                @Override
                public void call(final GroupedObservable<Integer, String> integerStringGroupedObservable) {
                    integerStringGroupedObservable.subscribe(new Action1<String>() {
                        @Override
                        public void call(String s) {
                             LogUtils.LogW("group >> " + integerStringGroupedObservable.getKey() + " value " + s);
                        }
                    });
                }
            });
        ```

        **通过groupBy中的call来决定具体分成什么组, 调用顺序依旧是传入的顺序**
        ```
        RxJavaDemo: group >> 2 value hello
        RxJavaDemo: group >> 1 value my
        RxJavaDemo: group >> 2 value name
        RxJavaDemo: group >> 2 value is
        RxJavaDemo: group >> 2 value nichool
        ```
        **就是将数据两两操作**
        ```
        RxJavaDemo: hello
        RxJavaDemo: hello my
        RxJavaDemo: hello my name
        RxJavaDemo: hello my name is
        RxJavaDemo: hello my name is nichool
        ```
      - buffer — 定期收集Observable的数据放进一个数据包裹，然后发射这些数据包裹，而不是一次发射一个值
        ```
        Observable.just("hello", "my", "name", "is", "nichool")
                .buffer(2).subscribe(new Observer<List<String>>() {
                    @Override
                    public void onCompleted() {

                    }

                    @Override
                    public void onError(Throwable e) {

                    }

                    @Override
                    public void onNext(List<String> strings) {
                        LogUtils.LogW(strings.toString());
                    }
                });
        ```
        **将数据2个一组发送出来**
        ```
        RxJavaDemo: [hello, my]
        RxJavaDemo: [name, is]
        RxJavaDemo: [nichool]
        ```
#### window 分发
如果说map是对发送源的合并，那window则是对数据源的分流，只是window只能按照设定的值讲连续的几个分发到相同的abservable。不同窗口的
数据分发到不同的observable。
```java
Observable.interval(1, TimeUnit.SECONDS) // 间隔一秒发一次
        .take(15) // 最多接收15个
        .window(3, TimeUnit.SECONDS)
        .subscribeOn(Schedulers.io())
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe((Consumer<? super Observable<Long>>) new Consumer<Observable<Long>>() {
            @Override
            public void accept(Observable<Long> observable) throws Exception {
                observable.subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Consumer<Long>() {
                            @Override
                            public void accept(@NonNull Long value) throws Exception {
                                Log.e(TAG, "Next:" + value + "\n");
                            }
                        });
            }
        });
```
#### buffer
buffer操作很有意思，它允许你从新截取连续的一组进行发送。这样的话你可以周期性的重叠一部分数据或者跳过一部分数据。buffer接受两个参数。
buffer(count,skip)，count是每次发送的数量。skip是每次的偏移量。
例如1,2,3,4,5,6,7,8
count,skip = 2,3时接收到的结果为：[1,2], [4,5],[7,8]
count,skip = 3,2时接收到的结果为：[1,2,3],[3,4,5],[5,6,7],[7,8]
```java
Observable.just(1, 2, 3, 4, 5)
        .buffer(3, 2)
        .subscribe(new Consumer<List<Integer>>() {
            @Override public void accept(@NonNull List<Integer> integers) throws Exception {
                mRxOperatorsText.append("buffer size : " + integers.size() + "\n");
                Log.e(TAG, "buffer size : " + integers.size() + "\n");
                mRxOperatorsText.append("buffer value : ");
                Log.e(TAG, "buffer value : " );
                for (Integer i : integers) {
                    mRxOperatorsText.append(i + "");
                    Log.e(TAG, i + "");
                }
                mRxOperatorsText.append("\n"); Log.e(TAG, "\n");
            }
        });
```

## 过滤操作
过滤操作 debounce, distinct, ElementAt, filter, First, IgnoreElements, last, Sample, skip, SkipLast, take, TakeLast
#### debounce
debounce(500, TimeUnit.MILLISECONDS)接收一个事件间隔和一个时间单位常量。debounce会检测发送事件的事件间隔，去掉发送间隔小于设定值的
前一个事件。
- 时间间隔是以该事件之后的间隔。这样的设计是合理的，因为第一个事件之间没有间隔这一说。另一点就是保证了最有一个
事件一定可以发送，因为最后一个事件后的时间一旦超过了设置的阀值，就可以发送事件了。
- 需要注意的是，时间间隔并不累积，每个事件仅和它后面挨着的间隔相关。若果所有的时间间隔都小于设定值，就会导致收不到事件的现象。或者
一个很长的时间内收不到事件。并不是该事件段没有事件，可能是因为这段时间发射频率过高。导致所有的事件均被过滤掉。
```java
Observable.create(new ObservableOnSubscribe<Integer>() {
        @Override
        public void subscribe(@NonNull ObservableEmitter<Integer> emitter) throws Exception {
            // send events with simulated time wait
                Thread.sleep(600);
                emitter.onNext(1); // skip
                Thread.sleep(400);
                emitter.onNext(2); // deliver
                Thread.sleep(505);
                emitter.onNext(3); // skip
                Thread.sleep(300);
                emitter.onNext(4); //deliver
                Thread.sleep(405);
                emitter.onNext(5); //deliver
                Thread.sleep(510);
                emitter.onComplete();
            }
        })
        .debounce(500, TimeUnit.MILLISECONDS)
        .subscribeOn(Schedulers.io())
        .subscribe(new Consumer<Integer>() {
            @Override
            public void accept(@NonNull Integer integer) throws Exception {
                Log.e(TAG, "debounce :" + integer + "\n");
            }
        });
```
#### distinct去重
```java
Observable.just(1, 1, 1, 2, 2, 3, 4, 5)
        .distinct()
        .subscribe(new Consumer<Integer>() {
            @Override public void accept(@NonNull Integer integer) throws Exception {
                mRxOperatorsText.append("distinct : " + integer + "\n");
                Log.e(TAG, "distinct : " + integer + "\n");
            }
        });
```
只会输出1,2,3,4,5
#### filter接受一个参数，可以将发射的值作为参数，对其进行判断，如果返回为false，则会被过滤掉。让其过滤掉不符合条件的值
```java
Observable.just(1, 20, 65, -5, 7, 19)
    .filter(new Predicate<Integer>() {
         @Override public boolean test(@NonNull Integer integer) throws Exception {
              return integer >= 10;
           }
    })
```
#### skip
skip 很有意思，其实作用就和字面意思一样，接受一个 long 型参数 count ，代表跳过 count 个数目开始接收。
例如发送1,2,3,4,5，skip为2，则只能接收到3,4,5。
#### take
take接受一个long类型的count，表示至多接受这么多个数据。
#### last
last 操作符仅取出可观察到的最后一个值，或者是满足某些条件的最后一项。


## 组合操作
组合操作 And/Then/When, CombineLatest, Join, merge, StartWith, Switch, zip
merge 顾名思义，熟悉版本控制工具的你一定不会不知道 merge 命令，而在 Rx 操作符中，merge 的作用是把多个
Observable 结合起来，接受可变参数，也支持迭代器集合。注意它和 concat 的区别在于，不用等到 发射器 A 发
送完所有的事件再进行发射器 B 的发送。
![merger操作]()
```java
Observable.merge(Observable.just(1, 2), Observable.just(3, 4, 5))
        .subscribe(new Consumer<Integer>() {
            @Override public void accept(@NonNull Integer integer) throws Exception {
                Log.e(TAG, "accept: merge :" + integer + "\n" );
            }
        });
```
       - merge — 将多个Observable合并为一个。
       ```
       Observable<String> a = Observable.just("hello", "my", "name");
       Observable<String> b = Observable.just("is", "nichool");
       Observable.merge(a, b)
               .subscribe(new Subscriber<String>() {
                   @Override
                   public void onNext(String s) {
                       LogUtils.LogW(s);
                   }

                   @Override
                   public void onError(Throwable error) {
                   }

                   @Override
                   public void onCompleted() {
                   }
               });
       ```
       ```
       RxJavaDemo: hello
       RxJavaDemo: my
       RxJavaDemo: name
       RxJavaDemo: is
       RxJavaDemo: nichool
       ```
       - zip — 使用一个函数组合多个Observable发射的数据集合，然后再发射这个结果。
       ```
       Observable<Integer> a = Observable.just(1,2,3,4);
       Observable<Integer> b = Observable.just(4,5,6);
       Observable.zip(a, b, new Func2<Integer, Integer, String>() {
           @Override
           public String call(Integer item1, Integer item2) {
               return item1 + " zip " + item2;
           }
       }).subscribe(new Action1<String>() {
           @Override
           public void call(String s) {
               LogUtils.LogW(s);
           }
       });
       ```
       ```
       RxJavaDemo: 1 zip 4
       RxJavaDemo: 2 zip 5
       RxJavaDemo: 3 zip 6
       ```
## 错误处理
错误处理 Catch和Retry
## 辅助操作
辅助操作 doOnnext，Delay, Do, Materialize/Dematerialize, ObserveOn, Serialize, Subscribe, SubscribeOn, TimeInterval, Timeout, Timestamp, Using.
#### doOnNext
它的作用是让订阅者在接收到数据之前干点有意思的事情。假如我们在获取到数据之前想先保存一下它，无疑我们可以这样实现。
```java
Observable.just(1, 2, 3, 4)
        .doOnNext(new Consumer<Integer>() {
            @Override public void accept(@NonNull Integer integer) throws Exception {
                mRxOperatorsText.append("doOnNext 保存 " + integer + "成功" + "\n");
                Log.e(TAG, "doOnNext 保存 " + integer + "成功" + "\n");
            }
        }).subscribe(consumer);
```
## 条件和布尔操作
条件和布尔操作 All, Amb, Contains, DefaultIfEmpty, SequenceEqual, SkipUntil, SkipWhile, TakeUntil, TakeWhile.
## 算数和集合操作
算术和集合操作 Average, Concat, Count, Max, Min, reduce, Sum.
#### 将整个队列合并为一个结果发射
reduse接收两个参数，第一次从发射队列取连个。返回处理结果，此结果所谓下一轮调用的第一个参参数，从队列中取第二个参数。一直到最后没有数据
才讲数据发送给观察者。例如计算发送队列整数的和。
```java
Observable.just(1, 2, 3)
                .reduce(new BiFunction<Integer, Integer, Integer>() {
                    @Override
                    public Integer apply(@NonNull Integer integer, @NonNull Integer integer2) throws Exception {
                        return integer + integer2;
                    }
                })
                .subscribe(new Consumer<Integer>() {
                    @Override public void accept(@NonNull Integer integer) throws Exception {
                        Log.e(TAG, "accept: reduce : " + integer + "\n");
                    }
                });
```
#### scan
Scan — 连续地对数据序列的每一项应用一个函数，然后连续发射结果
scan和reduse的处理逻辑一样，只是每执行一次都发送一个事件。如上，同样处理1,2,3，则会输出1本身，1和2的结果3，3和3的结果6。而不是只输出一次6。

## 转换操作
转换操作 To
## 连接操作
连接操作 Connect, Publish, RefCount, Replay.
## 反压操作
反压操作，用于增加特殊的流程控制策略的操作符
