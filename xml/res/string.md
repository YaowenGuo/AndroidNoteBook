# 定义字符串和其他资源引用的字符串，以及数组

## 字符串数组

```
<string-array name="sports_titles">
    <item>Baseball</item>
    <item>Badminton</item>
    <item>Basketball</item>
    <item>Bowling</item>
    <item>Cycling</item>
    <item>Golf</item>
    <item>Running</item>
    <item>Soccer</item>
    <item>Swimming</item>
    <item>Table Tennis</item>
    <item>Tennis</item>
</string-array>

// Get the resources from the XML file.
String[] sportsList = getResources()
    .getStringArray(R.array.sports_titles);
```

## 数组和 drawable 引用

```
<array name="sports_images">
   <item>@drawable/img_baseball</item>
   <item>@drawable/img_badminton</item>
   <item>@drawable/img_basketball</item>
   <item>@drawable/img_bowling</item>
   <item>@drawable/img_cycling</item>
   <item>@drawable/img_golf</item>
   <item>@drawable/img_running</item>
   <item>@drawable/img_soccer</item>
   <item>@drawable/img_swimming</item>
   <item>@drawable/img_tabletennis</item>
   <item>@drawable/img_tennis</item>
</array>
```

A convenient data structure to use would be a TypedArray. A TypedArray allows you to store an array of other XML resources. Using a TypedArray, you can obtain the image resources as well as the sports title and information by using indexing in the same loop.

1. In the initializeData() method, get the TypedArray of resource IDs by calling getResources().obtainTypedArray(), passing in the name of the array of Drawable resources you defined in your strings.xml file:
```
TypedArray sportsImageResources =
       getResources().obtainTypedArray(R.array.sports_images);
```

You can access an element at index i in the TypedArray by using the appropriate "get" method, depending on the type of resource in the array. In this specific case, it contains resource IDs, so you use the getResourceId() method.

2. Fix the code in the loop that creates the Sport objects, adding the appropriate Drawable resource ID as the third parameter by calling getResourceId() on the TypedArray:
```
for(int i=0;i<sportsList.length;i++){
   mSportsData.add(new Sport(sportsList[i],sportsInfo[i],
       sportsImageResources.getResourceId(i,0)));
}
```
3. Clean up the data in the typed array once you have created the Sport data ArrayList:
```
sportsImageResources.recycle();
```


## 获取指定语言目录下的字符串

```

public class LanguageUtil {
    private static String mLanguage = "";
    private static Resources mResources;

    /**
     * 获取当前字符串资源的内容
     *
     * @param id
     * @return
     */
    public static String getStringById(int id) {
        if (mResources == null) {
            mLanguage = PandaApplication.getPreferenceUtils().getString(Const.Language.SETTING);
            Context context = PandaApplication.getContext();
            if (context != null) {
                mResources = context.getResources();
                if (mResources != null) {
                    mResources = getResourcesByLocale(mResources, mLanguage);
                }
            }
        }
        if (mResources == null) {
            return "";
        }
        String string;
        if (mLanguage != null && !"".equals(mLanguage)) {
            string = mResources.getString(id, mLanguage);
        } else {
            string = mResources.getString(id, "");
        }
        return string;
    }

    public static void changeResources() {
        mLanguage = PandaApplication.getPreferenceUtils().getString(Const.Language.SETTING);
        if (mResources != null && mLanguage != null) {
            mResources = getResourcesByLocale(mResources, mLanguage);
        }
    }

    private static Resources getResourcesByLocale(Resources res, String localeName) {
        Configuration conf = new Configuration(res.getConfiguration());
        conf.locale = new Locale(localeName);
        return new Resources(res.getAssets(), res.getDisplayMetrics(), conf);
    }

    private void resetLocale(Resources res) {
        Configuration conf = new Configuration(res.getConfiguration());
//        conf.locale = mCurLocale;
        new Resources(res.getAssets(), res.getDisplayMetrics(), conf);
    }
}
```


## 特殊字符

```
'&' --> '&amp;'

'<' --> '&lt;'

'>' --> '&gt;'

<string name="magazine">Newspaper &amp; Magazines</string>
```

或者使用附加标签标识其中有特殊字符

```XML
<string name="guide_desc"><Data><![CDATA[More than <strong><font color=#234253>100,000</font></strong> users' choice]]></Data></string>

```

此时并不能直接用于布局文件，需要用 Html 类转换为 Spanned 对象。
```Kotlin
binding.desc.text = Html.fromHtml(getString(R.string.guide_desc))
```

## 字符串格式化

安卓中将字符串作为资源来支持多语言，经常有一部分需要变化的，可以用替换的方式来处理，比如“我的名字叫李四，我来自首都北京”；这里的“李四”和“首都北京”都需要替换。

```XML
<string name="alert">我的名字叫%1$s，我来自%2$s</string>
```
```Java
String sAgeFormatString sAgeFormat1= getResources().getString(R.string.alert);     
String sFinal1 = String.format(sAgeFormat1, "李四","首都北京");
```


xliff:g标签介绍：

属性值举例说明
`%n$ms`：代表输出的是字符串，n代表是第几个参数，设置m的值可以在输出之前放置空格
`%n$md`：代表输出的是整数，n代表是第几个参数，设置m的值可以在输出之前放置空格，也可以设为0m,在输出之前放置m个0
`%n$mf`：代表输出的是浮点数，n代表是第几个参数，设置m的值可以控制小数位数，如m=2.2时，输出格式为00.00

也可简单写成：

%d   （表示整数）

%f    （表示浮点数）

%s   （表示字符串）
