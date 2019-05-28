
> org.

在Android 6.0中，删除了对Apache HTTP客户端的支持。
从Android 9开始，该库将从bootclasspath中删除，默认情况下不可用于应用程序。 一些库仍然在使用，需要添加。

```
<uses-library android:name="org.apache.http.legacy" android:required="false"/>
```