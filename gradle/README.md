# Gradle

Gradle 的构建脚本虽然是 Grovy 或者 Kotlin, 但 Gradle 的核心代码都是 Java 编写的。

## 运行环境

所有的 Java 程序都会使用由环境变量 `JAVA_OPTS` （java options）设置的相同的 JVM 参数。如果想要给 Gradle 运行设置单独的参数，可以使用 `GRADLE_OPTS` 环境变量。例如，想要设置最小的堆空间为 1G，可以设置

```
GRADLE_OPTS="-Xmx2024m"
```
最好的添加位置是位于 `$GRADLE_HOME/bin` 目录下的 Gradle 启动脚本（gradle 命令本身是一个脚本程序，即 gradle 脚本文件，可以通过 which 查找）。

## gradle wrapper

该指令会在项目目录下生成一个和具体版本绑定的脚本，这样就不会因为版本兼容性的问题引起编译错误。该指令会生 gradlew 的脚本指令。用于下载对应版本的 gradle 和运行指令。

## gradle home 

在用户目录下的 .gradle 目录。 gradle wrapper 下载的内容都会下载到这个目录下，这样如果同一台机器上已经下载了同一版本的 gradle 后，就不用再次下载了。

.gradle
   |- init.d 初始化脚本，在该目录下的脚本，任何项目的 gradle 被执行时，该目录下的脚本都会执行。适合做一些所有项目都要执行的工作。



### 初始化脚本

`<USER_HOME>/.gradle/init.d` 目录下添加 `.gradle` 结尾的文件。例如 `build-announcements.gradle` 在构建成功或者失败后，桌面显示一条通知。

要对所有构建都起作用的一个合适的钩子是 `projectsLoaded`

```groovy
gradle.projectsLoaded { Gradle gradle ->
	gradle.rootProject {
		apply plugin: 'build-announcements'
	}
}
```

**一些回调必须在一个上下文环境中才有，例如这里的 `projectsLoaded` 在项目内的脚本中不会触发。因为项目创建发生在初始化阶段。**




## 启动守护进程(daemon)。

3.0 默认使用 Daemon，执行 gradle 等指令时，默认就会启动一个 Daemon 进程，而不必单独启动。 JVM 的启动非常慢，因此 启动一个 Deamon JVM。每次 Gradle 不再启动 JVM，而是将指令发给 Deamon，以此来加快运行速度。

有兼容性问题，例如 gradle 版本不一致，运行内存更大。如果不兼容，会再次启动一个 Daemon 进程。

默认 Daemon 运行三个小时就会自动关闭。

可以使用 --no-deamon 来禁用 daemon 进程。

gradlew stop


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


