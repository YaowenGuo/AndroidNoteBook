# Coroutine 

要理解协程，就要先理解协同式，和协同式相对的就是抢占式。

抢占式： 是指多个并发程序的执行调度程序，进程正在执行过程中，系统立即中止正在执行中的程序，并保存执行的状态（用户恢复时使用），将处理器立刻分配给新的进程。进程和线程都是抢占式运行的。

协同式：协程的思想本质上就是控制流在运行到需要得地方时，由程序本身主动让出（yield）和恢复（resume），而不是被系统机制强制的抢占。


 “协程”（Coroutine）概念最早由 Melvin Conway 于 1958 年提出，最早的应用是在汇编语言中构建协同式程序，从概念上甚至是比线程的提出还要早。这就需要从计算机发展过程和实现机制上来解释，抢占式调度依赖于硬件的支持，因为调度器需要“剥夺”进程的执行权，就意味着调度器需要运行在比普通进程高的权限上，否则任何“流氓（rogue）”进程都可以去剥夺其他进程了。只有 CPU 支持了执行权限后，抢占式调度才成为可能。x86 系统从 80386 处理器开始引入 Ring 机制支持执行权限，这也是为何 Windows 95 和 Linux 其实只能运行在 80386 之后的 x86 处理器上的原因。在此之前，由于理念没有提出和硬件没有得到支持，任何的调度，多任务调度都是协同式的。

 在 Melvin Conway 的博士论文中给出了协程的定义

 > 数据在后续调用中始终保持（ The values of data local to a coroutine persist between successive calls 协程的局部）

> 当控制流程离开时，协程的执行被挂起，此后控制流程再次进入这个协程时，这个协程只应从上次离开挂起的地方继续 （The execution of a coroutine is suspended as control leaves it, only to carry on where it left off when control re-enters the coroutine at some later stage）。

其实定义只是给出了一个粗略的出让，恢复的定义。由于现在的主流操作系统，都是抢占式的，虽然这个概念很早的提出，然而系统的安全性和功能需要，却让协同式失去了大部分系统级的应用，但是由于协同式轻量级、协同代码可读性好等优点，让它在应用级编程找到了用武之地，让这个理念换发了新的生机。


## 优点

最大和最优吸引力的好处就是它用同步的方式替换原来线程“异步+回调方式”写出来的复杂代码。这样我们编写的代码更加简洁和复合人们的阅读习惯。这样我们就可以按串行的思维模型去组织原本分散在不同上下文中的代码逻辑，而不需要去处理复杂的状态同步问题。

用户态，切换花费的资源更少


由于协程只是一个概念定义，具体到不同的语言上有不同的实现方式。

为了更好的理解协程的协作式，由于 Kotlin 没有实现单线程的协程，先看一个 Python 的迭代器示例。

```Python
def consumer():
    r = ''
    print('[CONSUMER] 1')
    while True:
        print('[CONSUMER] 2')
        n = yield r
        print('[CONSUMER] 3')
        if not n:
            print('[CONSUMER] 4')
            return
        print('[CONSUMER] Consuming %s...' % n)
        r = '200 OK'

def produce(c):
    c.send(None)
    n = 0
    while n < 5:
        n = n + 1
        print('[PRODUCER] Producing %s...' % n)
        r = c.send(n)
        print('[PRODUCER] Consumer return: %s' % r)
    c.close()

c = consumer()
produce(c)
```

这是一个生产者消费者模型。

1. 首先调用c.send(None)启动生成器；
2. 然后，一旦生产了东西，通过c.send(n)切换到consumer执行；
3. consumer通过yield拿到消息，处理，又通过yield把结果传回；
4. produce拿到consumer处理的结果，继续生产下一条消息；
5. produce决定不生产了，通过c.close()关闭consumer，整个过程结束。

