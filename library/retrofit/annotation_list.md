retrofit注解：

##### 请求方法注解
|  注解    |     作用   |   类似于sql操作　|
|---------|------------|----------------|
| @GET    | GET请求用于获取数据 |  查 |
| @POST   | POST请求用于新增数据 | 增(Create) |
| @PUT    | PUT请求用于替换，可以理解为完整替换  | 改(Update) |
| @DELETE | DELETE用于发送删除信号| 删 |
| @HEAD   | 发送请求头 | 获取资源的元数据 |
| @OPTIONS|  | 获取信息，关于资源的哪些属性是客户端可以改变的。 |
| @PATCH  | PATCH 请求是对 PUT 请求的补充，用于更新局部资源 | 改(Update) |
| @HTTP   | 通用注解，可以替换以上所有注解，其拥有三个属性：method，path，hasBody |

最容易混淆的是put，post，patch这三者，简单的说，post表示新增，put可以理解为完整替换，而patch则是更新资源。顺便来看看官方定义：

- POST to create a new resource when the client cannot predict the identity on the origin server (think a new order)
- PUT to override the definition of a specified resource with what is passed in from the client
- PATCH to override a portion of a specified resource in a predictable and effectively transactional way (if the entire patch cannot be performed, the server should not do any part of it)

##### 请求头注解

该类型的注解用于为请求添加请求头。
| 注解 	   | 说明  |
|---------|-------|
| @Headers |	用于添加固定请求头，可以同时添加多个。通过该注解添加的请求头不会相互覆盖，而是共同存在 |
| @Header |	作为方法的参数传入，用于添加不固定值的Header，该注解会更新已有的请求头 |


##### 请求和响应格式注解(标记注解)
该类型的注解用于标注请求和响应的格式。

| 名称 |	说明 |
|-----|-------|
| @FormUrlEncoded |	表示请求发送编码表单数据，每个键值对需要使用@Field注解 |
| @Multipart 	    |  表示请求发送multipart数据，需要配合使用@Part |
| @Streaming 	    |  表示响应用字节流的形式返回.如果没使用该注解,默认会把数据全部载入到内存中.该注解在在下载大文件的特别有用 |

##### 请求参数类注解

| 名称 	      | 说明 |
|-----------|-------|
| @Query    |  |
| @QueryMap |  |
| @Filed 	  | 多用于post请求中表单字段,Filed和FieldMap需要FormUrlEncoded结合使用 |
| @FiledMap | 和@Filed作用一致，用于不确定表单参数 |
| @Part 	  | 用于表单字段,Part和PartMap与Multipart注解结合使用,适合文件上传的情况 |
| @PartMap 	| 用于表单字段,默认接受的类型是Map |
| @Body 	  | 根据转换方式将实例对象转换为相应的字符串作为请求参数传递。多用于post请求发送非表单数据,比如想要以post方式传递json格式数据 |
***在这里我们来解释一下@Filed和@Part的区别。
两者都可以用于Post提交，但是最大的不同在于@Part标志上文的内容可以是富媒体形势，比如上传一张图片，上传一段音乐，即它多用于字节流传输。而@Filed则相对简单些，通常是字符串键值对。***

其他注解，@Path、@Url

***请求方法注解，　请求头注解，请求参数注解***

[TOC]

<font color=#DC143C size=5>几个特殊的注解</font>
### 请求方法
##### @HTTP
可以替代其他请求方法的任意一种
```java
  /**
   * method 表示请的方法，不区分大小写
   * path表示路径
   * hasBody表示是否有请求体
   */
    @HTTP(method = "get", path = "users/{user}", hasBody = false)
    Call<ResponseBody> getFirstBlog(@Path("user") String user);
```

@Url：使用全路径复写baseUrl，适用于非统一baseUrl的场景。



### 标记注解

##### @Streaming:用于下载大文件
```java
@Streaming
@GET
Call<ResponseBody> downloadFileWithDynamicUrlAsync(@Url String fileUrl);  

ResponseBody body = response.body();
long fileSize = body.contentLength();
InputStream inputStream = body.byteStream();
```

### 参数注解

##### @Url
```java
@GET
Call<ResponseBody> v3(@Url String url);
```

