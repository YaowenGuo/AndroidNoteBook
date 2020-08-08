Rxjava的事件以流的形式传递，这就是事件流机制。在事件传递过程中，有时候我们需要将其转换为另一种形式（数据或者事件)。Rxjava已经考虑到了这点，Rxjava建立在事件流的模型之上，数据流就像一条河，从发出的地方流向处理的地方：在流动过程中，它可以被观测，被过滤，被操作，或者被新的消费者与另外一条流合并为一条新的流。

> 响应式编程
响应式编程的一个关键概念是事件。事件可以被等待，可以触发过程，也可以触发其它事件。

RxJava 提供了对事件序列进行变换的支持，这是它的核心功能之一，也是大多数人说『RxJava 真是太好用了』的最大原因。所谓变换，就是将事件序列中的对象或整个序列进行加工处理，转换成不同的事件或事件序列。概念说着总是模糊难懂的，来看 API。
首先看一个 map() 的例子：

```java
Observable.just("images/logo.png") // 输入类型 String
        .map(new Function<String, Bitmap>() {
            @Override
                return getBitmapFromPath(filePath); // 返回类型 Bitmap
            }
        })
        .subscribe(new Consumer<Bitmap>() {
            @Override
            public void accept(Bitmap bitmap) throws Exception {
                showBitmap(bitmap);
            }
        });
```
这里出现了一个叫做 Function 的类。它和 Consumer 非常相似，也是 RxJava 的一个接口，用于包装含有一个参数的方法。 Function 和 Consumer
的区别在于， Function 包装的是有返回值的方法。另外，和 Consumer 只有一个， FunctionX 有多个，用于不同参数个数的方法。

可以看到，map() 方法将参数中的 String 对象转换成一个 Bitmap 对象后返回，而在经过 map() 方法后，事件的参数类型也由 String
转为了 Bitmap。这种直接变换对象并返回的，是最常见的也最容易理解的变换。不过 RxJava 的变换远不止这样，它不仅可以针对事件对象，
还可以针对整个事件队列，这使得 RxJava 变得非常灵活。我列举几个常用的变换：

##### flatMap()
这是一个很有用但非常难理解的变换，因此我决定花多些篇幅来介绍它。 首先假设这么一种需求：假设有一个数据结构『学生』，现在需要打印出一组学生的名字。实现方式很简单：
```java
Student[] students = ...;
Subscriber<String> subscriber = new Subscriber<String>() {
    @Override
    public void onNext(String name) {
        Log.d(tag, name);
    }
    // 其他方法
};
Flowable.fromArray(students)
        .map(new Function<Student, String>() {
            @Override
            public String apply(Student student) throws Exception {
                return student.getName();
            }
        })
        .subscribe(subscriber);
```
很简单。那么再假设：如果要打印出每个学生所需要修的所有课程的名称呢？（需求的区别在于，每个学生只有一个名字，但却有多个课程。）首先可以这样实现：
```java
Student[] students = null;
Subscriber<Student> subscriber = new Subscriber<Student>() {
    @Override
    public void onNext(Student name) {
        /*List<Course> courses = student.getCourses();
        for (int i = 0; i < courses.size(); i++) {
            Course course = courses.get(i);
            Log.d(tag, course.getName());
        }*/
    }
    // 其他方法的实现
};

Flowable.fromArray(students)
        .subscribe(subscriber);

```
依然很简单。那么如果我不想在 Subscriber 中使用 for 循环，而是希望 Subscriber 中直接传入单个的 Course 对象呢（这对于代码复用很重要）？用 map() 显然是不行的，因为 map() 是一对一的转化，而我现在的要求是一对多的转化。那怎么才能把一个 Student 转化成多个 Course 呢？

这个时候，就需要用 flatMap() 了：
```java
Student[] students = ...;
Subscriber<Course> subscriber = new Subscriber<Course>() {
    @Override
    public void onNext(Course course) {
        Log.d(tag, course.getName());
    }
    ...
};
Observable.from(students)
    .flatMap(new Func1<Student, Observable<Course>>() {
        @Override
        public Observable<Course> call(Student student) {
            return Observable.from(student.getCourses());
        }
    })
    .subscribe(subscriber);
```
从上面的代码可以看出， flatMap() 和 map() 有一个相同点：它也是把传入的参数转化之后返回另一个对象。但需要注意，和 map() 不同的是， flatMap() 中返回的是个 Observable 对象，并且这个 Observable 对象并不是被直接发送到了 Subscriber 的回调方法中。 flatMap() 的原理是这样的：1. 使用传入的事件对象创建一个 Observable 对象；2. 并不发送这个 Observable, 而是将它激活，于是它开始发送事件；3. 每一个创建出来的 Observable 发送的事件，都被汇入同一个 Observable ，而这个 Observable 负责将这些事件统一交给 Subscriber 的回调方法。这三个步骤，把事件拆成了两级，通过一组新创建的 Observable 将初始的对象『铺平』之后通过统一路径分发了下去。而这个『铺平』就是 flatMap() 所谓的 flat。