整个流程无锁，由一个线程执行， yield 在获取不到值时，主动停止程序的执行（挂起）而执行其函数外的程序，而 produce 在生成数据之后，使用 `c.send` 主动恢复 consumer 的执行。produce和consumer协作完成任务，所以称为“协程”，而非线程的抢占式多任务。

这种协作式的执行，还是阻塞式的，即一方执行的时候，只要不主动退出自己的执行，就一直占用着 CPU 的执行。

## Kotlin 的协程使用

在 Kotlin 中，需要如下的方式来实现。

```Kotlin
val job = CoroutineScope(Dispatchers.Unconfined)
val channel = Channel<Int>()
println("Thread in main: ${Thread.currentThread()}")
job.launch {
    println("Thread in cor1: ${Thread.currentThread()}")
    while(!channel.isClosedForSend) {
        val value = channel.receive()
        println("receive: $value")
    }
}


job.launch {
    println("Thread in cor2: ${Thread.currentThread()}")
    for (x in 0..2) {
        println("send $x")
        channel.send(x)
    }
    channel.close()
}
```
运行的结果是
```
Thread in main: Thread[main,5,main]
Thread in cor1: Thread[main,5,main]
Thread in cor2: Thread[main,5,main]
send 0
send 1
receive: 0
receive: 1
send 2
receive: 2

Process finished with exit code 0
```
从上面的协程大致能看出如下结果：
1. Kotlin 协程块是非阻塞的，有点像多线程的运行方式。同一开码块的代码还是顺序运行的。 （打印的 send 和 receive 输出顺序）
2. Kotlin 的协程可以运行在同一线程中 （打印结果的线程名）
3. 想要以协作式方式运行的代码必须运行在协程作用域内部 （launch 函数参数）
4. 一个协程可以创建多个代码块（使用 launch 函数创建）。

上面的代码一下看不懂不要紧，只是展示了一下 Kotlin 协程的运行方式，接下来一点一点逐步讲解如何使用协程。要使用协程，第一步就是要创建协程。

### 创建协程

Kotlin 虽然号称原生支持协程，使用起来却像是调用函数。我想这是因为是以库的形式支持，而不是核心支持，这就无法通过关键字来定义协程。 因此要使用协程，先要导入依赖包，对于安卓：

```
// 协程扩展库核心
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.1.1'
// 协程平台相关库
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.1.1'
```
- 核心库中包含的代码主要是协程的公共 API 部分。有了这一层公共代码，才使得协程在各个平台上的接口得到统一。
- 平台库中包含的代码主要是协程框架在具体平台的具体实现方式。因为多线程在各个平台的实现方式是有所差异的

创建一个协程，Kotlin 提供了三种方式创建协程

```
// 方法一，全局生命周期
val job = GlobalScope.launch {
    // 在后台启动一个新的协程并继续
    println("World!") // 在延迟后打印输出
}

// 方法二，静态函数
runBlocking {
    println("World!") // 在延迟后打印输出
}

// 方法三
//                               ⬇ 指定一个协程环境。
val job1 = CoroutineScope(Dispatchers.Unconfined)
    .launch {
        println("World!") // 在延迟后打印输出
    }

// 方法四 在协程内部调用 launch，创建子协程
launch { // 在 runBlocking 作用域中启动一个新协程
    println("World!")
}

```

方法一： GlobalScope 创建的协程，按照官方文档说法，“协程的生命周期只受整个应用程序的生命周期限制”。如非特殊需要，一般不适用。可以通过 `isActice` 验证，一旦创建，除非人为终止掉，否则一直 `true`。

方法二： 这种方式会阻塞所在的线程，具体后面说明。一般不能在 UI 线程中使用。

方法三： 为协程指定一个上下文环境，是应用程序中使用最普遍的方式。

方法四： 这种方法只能在协程作用域内，即一个协程的内部创建新协程。

既然我们还不知道协程上下文是什么，就先用前两种方式作为示例。

#### 协程的阻塞是什么意思？

