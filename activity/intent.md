# Intent

Content intents for notifications are similar to the intents you've used throughout this course. Content intents can be explicit intents to launch an activity, implicit intents to perform an action, or broadcast intents to notify the system of a system event or custom event.

Content intents

- explicit intents
```
Intent notificationIntent = new Intent(this, MainActivity.class);
```
- implicit intents
- broadcast intents


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