##### @Path
@Path：URL占位符，用于替换和动态更新,相应的参数必须使用相同的字符串被@Path进行注释
```java
@GET("group/{id}/users")
Call<List<User>> groupList(@Path("id") int groupId);
//--> http://baseurl/group/groupId/users

//等同于：
@GET
Call<List<User>> groupListUrl(@Url String url);
```
##### @Query,@QueryMap:查询参数
用于GET查询,需要注意的是@QueryMap可以约定是否需要encode
```java
@GET("group/users")
Call<List<User>> groupList(@Query("id") int groupId);
//--> http://baseurl/group/users?id=groupId

Call<List<News>> getNews((@QueryMap(encoded=true) Map<String, String> options);
```
##### @Body
用于POST请求体，将实例对象根据转换方式转换为对应的json字符串参数，
这个转化方式是GsonConverterFactory定义的。
```java
 @POST("add")
 Call<List<User>> addUser(@Body User user);

@Field，@FieldMap:Post方式传递简单的键值对,
```




Retrofit 2.0 底层依赖于okHttp，所以需要使用okHttp的Interceptors 来对所有请求进行拦截。
我们可以通过自定义Interceptor来实现很多操作,打印日志,缓存,重试等等。

要实现自己的拦截器需要有以下步骤

(1) 需要实现Interceptor接口，并复写intercept(Chain chain)方法,返回response
(2) Request 和 Response的Builder中有header,addHeader,headers方法,需要注意的是使用header有重复的将会被覆盖,而addHeader则不会。

标准的 Interceptor写法

public class OAuthInterceptor implements Interceptor {

  private final String username;
  private final String password;

  public OAuthInterceptor(String username, String password) {
    this.username = username;
    this.password = password;
  }

  @Override public Response intercept(Chain chain) throws IOException {

    String credentials = username + ":" + password;

    String basic = "Basic " + Base64.encodeToString(credentials.getBytes(), Base64.NO_WRAP);

    Request originalRequest = chain.request();
    String cacheControl = originalRequest.cacheControl().toString();

    Request.Builder requestBuilder = originalRequest.newBuilder()
        //Basic Authentication,也可用于token验证,OAuth验证
        .header("Authorization", basic)
        .header("Accept", "application/json")
        .method(originalRequest.method(), originalRequest.body());

    Request request = requestBuilder.build();

    Response originalResponse = chain.proceed(request);
    Response.Builder responseBuilder =
        //Cache control设置缓存
        originalResponse.newBuilder().header("Cache-Control", cacheControl);

    return responseBuilder.build();
  }
}



缓存策略

设置缓存就需要用到OkHttp的interceptors，缓存的设置需要靠请求和响应头。
如果想要弄清楚缓存机制，则需要了解一下HTTP语义，其中控制缓存的就是Cache-Control字段
参考：Retrofit2.0+okhttp3缓存机制以及遇到的问题
How Retrofit with OKHttp use cache data when offline
使用Retrofit和Okhttp实现网络缓存。无网读缓存，有网根据过期时间重新请求

一般情况下我们需要达到的缓存效果是这样的:

    没有网或者网络较差的时候要使用缓存(统一设置)
    有网络的时候，要保证不同的需求，实时性数据不用缓存,一般请求需要缓存(单个请求的header来实现)。

OkHttp3中有一个Cache类是用来定义缓存的，此类详细介绍了几种缓存策略,具体可看此类源码。

    noCache ：不使用缓存，全部走网络
    noStore ： 不使用缓存，也不存储缓存
    onlyIfCached ： 只使用缓存
    maxAge ：设置最大失效时间，失效则不使用
    maxStale ：设置最大失效时间，失效则不使用
    minFresh ：设置最小有效时间，失效则不使用
    FORCE_NETWORK ： 强制走网络
    FORCE_CACHE ：强制走缓存

配置目录

这个是缓存文件的存放位置,okhttp默认是没有缓存,且没有缓存目录的。

 private static final int HTTP_RESPONSE_DISK_CACHE_MAX_SIZE = 10 * 1024 * 1024;

  private Cache cache() {
         //设置缓存路径
         final File baseDir = AppUtil.getAvailableCacheDir(sContext);
         final File cacheDir = new File(baseDir, "HttpResponseCache");
         //设置缓存 10M
         return new Cache(cacheDir, HTTP_RESPONSE_DISK_CACHE_MAX_SIZE);
     }

