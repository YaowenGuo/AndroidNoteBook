# Configuration

## Dependency

在项目中，我们通常会用到三方工具库，而不是重复造轮子。使用的其他代码库，我们称为依赖。。项目中我们使用如下如下的配置来配置依赖

```groovy
dependencies {
    implementation project(':lib:util') // 引入子工程
    implementation "com.google.code.gson:gson:$gsonVersion" // 引入网络仓库的软件包

}
```

如果使用网络包的形式，网络仓库地址如何配置呢？

```groovy
allprojects {
    repositories {
        google()
        jcenter()
        maven { url 'https://developer.huawei.com/repo/' }
    }
}
```
当有新的依赖

同样的，构建脚本 Gradle 是基于 jvm 的脚本，同样会依赖于三方库，如何配置呢？

```groovy
buildscript {
    repositories {
        maven { url 'https://developer.huawei.com/repo/' }
        google()
        jcenter()
        ...
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.5.3'
        ...
    }
}
```

`buildscript` 指明了该作用域中的配置适用于构建脚本的，而不是项目中。为了简单，Gradle 的依赖配置使用和项目依赖一样的配置函数。



## 插件

当一些功能逻辑比较通用时，我们希望代码能够被抽取到公共的包内，在各个项目中都能使用。这在 Gradle 脚本中被称为插件。 Gradle 的插件必须实现自 `Pgluin` 接口。

```groovy
class MyAwesomePlugin implements Plugin<Project> {

    @Override
    void apply(Project project) {
        project.task("testPlugin", {
            println 'First gradle plugin.'
        })
    }
}
```

而一个 task，其实就是调用默认 project 实例的方法。因此，插件中需要用到 project 的任何方法、属性、配置，都需要改为如函数参数传入的 `project`， 以便在将插件应用到不同项目中时，对应于不同的 `project` 实例。

应用插件
```groovy
apply plugin: MyAwesomePlugin
```

aplly 方法能够自动生成 MyAwesomePlugin 的实例，然后将当前上下文中的 project 作为参数调用其 apply 方法。这时候，apply 方法中的代码就会执行。从未给当前脚本添加了 `task`。


### 抽取插件

有三种方式来抽取 Plugin。

1. 抽取到单独的 `.gradle` 脚本中，然后使用

```groovy
apply plugin: 'XXX.gradle'
``` 

或者也可以放到一个公共的服务器上，然后提供 Http 访问

```groovy
apply plugin: 'http://...XXX.gradle'
```


2. 抽取到 buildSrc 目录下。

buildSrc 是 gradle 默认给 groovy 脚本的目录，在该目录下可以像 Java 一样添加包、编写测试代码。方便于脚本的编写。

在项目的各个 build.gradle 运行之前，如果发现了 buildSrc，如果首先编译 buildSrc。然后自动把编译打包好的包路径添加到 `buildscript.dependencies` 的 classpath 中。这一步添加是默认的行为，不用添加任何配置。


3. 打包上传到 maven 仓库，然后使用 `buildscript` 的 `dependencies` 添加 classpath。 



### apply plugin 的过程

当 gradle 碰到一个导入插件的时候，例如 `apply plugin: "MyAwesomePlugin"`，它就会在 `buildscript` 的依赖中查找一个 `MyAwesomePlugin.properties` 的文件。
在该文件中声明了哪个类作为要实例化的 plugin 类。然后就会在对应的目录中查找该类，用于实例化对象。

apply from: 'tinker.gradle'
```