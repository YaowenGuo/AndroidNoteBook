> RESTful API 介绍

[理解RESTful架构](http://www.ruanyifeng.com/blog/2011/09/restful.html)
[RESTful API 设计指南](http://www.androidchina.net/3749.html)

但我们这里可以对 RESTful 的核心思想做一个最简练的总结，那就是：所谓”资源”，就是网络上的一个实体，或者说是网络上的一个具体信息。那么我们访问API的本质就是与网络上的某个资源进行互动而已。那么，因为我们实质是访问资源，所以 RESTful 设计思想的提出者Fielding认为：

REST(REpresentational State Transfer)是一组架构约束条件和原则。
RESTful架构都满足以下规则：
（1）每一个URI代表一种资源；
（2）客户端和服务器之间，传递这种资源的某种表现层；
（3）客户端通过四个HTTP动词，对服务器端资源进行操作，实现"表现层状态转化"。

URI 当中不应当出现 动词，因为”资源“表示一种 实体，所以应该用 名词 表示，而动词则应该放在HTTP协议当中。那么举个最简单的例子：
当中。那么举个最简单的例子：

xxx.com/api/createUser
xxx.com/api/getUser
xxx.com/api/updateUser
xxx.com/api/deleteUser

这样的API风格我们应该很熟悉，但如果要遵循 RESTful 的设计思想，那么它们就应该变为类似下面这样：

[POST]xxx.com/api/User
[GET] xxx.com/api/User
[PUT]xxx.com/api/User
[DELETE]xxx.com/api/User
也就是说：因为这四个API都是访问服务器的 USER表，所以在 RESTful 里URL是相同的，而是 通过HTTP不同的RequestMethod来区分增删改查的行为。

而有的时候，如果某个API的行为不好用请求方法描述呢？比如说，A向B转账500元。那么，可能会出现如下设计：

POST /accounts/1/transfer/500/to/2

在RESTful的理念里，如果某些动作是HTTP动词表示不了的，你就应该把动作做成一种资源。可以像下面这样使用它：

POST /transaction HTTP/1.1
Host: 127.0.0.1
from=1&to=2&amount=500.00

好了，当然实际来说RESTful肯定不是就这点内容。这里我们只是了解一下RESTful最基本和核心的设计理念。
