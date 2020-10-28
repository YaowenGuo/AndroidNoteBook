# 构建流程

## Building Blocks

Gradle 的构建包括三个基础块：projects、tasks、properties。

- 每个构建至少包含一个 project. 根据 `build.gradle` 的配置，实例化 `org.gradle.api.Project` 对象。可有通过 `project` 变量获取属性。在 `build.gradle` 不需要使用 `project` 调用它的方法或属性，默认该脚本在其内部调用，可以直接通过方法名或属性名访问。
- 每个 project 包含一个或多个 task.
- project 和 task 暴露用于控制构建的 properties.


## Action

Action 是 task 内部的可执行模块。Task 提供了两个对应的方法用于声明 `action`： doFirst(Closure) 和 doLast(Clusure)。当 Task 执行的时候，作为闭包参数的 action 逻辑被以此执行。



## 依赖

`dependsOn` 方法用于定义 task 之间的依赖关系。声明方式有多种

1. 在定义 task 时声明。

```
task first << { println "first" }
task second << { println "second" }
task printVersion(dependsOn: second)  {
    logger.quiet "Version: $version"
}
```

也可以声明多个依赖

```
task printVersion(dependsOn: [second, first]) { 
    logger.quiet "Version: $version"
}
```
**`first` 和 `second` 的执行顺序是不确定的。**

2. 对于已有的 task，也可以补充依赖

```
printVersion.dependsOn('first')
```

重要的是要理解 Gradle 不保证依赖任务的执行顺序。 dependsOn 仅定义需要先执行的依赖任务。 Gradle的哲学是声明在给定任务之前应该执行什么，而不是应该如何执行。 如果你使用过像Ant那样必须使用强制性地定义其依赖项的构建工具，则很难理解此概念。 在Gradle中，执行顺序是由任务的输入/输出规范自动确定的，正如您将在本章稍后看到的那样。 这个建筑设计决策有很多好处。 一方面，您无需了解整个任务依赖关系链即可进行更改，从而提高了代码的可维护性并避免了潜在的损坏。 另一方面，由于不必严格按照顺序执行构建，因此已启用了并行任务执行功能，这可以显着缩短构建执行时间。


## 清理任务

`finalizedBy` 用于定义一个任务执行之后执行的任务。


## 生命周期

`task configuration` 块总是在 `task action`` 之前执行。


```
Initialization phase(creates a Project instance)
      |
      ∨
Configuration phase(task 中的任务，直接在 build.gradle 中的脚本)
      |
      ∨
Execution phase(根据依赖执行 task 的 action.)
```

**Keep in mind that any configuration code is executed with every build of your proj- ect—even if you just execute gradle tasks.**

## 输出输出

Gradle通过比较两次构建之间的任务输入和输出快照来确定任务是否最新。如果自上次执行任务以来输入和输出未发生变化，则该任务被认为是最新的。 因此，仅当输入和输出不同时，任务才会运行； 否则，将被跳过。

- 输入可以是一个目录，一个或多个文件，或任意的属性

- 任务的输出是通过目录或1 ... n个文件。