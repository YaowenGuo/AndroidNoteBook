# 网络请求流程梳理

```
OkHttp         ---------- 失败重连，重定向跟踪。
                    超时，链接失败，抛出 IOException 等异常走 `onFailure`。
                    其他的状态码，只要服务正常返回数据体，都会走 onResponse
  |
  |
(Call)
  |
  ↓ 
Retrofit     ------------ Response 主要处理请求参数，和返回数据的转换。错误处理没有任何改变。
  |
  |
 (Response)
  |
  ↓ 
RxJavaAdapter ---------- 非 200 ~ 299 的，调用 Observer 的 onError, 
  |
  |
(ResponseBody)
  |
  ↓ 
Convert       ---------- Json 解析错误
  |
  |
(Json)
  |
  ↓ 
自己处理      ------------ Body 体里使用状态码。可以自己抛出异常，走 Observer 的 onError.
```


OkHttp 

```
/**
 * HTTP Status-Code 407: Proxy AuthenticationRequired.
 */
public static final int HTTP_PROXY_AUTH = 407;

/**
 * HTTP Status-Code 401: Unauthorized.
 */
public static final int HTTP_UNAUTHORIZED = 401;

/** Numeric status code, 307: Temporary Redirect. */
const val HTTP_TEMP_REDIRECT = 307
const val HTTP_PERM_REDIRECT = 308


/**
 * HTTP Status-Code 300: Multiple Choices.
 */
public static final int HTTP_MULT_CHOICE = 300;

/**
 * HTTP Status-Code 301: Moved Permanently.
 */
public static final int HTTP_MOVED_PERM = 301;

/**
 * HTTP Status-Code 302: Temporary Redirect.
 */
public static final int HTTP_MOVED_TEMP = 302;

/**
 * HTTP Status-Code 303: See Other.
 */
public static final int HTTP_SEE_OTHER = 303;

/**
 * HTTP Status-Code 408: Request Time-Out.
 */
public static final int HTTP_CLIENT_TIMEOUT = 408;

/**
 * HTTP Status-Code 503: Service Unavailable.
 */
public static final int HTTP_UNAVAILABLE = 503;


```



