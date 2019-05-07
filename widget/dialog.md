# Dialog 全屏

https://juejin.im/post/58de0a9a44d904006d04cead


## DialogFragment 监听返回按键

```
dialog?.setOnKeyListener(object : DialogInterface.OnKeyListener {
                    override fun onKey(dialog: DialogInterface?, keyCode: Int, event: KeyEvent?): Boolean {
                        if (keyCode == KeyEvent.KEYCODE_BACK) {
                            return true
                        }
                        return false
                    }

                })
```
