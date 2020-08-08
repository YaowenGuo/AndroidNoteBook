3. 在Android上的配置与使用
   ```
   compile 'io.reactivex:rxandroid:1.2.1'
   // Because RxAndroid releases are few and far between, it is recommended you also
   // explicitly depend on RxJava's latest version for bug fixes and new features.

   ```
   在需要使用RxJava的对应模块下的build.gradle 中添加这几句 (如需使用其他的版本，请修改版本号)。**使用RxAndroid时最好带着RxJava，官方的解释是RxAndroid的版本还很少，需要用RxJava来弥补它的不足**。

> RxAndroid

  解释： rxjava-android 模块包含RxJava的Android特定的绑定代码。它给RxJava添加了一些类，用于帮助在Android应用中编写响应式(reactive)的组件。

   - 它提供了一个可以在给定的Android Handler 上调度 Observable 的调度器 Scheduler，特别是在UI主线程上 (```AndroidSchedulers.mainThread()```、```AndroidSchedulers.handlerThread(handler)```)。
   - 它提供了一些操作符，让你可以更容易的处理 Fragment 和 Activity 的生命周期方法。
     ```
      // MyActivity
      private Subscription subscription;

      protected void onCreate(Bundle savedInstanceState) {
          this.subscription = observable.subscribe(this);
      }

      ...

      protected void onDestroy() {
          this.subscription.unsubscribe();
          super.onDestroy();
      }
     ```
   - 它提供了很多Android消息和通知组件的包装类，用于与Rx的调用链搭配使用。
   - 针对常见的Android用例和重要的UI，它提供了可复用的、自包含的响应式组件。（即将到来）

> Android中使用 RxLifecycle 更好的保证及时的注册与解除注册。

  ```
  .compose(this.<Long>bindToLifecycle())   //这个订阅关系跟Activity绑定，Observable 和activity生命周期同步
  ```
   **RxLifecycle更多方法请自行百度**
