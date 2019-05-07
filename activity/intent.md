# Intent

Intent 携带一些信息，告诉系统，要启动什么组件（启动 activity, service, 发送广播）以及传递给目标的附加信息。或者要执行的动作（隐式 intent，发送广播）。

Intent 携带的主要信息

- 组件名（可选）: 要启动的组件名。显示 intent 的标志，明确指定 intent 的交付目标。如果没有，则为隐式 intent。系统根据其他意图信息（例如下面描述的操作，数据和类别）决定哪个组件应该接收意图。

**注意：启动服务时，请始终指定组件名称。否则，您无法确定哪些服务将响应意图，并且用户无法查看哪个服务启动。**

- Action: 一个用于指定要执行动作的字符串。用于广播时，标识发生并将执行的动作。该操作很大程度上决定了意图的其余部分是如何构建的 - 特别是数据和附加内容中包含的信息。

- Data: URI（一个Uri对象），它引用要作用的数据和/或该数据的MIME类型。
提供的数据类型通常由意图的行为决定。例如，如果操作是ACTION_EDIT，则数据应包含要编辑的文档的URI。

- Category: 一个字符串，包含有关应处理 Intent 的组件类型的其他信息。可以在意图中放置任意数量的类别描述，但大多数意图不需要类别。
以下是一些常见类别：
    - CATEGORY_BROWSABLE: 目标活动允许自己由Web浏览器启动，以显示链接引用的数据，例如图像或电子邮件。
    - CATEGORY_LAUNCHER: 活动是任务的初始活动，并列在系统的应用程序启动器中。
    - [完整列表](https://developer.android.com/reference/android/content/Intent.html)

上面列出的这些属性（组件名称，操作，数据和类别）表示intent的定义特征。通过阅读这些属性，Android系统能够解析应该启动的应用程序组件。但是，意图可以携带其他信息，这些信息不会影响应用程序组件的解析方式。
意图还可以提供以下信息：

Extras: 键值对，带有完成请求的操作所需的附加信息。

> 分类

- explicit intents
明确指定目标 app 的包名，或者目标类的全路径的类名。显示 Intent 通常用于启动 app 内部组件，因为知道目标的具体类名。
```
Intent notificationIntent = new Intent(this, MainActivity.class);
```
- implicit intents

隐式 intent 不指定具体的组件名，而是传入一个要指定的动作。允许其他给能够处理该动作的 app 或组件处理。隐式 intent，系统通过匹配注册的 IntentFilter 来查找能够处理该 Intent 的组件或 app。当多个 IntentFilter 都匹配的时候，系统会弹出一个弹窗，让用户选择使用哪个程序处理该 Intent。

例如，通过为 Activity 声明一个 IntentFilter，可以让其他应用程序以某种 Intent 直接启动您的 Activity。
同样，如果您没有为 Activity 声明任何意 IntentFilter，则只能使用显示 Intent 启动它。

broadcast intents (隐式 Intent)


警告：为确保您的应用程序安全，请始终在启动服务时使用明确的意图，并且不要为您的服务声明意图过滤器。使用隐式意图启动服务存在安全隐患，因为您无法确定哪些服务将响应意图，并且用户无法查看启动哪个服务。
从Android 5.0（API级别21）开始，如果使用隐式intent调用bindService（），系统将抛出异常


## Implicit Intent


1. Get the string value of the EditText:
```
String url = mWebsiteEditText.getText().toString();
```
2. Encode and parse that string into a Uri object:
```
Uri webpage = Uri.parse(url);
```
3. Create a new Intent with Intent.ACTION_VIEW as the action and the URI as the data:
```
Intent intent = new Intent(Intent.ACTION_VIEW, webpage);
```

This intent constructor is different from the one you used to create an explicit intent. In your previous constructor, you specified the current context and a specific component (activity class) to send the intent. In this constructor you specify an action and the data for that action. Actions are defined by the Intent class and can include ACTION_VIEW (to view the given data), ACTION_EDIT (to edit the given data), or ACTION_DIAL (to dial a phone number). In this case the action is ACTION_VIEW because we want to open and view the web page specified by the URI in the webpage variable.

4. Use the resolveActivity() and the Android package manager to find an activity that can handle your implicit intent. Check to make sure the that request resolved successfully.

5. Inside the if-statement, call startActivity() to send the intent.
```
if (intent.resolveActivity(getPackageManager()) != null) {
    startActivity(intent);
}
```
This request that matches your intent action and data with the intent filters for installed applications on the device to make sure there is at least one activity that can handle your requests.

6. Add an else block to print a log message if the intent could not be resolved.
```
} else {
   Log.d("ImplicitIntents", "Can't handle this!");
}
```


## Question 4
How do you add the current value of the count to the intent?

As the intent data
As an intent action
As an intent extra

## 打开浏览器时，可能会因为浏览器不存在而抛出异常

ActivityNotFoundException

```java
    try {
        Intent i = new Intent(Intent.ACTION_VIEW, Uri.parse("http://m.fretebras.com.br/fretes"));
        startActivity(i);
    } catch (ActivityNotFoundException e) {
        e.printStackTrace();
    }
```
以上处理并不太好，可以先检测是否存在。

> 启动另一个 App

```Java
Intent launchIntent = getPackageManager().getLaunchIntentForPackage("com.package.address");
if (launchIntent != null) {
    startActivity(launchIntent);//null pointer check in case package name was not found
}


没有安装 app 则打开应用市场

public void startNewActivity(Context context, String packageName) {
    Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);
    if (intent == null) {
        // Bring user to the market or let them choose an app?
        intent = new Intent(Intent.ACTION_VIEW);
        intent.setData(Uri.parse("market://details?id=" + packageName));
    }
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
}
```


> 有闪屏页和主页时，点击图标会再次创建闪屏页的问题

```Kotlin
https://www.jianshu.com/p/b202690b7d96

if ((intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT) > 0) {
            finish()
            return
        }
```


> 通知会从新创建页面

下面代码会导致页面从新创建

```
resultIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK);

```
