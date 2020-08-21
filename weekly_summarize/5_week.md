# 网络请求最佳实践

不像后端的网络请求库有很多，在安卓上进行网络请求的选择性并不多。选择性少不代表质量会差，OkHttp 在网络请求中占有绝对的霸主地位。也可能是太好了，导致没有人再去浪费时间写新的库。用好一个库要比什么都懂点要好很多，因此，这里不会对比网络库之间的形成和设计差别，而是说明一个 OkHttp 的最佳实践。


## 通常组合

一般情况下，OkHttp + Retrofit + RxJava 是现在主流的使用方法。尽管在一些新项目开始向 OkHttp + Retrofit + Kotlin 协称迁移。但网络请求部分仍然没有变。

示例代码

```
```

## 线程调度

由于安卓的特性，网络请求要在非 UI 线程做，否则就会立即抛出异常。因此将网络请求放到其它线程就成了必选项。如果直接使用 OkHttp 通过方法调用的时候就能放到默认的线程中。

### OkHttp 直接进行线程调度

```Java
String run(String url) throws IOException {
    Request request = new Request.Builder()
        .url(url)
        .build();

    // 进行同步执行请求
    try (Response response = client.newCall(request).execute()) {
        return response.body().string();
    }
}


void run(String url) throws IOException {
    Request request = new Request.Builder()
            .url(url)
            .build();

    // enqueue 方法进行异步网络请求。
    client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(@NotNull Call call, @NotNull IOException e) {
                        
                }

                @Override
                public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {

                }
            });
}
```

使用 OkHttp 进行线程调度已经清晰明了了，但是存在的一个问题是，网络返回结果后，需要自己切回到主线程。

### RxJava 的线程切换

为了使用 RxJava 进行线程切换，我们需要使用 Retrofit 和 RxJava-Adapter.

在使用中，我们通常这样切换线程。

```
Api.getInstance()
    	.getChallengeDetail(challengeId)
    	.subscribeOn(Schedulers.io()) // 网络请求放到后台线程
    	.observeOn(AndroidSchedulers.mainThread()) // 返回结果切回到主线程。
    	.subscribe(...)

```

由于网络请求放在后台线程是必须的，在每处都写代码并不是一个好的选择，因为我们希望统一将网络请求放在后台完成。而 `RxJava-adapter` 已经为我们提供了选择。在设置 `Retrofit` 的 `RxJava-adapter` 的时候。

```
Retrofit.Builder builder = new Retrofit.Builder()
        .baseUrl(baseUrl)
        .addConverterFactory(GsonConverterFactory.create(defaultGson == null ? new Gson() : defaultGson))
        .client(createOkHttpClient());
		// .addCallAdapterFactory(RxJava2CallAdapterFactory.create()); // 默认不切换线程。
		.addCallAdapterFactory(RxJava2CallAdapterFactory.createWithScheduler(Schedulers.io())); // 使用 RxJava 的调度器切换。
		// .addCallAdapterFactory(RxJava2CallAdapterFactory.createAsync()) // 使用 OkHttp 的线程池。
```

注意到，还有一个切换到主线程的操作 `.observeOn(AndroidSchedulers.mainThread())`。有时候，有些人希望网络请求后能够自动切换到主线程（为什么说有些人，稍后会讲解，这并不是一个好的选择，这也是为什么 `Rxjava-adapter` 没有默认提供的原因。）。既然 `addCallAdapterFactory` 能够切换换到后台线程，那么我们希望也在此换到主线程。

### 统一网络请求后切换到主线程

1. 代码不集中
2. 接口的实现解析了两遍，从代码逻辑上看，很疑惑。
3. 没有实现多有的情况。


```Java
public class RxJavaObserverOnAdapterFactory extends CallAdapter.Factory {
    protected final Scheduler scheduler;
    public RxJavaObserverOnAdapterFactory(Scheduler scheduler) {
        this.scheduler = scheduler;
    }

    @Override
    public CallAdapter<?, ?> get(Type returnType, Annotation[] annotations, Retrofit retrofit) {
        Type type = getRawType(returnType);
        if (!(type == Observable.class || type == Single.class || type == Flowable.class
                || type == Completable.class || type == Maybe.class)) {
            return null;
        }

        return createCallAdapter(returnType, annotations, retrofit);

    }


    protected CallAdapter<Object, Object> createCallAdapter(Type returnType, Annotation[] annotations, Retrofit retrofit) {
        final CallAdapter<Object, Object> delegate =
                (CallAdapter<Object, Object>) retrofit.nextCallAdapter(this, returnType, annotations);

        return new CallAdapter<Object, Object>() {
            @Override
            public Object adapt(Call<Object> call) {
                // Delegate to get the normal Observable...
                Object o = delegate.adapt(call);
                // ...and change it to send notifications to the observer on the specified scheduler.
                if (o instanceof Observable) {
                    o = ((Observable<?>) o).observeOn(scheduler);
                } else if (o instanceof Single) {
                    o = ((Single<?>) o).observeOn(scheduler);
                }  else if (o instanceof Flowable) {
                    o = ((Flowable<?>) o).observeOn(scheduler);
                }  else if (o instanceof Maybe) {
                    o = ((Maybe<?>) o).observeOn(scheduler);
                }  else if (o instanceof Completable) {
                    o = ((Completable) o).observeOn(scheduler);
                }
                return o;
            }

            @Override
            public Type responseType() {
                return delegate.responseType();
            }
        };
    }
}
```

在 Retrofit 的 Builder 中添加。

