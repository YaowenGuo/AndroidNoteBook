# Migrate

升级 project gradle

```
classpath 'com.android.tools.build:gradle:3.3.0'
classpath 'com.google.gms:google-services:4.2.0'
```

升级 glide 到最新

```
distributionUrl=https\://services.gradle.org/distributions/gradle-4.10.1-all.zip
```

设置使用最新的编码
```
android.enableR8 = true
```

升级 Android studio 到最新的 3.3 不然迁移后出现 R 文件报错找不到，但是能正常编译的情况。

AndroidStudio -> Check for update


迁移

Refactor -> Migrate to AndroidX

错误处理

将 compiler 全部换成 implementation.

guava 报错

在 app 的 gradle 中添加

```
configurations {
    all*.exclude group: 'com.google.guava', module: 'listenablefuture'
}
```