其中获取cacahe目录,我们一般采取的策略就是应用卸载,即删除。一般就使用如下两个目录:

    data/$packageName/cache:Context.getCacheDir()
    /storage/sdcard0/Andorid/data/$packageName/cache:Context.getExternalCacheDir()

且当sd卡空间小于data可用空间时,使用data目录。

最后来一张图看懂Android内存结构,参考：Android文件存储使用参考 - liaohuqiu
```
 /**
     * |   ($rootDir)
     * +- /data                    -> Environment.getDataDirectory()
     * |   |
     * |   |   ($appDataDir)
     * |   +- data/$packageName
     * |       |
     * |       |   ($filesDir)
     * |       +- files            -> Context.getFilesDir() / Context.getFileStreamPath("")
     * |       |      |
     * |       |      +- file1     -> Context.getFileStreamPath("file1")
     * |       |
     * |       |   ($cacheDir)
     * |       +- cache            -> Context.getCacheDir()
     * |       |
     * |       +- app_$name        ->(Context.getDir(String name, int mode)
     * |
     * |   ($rootDir)
     * +- /storage/sdcard0         -> Environment.getExternalStorageDirectory()/ Environment.getExternalStoragePublicDirectory("")
     * |                 |
     * |                 +- dir1   -> Environment.getExternalStoragePublicDirectory("dir1")
     * |                 |
     * |                 |   ($appDataDir)
     * |                 +- Andorid/data/$packageName
     * |                                         |
     * |                                         | ($filesDir)
     * |                                         +- files                  -> Context.getExternalFilesDir("")
     * |                                         |    |
     * |                                         |    +- file1             -> Context.getExternalFilesDir("file1")
     * |                                         |    +- Music             -> Context.getExternalFilesDir(Environment.Music);
     * |                                         |    +- Picture           -> Context.getExternalFilesDir(Environment.Picture);
     * |                                         |    +- ...               -> Context.getExternalFilesDir(String type)
     * |                                         |
     * |                                         |  ($cacheDir)
     * |                                         +- cache                  -> Context.getExternalCacheDir()
     * |                                         |
     * |                                         +- ???
     * <p/>
     * <p/>
     * 1.  其中$appDataDir中的数据，在app卸载之后，会被系统删除。
     * <p/>
     * 2.  $appDataDir下的$cacheDir：
     * Context.getCacheDir()：机身内存不足时，文件会被删除
     * Context.getExternalCacheDir()：空间不足时，文件不会实时被删除，可能返回空对象,Context.getExternalFilesDir("")亦同
     * <p/>
     * 3. 内部存储中的$appDataDir是安全的，只有本应用可访问
     * 外部存储中的$appDataDir其他应用也可访问，但是$filesDir中的媒体文件，不会被当做媒体扫描出来，加到媒体库中。
     * <p/>
     * 4. 在内部存储中：通过  Context.getDir(String name, int mode) 可获取和  $filesDir  /  $cacheDir 同级的目录
     * 命名规则：app_ + name，通过Mode控制目录是私有还是共享
     * <p/>
     * <code>
     * Context.getDir("dir1", MODE_PRIVATE):
     * Context.getDir: /data/data/$packageName/app_dir1
     * </code>
     */
```
缓存第一种类型

配置单个请求的@Headers，设置此请求的缓存策略,不影响其他请求的缓存策略,不设置则没有缓存。

// 设置 单个请求的 缓存时间
@Headers("Cache-Control: max-age=640000")
@GET("widget/list")
Call<List<Widget>> widgetList();

缓存第二种类型

有网和没网都先读缓存，统一缓存策略，降低服务器压力。
```
private Interceptor cacheInterceptor() {
      Interceptor cacheInterceptor = new Interceptor() {
            @Override
            public Response intercept(Chain chain) throws IOException {
                Request request = chain.request();
                Response response = chain.proceed(request);

                String cacheControl = request.cacheControl().toString();
                if (TextUtils.isEmpty(cacheControl)) {
                    cacheControl = "public, max-age=60";
                }
                return response.newBuilder()
                        .header("Cache-Control", cacheControl)
                        .removeHeader("Pragma")
                        .build();
            }
        };
      }
```
此中方式的缓存Interceptor实现：ForceCachedInterceptor.java
缓存第三种类型

