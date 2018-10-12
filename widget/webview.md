# WebView 中点击看大图

WebView 中除了链接跳转，其他的点击事件是无法获取到的。但是 Android 提供了一种 Js 和 native 调用的方法，可以在 WebView 中使用 js 调用本地方法并传递参数，或者向 WebView 中传递本地数据。

## 1. 创建一个类，使用注解来标识哪些函数映射到 js 方法。

@android.webkit.JavascriptInterface 注解标识该方法会映射到 js 中，有一个同名方法，可以在 js 中调用，调用后将调用传递到本地调用。

```
class JavascriptInterface {

    @android.webkit.JavascriptInterface
    public ArrayList<String> getImageUrlList(String[] urlArray) {
        ArrayList<String> urlList = new ArrayList<>(Arrays.asList(urlArray));
        mImageUrlList = urlList;
        mHandler.sendEmptyMessage(0);
        return urlList;
    }

    @android.webkit.JavascriptInterface
    public void viewImage(String imageUrl) {
        if (imageUrl == null) return;
        Message message = new Message();
        message.obj = imageUrl;
        message.what = 1;
        mHandler.sendMessage(message);
    }
}
```

## 2. 将调用接口注册到 webView 中

```
WebView#addJavascriptInterface(new JavascriptInterface(), "webClickListener");
```

其中 `webClickListener` 是 `new JavascriptInterface()` 在 js 中映射对象的引用，可以通过该引用调用对象中定义的方法。 其中可以通过 `webClickListener` 或 `window.webClickListener` 都可以调用。

## 3. 定义 js, 调用 java 方法。
```
function(){
    var images = document.getElementsByTagName("img");
    var urlArray = [];
    for (var i = 0; i < images.length; i++) {
        urlArray[i] = images[i].getAttribute("src");
    };
    imageListener.getImageUrlList(urlArray);
}
```
编写完成后，我们将这段代码存放到assets路径，名称为js.txt。

## 4. 执行方法

WebView在页面加载完成时，会回调onPageFinished()方法，在这里实现js代码的注入。注入js代码的方法是通过调用WebView.loadUrl("javascript:xxxxxx")。

```
private String readJS() {
    try {
        InputStream inStream = getAssets().open("js.txt");
        ByteArrayOutputStream outStream = new ByteArrayOutputStream();
        byte[] bytes = new byte[1024];
        int len = 0;
        while ((len = inStream.read(bytes)) > 0) {
            outStream.write(bytes, 0, len);
        }
        return outStream.toString();
    } catch (IOException e) {
        e.printStackTrace();
    }
    return null;
}


WebView#setWebViewClient(new WebViewClient() {
    @Override public void onPageFinished (WebView webView, String s){
        mWebView.loadUrl("javascript:(" + readJS() + ")()");
    }
});


```

或者将代码直接一字符长形式写死在代码中

```
private void addImageClickListener(WebView webView) {
    webView.loadUrl("javascript:(function(){"
            + "    var images = document.getElementsByTagName(\"img\");"
            + "    for(var i=0;i < images.length; i++) {"
            + "        images[i].onclick = function() {"
            + "            imageListener.viewImage(this.src);" //通过js代码找到标签为img的代码块，设置点击的监听方法与本地的viewImage方法进行连接
            + "        };"
            + "    }"
            + "})()");

    webView.loadUrl("javascript:(function(){"
            + "    var images = document.getElementsByTagName(\"img\");"
            + "    var urlArray = [];"
            + "    for (var i = 0; i < images.length; i++) {"
            + "        urlArray[i] = images[i].getAttribute(\"src\");"
            + "    };"
            + "    imageListener.getImageUrlList(urlArray);"
            + "})()");
}

@Override
public void onPageFinished(WebView view, String url) {
    super.onPageFinished(view, url);
    addImageClickListener(view);
    loading.setVisibility(View.GONE);
}
```

**需要注意的是，要在 WebView 中执行的 js 代码是严格模式，每条语句的后面都要使用分号 “;” 结束，否则会无法正常调用**

**js 的 Array 对应的是 java 的 Array 类型， ArrayList 没有测试对应的类型。**