协程的可以执行多个代码块，这些代码其实就是一个函数的一个参数。

```
fun main() {
    runBlocking {
        // 添加延迟函数
        delay(1000)
        println("Thread in cor1: ${Thread.currentThread()}")
    }

    runBlocking {
        println("Thread in cor2: ${Thread.currentThread()}")
    }
    println("Thread in main: ${Thread.currentThread()}")
}
```

```
Thread in cor1: Thread[main,5,main]
Thread in cor2: Thread[main,5,main]
Thread in main: Thread[main,5,main]
```
可以看到，即便是第一个代码被延迟了。它仍旧在后面的代码之前输出，因为它阻塞了整个线程的执行。

作为对比

```
fun main() {
    GlobalScope.launch {
        delay(1000)
        println("Thread in cor1: ${Thread.currentThread()}")
    }

    GlobalScope.launch {
        println("Thread in cor2: ${Thread.currentThread()}")
    }
    println("Thread in main: ${Thread.currentThread()}")
    Thread.sleep(2000L) // 阻塞主线程 2 秒钟来保证 JVM 存活
}
```

如果不添加 `sleep` 函数，将会输出

```
Thread in main: Thread[main,5,main]
```

这很奇怪，其实是主线程先实行完毕后结束了，导致子线程也跟着结束引起的。


为了能够让主线程等待协程的执行完毕，在主线程中添加了 `sleep` 函数，等待协程的执行完毕（至于为什么子协程为什么会有一个单独的线程，稍后解释。）。可以看到，这种方式启动的协程，不仅不会阻塞主线程，而且多个协程代码也是非阻塞的。

```
Thread in main: Thread[main,5,main]
Thread in cor2: Thread[DefaultDispatcher-worker-2,5,main]
Thread in cor1: Thread[DefaultDispatcher-worker-1,5,main]
```

为了能够实现阻塞主线程以等待协程完成，又能够并行执行协程的方式。可以使用嵌套协程的方式。

```
fun main() = runBlocking{
    val job = GlobalScope.launch {
        delay(1000)
        println("Thread in cor1: ${Thread.currentThread()}")
    }
    println("Thread in main: ${Thread.currentThread()}")
    delay(2000)
}
```

当然，有时候，子协程的完成时间并不能确定，使用延时来等待并不是一个好的选择。可以使用 `join` 来显示等待子线程执行完毕

```
fun main() = runBlocking{
    val job = GlobalScope.launch {
        delay(1000)
        println("Thread in cor1: ${Thread.currentThread()}")
    }
    println("Thread in main: ${Thread.currentThread()}")
    job.join()
}
```

这个示例有几个问题

- 前面已经说过，GlobalScope.launch 创建的协程生命周期和应用一样长，除非手动终止。这样的话，一旦对其的引用丢失，就再也难以终止，这就会造成内存泄漏的问题。
- 虽然协程更轻量，但是多次创建协程还是有一定的消耗
- 必须手动保持引用，并且调用 join 来等待协程很容易被忘记。

事实上，我们可以在携程中创建子协程，这被称为 `机构化并发`。

```
fun main() = runBlocking{
    launch { // 在 runBlocking 作用域中启动一个新协程
        delay(1000L)
        println("World!")
    }
    println("Hello,")
}
```



#### 作用域

除了 join 和 launch 创建子协程可以达到外部协程等待子协程完成的目的，还可以定义作用域，它会创建一个协程作用域并且在所有已启动子协程执行完毕之前不会结束。runBlocking 与 coroutineScope 的主要区别在于后者在等待所有子协程执行完毕时不会阻塞当前线程。

```Kotlin
fun main() = runBlocking{
    coroutineScope { // 在 runBlocking 作用域中启动一个新协程
        launch {
            delay(1000L)
            println("World!")
        }
        delay(100L)
        println("Task from coroutine scope") // 这一行会在内嵌 launch 之前输出
    }
    println("Hello,")
}

```

