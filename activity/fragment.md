# Fragment

- Fragment 的 容器一定要用 FrameLayout, 不然 Fragment 的布局在想要靠近底部的时或者 LinearLayout 的 height match_parent 时并不能达到理想效果。



> Can not perform this action after onSaveInstanceState with DialogFragment

```
ft.replace(R.id.result_fl, mFragment);
        ft.commitAllowingStateLoss();


searchFragment?.apply {
    if (!this.isAdded && !this.isStateSaved) {
        val transaction = supportFragmentManager.beginTransaction()
        transaction.add(this, "SEARCH_FRAGMENT_TAG")
        transaction.commitAllowingStateLoss()
    }
}

clickListener.dismissAllowingStateLoss()
```

