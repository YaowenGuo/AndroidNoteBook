# Function

## 函数接口
函数类型由如下格式表示

```
(参数类型列表) -> 返回值类型
如
(Int, Int) -> Int
```

Kotlin 的函数跟普通的变量一样，可以作为参数。 

```
fun sum(list: List<Int>, add: (Int, Int) -> Int): Int {
    val result = 0
    for (it in list) {
        add(result, it)
    }
    return result
}
```

Kotlin 的类可以直接当做函数调用, 只需实现 `invok` 操作符 

```
class Add {
    var sum = 0
    operator fun invoke(num: Int) {
        sum += num
    }
}

fun test() {
    var add = Add()
    add(5)
}
```

更进一步的，函数类型可以作为接口进行继承。

```
class IntTransformer: (Int) -> Int {
    override operator fun invoke(x: Int): Int = TODO()
}

```
如上， IntTransformer 实现了一个 `(Int) -> Int` 型的函数，因为函数只指定了类型，所以它是一个接口型函数，必须对其实现。
```
override operator fun invoke(x: Int): Int = TODO()
```
则是在实现 `(Int) -> Int` 接口函数



