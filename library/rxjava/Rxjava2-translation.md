



```java
Student[] students = ...;
        Observable.fromIterable(students)
                .flatMap(new Function<String, ObservableSource<?>>() {
                    @Override
                    public ObservableSource<?> apply(@io.reactivex.annotations.NonNull Student student) throws Exception {
                        return Observable.fromArray(student.getCourses());
                    }
                });
```
从上面的代码可以看出， flatMap() 和 map() 有一个相同点：它也是把传入的参数转化之后返回另一个对象。但需要注意，和 map() 不同的是，
flatMap() 中返回的是个 Observable 对象，并且这个 Observable 对象并不是被直接发送到了 Subscriber 的回调方法中。 flatMap()
的原理是这样的：
1. 使用传入的事件对象创建一个 Observable 对象；
2. 并不发送这个 Observable, 而是将它激活，于是它开始发送事件；
3. 每一个创建出来的 Observable 发送的事件，都被汇入同一个 Observable ，而这个 Observable 负责将这些事件统一交给 Subscriber
的回调方法。这三个步骤，把事件拆成了两级，通过一组新创建的 Observable 将初始的对象『铺平』之后通过统一路径分发了下去。而这个『铺平』
就是 flatMap() 所谓的 flat。

> filter()操作符
```java
Observable.just(list).flatMap(new Function<List<String>, ObservableSource<?>>() {
            @Override
            public ObservableSource<?> apply(List<String> strings) throws Exception {
                return Observable.fromIterable(strings);
            }
        }).filter(new Predicate<Object>() {
            @Override
            public boolean test(Object s) throws Exception {
                String newStr = (String) s;
                if (newStr.charAt(5) - '0' > 5) {
                    return true;
                }
                return false;
            }
        }).subscribe(new Consumer<Object>() {
            @Override
            public void accept(Object o) throws Exception {
                System.out.println((String)o);
            }
        });
```
filter()操作符根据test()方法中，根据自己想过滤的数据加入相应的逻辑判断，返回true则表示数据满足条件，返回false则表示数据需要被过滤。最后过滤出的数据将加入到新的Observable对象中，方便传递给Observer想要的数据形式。

> take()操作符:输出最多指定数量的结果。

```java
Observable.just(list).flatMap(new Function<List<String>, ObservableSource<?>>() {
            @Override
            public ObservableSource<?> apply(List<String> strings) throws Exception {
                return Observable.fromIterable(strings);
            }
        }).take(5).subscribe(new Consumer<Object>() {
            @Override
            public void accept(Object s) throws Exception {
                System.out.println((String)s);
            }
        });
```
> doOnNext操作符

```
Observable.just(list).flatMap(new Function<List<String>, ObservableSource<?>>() {
            @Override
            public ObservableSource<?> apply(List<String> strings) throws Exception {
                return Observable.fromIterable(strings);
            }
        }).take(5).doOnNext(new Consumer<Object>() {
            @Override
            public void accept(Object o) throws Exception {
                System.out.println("准备工作");
            }
        }).subscribe(new Consumer<Object>() {
            @Override
            public void accept(Object s) throws Exception {
                System.out.println((String)s);
            }
        });
```
doOnNext()允许我们在每次输出一个元素之前做一些额外的事情。

以上就是一些常用的操作符，通过操作符的使用。我们每次调用一次操作符，就进行一次观察者对象的改变，同时将需要传递的数据进行转变，最终Observer对象获得想要的数据。
以网络加载为例，我们通过Observable开启子线程，进行一些网络请求获取数据的操作，获得到网络数据后，然后通过操作符进行转换，获得我们想要的形式的数据，然后传递给Observer对象。
