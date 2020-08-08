# okhttp是什么

Android 4.4 开始，安卓系统的 HttpURLConnection 就默认被替换为了 okhttp 实现。

OkHttp不仅具有高效的请求效率, 并且提供了很多开箱即用的网络疑难杂症解决方案.

- 支持HTTP/2, HTTP/2通过使用多路复用技术在一个单独的TCP连接上支持并发, 通过在一个连接上一次性发送多个请求来发送或接收数据
- 如果HTTP/2不可用, 连接池复用技术也可以极大减少延时
- 支持GZIP, 可以压缩下载体积
- 响应缓存可以直接避免重复请求
- 会从很多常用的连接问题中自动恢复
- 如果您的服务器配置了多个IP地址, 当第一个IP连接失败的时候, OkHttp会自动尝试下一个IP
- OkHttp还处理了代理服务器问题和SSL握手失败问题

使用 OkHttp 无需重写您程序中的网络代码。OkHttp实现了几乎和java.net.HttpURLConnection一样的API。如果你用了 Apache HttpClient，则OkHttp也提供了一个对应的okhttp-apache 模块。

还有一个好消息, 从Android 4.4起, 其HttpURLConnection的内部实现已经变为OkHttp, 您可以参考这两个网页:爆栈网和Twitter.


[TOC]

# 使用入门

#### [http](./http.md)
#### [使用okhttp](./useOkHttp.md)
#### [post请求](./post.md)
1, http
  1.1


## 使用
Gradle导入
```
compile 'com.squareup.okhttp3:okhttp:3.2.0'
compile 'com.squareup.okio:okio:1.6.0'
```
HTTP协议将请求分成８种。只有四种会经常用到。

## get请求




## 问题

OKHttp3 协议头不能添加中文。

java.lang.IllegalArgumentException: Unexpected char 0x514d at

在okhttp的源码Header.java，发现set 和add header, 都会有这个判断：

```Java
  static void checkName(String name) {
    if (name == null) throw new NullPointerException("name == null");
    if (name.isEmpty()) throw new IllegalArgumentException("name is empty");
    for (int i = 0, length = name.length(); i < length; i++) {
      char c = name.charAt(i);
      if (c <= '\u0020' || c >= '\u007f') {
        throw new IllegalArgumentException(Util.format(
            "Unexpected char %#04x at %d in header name: %s", (int) c, i, name));
      }
    }
  }


  static void checkValue(String value, String name) {
    if (value == null) throw new NullPointerException("value for name " + name + " == null");
    for (int i = 0, length = value.length(); i < length; i++) {
      char c = value.charAt(i);
      if ((c <= '\u001f' && c != '\t') || c >= '\u007f') {
        throw new IllegalArgumentException(Util.format(
            "Unexpected char %#04x at %d in %s value: %s", (int) c, i, name, value));
      }
    }
  }
```

这个是 OKHttp3 才有的。所以对于头中的参数，需要先处理一下再加入。

```
String name=java.net.URLEncoder.encode("测试", "UTF-8");
```

https://www.jianshu.com/p/c8fd4a84544e