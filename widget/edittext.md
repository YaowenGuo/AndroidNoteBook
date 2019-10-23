# EditText



## 焦点变化

```kotlin
var focusChangeListener = View.OnFocusChangeListener {
    v, hasFocus -> isInput = hasFocus
}

editText.onFocusChangeListener = focusChangeListener
```

文本框重新获取焦点方法：
```java
editText.setFocusable(true);
editText.setFocusableInTouchMode(true);
editText.requestFocus();

editText.clearFocus();//失去焦点
editText.requestFocus();//获取焦点
```

## 内容变化

```kotlin
val searchChangeListener = object: TextWatcher {
        override fun afterTextChanged(s: Editable?) {

        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

        }

        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            s?.let {
                binding.clearSearchIv.visibility = if (it.isNotEmpty()) View.VISIBLE else View.GONE
            }
        }

    }


editText.addTextChangedListener(searchChangeListener)
```


### 显示长度和长度限制

```
<com.google.android.material.textfield.TextInputLayout
    android:id="@+id/reason_desc_container"
    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    app:counterEnabled="true"
    app:counterMaxLength="400"
    android:visibility="gone">
    <com.google.android.material.textfield.TextInputEditText
        android:id="@+id/reason_desc"
        android:textSize="14sp"
        android:textColor="@color/textColorSecondary"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:minHeight="150dp"
        android:gravity="top"
        android:paddingStart="16dp"
        android:paddingEnd="16dp"
        android:paddingTop="8dp"
        android:paddingBottom="8dp"
        android:background="@drawable/bg_report_other_edit"
        tools:text="Other"
        android:maxLength="400"
        android:cursorVisible="true"
        android:textCursorDrawable="@null"
        android:text="@={viewModel.reasonDesc}"/>
</com.google.android.material.textfield.TextInputLayout>
```


commit b39cfded7e198310753c6947c79e426f3e8ad399 (HEAD -> 1.0.44_opt, tag: 1.0.42, origin/master, origin/HEAD, origin/1.0.44_opt, master)
Author: zhuming <zhuming@magicmaoma.com>
Date:   Tue Aug 20 09:53:47 2019 +0800

    Fix:Modify setup development issues

commit 0ca3e6e4836b3a8f2c06fea7b8afe58050f41beb
Author: zhuming <zhuming@magicmaoma.com>
Date:   Mon Aug 19 23:11:30 2019 +0800

    Fix:switch bug

commit 8613507b0f5e3b220ddf3e19aab5281d796fb62c
Author: zhuming <zhuming@magicmaoma.com>
Date:   Mon Aug 19 21:38:12 2019 +0800

    Fix:optimize switch logic and like your display problem

commit 5e1726224c8405fc388bdaf080506bc510d48ec6
Author: zhuming <zhuming@magicmaoma.com>
Date:   Mon Aug 19 19:16:18 2019 +0800

    Task：Changing the Settings switch state is controlled by the server

commit 448d2ec728726868feca5180c98112f7fb4adb7b
Author: zhuming <zhuming@magicmaoma.com>
Date:   Mon Aug 19 16:53:36 2019 +0800

    Fix:Restore card shows state and city issues

commit 89a8041a3e46cd8d7e245707fd50c41f44d5fc76 (tag: 1.0.40)