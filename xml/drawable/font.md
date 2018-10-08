一、自定义字体

1.android Typeface使用TTF字体文件设置字体

我们可以在程序中放入ttf字体文件，在程序中使用Typeface设置字体。
第一步，在assets目录下新建fonts目录，把ttf字体文件放到这。
第二步，程序中调用：
```

AssetManager mgr=getAssets();//得到AssetManager

Typeface tf=Typeface.createFromAsset(mgr, "fonts/ttf.ttf");//根据路径得到Typeface

tv=findViewById(R.id.textview);

tv.setTypeface(tf);//设置字体

```

2.在xml文件中使用android:textStyle=”bold” 可以将英文设置成粗体， 但是不能将中文设置成粗体，
将中文设置成粗体的方法是：
```
TextView tv = (TextView)findViewById(R.id.TextView01);
tv.getPaint().setFakeBoldText(true);//中文仿“粗体”--使用TextPaint的仿“粗体”设置setFakeBoldText为true。
```

注意：部分字体中文无效，虽然不会报错，但是对中文无效。
二、使用RoBoto
自从Android4.0后默认字体就使用了Roboto，下面介绍一下使用方法：
```
android:fontFamily="sans-serif" // roboto regular
android:fontFamily="sans-serif-light" // roboto light
android:fontFamily="sans-serif-condensed" // roboto condensed
android:fontFamily="sans-serif-thin" // roboto thin (android 4.2)
//in combination with
android:textStyle="normal|bold|italic"
```


可用的参数：
```
Regular
Italic
Bold
Bold-italic
Light
Light-italic
Thin
Thin-italic
Condensed regular
Condensed italic
Condensed bold
Condensed bold-italic
```
