
Material Design Typography

```xml
<style name="SportsDetailText"
    parent="TextAppearance.AppCompat.Subhead"/>
<style name="SportsTitle"
    parent="TextAppearance.AppCompat.Headline"/>
<style name="SportsTitle"
    parent="TextAppearance.AppCompat.Display1"/>

```

android TextView取消内置上下边距

```xml
android:includeFontPadding="false"
```

文字设置阴影

```xml
<TextView
    android:id="@+id/name_tv"
    style="@style/TextAppearance.MyApp.Headline6"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:ellipsize="end"
    android:shadowColor="#a6000000"
    android:shadowDy="1"
    android:shadowRadius="1"
    android:singleLine="true"
    android:textColor="#deffffff"
    tools:text="爱吃肉的石头" />
```
