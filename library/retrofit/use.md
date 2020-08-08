## 下载文件

对于很多Retrofit使用者来说：定义一个下载文件的请求与其他请求几乎无异：

// option 1: a resource relative to your base URL
@GET("/resource/example.zip")
Call<ResponseBody> downloadFileWithFixedUrl();

// option 2: using a dynamic URL
@GET
Call<ResponseBody> downloadFile(@Url String fileUrl);

如果你要下载的文件是一个静态资源（存在于服务器上的同一个地点），Base URL指向的就是所在的服务器，这种情况下可以选择使用方案一。正如你所看到的,它看上去就像一个普通的Retrofit 2请求。值得注意的是，我们将ResponseBody作为了返回类型。Retrofit会试图解析并转换它，所以你不能使用任何其他返回类型，否则当你下载文件的时候，是毫无意义的。

第二种方案是Retrofit 2的新特性。现在你可以轻松构造一个动态地址来作为全路径请求。这对于一些特殊文件的下载是非常有用的，也就是说这个请求可能要依赖一些参数，比如用户信息或者时间戳等。你可以在运行时构造URL地址，并精确的请求文件。如果你还没有试过动态URL方式，可以翻到开头，看看这篇专题博客Retrofit 2中的动态URL。

哪一种方案对你有用呢，我们接着往下看。
如何调用请求

声明请求后，实际调用方式如下：

FileDownloadService downloadService = ServiceGenerator.create(FileDownloadService.class);

Call<ResponseBody> call = downloadService.downloadFileWithDynamicUrlSync(fileUrl);

call.enqueue(new Callback<ResponseBody>() {  
    @Override
    public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
        if (response.isSuccess()) {
            Log.d(TAG, "server contacted and has file");

            boolean writtenToDisk = writeResponseBodyToDisk(response.body());

            Log.d(TAG, "file download was a success? " + writtenToDisk);
        } else {
            Log.d(TAG, "server contact failed");
        }
    }

    @Override
    public void onFailure(Call<ResponseBody> call, Throwable t) {
        Log.e(TAG, "error");
    }
});

如果你对ServiceGenerator.create()感到困惑，可以阅读我们的第一篇博客 。一旦创建了service，我们就能像其他Retrofit调用一样做网络请求了。

还剩下一件很重要的事，隐藏在代码块中的writeResponseBodyToDisk()函数：负责将文件写进磁盘。
如何保存文件

writeResponseBodyToDisk()方法持有ResponseBody对象，通过读取它的字节，并写入磁盘。代码看起来比实际略复杂：

private boolean writeResponseBodyToDisk(ResponseBody body) {  
    try {
        // todo change the file location/name according to your needs
        File futureStudioIconFile = new File(getExternalFilesDir(null) + File.separator + "Future Studio Icon.png");

        InputStream inputStream = null;
        OutputStream outputStream = null;

        try {
            byte[] fileReader = new byte[4096];

            long fileSize = body.contentLength();
            long fileSizeDownloaded = 0;

            inputStream = body.byteStream();
            outputStream = new FileOutputStream(futureStudioIconFile);

            while (true) {
                int read = inputStream.read(fileReader);

                if (read == -1) {
                    break;
                }

                outputStream.write(fileReader, 0, read);

                fileSizeDownloaded += read;

                Log.d(TAG, "file download: " + fileSizeDownloaded + " of " + fileSize);
            }

            outputStream.flush();

            return true;
        } catch (IOException e) {
            return false;
        } finally {
            if (inputStream != null) {
                inputStream.close();
            }

            if (outputStream != null) {
                outputStream.close();
            }
        }
    } catch (IOException e) {
        return false;
    }
}

大部分都是一般Java I/O流的样板代码。你只需要关心第一行代码就行了，也就是文件最终以什么命名被保存。当你做完这些工作，就能够用Retrofit来下载文件了。

但是我们并没有完全做好准备。而且这里存在一个大问题：默认情况下，Retrofit在处理结果前会将整个Server Response读进内存，这在JSON或者XML等Response上表现还算良好，但如果是一个非常大的文件，就可能造成OutofMemory异常。

如果你的应用需要下载略大的文件，我们强烈建议阅读下一节内容。
当心大文件：请使用@Streaming！

如果下载一个非常大的文件，Retrofit会试图将整个文件读进内存。为了避免这种现象的发生，我们添加了一个特殊的注解来声明请求。

@Streaming
@GET
Call<ResponseBody> downloadFileWithDynamicUrlAsync(@Url String fileUrl);

声明@Streaming并不是意味着你需要观察一个Netflix文件。它意味着立刻传递字节码，而不需要把整个文件读进内存。值得注意的是，如果你使用了@Streaming，并且依然使用以上的代码片段来进行处理。Android将会抛出android.os.NetworkOnMainThreadException异常。

因此，最后一步就是把这些操作放进一个单独的工作线程中，例如ASyncTask：
```java
final FileDownloadService downloadService =  
                ServiceGenerator.create(FileDownloadService.class);

new AsyncTask<Void, Long, Void>() {  
   @Override
   protected Void doInBackground(Void... voids) {
       Call<ResponseBody> call = downloadService.downloadFileWithDynamicUrlSync(fileUrl);
       call.enqueue(new Callback<ResponseBody>() {
           @Override
           public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
               if (response.isSuccess()) {
                   Log.d(TAG, "server contacted and has file");

                   boolean writtenToDisk = writeResponseBodyToDisk(response.body());

                   Log.d(TAG, "file download was a success? " + writtenToDisk);
               }
               else {
                   Log.d(TAG, "server contact failed");
               }
           }
       return null;
   }
}.execute();
```
至此，如果你能够记住@Streaming的使用和以上代码片段，那么就能够使用Retrofit高效下载大文件了。




