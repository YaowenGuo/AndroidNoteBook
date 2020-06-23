# Fragment

- Fragment 的 容器一定要用 FrameLayout, 不然 Fragment 的布局在想要靠近底部的时或者 LinearLayout 的 height match_parent 时并不能达到理想效果。


## 生命周期函数


生命周期函数通常用于初始化，绑定事件，销毁和性能优化。

```java
 生命周期    这些不是 
    v         v
onAttach() -------------------------  执行该方法时，Fragment与Activity已经完成绑定，该方法有一个Activity类型的参数，代表绑定的Activity，
    v
onCreate() -------------------------  初始化Fragment。可通过参数savedInstanceState获取之前保存的值。
    v
onCreateView() ---------------------  执行该方法时，与Fragment绑定的Activity的onCreate方法已经执行完成并返回，在该方法内可以进行与Activity交互的UI操作，所以在该方法之前Activity的onCreate方法并未执行完成，如果提前进行交互操作，会引发空指针异常。
    |                             |
    v                             |
    v   onViewCreated()           |
    v                             |
onActivityCreated()               |
    v                             |
onStart() ----------------------  | - 执行该方法时，Fragment由不可见变为可见状态。
    v                           | |
onResume()------------ v        | | - 执行该方法时，Fragment处于活动状态，用户可与之交互。
    v             User Visible  | |
onPause() ------------ ^        | | - 执行该方法时，Fragment处于暂停状态，但依然可见，用户不能与之交互。
    v                           | |
    v  onSaveInstanceState()    | | - 保存当前Fragment的状态。该方法会自动保存Fragment的状态，比如EditText键入的文本，即使Fragment被回收又重新创建，
    |                           | |   一样能恢复EditText之前键入的文本。退出应用时不会被调用
    v                           | |
onStop()  ----------------------  | - 执行该方法时，Fragment完全不可见。
    v                             |
onDestroyView() ------------------  - 销毁与Fragment有关的视图，但未与Activity解除绑定，依然可以通过onCreateView方法重新创建视图。通常在ViewPager+Fragment的方式下会调用此方法。
    |
    v
onDestroy()                         - 销毁Fragment。通常按Back键退出或者Fragment被回收时调用此方法。
    v
onDetach()                          - 解除与Activity的绑定。在onDestroy方法之后调用。
```


## Fragment 的隐藏和切换

Fragment 的一大用处就是动态的控制 View 显示。例如，一个页面有几个 Tab 和子页面，点击 Tab 显示不同的子页面。一种做法便是，将不同的子页面放在不同的 Fragment 中，在点击 Tab 时，动态的添加或替换 Fragment

每次都先移除，再添加

```Java
void addFragment(int containerId, @NonNull Fragment fragment, @NonNull String tag){
    FragmentManager fragmentManager = getFragmentManager();
    if (fragmentManager != null) {
        Fragment oldFragment = fragmentManager.findFragmentByTag(tag);
        if (oldFragment != null) {
            fragmentManager.beginTransaction().remove(oldFragment).commit();
        }
        fragmentManager.beginTransaction().add(containerId, fragment, tag).commitAllowingStateLoss();
    }
}
```

或者使用 replease 替换

```Java
private void showMyFragment(Fragment fragment) {
    FragmentTransaction transaction = fragmentManager.beginTransaction();
    transaction.replace(R.id.layout_fragment, fragment);
    transaction.commit();
}
```

这种替换对于页面数据，数据是本地的还能够应付，但对于页面复杂的，每次都从新创建 View ，同时从网络加载数据，是一个即耗时，又浪费资源的操作。因此，有了 hide 和 show 的替代方法。

```Java
private void switchToFragment(Fragment showFragment) {
    if (showFragment != mLastFragment) {
        FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
        if (mLastFragment != null) {
            transaction.hide(mLastFragment);
        }
        if (!showFragment.isAdded()) {
            // 隐藏当前的fragment，显示选中的fragment
            transaction.add(R.id.fl_content, showFragment, showFragment.getClass().getName().commitAllowingStateLoss();
        } else {
            // 隐藏当前的fragment，显示选中的fragment
            transaction.show(showFragment).commitAllowingStateLoss();
        }
        mLastFragment = showFragment;
    }
}
```

