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
