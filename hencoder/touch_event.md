# 触摸反馈

就是响应用户的点击，长按，滑动操作。触摸反馈的本质就是把一系列触摸事件，解读为对应的操作。比如，按下->抬起就是点击，按下->移动一段距离就是滑动。然后根据解读出来的操作，给出相应的反馈，这就是触摸反馈的本质。需要注意的是：
- 触摸事件包含基本的几个事件：按下，移动，抬起，取消
- 触摸事件并不是相互独立的，而是成序列的，成组的（这是安卓的实现机制，每隔一段时间就采集一次，然后下发给正在显示的视图）。每一组事件都以按下事件为开头，以抬起事件或者取消事件为结束。取消事件（ACTION_CANCEL）是一种特殊的事件，它对应的是事件序列的非人为提前结束。
    - ACTION_DOWN -> ACTION_UP
    - ACTION_DOWN -> ACTION_MOVE -> ACTION_MOVE -> ACTION_MOVE -> ACTION_UP
    - ACTION_DOWN -> ACTION_MOVE -> ACTION_MOVE -> ACTION_CANCEL


## 触摸事件的处理流程

触摸事件由系统采集，从外层到内的传递给 View。每一个触摸事件都会交给 View 的 `onTouchEvent` 方法来处理。在用户触摸屏幕产生触摸操作的时候，他触摸到的 View 的 onTouchEvent 方法会被调用，并把当前事件的信息（比如，这是一个什么类型的事件，按下还是移动。以及设置事件的坐标，等等呢个之类的信息。）作为参数传进 `onTouchEvent` 里面。当 一系列事件不断产生，`onTouchEvent` 就会不断别调用。从而判断出事件对应的操作，并作出反馈。

## 触摸事件分发

事件分发并不是事件处理的核心，核心就是在 `onTouchEvent` 中接受事件，判断事件对应的操作，并给以用户反馈。事件分发是为了解决触摸事件冲突而设置的机制。

响应事件的直觉是，从距离手指触摸最近的组件响应触摸。从 View 嵌套排布上来说，总是前面的 View 高于后面的 View 先调用 `onTouchEvent`，内部的 View 高于外部的 View 调用 `onTouchEvent`。如果这个 View 接受这个事件，那么，事件就不再继续传递，后面的，或者外层的 View 就接收不到后面的事件。这个 `DOWN` 事件之后的所有事件都会直接发送给它，不会给其他 View，知道这组事件结束，也就是 `UP` 或者 `CANCEL` 事件出现。

> 这个响应，是如何体现在代码上的？

就是 `onTouchEvent` 的返回值，返回 `true` 表示响应事件。即处理这个 `DOWN` 为起始点的事件流。

其实只有 `DOWN` 事件的返回值需要是 `true`，它的后继事件 `UP`、`MOVE`，`CANCEL` 的返回值没有任何影响。但是，为了统一好记，返回 `true` 就行了。

## 事件拦截

在触摸事件之前，还有一个拦截机制。 每一个触摸事件到达 View 的 onTouchEvent 之前，Android 会总从整个 Activity 里面最底部的那个根 View 向上一级的询问：你要不要拦截这组事件。拦截就是，事件不交给子 View 处理了，而是自己处理。具体实现是调用 `ViewGroup` 的 `onInterceptTouchEvent` 方法来实现的。

每一个事件发生时，系统从下向上递归调用每一级的 `onInterceptTouchEvent`, 去询问它是否要拦截这组事件，它默认返回 `false`，也就是不拦截。如果它返回 false，那么即使继续向上去寻问它的子 View，如果直到整个流程都走完，全部都返回 false，这个事就就会走第二个流程：事件分发，`onTouchEvent`, 从上往下。

而如果中途某个 View 想要响应事件，它就可以在 `onInterceptTouchEvent` 里面返回 `true`。然后这个事件就不会再发给它的子 View 了。而是直接转交给它自己的 `onTouchEvent`。并且在这之后的这组事件的所有后继事件，就全部会被自动拦截了。不会再交给他的子 View。也不会交给它的 `onInterceptTouchEvent`。而是直接交给它的 `onTouchEvent`。

另外，`onInterceptTouchEvent` 和 `onTouchEvent` 有一点不同在于，onTouchEvent 是否要消费这组事件，是需要在 `DOWN` 事件中决定的。如果在 `DOWN` 事件发过来的时候返回了 `false`，以后就跟这组事件无缘了，没有第二次机会。 而 `onInterceptTouchEvent` 则是在整个事件流过程中都可以对事件流中的每个事件进行监听。可以选择先行观望，给子 View 一个处理事件的机会。而一旦事件流的发展达到了你的触发条件，这个时候你再返回 true，立刻就可以实现事件流的接管。这样就做到了两不耽误，就让子View 有机会去处理事件，有可以在需要的时候把处理事件的工作接管过来。

当 `onInterceptTouchEvent` 返回 `true` 的时候，除了完成事件的接管，这个 View 还会做一件事，就是他会对它的子 View 发送一个额外的取消事件 `CANCEL`。因为在接管事件的时候，上面的 View 可能正处在一个中间状态，例如 button 被按下的样子。

在某些场景下，希望父布局不要拦截事件，例如在一个滑动列表中，长按拖动重排。这时候需要调用 `requestDisallowInterceptTouchEvent()`，这个方法不是用来重写的，而是用来调用的。在子 View 的事件处理过程中，调用父 View 的这个方法。父View 就不会通过 `onInterceptTouchEvent` 来尝试拦截了。并且它是一个递归方法，它会阻止每一级父 View 的拦截。仅限于当前事件流，在当前事件流结束之后，一切恢复正常。

另外： `dispatchTouchEvent` 是事件分发的总调度方法，`onTouchEvent` 和 `onInterceptTouchEvent` 都是在 `dispatchTouchEvent` 方法中发生的。一个事件分发的过程，是加上就是从根 View 递归的调用 `dispatchTouchEvent` 的过程。

虽然子 View 可以调用 `requestDisallowInterceptTouchEvent`，这时父 `View` 只能接收到 `DOWN` 方法，此后的事件都接收不到，就无法在 `onInterceptTouchEvent` 实现接收事件的操作。 但是，这不是绝对的，仍然可以通过重写
```java
@Override
public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {
//        super.requestDisallowInterceptTouchEvent(disallowIntercept);
}
```
这时，不布局的 `requestDisallowInterceptTouchEvent` 无法被调用，就会继续能够拦截事件。
