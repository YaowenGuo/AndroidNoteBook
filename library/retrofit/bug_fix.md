Panda---提取字幕（从长段音频和视频里）：
youtube和Facebook都已经有自动字幕功能，但国内的视频平台基本都没有该功能；
review从视频提取字幕的方案：
开源的框架：没有足够语料支撑，效果很差，直接舍弃这种方式；
讯飞云：基于JAVA平台，已经实现，收费标准：10元 / 小时；
Google API：找到一个autosub库，是联合Google的speech recognize和translate API实现的，其中translateAPI也是收费的，但Google里应该有$300的免费额度可用，也已经有Demo实现；
效果：都不错（没有背景音的视频准确率95%左右，含背景音的暂时还未测试），讯飞准确度相对更好一些，而且有更详细的词与音轨的对应关系





## javax.net.ssl.SSLHandshakeException: Connection closed by pree

二.原因分析：
CAS部署时，常常要涉及到HTTPS的证书发布问题。由于在实验环境中，CAS和应用服务常常是共用一台PC机，它们跑在相同的JRE环境和Tomcat服务器上，因此忽略了证书的实际用途，一旦将CAS和应用分别部署在不同的机器上时，就晕了！

这里假设如下实验环境来说明相应的部署  
机器A： 部署CAS服务  
机器B： 部署OA应用
机器C： 用户浏览器端

1.由机器A上生成.keystore的证书文件，证书颁发者是机器A的完全域名
2.机器A上用于部署CAS的Tomcat的server.xml文件中定义HTTPS的配置，指向.keystore文件证书
3.从.keystore中导出的凭证文件要copy到机器B上，并导入机器B的JRE环境的证书库中
4.机器B上部署OA的Tomcat必须指定运行在导入凭证JRE环境上，而不是JDK，这点常有人搞错。

三.导入证书步骤：
1.找到JRE
1）机器B的OA应用直接部署在Tomcat
>>>独立的JRE
如果你在安装JDK时，选择了同时安装JRE，那么系统是跑在独立的JRE上。
为什么？因为在安装独立JRE的时候程序自动帮你把jre的java.exe添加到了系统变量中，验证的方法很简单，大家看到了系统环境变量的 path最前面有“%SystemRoot%system32;%SystemRoot%;”这样的配置，那么再去Windows/system32下面去看看吧，发现了什么？有一个java.exe。
>>>JDK里的JRE
如果没有同时安装独立JRE，那么系统跑在JDK自带的JRE上。
2）机器B的OA应用在MyEclipse中开发测试中
MyEclipse-右键project-Java Build Path-Libraries-双击JRE-一般是Workspace default JRE;
MyEclipse-windows-Preferences-Java-Installed JREs-右边有Myeclipse默认自带的JDK，双击即可查到JRE home；
2.到机器A拷贝证书xxx.cer文件到机器B
3.导入命令
cmd进入命令行窗口；
cd进入JRE目录\lib\security；
keytool -import -alias cacerts -keystore JRE目录\lib\security\cacerts -file 证书目录\xxx.cer -trustcacerts;
提示输入密码：changeit；
确定：y
4.如果keytool用不了，查看下path，classpath是否配置正确。


down vote
accepted
Key here is to force TLS 1.2 protocol, based on this link here.

Only thing that I needed to correct here is to force TLS 1.2 protocol directly, like this:
```java
private class NoSSLv3SSLSocket extends DelegateSSLSocket {

    private NoSSLv3SSLSocket(SSLSocket delegate) {
        super(delegate);
    }

    @Override
    public void setEnabledProtocols(String[] protocols) {
        super.setEnabledProtocols(new String[]{"TLSv1.2"}); // force to use only TLSv1.2 here
    }
}
```
