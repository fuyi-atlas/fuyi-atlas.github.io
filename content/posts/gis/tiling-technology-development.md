---
title: "切片技术发展"
date: 2024-05-03T10:20:47+08:00
draft: false
categories: 
  - gis
  - tiling technology
tags: 
  - image tile
  - vector tile
  - dynamic vector tile
---

## 前言

> 本文80%内容节选自：[《WebGIS数据不切片或是时代必然》](https://zhuanlan.zhihu.com/p/512298212)，后在其基础上添加了部分内容。

数据切片是解决大规模大体积地理数据在Web前端轻量化传输和显示的关键技术，是每一个开发者几乎每天都在使用的技术，有时候将服务端底图切成xyz图片，有时候将大影像数据切成xyz图片，也有时候将矢量数据切成xyz的矢量切片。

## 数据切片起源--图像切片时代（WMS → WMTS，服务端渲染+预处理）

Web上古时代，人们浏览在线地图，一般是服务器端将页面地图要显示的地理范围内的地理数据都查询出来，然后在服务端按照专题地图的配置样式，渲染成地图图片，再返回客户端浏览，这个时代诞生的OGC标准就是<font color="orange">WMS（Web Map Service）</font>服务，该服务一直沿用至今。

类似WMS这种服务存在很多致命的缺点：由于地理范围的不可控，获取范围内的数据不可控，数据有时候会很大，数据通常在数据库中，IO和网络传输就耗时很严重；服务端获取数据后会进行数据渲染成地图图片，占用大量CPU资源；克服一系列的困难终于成图传输给前端浏览。可以想象，这个过程如此艰难，用户可能等的花儿都开了。

为了解决这个痛点，谷歌地图开创性提出了<u>基于Web墨卡托投影，<font color="orange">预先</font>在服务端全量渲染，然后按照地图不同的显示级别（金字塔原理），切成了xyz的图片。</u>

该技术成为Web2.0时代使用最广泛的技术，成为WebGIS标准，诞生了一系列如基于工业标准的TMS服务，基于OGC规范的WMTS服务。很快，百度地图，高德地图、天地图都使用该技术原理建设了自己的切片地图服务。广大GIS从业者也开始了<font color="orange">“项目一启动，先把底图切”</font>的套路。

基于该技术原理，对大的影像数据如几十G的GeoTiff数据也进行了切片，形成影像底图给客户端使用。

这个时期的开源GIS主要技术是基于GeoServer的WMS、WFS、TMS、WMTS服务。

<u>核心技术：Web墨卡托投影、栅格金字塔</u>

## 数据切片发展--矢量切片时代（WMTS，客户端渲染+预处理）

虽然基于XYZ的图片切片技术很成功，但是也存在不少问题：

1. 全图预切耗时长：通常切图zoom级别从0到20，通过金字塔原理图可知，上一级别的一张图片，下一级别会裂变成4张，级别越大，图片越多，同时地理范围越大，图片也越多，图片多了，切图耗时就很长，资源无论是基础底图切片还是影像底图切片都要耗时漫长。
2. 资源要求高：需要庞大的服务端渲染和切图的计算资源，满足分布式渲染、切图、存储需求。
3. 存储冗余：原始矢量和栅格数据，同时冗余存储了数据切片，存储压力大，数据切片转储IO压力大。ArcGIS为了提升转储性能，开创了离散性切片和紧凑型切片两个格式，紧凑型切片在转储时性能较高。
4. 数据更新不及时：由于切图耗时长，通常很少会定期更新地图切片数据，导致数据显示落后于实际生活现状，不能很好的服务用户。
5. 地图千篇一律：这个时期项目最常采用的是天地图地图服务，不管啥项目，不管什么地区，似乎地图都长一个样子。甲方可能审美疲惫了，他们希望底图能是定制化的，能不能暗黑一点？科幻一点？

既然存在问题，自然有人想解决问题，从15年左右，Mapbox受够了传统地图显示风格了，它提出了MVT矢量切片技术，该技术一经推出就大受欢迎，开启了WebGIS底图定制化时代。

![Untitled](https://zhou-fuyi.github.io/picx-images-hosting/Untitled.5xafx3l5e3.webp)

很显然，<font clolor="orange">矢量切片和图像切片最大的区别就是：渲染从服务端迁移到客户端了</font>，换句话说，服务端减负了，带来的好处也是不言而喻：

1. 资源要求降低：服务器资源要求可见性降低，渲染很耗资源的。
2. 数据更新比较及时：<u>如果数据更新，简单更新下局部变更地区的数据的矢量切片即可</u>，由于不用全图渲染，耗时极大减少，数据的有效性极大提高。
3. 存储冗余降低：采用MbTiles的设计规范，将数据和序号索引剥离，复用重复区域数据，极大降低切片数据量。但是数据冗余还是存在的。
4. 地图不再千篇一律：渲染是客户端的，那么甲方各种优秀的创意都能得到释放了，配置大屏的感觉已经是很容易的事情了。各行各业的地图五彩斑斓各有千秋，地图设计者们的春天来了。高德、百度跟的很快，目前也都提供矢量切片底图定制化服务了

这个时期的开源GIS主要技术是基于GeoServer的矢量切片服务，基于Mapbox的底图切图工具tippecanoe等。这个时期，3D GIS蓬勃发展，诞生了3DTiles、I3S等3D切片ogc规范，并大量在工程中使用。

矢量切片解决了不少问题，但仍遗留问题是：<font clolor="orange">全图预切耗时长，切片数据冗余占用存储空间</font>。这个问题同样也是栅格切片、3D切片共同的问题。于是有人问，能不能数据不切片？也就不存在预切耗时长，切片数据冗余的问题了？答案是肯定的。

<u>核心技术：矢量金字塔，MVT</u>

> 正所谓尾大不掉，虽然已经出现了矢量切片技术，但是整体的工艺流程还是在预切路线。这可能和矢量切片解决的问题相关，因为矢量切片解决的是渲染的问题，可以更自由的进行渲染了，而且只需要提供一份切片数据即可。

## 数据切片方向--动态切片时代（WMTS，客户端渲染）

那么上一个阶段遗留的问题还有什么：预处理，也就是不管怎么样，我先切数据

笔者（原文作者：**[遥想公瑾当年](https://www.zhihu.com/people/yao-xiang-gong-jin-dang-nian-88-8)**）曾经大量使用PostGIS+并行计算+动态矢量切片技术实现动态业务数据的快速前端矢量呈现，PostGIS是目前开源架构里唯一能支持动态矢量切片的数据技术。

![动态矢量切片对比图png](https://zhou-fuyi.github.io/picx-images-hosting/动态矢量切片对比图png.lvjce1v2j.webp)

<font color="orange">动态切片技术不再预先切图，也不会有大量切片的文件存储，将切片技术诞生以来所遗留的问题都一次清空</font>。由于通常数据量很大，动态矢量切片技术基本上数据不出库，而由数据库汇总组织数据并直接生成切片结果出去，后台几乎啥也不做，时空数据库的地位越来越重要。

这是一个崭新的时代，预示着数据不切片时代的来临，毕竟矢量和栅格不切片技术理论上还是比较成熟的，未来3DTiles这些3D切片理论也会逐渐成熟的。

<u>核心技术：动态矢量切片+矢量金字塔+MVT</u>

> 在这里我想要补充一下上面的示意图，这里不是说动态矢量切片技术只能应用在数据库中，前文中也提到当前开源架构中PostGIS是唯一能支持动态矢量切片的数据技术。这里是基于传统矢量切片技术与PostGIS的动态矢量切片技术的对比，更多的是想表达流程的变化（预切 → 动态，以及切片产生的位置），以及流程变化带来的性能提升和相关影响；还有就是原文作者认为的后续的发展方向，Based on spatial database。

## 关于动态矢量切片技术

动态矢量切片技术可以说是传统矢量切片的动态应用（更广义的可以认为：是可以按需动态生成的，具备多层次模型，且每个层次包含适当选取及简化的数据的切片技术）。强调不再预切，而是按需生成，且应该同时满足可以快速显示的要求。

- 按需动态生成（与数据源是链接着的或是可链接的，即可达成随时可访问），不做预切
- 多层次结构（如：矢量金字塔）
- 数据选取与简化
- MVT支持

从发展进程上面看，技术的升级是为了解决此前存在的痛点问题。动态矢量切片技术是为了解决预切耗时，且会产生大量的瓦片存储（预切），数据越大，产生的瓦片越多。

从实际的应用上看，此前的矢量切片技术我更愿意将之称为传统矢量切片技术，用以与矢量切片做一定的区分。传统矢量切片技术还是走的预处理的路子，产生的是静态矢量瓦片数据，即在流程上是无法做到快速更新的。与之对应的便是动态实时生产的路线，可称为动态矢量瓦片技术。私以为，两者更大的区别在于矢量瓦片生产的思路，也就是是否需要预切。

所以，动态矢量切片技术可以有各种各样的实现，而PostGIS中的动态矢量瓦片技术便是其中的一种。且到目前，GeoServer同样实现了动态矢量瓦片技术（只不过其历史包袱过重 🫡）。

> 值得注意的是，基于数据库的动态矢量切片有一个很大的特点：缩短了切片的传导路径（也就是所谓的数据不出库，出库即为切片）。

## 参考

- [WebGIS数据不切片或是时代必然](https://zhuanlan.zhihu.com/p/512298212)
- [PostGIS动态矢量切片（原理+实现）](https://www.jianshu.com/p/fede7a0d3154)