```
Retrofit.Builder builder = new Retrofit.Builder()
        // ...
		.addCallAdapterFactory(new RxJavaObserverOnAdapterFactory(AndroidSchedulers.mainThread()))
        .addCallAdapterFactory(RxJava2CallAdapterFactory.createWithScheduler(Schedulers.io()));
```

**虽然给出了方案，但是这并不是最佳实践，一是因为切换到前台线程并不是一定的。二是，RxJava 通常要进行一些变换，而这些变换可能是耗时的，我们希望它也能在后台线程完成。而 observerOn 影响它后面的线程操作，如果我们在网络拦截里如果已经切换到前台线程，那么后继的操作都会在 UI 线程中执行，因此要再次切换到后台，再次切换到前台，非常繁琐，代码不够清晰。**





##  网络请求错误处理

### 存在的问题

1. Exception 类型太多，处理不清楚用哪一个，每个人，每个包里都要自己独特的写法。

仅 Http 请求结果的 Exception 就有（还没看 network 包中的情况）：
```
// package com.fenbi.android.retrofit.exception;
ApiException
ApiRspContentException
ApiStatusException

// Retrofit 的异常
// package retrofit2
HttpException
```

network 包中的异常种类更多，没有规律可把握，使用和看代码都很纠结和疑惑。

2. 每个非正常结果的检查都要自己做并抛出异常，模板代码太多，由于项目中定义的异常种类太多，每种写法还不一样。

有的在 Java 的 Observer 中做检测

```Java
com.fenbi.android.retrofit.observer.ApiObserver 

com.fenbi.android.retrofit.observer.ApiObserverNew {
    @Override
    public void onNext(T t) {
        if (t instanceof Response) {
            int httpCode = ((Response)t).code();
            boolean isSucc = httpCode >= 200 && httpCode < 300;
            if (!isSucc) {
                onError(new HttpException((Response) t));
                return;
            }
        }

        if (t instanceof  BaseRsp) {
            BaseRsp baseRsp = (BaseRsp)t;

            if (!baseRsp.isSuccess()) {
                onError(new ApiRspContentException(baseRsp.getCode(), baseRsp.getMsg()));
                return;
            }
        }

        onSuccess(t);
        onFinish();
    }
}



```




1. 当网络错误发生的时候，什么时候分发到 onResponse？ 什么时候分发到 onError?

2. 多个请求同时发出，token 过期后，同时返回了错误，拦截后，获取多个请求结果，如何获取

3. 在何处处理错误，并将结果统一分发？
    1. 在 RxJava 的 subscribe 订阅的观察者（太靠上层了）
      所有的子类都要继承自该类，没有代码的约束力，需要靠文档或者老同学给新同学说，一定要继承。一旦新同学不知道，或者忘记继承将不起作用。
      
      需要定义多个，RxJava2 开始便有不同类型的观察者， Single, Maybe, Flowable, Observer, Compatable. 需要都复写。

      中间过程 map, 都无法检测到错误，一样会执行变换，变换后不使用，无用操作，太浪费。网络是错误的，变换和 Json 解析也可能数据不对应而出错。


    2. 自定义 Adapter 或者 Convert 可以吗？
    

    
    2. OkHttp 的拦截器中。



4. 如何统一处理网络请求错误？ 
  1. 无网络
  2. 链接错误
  3. 页面错误
  4. Json 转换错误

4. 如何处理错误请求。



原则：

1. 希望同一类型的错误判断最好集中，而不用每次都写
2. 不同类型的错误希望能够分门别类
3. 灵活一些，不限制使用类型。


```
OkHttp         ---------- 失败重连，重定向跟踪。
                    超时，链接失败，抛出 IOException 等异常走 `onFailure`。
                    其他的状态码，只要服务正常返回数据体，都会走 onResponse
  |
  |
  (Response)
  |
  ↓ 
Retrofit     ------------ Response 主要处理请求参数，和返回数据的转换。错误处理没有任何改变。
  |
  |
  (Response)
  |
  ↓ 
RxJavaAdapter ---------- 非 200 ~ 299 的，调用 Observer 的 onError, 但是如果请求的 Type 如果是 Request，就无法正确处理网络请求错误。
  |
  |
  (ResponseBody)
  |
  ↓ 
Convert       ---------- Json 解析错误
  |
  |
   (Json)
  |
  ↓ 
自己处理      ------------ Body 体里使用状态码。可以自己抛出异常，走 Observer 的 onError.
```


OkHttp 

```
/**
 * HTTP Status-Code 407: Proxy AuthenticationRequired.
 */
public static final int HTTP_PROXY_AUTH = 407;

/**
 * HTTP Status-Code 401: Unauthorized.
 */
public static final int HTTP_UNAUTHORIZED = 401;

/** Numeric status code, 307: Temporary Redirect. */
const val HTTP_TEMP_REDIRECT = 307
const val HTTP_PERM_REDIRECT = 308


/**
 * HTTP Status-Code 300: Multiple Choices.
 */
public static final int HTTP_MULT_CHOICE = 300;

/**
 * HTTP Status-Code 301: Moved Permanently.
 */
public static final int HTTP_MOVED_PERM = 301;

/**
 * HTTP Status-Code 302: Temporary Redirect.
 */
public static final int HTTP_MOVED_TEMP = 302;

/**
 * HTTP Status-Code 303: See Other.
 */
public static final int HTTP_SEE_OTHER = 303;

/**
 * HTTP Status-Code 408: Request Time-Out.
 */
public static final int HTTP_CLIENT_TIMEOUT = 408;

/**
 * HTTP Status-Code 503: Service Unavailable.
 */
public static final int HTTP_UNAVAILABLE = 503;
```

> 待研究

https://blog.csdn.net/anhenzhufeng/article/details/86677016