结合前两种，离线读取本地缓存，在线获取最新数据(读取单个请求的请求头，亦可统一设置)。
```
private Interceptor cacheInterceptor() {
        return new Interceptor() {
            @Override
            public Response intercept(Chain chain) throws IOException {
                Request request = chain.request();

                if (!AppUtil.isNetworkReachable(sContext)) {
                    request = request.newBuilder()
                            //强制使用缓存
                            .cacheControl(CacheControl.FORCE_CACHE)
                            .build();
                }

                Response response = chain.proceed(request);

                if (AppUtil.isNetworkReachable(sContext)) {
                    //有网的时候读接口上的@Headers里的配置，你可以在这里进行统一的设置
                    String cacheControl = request.cacheControl().toString();
                    Logger.i("has network ,cacheControl=" + cacheControl);
                    return response.newBuilder()
                            .header("Cache-Control", cacheControl)
                            .removeHeader("Pragma")
                            .build();
                } else {
                    int maxStale = 60 * 60 * 24 * 28; // tolerate 4-weeks stale
                    Logger.i("network error ,maxStale="+maxStale);
                    return response.newBuilder()
                            .header("Cache-Control", "public, only-if-cached, max-stale="+maxStale)
                            .removeHeader("Pragma")
                            .build();
                }

            }
        };
    }
```
此中方式的缓存Interceptor实现：OfflineCacheControlInterceptor.java
错误处理

在请求网络的时候,我们不止会得到HttpException,还有我们和服务器约定的errorCode和errorMessage,为了统一处理,我们可以
预处理以下上面两个字段,定义BaseModel,在ConverterFactory中进行处理,
可参照:
```
    Retrofit+RxJava实战日志(3)-网络异常处理
    retrofit-2-simple-error-handling
```
网络状态监听

一般在没有网络的时候使用缓存数据,有网络的时候及时重试获取最新数据,其中获取是否有网络，我们采用广播的形式：
```
 public class NetWorkReceiver extends BroadcastReceiver {

     @Override
     public void onReceive(Context context, Intent intent) {
         HttpNetUtil.INSTANCE.setConnected(context);
     }
 }
```
HttpNetUtil实时获取网络连接状态,关键代码
```
   /**
     * 获取是否连接
     */
    public boolean isConnected() {
        return isConnected;
    }
   /**
     * 判断网络连接是否存在
     *
     * @param context
     */
    public void setConnected(Context context) {
        ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (manager == null) {
            setConnected(false);


            if (networkreceivers != null) {
                for (int i = 0, z = networkreceivers.size(); i < z; i++) {
                    Networkreceiver listener = networkreceivers.get(i);
                    if (listener != null) {
                        listener.onConnected(false);
                    }
                }
            }

        }

        NetworkInfo info = manager.getActiveNetworkInfo();

        boolean connected = info != null && info.isConnected();
        setConnected(connected);

        if (networkreceivers != null) {
            for (int i = 0, z = networkreceivers.size(); i < z; i++) {
                Networkreceiver listener = networkreceivers.get(i);
                if (listener != null) {
                    listener.onConnected(connected);
                }
            }
        }

    }
```
在需要监听网络的界面或者base(需要判断当前activity是否在栈顶)实现Networkreceiver。
Retrofit封装

全局单利的OkHttpClient：
```
okHttp() {
        HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
        interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);

        okHttpClient = new OkHttpClient.Builder()
                //打印日志
                .addInterceptor(interceptor)

                //设置Cache目录
                .cache(CacheUtil.getCache(UIUtil.getContext()))

                //设置缓存
                .addInterceptor(cacheInterceptor)
                .addNetworkInterceptor(cacheInterceptor)

                //失败重连
                .retryOnConnectionFailure(true)

                //time out
                .readTimeout(TIMEOUT_READ, TimeUnit.SECONDS)
                .connectTimeout(TIMEOUT_CONNECTION, TimeUnit.SECONDS)

                .build()

        ;
    }
```
全局单利的Retrofit.Builder,这里返回builder是为了方便我们设置baseUrl的,我们可以动态创建多个api接口,当然也可以用@Url注解
```
Retrofit2Client() {
        retrofitBuilder = new Retrofit.Builder()
                //设置OKHttpClient
                .client(okHttp.INSTANCE.getOkHttpClient())

                //Rx
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())

                //String转换器
                .addConverterFactory(StringConverterFactory.create())

                //gson转化器
                .addConverterFactory(GsonConverterFactory.create())
        ;
    }
```