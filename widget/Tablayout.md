# Tablayout 的 tab 宽度

Tablayout 只有一个 tab 的时候，即使设置模式为 fixed，也无法撑满整个宽度，这时候是 Theme 给 Tab 设置了最大宽度。使用如下属性覆盖 Theme 中的属性即可。
```xml
android:maxTabWidth="1080dp";
```


