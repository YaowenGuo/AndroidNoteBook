# Model

![MVVM 结构](images/mvvm.png)

- Entity: 一个用于映射数据库表的类，属性对应着数据库表的列。
- SQLite: 安卓系统自带的数据库
- DAO(Data access object): 用于定义各种数据库操作的类。
- Room database: SQLite数据库之上的数据库层，包含数据库访问的常用辅助类，例如SQLiteOpenHelper。提供更轻松的本地数据存储。Room数据库使用DAO向SQLite数据库发出查询。
- Repository：您为管理多个数据源而创建的类，例如协调网络和本地存储逻辑，缓存机制。

- 您的Room类必须是抽象的并扩展RoomDatabase。通常，您只需要整个应用程序的Room数据库的一个实例。
