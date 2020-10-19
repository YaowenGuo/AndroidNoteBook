# GClient

GClient 是一个管理多个代码模块组成一个项目的工具，这些模块可以来自不同的代码仓库。它包装了基础的代码仓库管理命令，以提供对目录树中多个子工作目录的更新、状态查询、和 diff 差异命令。类比一下 repo 或 git submoudles。 相比之下 gclient 支持根据平台检出不同依赖。例如根于要开发的项目是 IOS 还是安卓检出不同的依赖库和工具链。

在用于包含项目目录的目录中，包含一个 `.gclient` 用于控制不同仓库的组合。`.gclient` 文件时 python 脚本格式，内部定义了一个如下格式名为 `solution` 的列表：

```
solutions = [
  { "name"        : "src", # 项目要检出到的目录名
    "url"         : "https://chromium.googlesource.com/chromium/src.git", # 项目检出的仓库。
    "custom_deps" : {
      # To use the trunk of a component instead of what's in DEPS:
      #"component": "https://github.com/luci/luci-go",
      # To exclude a component from your working copy:
      #"data/really_large_component": None,
    }
  },
]
```

solutions 列表的每一项都是一个 python 字典对象。

- url: 项目检出的仓库。 gclient期望检出的解决方案将包含一个名为DEPS的文件，该文件又定义了必须检出的特定部分，以创建用于构建和开发解决方案的软件的工作目录布局。

- deps_file： 一个文件名，而不是路径。存在于 name 定义的项目目录下，用于定义依赖项列表。 此标记是可选的，默认为DEPS。

- custom_deps： 一个包含可选字段的字典类型，可选字段用于覆盖 DEPS 文件中的条目。可以用于定制使用本地目录，以避免检出和更新特性组件，或将给定组件的本地工作目录副本同步到其他特定版本，分支或树的头部。 它也可以用于附加DEPS文件中不存在的新条目。

## DEPS 文件

也可以由 `deps_file` 定制的文件名。该文件定义了项目不同组件必须检出的依赖。DEPS文件是一个Python脚本，它定义了一个名为 `deps` 的字典。

```
deps = {
  "src/outside": "https://outside-server/one/repo.git@12345677890123456778901234567789012345677890",
  "src/component": "https://dont-use-github.com/its/unreliable.git@0000000000000000000000000000000000000000",
  "src/relative": "/another/repo.git@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
}
```

每一项由 `"检出目录": "git 仓库地址@提交节点"` 组成。检出目录是相对于 .gclient 文件的相对路径。该值是将从中检出该目录的URL。 如果没有地址方案（即没有http：前缀），则该值必须以斜杠开头并且相对于检出方案仓库的根的路径。节点 id 如果没有指定，则会下载该仓库的最新节点。

