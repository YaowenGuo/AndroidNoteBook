# 管理 Gradle 的代码

自定义 Gradle 的构建时，会自己写代码，这些代码同样涉及到管理问题。理想的方法是建立一个目录，专门用于存放 gradle 代码。可以新建一个 buildSrc 目录，用户存放相关代码。

Gradle标准化了buildSrc目录下源文件的布局。Java代码需要位于目录 src/main/java中，并且Groovy代码应该位于目录 src/main/groovy 下。 这些目录中找到的所有代码都会自动编译并放入常规Gradle构建脚本的类路径中。 buildSrc 目录是组织代码的好方法。 因为您要处理类，所以也可以将它们放入特定的程序包中。 您可以将它们作为 com.manning.gia 包的一部分。 

同样，groovy 也使用和 Java 一样的包结构和使用 `import` 导入类。