添加一个 Fragment 的执行过程

```
Conversation onAttach
Conversation onCreate
Conversation onCreateView
Conversation onViewCreated
Conversation onActivityCreated
Conversation onResume

Conversation setUserVisibleHint true true

添加另一个 Fragment

MyMatchFragment onAttach
MyMatchFragment onCreate
Conversation onHiddenChanged true // 隐藏为 true
MyMatchFragment onCreateView
MyMatchFragment onViewCreated
MyMatchFragment onActivityCreated
Conversation onResume

切换， 执行 hide 和 shou 函数

MyMatchFragment onHiddenChanged true
Conversation onHiddenChanged false
```


### 懒加载

由于这种方式在点击 Tab 时才添加 Fragment，自然而然是懒加载的。然而，在 hide 和 show 切换页面展示的时候，由于不走生命周期函数， 需要通过 onHiddenChanged 函数来一来判断。 但是第一次添加显示的时候， onHiddenChanged 并不会执行。


### setMaxLifecycle

[该部分参考了](https://juejin.im/post/5cdb7c15f265da036c57ac66)

Fragment 的生命周期函数已经够多了，再加上 `setUserVisibleHint` 和 `onHiddenChanged` 的加入，使整个逻辑更加复杂，所以谷歌给 Fragment 的切换加入了 `setMaxLifecycle`，用于替换不再使 `setUserVisibleHint`。在新的 API 中 `setUserVisibleHint` 已经被标记为废弃，同时提醒使用 `setMaxLifecycle` 替代。

`setMaxLifecycle` 给了一个控制声明周期的方法。 根据函数名，其实就是设置 Fragment 的最大生命周期状态，声明周期状态一共有五个

```
static final int INITIALIZING = 0;     // Not yet created.
static final int CREATED = 1;          // Created.
static final int ACTIVITY_CREATED = 2; // Fully created, not started.
static final int STARTED = 3;          // Created and started, not resumed.
static final int RESUMED = 4;          // Created started and resumed.
```

也就是说
```
new 对象 --------------------------
    v                             |          
onAttach()                     INITIALIZING
    v                             |
onCreate() -----------------------v
    v                             |
onCreateView()                    |
    v                           CREATED
onViewCreated()                   |
    v                             |
onActivityCreated() --------------v
    v                        ACTIVITY_CREATED
onStart() ------------------------v
    v                           STARTED
onResume()------------------------v
    v                            RESUMED
onPause() ------------------------v
    v                             |
onStop()  ------------------------v
    v                             |
onDestroyView()                   |
    v                             |
onDestroy() ----------------------v
    v                             |
onDetach()                        |
    v                             |
垃圾回收 ---------------------------
```
虽然生命周状态状态有五个，但是可操作的只有 `CREATED、STARTED、RESUMED` 三个， 也只有这三个状态是和 Fragment 的生命周期是重合的。

BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT

```
 public enum State {
        /**
         * Initialized state for a LifecycleOwner. For an Activity, this is
         * the state when it is constructed but has not received Activity#onCreate yet.
         */
        INITIALIZED,


        /**
         * Created state for a LifecycleOwner. For an Activity, this state
         * is reached in two cases:
         *     after Activity#onCreate() call;
         *     before Activity#onStop() call.
         */
        CREATED,


        /**
         * Started state for a LifecycleOwner. For an Activity, this state
         * is reached in two cases:
         *     after Activity#onStart() call;
         *     before Activity#onPause() call.
         */
        STARTED,

        /**
         * Resumed state for a LifecycleOwner. For an Activity, this state
         * is reached after Activity#onResume() is called.
         */
        RESUMED;

        /**
         * Destroyed state for a LifecycleOwner. After this event, this Lifecycle will not dispatch
         * any more events. For instance, for an {@link android.app.Activity}, this state is reached
         * <b>right before</b> Activity's {@link android.app.Activity#onDestroy() onDestroy} call.
         */
        DESTROYED,
 }
```

生命周期是成对出现的，而设置生命周期是循环，而不可逆的（不可逆是指，只能从低状态向高状态转变，例如从 onCreate 到 onStart 而不能从 onStart 到 onCreate。 循环是指调用成对出现的状态能够构成一个循环，例如 onStop 之后，能继续调用对应的 onStat() -> onResume() --> onPause() --> onStop() --> onStart() 形成一个循环。），所以调用 `setMaxLifecycle` 时如果 Fragment 的状态小于设置的状态，则 Fragment 最多走到设置的生命周期。例如，

```Java
FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
transaction.add(R.id.fl_content, showFragment, showFragment.getClass().getName());
transaction.setMaxLifecycle(showFragment, Lifecycle.State.CREATED);
transaction.commitAllowingStateLoss();
```

```
Conversation onAttach
Conversation onCreate
```

如果当时的生命周期高于这个状态，则会强制其运行到对应的销毁状态。 例如对于正在显示的 Fragment，调用

```Java
// 先让其显示
FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
transaction.add(R.id.fl_content, showFragment, showFragment.getClass().getName());
transaction.setMaxLifecycle(showFragment, Lifecycle.State.RESUMED); // 也可以不设置
transaction.commitAllowingStateLoss();

// 然后改变生命周期状态

FragmentTransaction transaction = getChildFragmentManager().beginTransaction();
transaction.add(R.id.fl_content, showFragment, showFragment.getClass().getName());
transaction.setMaxLifecycle(showFragment, Lifecycle.State.STARTED); // 也可以不设置
transaction.commitAllowingStateLoss();
```

```
Conversation onAttach
Conversation onCreate
Conversation onCreateView
Conversation onViewCreated
Conversation onActivityCreated
Conversation onResume

设置声明周期为 Lifecycle.State.STARTED 之后

Conversation onPause  // 先销毁
Conversation onStop
Conversation onDestroyView
Conversation onCreateView // 后创建
Conversation onViewCreated
Conversation onStart
```

因此，对于想要通过 hide 和 show 来实现懒加载的方式，有一个更方便和统一的方法，对于 hide 的 Fragment, 设置 Fragment 的生命周期状态为 `Lifecycle.State.STARTED`??????DESTROYED?，就会执行该 Fragment 的 `onPause` 操作。而对于显示的 Fragment，设置最大生命周期状态为 `State.RESUMED`， 就会再次执行 `onPause` 操作。这样更加符合声明周期的逻辑。 事实上，新的 ViewPagerAdapter 的`BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT` 模式就是这样控制的。



## BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT

### 与 ViewPager 合用

在和 ViewPager 合用的时候，事情变得麻烦了。 ViewPager 有一定的预加载功能，会提前创建左右各一个页面的 View，甚至，可以通过设置，提前创建几个页面的 View。 这时候，为了优化性能，通常不希望一创建 View 就加载数据：一是加载和绑定数据会在 Activity 创建时的性能影响很大；二是过早加载数据核能用户根本不会使用，是一种很大的浪费。一般会在显示时才加载和绑定数据。

Fragment 单独使用的时候，什么时候对用户可见，不是那么好判断。但可以跟踪 Fragment 的生命周期函数来确定。 在和 ViewPager 一起使用的时候，相邻页面的函数调用也是一样的。这就无法判断 Fragment 是否显示。为此，需要根据 setUserVisibleHint(boolean isVisibleToUser) 来辅助判断是否对用户是否可见。为什么是辅助？因为单凭 setUserVisibleHint 的调用点就是个奇葩。必须和 onResume 一起来判断。对于立即显示的 Fragment，调用过程是：

onAttach() --> setUserVisibleHint(false) --> setUserVisibleHint(true) --> onCreate() --> ... --> onResume()

对于相邻的 Fragment 调用是：

onAttach() --> setUserVisibleHint(false)  --> onCreate() --> ... --> onResume()

这还是首次调用，对于切换 Tab 就更迷了。 首先调用正在显示页面的 setUserVisibleHint(false)，然后调用下一个页面的 setUserVisibleHint(true)。

因为在 setUserVisibleHint(true) 首次调用为 true 的时候， view 并没有创建完成，这时候绑定数据存在着危险，因此需要将 setUserVisibleHint 和 onResume 结合使用来实现懒加载的性能优化。 这让 Fragment 本来就复杂的生命周期变得更复杂了。因此，谷歌在新版本的 API 生命周期上做了调整。只需要在创建 Adapter 是传递一个参数 `BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT`, 就会使 ViewPager 在显示 Fragment 的时候才调用 `onResume` 方法，隐藏的时候调用 `onPause` 方法，生命周期变得简洁清晰。  



## Adapter

FragmentPagerAdapter在销毁Fragment时不会调用onDestroy（）方法，而 `FragmentStatePagerAdapter` 则会调用Fragment的onDestroy()方法，换言之，前者仅仅是销毁了Fragment的View视图而没有销毁Fragment这个对象，但是后者则彻彻底底地消灭了Fragment对象。因此 `FragmentStatePagerAdapter` 适合作为动态 Tab 比较多的场景。


### 避免销毁和内存释放的平衡

优化方案二：避免Fragment的销毁
不管是FragmentStatePagerAdapter还是FragmentPagerAdapter，其中都有一个方法可以被覆写：

```
@Override
public void destroyItem(ViewGroup container, int position, Object object) {
   // super.destroyItem(container, position, object);
}

```


把中间的代码注释掉就行了，这样就可以避免Fragment的销毁过程，一般情况下能够这样使用，但是容易出现一个问题，我们再来看看FragmentStatePagerAdapter的源码：

```
@Override
public void destroyItem(ViewGroup container, int position, Object object) {
    Fragment fragment = (Fragment) object;
    if (mCurTransaction == null) {
        mCurTransaction = mFragmentManager.beginTransaction();
    }
    if (DEBUG) Log.v(TAG, "Removing item #" + position + ": f=" + object
            + " v=" + ((Fragment)object).getView());
    while (mSavedState.size() <= position) {
        mSavedState.add(null);
    }
    mSavedState.set(position, fragment.isAdded()
            ? mFragmentManager.saveFragmentInstanceState(fragment) : null);
    mFragments.set(position, null);
    mCurTransaction.remove(fragment);
}
```

这个过程之中包含了对FragmentInstanceState的保存！这也是FragmentStatePagerAdapter的精髓之处，如果注释掉，一旦Activity被回收进入异常销毁状态，Fragment就无法恢复之前的状态，因此这种方法也是有纰漏和局限性的。FragmentPagerAdapter的源代码就留给大家自己去研究分析，也会发现一些问题的哦。

优化方案三：避免重复创建View
优化Viewpager和Fragment的方法就是尽可能地避免Fragment频繁创建，当然，最为耗时的都是View的创建。所以更加优秀的优化方案，就是在Fragment中缓存自身有关的View，防止onCreateView函数的频繁执行，我就直接上源码了：
```
public class MyFragment extends Fragment {
	View rootView;
	
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        if (rootView == null) {
            rootView = inflater.inflate(R.layout.fragment_my, container, false);
        }
        return rootView;
    }

   @Override
    public void onDestroyView() {
        super.onDestroyView();
        Log.d(TAG, "onDestroyView: " + mParam1);
        mIsFirstLoad=true;
        mIsPrepare=false;
        mIsVisible = false;
        if (rootView != null) {
            ((ViewGroup) rootView.getParent()).removeView(rootView);
        }
    }
}
```

onCreateView中将会对rootView进行null判断，如果为null，说明还没有缓存当前的View，因此会进行过缓存，反之则直接利用。当然，最为重要的是需要在onDestroyView() 方法中及时地移除rootView，因为每一个View只能拥有一个Parent，如果不移除，将会重复加载而导致程序崩溃。



## Fragment 管理和事务

https://www.jianshu.com/p/9f538c3a1918


## 问题

1. 设置初始化参数setArguments()必须在绑定（onAttach）之前调用，当Fragment附加到Activity之后，就无法再调用setArguments()。



2. Can not perform this action after onSaveInstanceState with DialogFragment

```
ft.replace(R.id.result_fl, mFragment);
        ft.commitAllowingStateLoss();


searchFragment?.apply {
    if (!this.isAdded && !this.isStateSaved) {
        val transaction = supportFragmentManager.beginTransaction()
        transaction.add(this, "SEARCH_FRAGMENT_TAG")
        transaction.commitAllowingStateLoss()
    }
}

clickListener.dismissAllowingStateLoss()
```