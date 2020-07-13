# 触摸反馈

就是响应用户的点击，长按，滑动操作。触摸反馈的本质就是把一系列触摸事件，解读为对应的操作。比如，按下->抬起就是点击，按下->移动一段距离就是滑动。然后根据解读出来的操作，给出相应的反馈，这就是触摸反馈的本质。需要注意的是：
- 触摸事件包含基本的几个事件：按下，移动，抬起，取消
- 触摸事件并不是相互独立的，而是成序列的，成组的（这是安卓的实现机制，每隔一段时间就采集一次，然后下发给正在显示的视图）。每一组事件都以按下事件为开头，以抬起事件或者取消事件为结束。取消事件（ACTION_CANCEL）是一种特殊的事件，它对应的是事件序列的非人为提前结束。
    - ACTION_DOWN -> ACTION_UP
    - ACTION_DOWN -> ACTION_MOVE -> ACTION_MOVE -> ACTION_MOVE -> ACTION_UP
    - ACTION_DOWN -> ACTION_MOVE -> ACTION_MOVE -> ACTION_CANCEL


## 触摸事件的处理流程

1. 事件由系统采集，由 Activity 开始的。

Activity.dispatchTouchEvent  --->  PhoneWindow.superDispatchTouchEvent ----> DecorView.superDispatchTouchEvent -----> DecorView.dispatchTouchEvent


1. PhoneWindow.DecorView，它是一个真正Activity的root view,它继承了FrameLayout。通过super.dispatchTouchEvent他会把touchevent派发给各个activity的子view。

2. 每一层的 View 的 dispatchTouchEvent 都是一个调度方法，

    - 如果是 ViewGroup

        1. 如果是一个 ViewGroup 会判断子 View 是否请求过禁止拦截。如果拦截被禁止，则直接调用 子 View 的 `dispatchTouchEvent` 传递过去。

        1. 如果没有禁止过，会先判断子 onInterceptTouchEvent 是否拦截事件，返回 true 表示拦截，就调用自己的 `onTouchEvent`。

        2. 如果不拦截才调用子 View 的 `dispatchTouchEvent`，看子 View 是否处理 `ACTION_DOWN` 事件，返回 `true` 表示处理，则后继事件会继续向子 View 发送，否则后继事件都会调用自己的 `onTouchEvent` 来处理，不会再向子View 传递。

        3. 如果子 View 的 `dispatchTouchEvent` 返回的是 `false` 则会调用自己的 `onTouchEvent` 来判断是否处理事件。并将结果返回外层。

    - 如果是 View

        1. 直接调用自身的 onTouchEvent 判断是否处理事件，返回 true 表示处理，返回 false 标识不处理。
        2. onTouchEvent 的结果最终会被 dispatchTouchEvent 返回给父 View。



## 触摸事件分发

