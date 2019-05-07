# Toast

自定义 Toast

```Java
protected void toast(String message) {
       View toastRoot = LayoutInflater.from(context).inflate(R.layout.toast, null);
       Toast toast = new Toast(context);
       toast.setView(toastRoot);
       TextView tv = (TextView) toastRoot.findViewById(R.id.toast_notice);
       tv.setText(message);
       toast.show();
   }


```

```XML
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
              android:layout_width="wrap_content" android:layout_height="wrap_content"
              android:background="@drawable/toast_border">
    <TextView android:id="@+id/toast_notice"
              android:layout_width="wrap_content"
              android:layout_height="@dimen/toast_height"
              android:layout_gravity="center_vertical"
              android:gravity="center_vertical"
              android:textColor="@color/app_toast_text">
    </TextView>
</LinearLayout>
```
