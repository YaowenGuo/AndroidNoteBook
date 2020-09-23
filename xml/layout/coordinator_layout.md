# CoordinatorLayout

- Theme
```
android:theme="@style/AppTheme.NoActionBar">

<style name="AppTheme.NoActionBar">
    <item name="windowActionBar">false</item>
    <item name="windowNoTitle">true</item>
</style>
```

- AppBarLayout
```
<android.support.design.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context="com.example.android.droidcafeinput.MainActivity">

    <android.support.design.widget.AppBarLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:theme="@style/AppTheme.AppBarOverlay">

        <android.support.v7.widget.Toolbar
            android:id="@+id/toolbar"
            android:layout_width="match_parent"
            android:layout_height="?attr/actionBarSize"
            android:background="?attr/colorPrimary"
            app:popupTheme="@style/AppTheme.PopupOverlay" />

    </android.support.design.widget.AppBarLayout>

    <include layout="@layout/content_main" />

   ....

</android.support.design.widget.CoordinatorLayout>
```

- Scroll

The app:layout_behavior for the ConstraintLayout is set to @string/appbar_scrolling_view_behavior, which controls how the screen scrolls in relation to the app bar at the top. (This string resource is defined in a generated file called values.xml, which you should not edit.)

```
```