为了更好地实现复杂的链式操作，我们就需要来好好解析下它的工作原理了。
### RxJava"变换"的原理：lift()

这些变换虽然功能各有不同，但实质上都是针对事件序列的处理和再发送。而在 RxJava 的内部，它们是基于同一个基础的变换方法： lift(Operator)。首先看一下 lift() 的内部实现（仅核心代码）：

这是```map()```的源码(源码版本为RxJava1.1.6)，其中调用了"变换"的核心方法```left()```，我们先来分析下这段代码：
```
    //Observable.java
    public final <R> Observable<R> map(Func1<? super T， ? extends R> func) {
        return lift(new OperatorMap<T， R>(func));
    }

    public final <R> Observable<R> lift(final Operator<? extends R， ? super T> operator) {
       return new Observable<R>(new OnSubscribeLift<T， R>(onSubscribe， operator));
    }

    //OnSubscribeLift.java
    @Override
    public void call(Subscriber<? super R> o) {
        try {
            Subscriber<? super T> st = hook.onLift(operator).call(o);
            try {
                // new Subscriber created and being subscribed with so 'onStart' it
                st.onStart();
                parent.call(st);
            } catch (Throwable e) {
                // localized capture of errors rather than it skipping all operators
                // and ending up in the try/catch of the subscribe method which then
                // prevents onErrorResumeNext and other similar approaches to error handling
                Exceptions.throwIfFatal(e);
                st.onError(e);
            }
        } catch (Throwable e) {
            Exceptions.throwIfFatal(e);
            // if the lift function failed all we can do is pass the error to the final Subscriber
            // as we don't have the operator available to us
            o.onError(e);
        }
    }
```
通过上面的源码我们可以得知"变换"```left()```的流程如下（有些代码没有列出，此处不再赘述，感兴趣的朋友可以去Github上详细看下）：
通过```hook.onLift(operator)```执行封装的操作，通过```call()```传入原始```Subscriber```然后封装成新的```Subscriber```，然后通知父```Observable```来处理这个新的```Subscriber```。

 简述:
 1. 创建一个新的```Observable```（被观察者）
    - 新的```Observable```的```call()```中
      a. 通过```Operator```来创建一个新的```Subscriber```（观察者）。
      b. 调用父```Observable```的```call```方法通知它对新创建的```Subscriber```进行处理。


我们通过下面的一个例子来理解下整个链式操作的流程：
```
Observable.just("hello"， "my"， "name"， "is"， "nichool")
        .map(new Func1<String， String>() {
            @Override
            public String call(String s) {
                return "map: " + s;
            }
        })
        .map(new Func1<String， String>() {
            @Override
            public String call(String s) {
                return "map1: " + s;
            }
        })
        .subscribe(new Action1<String>() {
            @Override
            public void call(String s) {
                LogUtils.LogW(s);
            }
        });
```
**先预想下将会打印的Log是什么！！**.

上面的代码可以分成下面这几个流程：

```mermaid
sequenceDiagram
Title: 执行流程
Observable ->> map1: (A) 生成Observable1
map1->>map2: (A) 生成Observable2
map2->>subscribe():(B)
```

执行流程时序图中(A)操作: 也就是刚才的```left()```的简述

时序图(B)操作：```Observable2.subscribe()```将注册的```Subscriber```传入并调用```call()```，开始通知流程

 ```mermaid
 sequenceDiagram
 Title: 通知流程
 subscribe() ->> map2: (C)
 map2->>map1: (D)
 map1->>Observable: (E)
 ```

 通知流程时序图中操作：
  (C) : 调用Observable2.call() - ( 就是```left()```中```call```方法）生成新的Subscriber subscriber2 然后调用Observable1.call();
  (D) : 调用Observable1.call() - 生成 subscriber1，调用 Observable.call();
  (E) : 调用Observable.call() - 将封装了所有操作的subscriber1传入call方法中，开始发送流程

 ```mermaid
 sequenceDiagram
 Title: 发送流程
 Observable ->> subscriber1: (F)
 subscriber1->> subscriber2: (I)
 subscriber2->> subscriber:  (J)
 ```

 发送流程时序图中操作：
  (F) : 调用subscriber1 中的onNext 等方法
  (I) : 调用subscriber2 中的onNext 等方法
  (J) : 调用subscriber(此处为上面代码中的subscribe()方法中的Subscriber) 中的onNext 等方法

 整个流程合起来的流程图 (图片来自 https://gank.io/post/560e15be2dca930e00da1083#toc_15)：
![流程图](1.jpg)

这是结果的Log
```
RxJavaDemo: map1: map: hello
RxJavaDemo: map1: map: my
RxJavaDemo: map1: map: name
RxJavaDemo: map1: map: is
RxJavaDemo: map1: map: nichool
```

> 总结

RxJava中"变换"的核心就是将**操作**封装成新的观察者，多个”变换“的链式操作也就是多个观察者与被观察者相互通知与处理的流程，整个RxJava项目通过这种代理的思想来实现复杂的逻辑。(_真心厉害！！！_)

**本文的分析将非常有助于线程调度方面的理解！！**
