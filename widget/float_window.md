App 的弹窗只有悬浮窗能够在其他 app 上方显示。需要弹窗权限。



> 关于Android悬浮窗要获取按键响应的问题


要在Android中实现顶层的窗口弹出，一般都会用WindowsManager来实现，但是几乎所有的网站资源都是说弹出的悬浮窗不用接受任何按键响应。

而问题就是，我们有时候需要他响应按键，比如电视上的android，我们要它响应遥控器上的音量按键等等之类的。这时就必须要对添加的View进行LayoutParams的相关设置了。

主要的代码就两个地方。

第一，添加的view不可以设置layoutParams.flags=LayoutParams.FLAG_NOT_FOCUSABLE;//否则就完全屏蔽了按键了

第二，需要设置view.setFocusableInTouchMode(true);

这两个设置后，为添加的VIew设置的按键监听才可以接收到按键信息，怎么处理就是看需求了。

```Java
view.setOnKeyListener(new OnKeyListener() {            
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                Log.e("wytings","onKeyListener");
                return false;
            }
        });
```