---
title: "Socket简单案例实现"
date: 2020-08-03T22:17:53+08:00
draft: false
categories: 
  - program
  - network program
tags: 
  - socket
---

## 前言

终于还是吃了自己的狗粮......

## 关于 客户端-服务端 网络模型

> 常规情况下，网络应用都会存在客户端和服务器端，比如平时外卖应用一样，我们在外卖应用上的操作，都对应着客户端应用向服务器发起请求，并收到响应的过程。服务器为客户端提供业务数据支持，客户端则为用户提供交互界面。
>
> 在网络编程中，具体到**客户端 - 服务器**模型时，我们经常会考虑是使用**TCP**还是**UDP**，其实它们二者的区别也很简单：在**TCP**中连接是谁发起的，在**UDP**中报文是谁发送的。在**TCP**中，建立连接是一个非常重要的环节。区别出客户端和服务器，本质上是因为二者编程模型是的不同的。
>
> 服务器端需要在一开始就监听在一个确定的端口上，等待客户端发送请求，一旦有客户端建立连接，服务器端则会消耗一定的计算机资源为它服务。
>
> 客户端相对简单，它向服务器的监听端口发起请求，连接建立之后，通过连接通路和服务器端进行通信。
>
> 还有一点要强调的是，无论是客户端还是服务器端，它们运行的基本单位都是进程（Process），而不是机器。一个客户端，可以同时建立多个到不同服务器的连接；而服务器更是可能在一台机器上部署运行多个服务。

<!-- more -->

## 什么是 socket

> socket是一种操作系统提供的进程间通信机制。这里并不局限于本地，可以是本地进程间的通信，也可以是远端进程间的通信。在操作系统中，通常会为应用程序提供一组应用程序接口（API），称为**套接字接口（socket API）**。应用程序可以通过套接字接口来使用**套接字（socket）**，已进行数据交换。
>
> 这里要注意一下，我们常说的**TCP**和**UDP**只是传输层协议，是一种约定。**TCP三次握手**则是基于**TCP**协议创建网络通路，该通路的具体创建与实现还是**socket**完成。**socket**是我们用来建立连接、传输数据的唯一途径。

### 如何使用 socket 建立连接

通过前面的**客户端 - 服务器**模型，我们知道至少需要一对套接字才能进行网络连接的建立，它们分别是服务端套接字和客户端套接字，这里我们先从服务端说起。

#### 服务端准备连接过程

- 创建套接字（我们这里会使用 `TCP`的实现）
- 绑定监听地址：即为绑定需要监听的 `IP地址`以及 `端口号`，这里也可以使用本机 `IP`，但是考虑到部署环境 `IP`可能会发生变化，所以这里需要进行 `IP地址`的绑定（比如进行通配地址指定，或者主机存在多张网卡时指定具体的 `IP`）。如果不显式的指定端口号，就意味着把端口的选择权交给操作系统内核来处理，操作系统内核会根据一定的算法选择一个空闲的端口，完成套接字的绑定。
- 开启套接字监听模式：bind函数只是实现套接字与地址的关联，如同登记了电话号码，如果要让别人打通带年华，还需要我们把电话设备接入电话线，让服务器真正处于可接听的状态，这个过程需要依赖 `listen`函数。这里可以这么理解，`socket`存在 `主动`和 `被动`模式，比如服务器就是处于 `被动`模式下，它需要等待客户端套接字的 `主动`连接。而 `listen`函数便是可以将套接字设置为 `被动`模式，即告诉内核：“我这个套接字是用来等待用户请求的”。
- 建立连接（`accept`阻塞）：在客户端连接请求到达时，服务端应答成功，便完成连接建立。

```java
package com.zhoujian.socket;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** 
  * 线程池工具类 
  * @author zhoujian 
  */
public class ExecutorServicePool {

    /** 
      * 初始化线程池
      */
    public static ExecutorService executorService = Executors.newFixedThreadPool(10);

}

```

```java
package com.zhoujian.socket.server;

import com.zhoujian.socket.ExecutorServicePool;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** 
  * Socket服务端示例 
  * @author zhoujian 
  */
public class SocketServer {

    /**
      * 监听端口
      */
    private static int PORT = 8088;
    private ServerSocket serverSocket;
    private static Logger logger = LoggerFactory.getLogger(SocketServer.class);
  
    public static void main(String[] args) {
        try {
            new SocketServer().startUp(PORT);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
  
    private void startUp(int port) throws IOException {
        /** 
          * 在初始化的过程中先后完成了监听地址绑定和 listen 函数调用
          */
        serverSocket = new ServerSocket(port);
        logger.info("Socket Server is online, listening at port {}", PORT);
        while (true){
            /**
              * 此处阻塞，等待客户端连接，在三次握手成功完成后，释放阻塞
              */
            Socket socket = serverSocket.accept();
            logger.info("socket port is {} connect successful", socket.getPort());
            ExecutorServicePool.executorService.execute(new AnswerThread(socket));
        }
    }
  
    /** 
      * 应答线程 
      */
    static class AnswerThread implements Runnable {
  
        private Socket socket;
  
        public AnswerThread(Socket socket){
            this.socket = socket;
        }
  
        @Override
        public void run() {
            String content = null;
            BufferedReader bufferedReader = null;
            try {
                bufferedReader = new BufferedReader(new InputStreamReader(socket.getInputStream(), "UTF-8"));
                /**
                  * 这里的判断条件就是数据发送完毕的标识
                  */
                while ((content = bufferedReader.readLine()) != null){
                    logger.info("form client: {}", content);
                    socket.getOutputStream().write(content.getBytes());
                    socket.getOutputStream().write("\n".getBytes());
                    socket.getOutputStream().flush();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

```

