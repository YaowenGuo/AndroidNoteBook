# Color



API24
```
int colorRes = getResources().getColor(colorResourceName);
```

API23
```
int colorRes = getResources().getColor(colorResourceName, this.getTheme());
```

API15
```
int colorRes = ContextCompat.getColor(this, colorResourceName);
```
ContextCompat provides many compatibility methods to address API differences in the application context and app resources. The getColor() method in ContextCompat takes two arguments: the current context (here, the activity instance, this), and the name of the color.