```
Task from coroutine scope
World!
Hello,
```

由于 `coroutineScope` 并不是协程，所以 `println("Hello,")` 会等到其结束后才执行。而 `launch` 新协程并不会阻塞外部协程，所以会在 `Task from coroutine scope` 之后输出。

## 协程的调试

开始新的内容之前，先说一下 Kotlin 的协程的调试。协程可以在一个线程上挂起并在其它线程上恢复。 甚至一个单线程的调度器也是难以弄清楚哪个协程在执行，执行到什么位置。对于多线程通常的方法是使用 log输出线程名，协程也可以使用类似的方式。 对于普通的 Kotlin 程序，在 JVM 参运行参数中添加 `-Dkotlinx.coroutines.debug` 或 `-ea`。 kotlin 的调试信息会在线程名中添加协程名信息。 定义如下函数用户调试

```
fun log(msg: String) = println("[${Thread.currentThread().name}] $msg")
```

对于
```
val a = launch {
    log("I'm computing a piece of the answer")
}
```
就会输出
```
[main @coroutine#2] I'm computing a piece of the answer
```
`[main @coroutine#2]` 分别是 `[线程名 @协程名#协程ID]`


对于安卓程序的调试， 要了解哪个协同程序执行当前工作，可以通过System.setProperty打开调试工具并通过Thread.currentThread().name来记录线程名称。

```
//调式模式
System.setProperty("kotlinx.coroutines.debug", if(BuildConfig.DEBUG) "on" else "off")

launch(UI) {
    log("Data loading started")
    
    val task1 = async { log("Hello") }
    val task2 = async { log("World") }
    
    val result = task1.await() + task2.await()
    
    log("Data loading completed: $result")
}

fun log(msg: String){
    Log.d(TAG， "[${Thread.currentThread().name}] $msg")
}
```


通过生产者消费者的例子，可以发现，对于速度比较快，或者不用响应用户操作等立即响应的操作还行，比线程有着更高的效率。而对于用户操作和网络请求这种切换随机性比较高的场景，显然需要有其他的解决方案。我们说协程的中心思想是协作式的操作接口，对此 kotlin 给出的解决方案是，将耗时任务扔到单独线程中，同时保持协同式的接口。之所以必须引入线程的另一个原因是，协程必须运行在一个线程中，虽然协程之间可以达到非阻塞，然而主程序可能并不是一个协程，为了能够做到协程不阻塞主程序，必须引入运行后台程序的线程。

## 协程上下文与调度器

要说协程的运行线程，就不得不提协程运行的上下文，即便协程比线程轻量级，它的挂起和回复都需要一定的环境。协程总是运行在一些以 CoroutineContext 类型为代表的上下文中，协程上下文是各种不同元素的集合。其中包括协程调度器，协程总是运行在线程中，调度器确定了协程在哪些线程中执行。协程调度器可以将协程限制在一个特定的线程执行，或将它分派到一个线程池，亦或是让它不受限地运行。


所有的协程构建器诸如 launch 和 async 接收一个可选的 CoroutineContext 参数，它可以被用来显式的为一个新协程或其它上下文元素指定一个调度器。可用的调度器有

```Kotlin
Dispatchers.Unconfined  // 不受限制的调度器，其实就是运行在协程创建所在的线程。 是 runBlocking 的默认调度器
Dispatchers.Main // 平台相关，只有在安卓程序中才能使用，是安卓的 UI 线程
Dispatchers.IO // 线程池
Dispatchers.Default // 线程池, 也是 GlobalScope.launch 的默认调度器。
// 或者使用 newSingleThreadContext 建一个单独的线程
newSingleThreadContext("线程名")
```

newSingleThreadContext 为协程的运行启动了一个线程。 一个专用的线程是一种非常昂贵的资源。 在真实的应用程序中两者都必须被释放，当不再需要的时候，使用 close 函数，或存储在一个顶层变量中使它在整个应用程序中被重用。