## 监听文件下载进度
虽然Retrofit没有提供文件下载进度的回调，但是Retrofit底层依赖的是OkHttp，实际上所需要的实现OkHttp对下载进度的监听，在OkHttp的官方Demo中，有一个Progress.java的文件，顾名思义。[点我查看](http://有一个progress.xn--java,-9h1h2a84miko6si1h1sx9qcwxmq00azqfuy0f1gf636ks7b/)。

okHttp3默认的ResponseBody因为不知道进度的相关信息，所以需要对其进行改造。可以使用接口监听进度信息。这里先讲改造的ProgressResponseBody。
```java
public class DownloadProgressResponseBody extends ResponseBody {
    private ResponseBody mResponseBody;
    private DownloadProgressListener mProgressListener;
    private BufferedSource mBufferedSource;

    public DownloadProgressResponseBody(ResponseBody responseBody, DownloadProgressListener progressListener) {
        mResponseBody = responseBody;
        mProgressListener = progressListener;
    }

    @Nullable
    @Override
    public MediaType contentType() {
        return mResponseBody.contentType(); // 响应体数据类型 ContectType 字段的内容
    }

    @Override
    public long contentLength() {
        return mResponseBody.contentLength(); // 响应体大小，单位字节
    }

    @Override
    public BufferedSource source() {
        if (mBufferedSource == null) {
            mBufferedSource = Okio.buffer(source(mResponseBody.source()));
        }
        return null;
    }

    private Source source(Source source) {
        return new ForwardingSource(source) {
            long bytesReaded = 0;
            @Override
            public long read(Buffer sink, long byteCount) throws IOException {
                long bytesRead = super.read(sink, byteCount);
                bytesReaded += bytesRead == -1 ? 0 : bytesRead;
                //实时发送当前已读取的字节和总字节
                if (null != mProgressListener) {
                    mProgressListener.update(bytesReaded, mResponseBody.contentLength(), bytesRead == -1);
                }
                return bytesRead;
            }
        };
    }
}
```


### 拦截器
拦截器Interceptors使用

熟悉OkHttp的童鞋对Interceptors一定不会陌生。而Retrofit 2.0 底层强制依赖okHttp，所以可以使用okHttp的拦截器Interceptors 来对所有请求进行再处理。同样来说，我们经常使用拦截器实现以下功能：

    设置通用Header
    设置通用请求参数
    拦截响应
    统一输出日志
    实现缓存

下面我们以上各自使用的场景给出相应的代码说明：
设置通用Header

在App api接口设计中，我们往往需要客户端在请求方法时，携带appid，appkey，timestamp，signature及version等header。你可能会问前边不提到的@Headers不也同样可以做到这事情么？在方法很少的情况下，或者个别请求方法需要的情况下使用@Headers来添加当然可以，但是如果要为所有请求方法都添加还是借助拦截器使用更为方便。直接看代码：
```java
public static Interceptor getRequestHeader() {
     Interceptor headerInterceptor = new Interceptor() {

         @Override
         public Response intercept(Chain chain) throws IOException {
             Request originalRequest = chain.request();
             Request.Builder builder = originalRequest.newBuilder();
             builder.header("appid", "1");
             builder.header("timestamp", System.currentTimeMillis() + "");
             builder.header("appkey", "zRc9bBpQvZYmpqkwOo");
             builder.header("signature", "dsljdljflajsnxdsd");

             Request.Builder requestBuilder =builder.method(originalRequest.method(), originalRequest.body());
             Request request = requestBuilder.build();
             return chain.proceed(request);
         }

     };

     return headerInterceptor;
 }
 ```
 你会发现在设置header的时候，我们有两种方法可选择：addHeader()和header()。切莫混淆两者之间的区别：

     使用addHeader()不会覆盖之前设置的header,若使用header()则会覆盖之前的header

统一输出请求日志

在开发调试阶段，我们希望看到每个请求的详细信息，在release时关闭这些消息。
得益于retrofit和okhttp的良好设计，可以方便的通过添加Log拦截器来实现，这里我们使用到OkHttp中的HttpLoggingInterceptor拦截器。

在retrofit 2.0中要使用日志拦截器，首先添加依赖：

  compile 'com.squareup.okhttp3:logging-interceptor:3.1.2'

然后创建日志拦截器
```java
public static HttpLoggingInterceptor getHttpLoggingInterceptor() {
        HttpLoggingInterceptor loggingInterceptor = new HttpLoggingInterceptor();
        loggingInterceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
        return loggingInterceptor;
}
```

拦截服务器响应

通常来说，我们多利用拦截器来实现对请求的拦截。但是在很多的情况下我们需要从响应中获取响应的Headers中获取指定的header，比如在有些功能中我们需要服务端会给出我们某个活动的起始时间，需要我们客户端来判断当然活动是否可以执行。这时候，我们显然不能利用客户端本地的时间（有条原则叫做永远不要相信客户端的时间），这时候就需要服务端在将服务器的时间传给我们。为了方便，通常时间服务器的时间戳放在每个响应Header当中。

那么我们该怎么拿到这个时间戳呢？拦截器可以非常容易的帮助我们解决这个问题。这里我们假设服务器在任何一个响应的Header中都添加了time，我们要做的就是通过拦截器来获取到Header，具体见代码：
```java
public static Interceptor getResponseHeader() {
        Interceptor interceptor = new Interceptor() {

            @Override
            public Response intercept(Chain chain) throws IOException {
                Response response = chain.proceed(chain.request());
                String timestamp = response.header("time");
                if (timestamp != null) {
                    //获取到响应header中的time
                }
                return response;
            }
        };
        return interceptor;
  }
```  
