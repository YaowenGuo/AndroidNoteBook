#

快速抽取值到资源文件。

```
android:textSize="160sp"
```
Extract the text size of the TextView as a dimension resource named count_text_size, as follows:

- Click the Text tab to show the XML code, if you haven't already done so. Place the cursor on "160sp".

- Press Alt-Enter (Option-Enter on the Mac).

- Click Extract dimension resource.

Set the Resource name to count_text_size, and click OK. (If you make a mistake, you can undo the change with Ctrl-Z).

In the Project view, navigate to values/dimens.xml to find your dimensions. The dimens.xml file applies to all devices. The dimens.xml file for w820dp applies only to devices that are wider than 820dp.

> SELECT color

Add a background color to the TextView.
android:background="#FFFF00"
In the Layout Editor (Text tab), place your mouse cursor over this color and press Alt-Enter (Option-Enter on the Mac).\


> 抽取定义方法

Add the following attribute to thebutton_count button.
```
android:onClick="countUp"
```
- Inside of activity_main.xml, place your mouse cursor over each of these method names.
- Press Alt-Enter (Option-Enter on the Mac), and select Create onClick event handler.
- Choose the MainActivity and click OK.

```
Toast toast = Toast.makeText(context, "Hello Toast", Toast.LENGTH_LONG);
```
Extract the "Hello Toast" string into a string resource and call it toast_message.

Place the cursor on the string "Hello Toast!".

Press Alt-Enter (Option-Enter on the Mac).

Select Extract string resources.

Set the Resource name to toast_message and click OK.

This will store "Hello World" as a string resource name toast_message in the string resources file res/values/string.xml. The string parameter in your method call is replaced with a reference to the resource.
