# Service

Service 是安卓上用于执行长时间任务的组件。他没有UI，通常用于在后台执行长时间的任务，如文件下载，上传，音乐播放等。

> Servide 和 Thread 的区别

首先我们要弄明白Service和Thread分别是怎么定义的：

- Thread 是程序执行的最小单元，它是分配CPU的基本单位。可以用 Thread 来执行一些异步的操作。
- Service是Android的四大组件之一，被用来执行长时间的后台任务。默认情况下Service是运行在主线程中的。

二者的使用上的区别

1. 在Android中，Thread只是一个用来执行耗时任务的并发工具类，它可以在Activity中被创建，也可以在Service中被创建。

2. Service组件主要有两个作用：后台运行和跨进程访问。service可以在android系统后台独立运行，线程是不可以。

3. Service类是可以供其他应用程序来调用这个Service的而Thread只是在本类中在使用，如果本类关闭那么这个thread也就下岗了而Service类则不会。

4. 如果需要执行复杂耗时的操作，必须在Service中再创建一个Thread来执行任务。Service的优先级高于后台挂起的Activity，当然也高于Activity所创建的Thread，因此，系统可能在内存不足的时候优先杀死后台的Activity或者Thread，而不会轻易杀死Service组件，即使被迫杀死Service，也会在资源可用时重启被杀死的Service。