```Java
@Override
public boolean dispatchTouchEvent(MotionEvent ev) {

    boolean handled = false;
    
    final int action = ev.getAction();
    final int actionMasked = ev.getActionMasked();;

    // 1. 如果是按下事件，清理之前的标志位
    if (actionMasked == MotionEvent.ACTION_DOWN) {
        // 新操作流来临时清空之前的状态
        // 状态可能被前事件流中的 Cancel 或 UP 清理了。
        // 但是也存在一些 app 切换, ANR或其他状态改变的意外情况。如自定义 ViewGrup 拦截后没有很好的处理 CANCEL.
        cancelAndClearTouchTargets(ev);
        resetTouchState();
    }

    // 检查是否拦截事件
    final boolean intercepted;
    if (actionMasked == MotionEvent.ACTION_DOWN || mFirstTouchTarget != null) {
        // DOWN 或者有子 View 相应的事件  
        final boolean disallowIntercept = (mGroupFlags & FLAG_DISALLOW_INTERCEPT) != 0;
        if (disallowIntercept) {
            intercepted = false;
        } else {
            intercepted = onInterceptTouchEvent(ev);
            ev.setAction(action); // restore action in case it was changed   
        }
    } else {
        // 如果没有子 View 相应事件，则默认拦截。
        // 这也是为什么一旦 DOWN 事件不返回 True, 就再也收不到事件的原因。被启用了默认拦截。
        intercepted = true;
    }

    // 拦截（自己处理）或者有子 View 处理事件，正常分发。
    if (intercepted || mFirstTouchTarget != null) {
        ev.setTargetAccessibilityFocus(false);
    }

    // 检查终止事件
    final boolean canceled = resetCancelNextUpFlag(this)
                    || actionMasked == MotionEvent.ACTION_CANCEL;

    // Update list of touch targets for pointer down, if needed.
    final boolean split = (mGroupFlags & FLAG_SPLIT_MOTION_EVENTS) != 0;
    TouchTarget newTouchTarget = null;
    boolean alreadyDispatchedToNewTouchTarget = false;
    if (!canceled && !intercepted) {
        // 如果事件的目标能够处理事件，把事件分发给它；否则，清除标志位，正常将事件分发给其他子 View.
        // 事件非常重要，必须寻找可获得焦点的宿主以避免持有状态。
        View childWithAccessibilityFocus = ev.isTargetAccessibilityFocus()
                        ? findChildWithAccessibilityFocus() : null;

        if (actionMasked == MotionEvent.ACTION_DOWN
                || (split && actionMasked == MotionEvent.ACTION_POINTER_DOWN)
                || actionMasked == MotionEvent.ACTION_HOVER_MOVE) {
            final int actionIndex = ev.getActionIndex(); // always 0 for down
            final int idBitsToAssign = split ? 1 << ev.getPointerId(actionIndex)
                            : TouchTarget.ALL_POINTER_IDS;

            // 清除该事件之前的目标，防止触摸目标已经变化。
            removePointersFromTouchTargets(idBitsToAssign);

            final int childrenCount = mChildrenCount;
            if (newTouchTarget == null && childrenCount != 0) {
                final float x = ev.getX(actionIndex);
                final float y = ev.getY(actionIndex);
                // 从前向后(层叠的 View, 前面的 View 先接收事件)扫描，找到一个可以接收事件的子 View.
                final ArrayList<View> preorderedList = buildTouchDispatchChildList();
                final boolean customOrder = preorderedList == null
                                && isChildrenDrawingOrderEnabled();
                final View[] children = mChildren;
                // 寻找能处理事件的子 View。
                for (int i = childrenCount - 1; i >= 0; i--) {
                    final int childIndex = getAndVerifyPreorderedIndex(
                            childrenCount, i, customOrder);
                    final View child = getAndVerifyPreorderedView(
                            preorderedList, children, childIndex);

                    // 如果有一个子 View 能获得焦点，就把事件先分发给它。如果没有处理，则继续分发给其它 View.
                    // We may do a double iteration but this is
                    // safer given the timeframe.
                    if (childWithAccessibilityFocus != null) {
                        if (childWithAccessibilityFocus != child) {
                            continue;
                        }
                        childWithAccessibilityFocus = null;
                        i = childrenCount - 1;
                    }

                    if (!child.canReceivePointerEvents()
                            || !isTransformedTouchPointInView(x, y, child, null)) {
                        ev.setTargetAccessibilityFocus(false);
                        continue;
                    }

                    newTouchTarget = getTouchTarget(child);
                    if (newTouchTarget != null) {
                        // 子 View 已经处理在它边界内的事件，
                        // 给它分发一个 pointer 事件。
                        newTouchTarget.pointerIdBits |= idBitsToAssign;
                        break;
                    }

                    resetCancelNextUpFlag(child);
                    if (dispatchTransformedTouchEvent(ev, false, child, idBitsToAssign)) {
                        // 子 View 希望处理它边界内的事件。
                        mLastTouchDownTime = ev.getDownTime();
                        if (preorderedList != null) {
                            // childIndex points into presorted list, find original index
                            for (int j = 0; j < childrenCount; j++) {
                                if (children[childIndex] == mChildren[j]) {
                                    mLastTouchDownIndex = j;
                                    break;
                                }
                            }
                        } else {
                            mLastTouchDownIndex = childIndex;
                        }
                        mLastTouchDownX = ev.getX();
                        mLastTouchDownY = ev.getY();
                        newTouchTarget = addTouchTarget(child, idBitsToAssign);
                        alreadyDispatchedToNewTouchTarget = true;
                        break;
                    }

                    // The accessibility focus didn't handle the event, so clear
                    // the flag and do a normal dispatch to all children.
                    ev.setTargetAccessibilityFocus(false);
                }
                if (preorderedList != null) preorderedList.clear();
            }

            if (newTouchTarget == null && mFirstTouchTarget != null) {
                // 没有找到处理事件的子 View, 将事件分发给最后一个添加的 Target.
                newTouchTarget = mFirstTouchTarget;
                while (newTouchTarget.next != null) {
                    newTouchTarget = newTouchTarget.next;
                }
                newTouchTarget.pointerIdBits |= idBitsToAssign;
            }
        }
    }

    // 将事件分发给子 View.
    if (mFirstTouchTarget == null) {
        // 没有子 View 接收事件，分发给自己。
        handled = dispatchTransformedTouchEvent(ev, canceled, null, TouchTarget.ALL_POINTER_IDS);
    } else {
        // 分发给目标 View, 排除已经分发的目标 View. 如果有必要终止事件。.
        TouchTarget predecessor = null;
        TouchTarget target = mFirstTouchTarget;
        while (target != null) {
            final TouchTarget next = target.next;
            if (alreadyDispatchedToNewTouchTarget && target == newTouchTarget) {
                handled = true;
            } else {
                final boolean cancelChild = resetCancelNextUpFlag(target.child) || intercepted;
                if (dispatchTransformedTouchEvent(ev, cancelChild, target.child, target.pointerIdBits)) {
                    handled = true;
                }
                // 如果拦截了，将 mFirstTouchTarget 置 null
                if (cancelChild) {
                    if (predecessor == null) {
                        mFirstTouchTarget = next;
                    } else {
                        predecessor.next = next;
                    }
                    target.recycle();
                    target = next;
                    continue;
                }
            }
            predecessor = target;
            target = next;
        }
    }

    // 终止或者抬起事件，重置状态。
    if (canceled 
            || actionMasked == MotionEvent.ACTION_UP
            || actionMasked == MotionEvent.ACTION_HOVER_MOVE) {
                resetTouchState();
    } else if (split && actionMasked == MotionEvent.ACTION_POINTER_UP) {
        // 其中一根手指抬起，通知该 View 结束事件。
        final int actionIndex = ev.getActionIndex();
        final int idBitsToRemove = 1 << ev.getPointerId(actionIndex);
        removePointersFromTouchTargets(idBitsToRemove);
    }

    return handled;
}
```

