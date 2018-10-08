2.2 Create click handlers

Each clickable image needs a click handler—a method for the android:onClick attribute to call. The click handler, if called from the android:onClick attribute,
- must be public,
- return void,
- and define a View as its only parameter.

Follow these steps to add the click handlers:

Add the following showDonutOrder() method to MainActivity. For this task, use the previously created displayToast() method to display a Toast message:
```
/**
* Shows a message that the donut image was clicked.
*/
public void showDonutOrder(View view) {
    displayToast(getString(R.string.donut_order_message));
}
```
