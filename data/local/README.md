# 手机存储数据

- 文件
- 数据库
- SharedPreference

## 文件存储位置

- 内部存储
    - 仅本应用可以直接访问，其他应用无法访问（除非拥有 root 权限）。
    - 当应用被卸载时，数据被一同删除。
    - 每个应有单独一个目录
    
- 内部缓存文件 (内部存贮的一种)
    - 当内部存储空间不足时，安卓可能删除这些文件以空出空间。但是，您不应依赖系统为您清理这些文件，而应始终自行维护缓存文件，使其占用的空间保持在合理的限制范围内（例如 1 MB）

- 外部存储


## 存储位置

- 内部存贮

获取

```Kotlin
context.filesDir
// 一般位于：/data/use/0/<package name>/files
// Android Studio 的文件查看器 /data/data/<package name>/files

// 可见两者并不一致，应该是一个是系统挂载位置，一个磁盘位置。
```