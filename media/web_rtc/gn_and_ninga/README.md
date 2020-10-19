# GN & ninga

一篇很好的讲解 gn 作用的文章 https://www.icode9.com/content-4-134465.html

## 构建系统

软件开发中我们将程序由代码编译、链接、打包成包或者可执行程序，当代码比较少时，例如只是写一写算法程序，我们可以直接编译。如
```
gcc helloworld.c
```
但是当程序变得复杂时，例如编写一个软件，各个源文件之间的依赖关系变得不是那么好写了，同时庞大的文件数量我们并不想每次构建程序都手写一次，我们总是希望将复杂的关系写成文件或者脚本，然后可以随时就能很见到的执行编译。这样，构建系统出现了，例如 Make 构建工具。需要注意的是，构建系统并不是取代gcc这样的工具链，而是定义编译规则，最终还是会调用工具链编译代码。

然而，当软件规模进一步扩大，特别是有多平台支持需求的时候，编写  Makefile 将是一件繁琐和乏味的事情，而且极容易出错。这时就出现了生成Makefile的工具，比如cmake、AutoMake等等，这种构建系统称作元构建系统（meta build system）。构建和编译软件的步骤是：

./configure
make
make install

第一步 `./configure` 就是调用 AutoTool 工具，根据系统环境（Linux的版本众多，软件安装情况也不一样），生成GNU Makefile。


```
[构建规则] -- 元构建系统（CMake/AutoTool） --> [构建文件(编译指令和依赖关系)] --构建系统 (Make)--> 程序 --打包，封装等---> 软件
```

### Chromium中的构建系统

元构建系统有很多，几年前的chromium开源项目采用的是GYP(Generate Your Projects）构建系统，而不是常见的 CMake。软件工程师根据GYP规则编写构建工程文件（通常以gyp, gypi为后缀），GYP工具根据gyp文件生成GNU Makefile。然而对于 chromium 这样的大型项目来说，make 的构建过程太慢了，于是 chromium 项目又整出了Ninja构建系统，用于取代GNU make，据谷歌官方的说法是速度有了好几倍的提升。

同时也推出了一个新的元构建系统 gn，用于生成构建文件。因为元构建系统就是用来生成构建文件的，除非深入研究，我们不用再深入了解 Makefile 和 gpy 怎么写了，因为只是一种中间输出。我们只需要会用 ninga 的构建指令即可。

GN文件相当于gyp文件的下一代，和GYP差别不大，但是总体上比原来的GYP文件更清晰。

## GN 构建系统

GN是一种元构建系统，来代替 GYP 生成 Ninja 构建文件（Ninja build files），相较GYP而言，具有如下优点：

- 可读性更好，更容易编写和维护。
- 速度更快，谷歌官方给的数据是20倍的速度提升。
- 修改GN文件后，执行ninja构建时会自动更新 Ninja 构建文件。
- 更简单的模块依赖，提供了public_deps, data_deps等，在GYP中，只有一种目标依赖，导致依赖关系错综复杂，容易引入不必要的模块依赖。
- 提供了更好的工具查询模块依赖图谱。这在GYP构建系统中是一个噩梦，要查一个目标依赖哪些模块或者一个模块被哪些目标依赖几乎是不可能的。
- 更好的调试支持。在GN中，只需要一条print语句就可以解决。

缺点:
为 chromium 项目编写的专用构建系统，并不容易在其他项目使用。很好的是高版本的 CMake 已经可以生成 Ninga 构建文件了。

**gn 和 gclient 是为 chromium 专门构建的脚本工具，想要使用可以使用 CMake 代替**

### 运行GN

gn 实际上是depot_tools下的一个脚本，所以要先[配置好 depot_tools 的 环境](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)。


### 生成构建文件

在GYP中，有两个特定的目录Debug和Release目录，分别用于生成Debug版本和Release版本。在GN中，采用了更灵活的方式，你随便指定一个目录，比如为了测试，定义一个test输出目录，可以采用如下的命令：

```
gn gen out/test
```

那如何区分 Debug版本和Release版本呢？GN通过传递参数来解决。也就是说，现在光通过输出目录是无法确定到底是Debug版本和Release版本，而要取决于传递的构建参数。

gn args out/test

可以使用下面的命令列出可用的构建参数和它们的缺省值：

gn args --list out/test



### 项目结构

```
root_dir
|- .gclient 配置编译目标平台、项目远程地址（gn 工具天生是协作式的）。
|- .gclient_entries 各个子项目地址，gn 能够配置多个模块成为单独的项目，不同模块组合不同的项目。
|- src 源码
|   |- .gn 项目根编译配置
|   |- 
|
```

gn 项目现在会检查 GClient 目录必须是一个 GClient 的 solution。紧