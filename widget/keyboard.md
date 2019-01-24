

## 收起软键盘

```
InputMethodManager inputManager = (InputMethodManager)
   getSystemService(Context.INPUT_METHOD_SERVICE);

if (inputManager != null ) {
   inputManager.hideSoftInputFromWindow(view.getWindowToken(),
           InputMethodManager.HIDE_NOT_ALWAYS);
}

```
