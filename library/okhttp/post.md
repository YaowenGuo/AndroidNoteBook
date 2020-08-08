[TOC]
===========================

# 3 post上传请求

## 3.1 发送内容的信息说明
使用post提交请求，由于传输内容的格式多样，http协议需要指出内容的格式，以便对不同内容做出响应的处理。okhttp使用MediaType类
来封装内容格式和编码的说明。
```java
MediaType MEDIA_TYPE_MARKDOWN = MediaType.parse("text/x-markdown; charset=utf-8");
```
有意思的是okhttp并没有对该字符串给出范围，所以所有http能够传输的内容，都能够传入。常用的几个类型有：

> 属性： 
text/html ： HTML格式
text/plain ：纯文本格式
text/xml ：  XML格式
image/gif ：gif图片格式
image/jpeg ：jpg图片格式 
image/png：png图片格式

> 以application开头的媒体格式类型：
application/xhtml+xml ：XHTML格式
application/xml       ： XML数据格式
application/atom+xml  ：Atom XML聚合格式
application/json      ： JSON数据格式
application/pdf       ：pdf格式
application/msword    ： Word文档格式
application/octet-stream ： 二进制流数据（如常见的文件下载）
application/x-www-form-urlencoded ： <form encType=””>中默认的encType，form表单数据被编码为key/value
格式发送到服务器（表单默认的提交数据的格式）

> 另外一种常见的媒体格式是上传文件之时使用的：
multipart/form-data ： 需要在表单中进行文件上传时，就需要使用该格式
注意：MediaType.parse("image/png")里的"image/png"不知道该填什么，可以参考---》http://www.w3school.com.cn/media/media_mimeref.asp


## 3.2 发送内容
发送内容，又叫请求体。get请求没有请求体，而post要发送内容，发送的内容就放在请求体中。
```java
String postBody = "" + "Releases\n" + "--------\n" + "\n" + " * _1.0_ May 6, 2013\n" + " * _1.1_ June 15, 2013\n" + " * _1.2_ August 11, 2013\n";

RequestBody requestBody = RequestBody.create(MEDIA_TYPE_MARKDOWN, postBody);
```
create函数进行了重载，能够接收String, ByteString, Byte[], File类型的数据。
## 3.3 提交字符串
下面是使用HTTP POST提交请求到服务. 这个例子提交了一个markdown文档到web服务, 以HTML方式渲染markdown. 因为整个
请求体都在内存中, 因此避免使用此api提交大文档（大于1MB）. 

```java
MediaType MEDIA_TYPE_MARKDOWN = MediaType.parse("text/x-markdown; charset=utf-8");
OkHttpClient client = new OkHttpClient();
String postBody = ""
        + "Releases\n"
        + "--------\n"
        + "\n"
        + " * _1.0_ May 6, 2013\n"
        + " * _1.1_ June 15, 2013\n"
        + " * _1.2_ August 11, 2013\n";
Request request = new Request.Builder()
        .url("https://api.github.com/markdown/raw")
        .post(RequestBody.create(MEDIA_TYPE_MARKDOWN, postBody))
        .build();
Response response = null;
try {
    response = client.newCall(request).execute();
    if (response.isSuccessful()) {
        System.out.println(response.body().string());
    }
} catch (IOException e) {
    e.printStackTrace();
}
```

## 3.4 
以流的方式POST提交请求体. 请求体的内容由流写入产生. 这个例子是流直接写入Okio的BufferedSink. 你的程序可能
会使用OutputStream, 你可以使用BufferedSink.outputStream()来获取. OkHttp的底层对流和字节的操作都是基
于Okio库, Okio库也是Square开发的另一个IO库, 填补I/O和NIO的空缺, 目的是提供简单便于使用的接口来操作IO.
```

