# Gradle



## 运行环境

所有的 Java 程序都会使用由环境变量 `JAVA_OPTS` （java options）设置的相同的 JVM 参数。如果想要给 Gradle 运行设置单独的参数，可以使用 `GRADLE_OPTS` 环境变量。例如，想要设置最小的堆空间为 1G，可以设置

```
GRADLE_OPTS="-Xmx2024m"
```
最好的添加位置是位于 `$GRADLE_HOME/bin` 目录下的 Gradle 启动脚本（gradle 命令本身是一个脚本程序，即 gradle 脚本文件，可以通过 which 查找）。



## 执行命令

gradle 命令本身是一个脚本，有它再启动 Gradle 构建程序。 gradle 的构建脚本名默人为 `build.gradle`，当执行 gradle 命令时，脚本就会在命令执行的目录查找 `build.gradle` 文件。 先写个 `Hello World` 示例：

```
// build.gradle
task helloWorld() {
    doLast {
        println 'Hello world!'
    }
}
```

然后在当前目录下即可运行.
```
$ gradle -q helloWorld
```

`-q` 意为 `quiet`，使 gradle 仅输出 task 的输出。它是可选的。


