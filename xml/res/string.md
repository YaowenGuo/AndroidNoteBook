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