事件分发并不是事件处理的核心，核心就是在 `onTouchEvent` 中接受事件，判断事件对应的操作，并给以用户反馈。事件分发是为了解决触摸事件冲突而设置的机制。


dispatchTouchEvent 的调用是一个先序遍历， 而 onTouchEvent 的调用则是一个后序遍历。因此，可以说事假的分发是从外而内的，而事件的处理是有内而外的。

响应事件的直觉是，从距离手指触摸最近的组件响应触摸。从 View 嵌套排布上来说，总是前面的 View 高于后面的 View 先调用 `onTouchEvent`，内部的 View 高于外部的 View 调用 `onTouchEvent`。如果这个 View 接受这个事件，那么，事件就不再继续传递，后面的，或者外层的 View 就接收不到后面的事件。这个 `DOWN` 事件之后的所有事件都会直接发送给它，不会给其他 View，直到这组事件结束，也就是 `UP` 或者 `CANCEL` 事件出现。

> 这个响应，是如何体现在代码上的？

就是 `onTouchEvent` 的返回值，返回 `true` 表示响应事件。即处理这个 `DOWN` 为起始点的事件流。

其实只有 `DOWN` 事件的返回值需要是 `true`，它的后继事件 `UP`、`MOVE`，`CANCEL` 的返回值没有任何影响。但是，为了统一好记，返回 `true` 就行了。

## 事件拦截


每一个事件发生时，系统从层叠 View 的后向前递归调用每一级的 `onInterceptTouchEvent`, 去询问它是否要拦截这组事件，它默认返回 `false`，也就是不拦截。如果它返回 false，那么即使继续向上去寻问它的子 View，如果直到整个流程都走完，全部都返回 false，这个事就就会走第二个流程：事件分发，`onTouchEvent`, 从上往下。

而如果中途某个 View 想要响应事件，它就可以在 `onInterceptTouchEvent` 里面返回 `true`。然后这个事件就不会再发给它的子 View 了。而是直接转交给它自己的 `onTouchEvent`。并且在这之后的这组事件的所有后继事件，就全部会被自动拦截了。不会再交给他的子 View。也不会交给它的 `onInterceptTouchEvent`。而是直接交给它的 `onTouchEvent`。

另外，`onInterceptTouchEvent` 和 `onTouchEvent` 有一点不同在于，onTouchEvent 是否要消费这组事件，是需要在 `DOWN` 事件中决定的。如果在 `DOWN` 事件发过来的时候返回了 `false`，以后就跟这组事件无缘了，没有第二次机会。 而 `onInterceptTouchEvent` 则是在整个事件流过程中都可以对事件流中的每个事件进行监听。可以选择先行观望，给子 View 一个处理事件的机会。而一旦事件流的发展达到了你的触发条件，这个时候你再返回 true，立刻就可以实现事件流的接管。这样就做到了两不耽误，就让子View 有机会去处理事件，有可以在需要的时候把处理事件的工作接管过来。

当 `onInterceptTouchEvent` 返回 `true` 的时候，除了完成事件的接管，这个 View 还会做一件事，就是他会对它的子 View 发送一个额外的取消事件 `CANCEL`。因为在接管事件的时候，上面的 View 可能正处在一个中间状态，例如 button 被按下的样子。

在某些场景下，希望父布局不要拦截事件，例如在一个滑动列表中，长按拖动重排。这时候需要调用 `requestDisallowInterceptTouchEvent()`，这个方法不是用来重写的，而是用来调用的。在子 View 的事件处理过程中，调用父 View 的这个方法。父View 就不会通过 `onInterceptTouchEvent` 来尝试拦截了。并且它是一个递归方法，它会阻止每一级父 View 的拦截。仅限于当前事件流，在当前事件流结束之后，一切恢复正常。



虽然子 View 可以调用 `requestDisallowInterceptTouchEvent`，这时父 `View` 只能接收到 `DOWN` 方法，此后的事件都接收不到，就无法在 `onInterceptTouchEvent` 实现接收事件的操作。 但是，这不是绝对的，仍然可以通过重写

```java
@Override
public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {
//        super.requestDisallowInterceptTouchEvent(disallowIntercept);
}
```
这时，父布局的 `requestDisallowInterceptTouchEvent` 无法被调用，就会继续能够拦截事件。