#### 客户端发起连接过程

- 创建套接字
- 使用 `connect`发起连接：调用 `connect`函数向服务端发起连接请求，这里传入的是服务端套接字的地址，`connect`函数可以看做是将套接字转换为 `主动`模式。这里值得注意的是，客户端在调用 `connect`函数前不是非得调用 `bind`函数，因为如果需要（TCP|UDP|本地 套接字）的话，操作系统内核会确定源IP地址，并按照一定的算法选择一个临时端口作为源端口（这里是客户端，服务端应当先完成地址绑定，因为需要一个稳定的地址进行标记，客户端大可不必，还可以减小端口冲突的可能）。在这里我们使用的是 `TCP套接字`，在调用 `connect`函数时将激发 `TCP的三次握手`，贴图如下（图片来自于 `极客时间`），**这里务必注意阻塞状态的改变情况**:

![TCP三次握手.png](/geektime-learning/socket/TCP三次握手.png)

````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````
注意：Read方法也是阻塞的，当调用Read方法是，它就会一直阻塞在那里，直到另一方告诉它数据已经发送完毕（一般情况下，都会使用长度进行控制，这里是采用`\n`来作为数据完结发送的标识）
````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````

---

```java
package com.zhoujian.socket.client;

import com.zhoujian.socket.ExecutorServicePool;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.*;
import java.net.Socket;

/** 
  * Socket客户端示例 
  * @author zhoujian 
  */
public class SocketClient {

    /** 
      * 服务端套接字IP地址 
      */
    private static String HOST = "127.0.0.1";
  
    /** 
      * 服务端套接字监听端口 
      */
    private static int PORT = 8088;
    private static Logger logger = LoggerFactory.getLogger(SocketClient.class);
  
    /** 
      * 于主线程中初始化客户端套接字，并完成与服务端套接字的连接 
      * @param args 
      * @throws IOException 
      */
    public static void main(String[] args) throws IOException {
        Socket client = new Socket(HOST, PORT);
        ExecutorServicePool.executorService.execute(new ReceiveThread(client));
        BufferedReader reader = new BufferedReader(new 
            InputStreamReader(System.in, "UTF-8"));
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(client.getOutputStream()));
            while (true){
                String msg = reader.readLine();
                writer.write(msg);
                writer.write("\n");
                writer.flush();
            }
        }
  
        /** 
          * 用于接收服务端套接字的应答 
          */
        static class ReceiveThread implements Runnable{
  
            private Socket socket;
  
            public ReceiveThread(Socket socket){
                this.socket = socket;
            }
  
            @Override
            public void run() {
                String receive = null;
                BufferedReader bufferedReader = null;
                try {
                    bufferedReader = new BufferedReader(new InputStreamReader(socket.getInputStream(), "UTF-8"));
                while ((receive = bufferedReader.readLine()) != null){
                    logger.info("from server: {}", receive);
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}

```

#### 运行截图

###### 服务端套接字启动

![服务端套接字启动.png](/geektime-learning/socket/服务端套接字启动.png)

###### 客户端A套接字启动

![客户端A套接字启动客户端.png](/geektime-learning/socket/客户端A套接字启动-客户端.png)

![客户端A套接字启动服务端.png](/geektime-learning/socket/客户端A套接字启动-服务端.png)

###### 客户端B套接字启动

![客户端B套接字启动客户端.png](/geektime-learning/socket/客户端B套接字启动-客户端.png)

![客户端B套接字启动服务端.png](/geektime-learning/socket/客户端B套接字启动-服务端.png)

###### 客户端A套接字与服务端套接字通信

![客户端A套接字与服务端套接字通信.png](/geektime-learning/socket/客户端A套接字与服务端套接字通信.png)

![客户端A套接字与服务端套接字通信服务端.png](/geektime-learning/socket/客户端A套接字与服务端套接字通信-服务端.png)

###### 客户端B套接字与服务端套接字通信

![客户端B套接字与服务端套接字通信.png](/geektime-learning/socket/客户端B套接字与服务端套接字通信.png)

![客户端B套接字与服务端套接字通信服务端.png](/geektime-learning/socket/客户端B套接字与服务端套接字通信-服务端.png)

## 拓展

待更新......

## 引用

[网络编程模型：认识客户端-服务器网络模型的基本概念](https://time.geekbang.org/column/article/112307)

[套接字和地址：像电话和电话号码一样理解它们](https://time.geekbang.org/column/article/113607)

[TCP三次握手：怎么使用套接字格式建立连接](https://time.geekbang.org/column/article/116042)

[使用套接字进行读写：开始交流吧](https://time.geekbang.org/column/article/116043)

[Java socket详解，看这一篇就够了](https://www.jianshu.com/p/cde27461c226)

## 说明

> 本节内容涉及的完整代码地址：[socket-example](https://github.com/thread-zhou/geekbang-learning-repository/tree/master/network-program/src/main/java/com/zhoujian/network/socket)

```text
本文内容大部分源自极客时间以及网络博客图文内容节选，如有冒犯，还请告知我进行处理

邮箱：thread_zhou@126.com
```