### 协程的并发

使用 CoroutineScope 创建线程是开发中使用最多，它的生命周期在代码块运行结束后自动结束。

```
fun main() {
    log("")
    val job = CoroutineScope(Dispatchers.Unconfined).launch {
        log("$isActive")
    }
    log("${job.isActive}")
}
```

```
[main] 
[main @coroutine#1] true
[main] false
```
CoroutineScope 只是指定了一个运行环境，它可以创建多个协程

```
fun main() {
    log("")
    val context = CoroutineScope(Dispatchers.Unconfined)
    val job1 = context.launch {
        for (i in 0..5) {
            log("$i")
        }

    }

    val job2 = context.launch {
        for (i in 0..5) {
            log("$i")
        }
    }
}
```

由于指定了 `Dispatchers.Unconfined`，虽然创建了多个协程，他们确实运行在同一线程中运行的，仍旧是顺序运行的。

- launch 函数也是可以指定调度器的，如果不指定，它从启动了它的 CoroutineScope 中承袭了上下文（以及调度器）。这里，它从 CoroutineScope 承袭了上下文。

- 当协程在 GlobalScope 中启动的时候使用， 它使用默认的 Dispatchers.Default 调度器，使用线程池运行任务。


Dispatchers.Unconfined 指定的调度器有个很特殊， delay 之后，执行的线程名字变化了。

```
fun main()  {
    CoroutineScope(Dispatchers.Unconfined).launch { // 非受限的——将和主线程一起工作
        log("Unconfined")
        delay(500)
        log("Unconfined")
    }
    Thread.sleep(2000)
}
```

```
[main @coroutine#1] Unconfined
[kotlinx.coroutines.DefaultExecutor @coroutine#1] Unconfined
```
可以看到 delay 挂起前后，线程不一样。Dispatchers.Unconfined 协程调度器在调用它的线程启动了一个协程，但它仅仅只是运行到第一个挂起点。挂起后，它恢复线程中的协程，而这完全由被调用的挂起函数来决定。

非受限的调度器非常适用于执行不消耗 CPU 时间的任务，以及不更新局限于特定线程的任何共享数据（如UI）的协程。因为它是阻塞的当前线程的。非受限的调度器是一种高级机制，可以在某些极端情况下提供帮助而不需要调度协程以便稍后执行或产生不希望的副作用， 因为某些操作必须立即在协程中执行。 非受限调度器不应该在通常的代码中使用。


delay 不会阻塞前程，如果使用 delay 挂起协程，所在线程会提前结束，所以这里使用 `Thread.sleep(2000)` 等待线程执行结束。

### 切换线程

协程可以运行在多个线程中，而切换线程非常简单，由于协程的上下文中的调度器是指定运行线程的，只需要使用 `withContext` 改变调度器就可以切换线程。 

```
fun main()  {
    CoroutineScope(Dispatchers.Unconfined).launch { // 非受限的——将和主线程一起工作
        log("Unconfined")
        withContext(Dispatchers.IO) {
            log("IO")
        }
        withContext(Dispatchers.Default) {
            log("Unconfined")
        }
    }
    Thread.sleep(1000)
}
```

### 上下文中的作业

协程的 Job 是上下文的一部分，并且可以使用 coroutineContext [Job] 表达式在上下文中检索它：

```
println("My job is ${coroutineContext[Job]}")
```

协程上下文是各种不同元素的集合。其中主元素是协程中的 Job。

### 子协程

当在一个协程内部使用 launch 或 sync 启动协程的时候， 它将通过 CoroutineScope.coroutineContext 来承袭外部协程上下文，并且这个新协程的 Job 将会成为父协程作业的子作业。一个父协程总是等待所有的子协程执行结束。

然而，当使用 GlobalScope 来启动一个协程时，则新协程的作业没有父作业。 因此它与这个启动的作用域无关且独立运作。

### 命名协程

