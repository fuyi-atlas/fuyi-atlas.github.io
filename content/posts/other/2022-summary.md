---
title: "2022, 迟到的年终总结"
date: 2023-02-18T17:01:45+08:00
draft: false
tags: ["summary"]
categories: ["other", "summary"]
---

## 前言

拖延症真的存在！！！

今天是2023年2月13日晚，我在此时写下本文的第二行内容。其实从年前就开始计划写一篇关于2022年的年终总结，无奈受到拖延病毒的威胁，一直拖到现在才暂时摆脱控制。

如题，本文将对2022年进行简要总结，同时对2023年做一个初步的展望（仅作记录）。

<!-- more -->

## 2022年大事记

### 第一个在外过的春节

受新冠疫情影响，2022年的春节是在杭州过的。还记得当时附近好几个地方都被划为了高风险，对整个区进行了管控。如果选择回家的话，得到将是14天的隔离，还不确定能否回来上班。因此便没有回去了。

好在所在的区域情况并没有那么的严重，还是可以去买菜的。领了消费券，再加上公司发的年货，也没有想象中的那么糟糕。

![年夜饭](https://img.zhoujian.site/knowledge-base/other/2022%E6%98%A5%E8%8A%82-%E6%99%9A%E9%A4%90.jpeg)

### 拂衣天气

集地理信息与天气预报为一体的天气预报类小程序，界面精美，使用便捷。【致敬：和风天气】

2022年，是我工作的第四个年头。受多方面的信息影响，我也想看看验证自己是否有进入全栈开发的能力。该项目从2022年1月12号正式启动，于2022年3月19日发布一阶段最终版本（1.1.9），总体耗时2个月零7天。从内容完整度以及界面友好程度来说，我给自己70分。

> 其实最开始是想基于webview来实现更多的地图方面的特性的，但webview对个人认证不开放。

在完成之后，本来计划是将拂衣天气完整的开发过程通过文章的方式记录下来，并将该项目开源出去，甚至还想将该项目提交给和风天气。但最后的结果就是：文章就完整了四篇，也就是一个开头，没啥实际内容。

那么原因是什么呢？经过深深的反思过后，主要的原因有那么几点：

- 拂衣天气的实现太乱了，本想借着文章梳理重构之后再开源
- 同阶段想要做的事情太多了
- 拖延症后期患者
- 对，都是借口，就是懒

![首页--001](https://img.zhoujian.site/knowledge-base/other/%E6%8B%82%E8%A1%A3%E5%A4%A9%E6%B0%94-001.png)

![首页--002](https://img.zhoujian.site/knowledge-base/other/%E6%8B%82%E8%A1%A3%E5%A4%A9%E6%B0%94-002.png)

![首页--003](https://img.zhoujian.site/knowledge-base/other/%E6%8B%82%E8%A1%A3%E5%A4%A9%E6%B0%94-003.png)

![城市选择](https://img.zhoujian.site/knowledge-base/other/%E6%8B%82%E8%A1%A3%E5%A4%A9%E6%B0%94-004.png)

![分享卡片](https://img.zhoujian.site/knowledge-base/other/%E6%8B%82%E8%A1%A3%E5%A4%A9%E6%B0%94-005.png)

### WebGIS项目开发

我是2021年5月份进入的现在的这家公司，任职岗位是GIS开发工程师，主要负责服务端GIS内容的实现。从入职后到今年年初，一直在做一个小程序，算是公司的一个实验性产品，和已有产品的实际关联不大。

从3月份开始，将基于既有的产品实现，结合新项目的特性以及通用性要求，实现产品的升级。这对我来说，也算是一个重要的时间节点。因为自此我算是真正进入了WebGIS开发领域，以服务端开发为切入点。

### 项目部署工作

大概是22年的7-8月份，上面提到的WebGIS项目实现将作为基线产品的一部分，为后续的项目应用提供支持。而后面我将会同时负责WebGIS服务端的项目部署工作。

截至到2023年初，我已经经历了很多个项目。思来想去，我觉得这对我来说也是一个有意义的时间节点。从项目应用开发到基线产品，再到基线产品项目应用部署。一方面也算是证明了当初选择的路线，同时也更加坚定。另一方面，在疫情时代，公司能有项目那应该是好事，虽然我大抵是不喜欢做部署工作。

### 公司年会

对，这也是另一个重要的时间节点。2022年12月4号晚，发布了《杭州市关于优化调整疫情防控相关措施的通告》。2023年1月13日下午，公司举办了年会。这么结合起来看，是不是看起来明年会更好！

今年其实发生了挺多的事情，自己在心态上也发生了一定的变化（主要指工作方面）。从3月的充满希望，到年底的身心俱疲。正好借年会的氛围想了想，我觉得可以换一种心态开启2023年。当初选择来这里，也就是因为自己的路线规划与公司的技术发展方向是基本一致的，到今天公司并没有发生较大的变化。那么既然是自己想要做的，那么就更应该去做好，主动去做，你是在借助公司的资源实现自我的目标，你甚至可以尝试去干预以符合你的目标。未来的岳父大人也给我说：有的时候，不要计较那么多，即使辛苦一点也没关系，但是你要清楚你在做什么。

> 做了再多，不如做好一个，这就是你最好的名片。——自我PUA

## 2023展望

### 技术

围绕地理信息，更加深入底层实现。以空间数据库为核心，以数据处理与使用为重点，以数据渲染为次重点，由内到外，逐步构建技术体系。

### 写作

2022年的成果惨淡，整整一年只有仅仅四篇文章，还都是拂衣天气的内容。

希望从2023年开始，可以实现一周双更，单更是底线。同时还要能够提高文字表达的能力。

### 生活

可以一夜暴富吗？

## 后记

- 第一次更新：2023年2月13日晚，完成前言编写

- 第二次更新：2023年2月18日下午，完稿