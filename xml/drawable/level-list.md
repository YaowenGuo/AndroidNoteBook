Level list 的 小号一定要写在上面，大号写在下面，否则在设置 后面的小的图层的时候，会被前面的图层盖住不显示
```
<item android:maxLevel="89" android:drawable="@drawable/pinyin_tone_yanjing" />
<item android:maxLevel="67" android:drawable="@drawable/pinyin_tone_buyao" />

image.getDrawable().setLevel(67); // 设置 67 会显示 89 ，将其顺序反过来就行了。
```

```
<?xml version="1.0" encoding="utf-8"?>
<level-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:maxLevel="64" android:drawable="@drawable/pinyin_tone_nihao" />
    <item android:maxLevel="67" android:drawable="@drawable/pinyin_tone_buyao" />
    <item android:maxLevel="89" android:drawable="@drawable/pinyin_tone_yanjing" />
</level-list>
```