当一个协程与特定请求的处理相关联时或做一些特定的后台任务，最好将其明确命名以用于调试目的。 CoroutineName 上下文元素与线程名具有相同的目的。当调试模式开启时，它被包含在正在执行此协程的线程名中。

```
fun main() = runBlocking(CoroutineName("main")) {
    log("Started main coroutine")
    // 运行两个后台值计算
    val v1 = launch(CoroutineName("v1coroutine")) {
        delay(500)
        log("Computing v1")
        252
    }
    val v2 = launch(CoroutineName("v2coroutine")) {
        delay(1000)
        log("Computing v2")
        6
    }
    log("The answer for v1 / v2 = ${v1.await() / v2.await()}")    
}
```

## 挂起


通过之前的概念，所谓挂起，就是不再执行后面的代码了，保存当前的状态和执行位置，然后去执行其他的代码。那这就产生以下疑问

> 挂起的是什么？ 总不能把整个程序都挂起，这样整个程序都不执行了。挂起是如何确定要挂起的代码范围的？

和线程切换的单位是线程内部的代码块一样，协程挂起的协程本身，协程内部的代码块被挂起。 和线程不一样的是，协程的挂起是主动的，所以挂起点是可以预知的。也就是从那个地方挂起，其实取决于我们自己写的代码。例如 delay 函数其实是一个挂起函数。

```
launch {
    log("run ${System.currentTimeMillis()}")
    delay(1000) // 挂起点，改协程被挂起 1S 后自动回复执行
    log("run ${System.currentTimeMillis()}")
}
```

这段代码被协程包裹， 当执行到 `delay` 时，整个协程被挂起，之后的代码被暂停执行，如果这个协程所在的线程有其他可执行的协程(没有被挂起，或者线程来自线程池有其他协程从线程池获取线程)，当前线程会被用来执行其他协程。在 delay 时间到期后，协程调度程序会为我们主动恢复协程的执行，则会继续执行挂起点之后的代码。


### 挂起函数

当我们将包含挂起点的代码抽取成一个函数，以使其更加符合代码的模块化、复用和易读的思想时。这就引起一个问题，这些包含挂起点的函数只能在协程中别调用，如果使用函数的人不是开发者，更容易忽视这个问题。为此 kotlin 引入了 `suspend` 关键字，标记一个函数为挂起函数。 

- 挂起函数是带有 `suspend` 关键字的函数。
- 带有挂代码的函数，一定要被标记为挂起函数，否则语法提示器会提示错误。但是挂起函数不一定非要包含带有挂起功能的代码，这是函数根本起到挂起作用，这时反而限制了函数的使用范围，只能在协程中使用。
- `suspend` 仅起到提示作用，并不是执行到这个函数就会挂起，真正执行挂起的是有挂起功能的代码，例如 `delay()` 函数。

kotlin 中有挂起功能的函数还有很多，例如 `withContext`、`Channel.send()`、`Channel.receive()`，后面慢慢讲，即使没有提到，或者不知道，在开发中 IDE 的语法提示器也会给出错误提示，就会慢慢了解了，没有必要一下记住。

```kotlin
// 切换线程挂起
suspend fun testSuspend(channel: Channel<String>) = withContext(Dispatchers.IO){
    // load data
}

// delay 的挂起
suspend fun testDelay() {
    // ...
    delay(1000)
    // ...
}

```








## 协程的取消与延时

当一个父协程被取消的时候，所有它的子协程也会被递归的取消。

参考资料

[Kotin 的协程](https://blog.csdn.net/axi295309066/article/details/78070011)

[协程和线程的区别](http://www.iigrowing.cn/?p=6736)

[协程概述](https://blog.csdn.net/chengqiuming/article/details/80573288)
[Python 协程](https://www.liaoxuefeng.com/wiki/1016959663602400/1017968846697824)
[协程与进程、线程的比较](https://blog.csdn.net/chengqiuming/article/details/80573288)






