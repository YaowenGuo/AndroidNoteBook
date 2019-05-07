# WebView 中点击看大图


## Android 8.0 上不显示

设置了字体后，会导致 WebView 不显示。是 AndroidManifest.xml 中添加字体，自动添加了一个配置，删除即可，不影响字体的使用。

Try to remove the preloading of fonts by removing
```
<meta-data
android:name="preloaded_fonts"
android:resource="@array/preloaded_fonts" />
```



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


# WebView 拦截 A 标签跳转地址兼容老版本

``` java
webView.setWebViewClient(new WebViewClient() {
                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(view, url);
                    addImageClickListener(view);
                    loading.setVisibility(View.GONE);
                }

                @Override
                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        String url = request.getUrl().toString();
                        if (url == null || mTopicListener == null) return true;
                        mTopicListener.onLickClick(url);
                    }
                    return true;
                }

                @Override
                public boolean shouldOverrideUrlLoading(WebView view, String url) {
                    //该方法在Build.VERSION_CODES.LOLLIPOP以前有效，从Build.VERSION_CODES.LOLLIPOP起，建议使用shouldOverrideUrlLoading(WebView, WebResourceRequest)} instead
                    //返回false，意味着请求过程里，不管有多少次的跳转请求（即新的请求地址），均交给webView自己处理，这也是此方法的默认处理
                    //返回true，说明你自己想根据url，做新的跳转，比如在判断url符合条件的情况下，我想让webView加载http://ask.csdn.net/questions/178242
                    if (url == null) return true;
                    if (url.contains("/name")){
                        Activity activity = getActivity();
                        if (activity != null) {
                            startActivity(new Intent(activity, NameActivity.class));
                        }

                    } else {
                        jumpToBrowser(url);
                    }
                    return true;
                }

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


            });
```


## Problem

> 在首次安装时 App，WebView 会回调 `override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?)` 出现 error.code 为 -1， error.description 为 `net::ERR_CACHE_MISS` 的错误。并且数据也正常获取了，第二次启动就没有问题了。需要在 WebView 创建时设置


```
if (Build.VERSION.SDK_INT >= 19) {
        mWebView.getSettings().setCacheMode(WebSettings.LOAD_CACHE_ELSE_NETWORK);
}
```

> 调试

想要调试 WebView 需要对 WebView 进行设置 `        WebView.setWebContentsDebuggingEnabled(true)
` 然后就可以进行调试了。


调试手机 Web 页面
https://developers.google.com/web/tools/chrome-devtools/remote-debugging/?utm_source=dcc&utm_medium=redirect&utm_campaign=2016q3

调试 WebView

https://github.com/riskers/blog/issues/11


> 获取 User-Agent

不要使用如下方法，因为如果已经创建了一个 WebView 时，将抛出错误。

```
String ua=new WebView(this).getSettings().getUserAgentString();
```
使用 WebSettings 的静态方法直接获取。

```
@TargetApi(17)
static class NewApiWrapper {
  static String getDefaultUserAgent(Context context) {
    return WebSettings.getDefaultUserAgent(context);
  }
}
```

> 出错时加载内部网页

```Java
view?.loadUrl("file:///android_asset/web/error_page.html")

```
