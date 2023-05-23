---
title: "如何构建一个矢量瓦片服务"
date: 2023-05-23T22:46:59+08:00
draft: false
categories: 
  - program
  - map
tags: 
  - vector tile 
  - service
---

## 前言

### 关于矢量瓦片（节选）

地图瓦片技术是在线地图服务常用的瓦片技术，瓦片就是地图瓦片的具体存储形态，提前切好的瓦片可以大大提高在线地图的访问效率。

#### 栅格瓦片

以图片为介质的栅格瓦片使得在线地图得以迅速普及，优势在于显示效率高、方便传输。但是，随着地图的移动化和应用的逐渐深入，栅格瓦片占用带宽和存储都较大，不利于地图在移动设备的应用。

#### 矢量瓦片

矢量瓦片的产生弥补了栅格瓦片的不足。矢量瓦片数据以矢量形式存在。矢量瓦片体积下，可高度压缩，占用的存储空间比栅格瓦片要小上千倍。数据传输体量小，地图更新的代价小

![适量瓦片介绍架构图](https://img.zhoujian.site/knowledge-base/program/map/vector-tile-arch.png)

### 常见的矢量瓦片制作工具（节选）

目前开源的矢量切片工具还是非常多的，列出一些主流的阐述下：

- 基于GeoServer的矢量切片插件，适合熟悉GeoServer的用户，操作还比较简单，缺点是切片的行列号与一般的XYZ编号不同不容易单独部署。
- 基于tippecanoe的矢量切片工具方案，该工具提供了很多高级功能在数据定制化上有很强的优势，但只能部署在Linux，并不是跨平台，只能读取geojson文件，不能直连数据库，不是很好，如果有幸您是c++开发大神，可以改下库的编译绑定平台，使其支持windows，再更改下数据源底层，使其能支持空间数据库，那么该工具会有更多的应用空间。
- 基于PostGIS的矢量切片方案，该方案在熟悉PostGIS的用户中应该很受欢迎，优势是支持动态矢量切片，有PG社区的系统级加成。

总的来说，工具虽然很多，但是没有一款可以说覆盖一切场景的，具体应用还是看场景的，比如前两个方案都是做底图数据时比较有用，都是静态矢量切片方案，geoserver能直连数据库，tippecanoe有强数据定制性要求，那么如果用户侧重点是简单点的话geoserver够了，用户侧重点是希望对数据做很多高级过滤什么的操作用tippecanoe，但步骤麻烦点。这些矢量切片工具仅仅在处理很久不变的数据，就是切一次用很久的数据，如果数据频繁变化，这种静态数据切片工具就很不好用了。

与其他方案相比，PostGIS方案的好处主要有两大点：

- 资源开销低：空间数据一般存空间数据库中，传统工具会先从数据库中捞数据，这个数据通常很大，网络开销和服务器端内存都要很大，查询慢计算慢是肯定的。而PostGIS是在数据库中把数据处理完，只把结果传给后台转前台，可以很方便的使用数据库的索引，并行计算等，优化查询和处理速度。
- 动态矢量切片，数据时效性高：每当根据xyz请求时，数据库会动态查询范围内数据，裁剪简化并输出pbf格式的二进制数据出去，在数据变化频繁的场景下，可以保证用户看到的是最新的数据。

> 💡 GeoServer、Tippecanoe 皆为静态矢量切片方案，需提前准备切片数据，并进行持久化（GeoServer也可以在使用时进行切片，同时进行持久化）。PostGIS支持动态矢量切片方案，即实时计算生成切片，且不进行切片的持久化。

### 为什么要自己写一个服务

于我个人而言，我目前仅接触和使用到了GeoServer，且对其中的实现细节并不太清楚，所以想通过参考模仿的方式实现一个示例服务。其次，还想测试在没有如GeoWebcache此类的瓦片缓存的情况下，服务的性能如何。综上所述，其实也就是为了如下这几方面的目的：

- 学习，了解其中的实现细节
- 更好的适配
    
    比如说，WMTS服务很明确存在缓存，WMS性能又不够好。如果使用WMTS服务确实可以提升服务的性能，但是对于源数据存在编辑的场景下，缓存问题还是会让人头疼。
    

---

那么是否存在动态的矢量瓦片服务？既能解决缓存的问题，同时还没有太大的性能问题。

你或许会提到基于PostGIS的动态矢量瓦片服务，但是有些历史的原因，短时间内没有变法变更数据库。当然也可以基于类如CDC这样的功能进行缓存的更新，但其实还是会存在缓存的问题，只是说可以通过一些手段降低缓存问题出现的概率，并无法从根本上解决问题

所以，基于此，既然PostGIS可以实现动态矢量瓦片服务，我们自然也可以。公瑾大佬曾发文说过，当下[地图服务去服务化](https://mp.weixin.qq.com/s?__biz=Mzg2OTUxMzM2MA==&mid=2247484242&idx=1&sn=5900ba848b5cad687a7f17618b6e0872&chksm=ce9aa2adf9ed2bbbc2871bebf311932895b34a2c458e0a307be1b47bcb6cb2e667b177b53d3d&mpshare=1&scene=23&srcid=0513nR06xrC66TIgghKCM2iJ&sharer_sharetime=1683967136869&sharer_shareid=a30258a8ecb50abd4544d59818ed586e#rd)、[数据不切片](https://zhuanlan.zhihu.com/p/512298212)基本上已经是必然的趋势，那么我为什么还要去做一个服务化的东西。大概就是下面这几个原因了：

- 数据库技术，在某些特定的因素下，短时间内无法切换到PostGIS
- 数据量级
- 性能容忍度
- 小厂，我不思进取 🙄
- 后续知识储备

## 矢量瓦片标准

参见：**[矢量瓦片标准](https://github.com/jingsam/vector-tile-spec/blob/master/2.1/README_zh.md)**

在这里贴几个关键点（对于目前使用上来说）：

- 文件格式
    
    矢量瓦片文件采用[Google Protocol Buffers](https://developers.google.com/protocol-buffers/)进行编码。Google Protocol Buffers是一种兼容多语言、多平台、易扩展的数据序列化格式。
    
- 投影和范围
    
    矢量瓦片表示的是投影在正方形区块上的数据。矢量瓦片**不应该**包含范围和投影信息。解码方被假定知道矢量瓦片的范围和投影信息。
    
    [Web Mercator](https://en.wikipedia.org/wiki/Web_Mercator)是默认的投影方式，[Google tile scheme](http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/)是默认的瓦片编号方式。两者一起完成了与任意范围、任意精度的地理区域的一一对应，例如`https://example.com/17/65535/43602.mvt`。
    
    矢量瓦片**可以**用来表示任意投影方式、任意瓦片编号方案的数据。
    
- 内部结构
    - 图层
        
        每块矢量瓦片**应该**至少包含一个图层。每个图层**应该**至少包含一个要素。
        
    - 几何图形编码
        
        矢量瓦片中的几何数据被定义为**屏幕坐标系**。瓦片的左上角（显示默认如此）是坐标系的原点。X轴向右为正，Y轴向下为正。几何图形中的坐标**必须**为整数。
        

## 矢量瓦片服务构建

在这里，我选择抄GeoServer的作业。众所周知，PostGIS是开源的，那为什么没有选择抄PostGIS的作业呢？

- 当下水平不够
- 想快速验证想法
- 想基于GeoServer做二次开发，或者说是基于现存的地图服务相关的实现，集各家之大成，合并成一个组在功能上可自由搭配的、较高性能服务端组件

接着说当前的事情。要实现一个动态矢量瓦片服务，我们需要先分析一下实现内容，在此先做出如下拆解：

- 动态矢量瓦片服务可以理解为没有瓦片缓存的，实时生成的矢量瓦片服务，所以核心还是矢量瓦片服务
- 矢量瓦片服务也就是根据调用端传递的参数，从数据源获取对应的数据，并将其转换为矢量瓦片格式，最终返回给调用端
- 这里选择瓦片坐标作为检索参数，可以便于服务降级（缓存）和性能优化（瓦片坐标值相对来说更加准确和可固定，且便于降维）
- 需要实现瓦片坐标系到数据源坐标系下数据范围的相互转换
- 需要实现数据源的范围查询
- 需要实现矢量数据到矢量瓦片的编解码

那么大体的实现路径可归结于如下所示：

![矢量瓦片服务实现路径](https://img.zhoujian.site/knowledge-base/program/map/%E7%9F%A2%E9%87%8F%E7%93%A6%E7%89%87%E6%9C%8D%E5%8A%A1%E5%AE%9E%E7%8E%B0%E8%B7%AF%E5%BE%84.png)

其中的核心要点总结如下：

- 瓦片金字塔模型构建
    - 瓦片坐标系与空间坐标系的映射关系
    - 切片方案确定
        - 瓦片大小
        - 分辨率
        - …
- 矢量瓦片的编解码
- 矢量数据查询

下面将对以上几点作详细描述，本次内容基本上全部参考GeoServer实现完成。

### 瓦片金字塔模型构建

#### 瓦片金字塔模型（节选）

瓦片最早是由谷歌地图提出并进行应用的，其采用特定的切割方式对采用WebMercator投影坐标的世界地图栅格影像进行切片，由于WebMercator投影方便计算机进行计算，随后各大主流WebGIS和互联网地图应用商都采用基于WebMercator投影坐标系的方式进行切片。

瓦片金字塔的主要原理为：基于某个特定的地图投影坐标系，将曲面 的地球投影到二维平面，而后将该二维平面进行多尺度地划分，即相当于制作了多个不同分辨率层级的数字地图。各层级对应相应编码，层级越高地图所对应的分辨率越高；而后对每一层级的全球空间范围地图按照某种空间划分方法进行格网划分，划分成若干行和列的固定尺寸的正方形栅格图片，这些切分出来的规整的单个格网单元称为瓦片，各层级的划分方法都是相同的。

瓦片划分方法需满足以下条件：

1. 每个层级下的所有瓦片可以无缝拼合成一张全球空间范围的世界地图
2. 每个瓦片都有唯一编码，根据编码可以解算该瓦片对应的空间范围
3. 在某一层级下给定一坐标点可以根据其空间坐标解算其所在瓦片的编号

每一层级瓦片对应一层金字塔，各个层级的瓦片构成了整个瓦片金字塔模型。每一层中的瓦片划分方法一般采用均匀四分的划分方法，即以赤道和中央经线的交点为初始中心，不断地对地图进行四分，直到每个格网的大小为tilesize * tilesize为止，其中tilesize表示单个瓦片的边长。基于此种划分方法，第0层金字塔（*金字塔顶层*）用一个瓦片就能表示整张世界地图，第1层要用4^z个瓦片来表示整个世界地图，z为当前瓦片的金字塔层级。

![金字塔模型示意图](https://img.zhoujian.site/knowledge-base/program/map/%E9%87%91%E5%AD%97%E5%A1%94%E7%A4%BA%E6%84%8F%E5%9B%BE1.png)

#### 瓦片坐标系（节选）

所有瓦片的编码都是基于瓦片坐标系下进行的，瓦片坐标系的原点一般都在左上角或者左下角，TMS规范中是在左下角（GeoServer遵循该规范），但是现有的Google、MapNIK切片系统都是选用左上角作为原点，本文主要以原点在左上角的瓦片坐标系进行说明。

瓦片的编码方式如下图所示，层级用z表示，瓦片经线方向（*指瓦片经度发生变化的方法，即东西向，东向为正*）上编号为x，纬线方向（指瓦片维度发生变化的方向，即南北向，南向为正）上编号为y，因此每一个瓦片都可以通过一个三维元组（x,y,z）来唯一描述。

![瓦片坐标系1](https://img.zhoujian.site/knowledge-base/program/map/%E7%93%A6%E7%89%87%E5%9D%90%E6%A0%87%E7%B3%BB1.png)
![瓦片坐标系2](https://img.zhoujian.site/knowledge-base/program/map/%E7%93%A6%E7%89%87%E5%9D%90%E6%A0%87%E7%B3%BB2.png)
![瓦片坐标系3](https://img.zhoujian.site/knowledge-base/program/map/%E7%93%A6%E7%89%87%E5%9D%90%E6%A0%87%E7%B3%BB3.png)

> 💡 节选自《高性能影像数据瓦片化关键技术研究-刘世永-2016》，章节：第二章，2.1-2.3

#### 瓦片金字塔程序模型

此处只显示核心模块

- Grid，对应单层金字塔
    
    ```java
    // 指定层级横向的瓦片数量
    private long numTilesWide;
    // 指定层级纵向的瓦片数量
    private long numTilesHigh;
    // 分辨率
    private double resolution;
    // 比例尺分母
    private double scaleDenom;
    private String name;
    ```
    
- GridSet，对应完整的金字塔层级
    
    ```java
    // 名称
    private String name;
    private SRS srs;
    // 瓦片宽度，一般为256
    private int tileWidth;
    // 瓦片高度，一般为256
    private int tileHeight;
    protected boolean yBaseToggle = false;
    private boolean yCoordinateFirst = false;
    private boolean scaleWarning = false;
    private double metersPerUnit;
    private double pixelSize;
    // 数据范围
    private BoundingBox originalExtent;
    private Grid[] gridLevels;
    private String description;
    private boolean resolutionsPreserved;
    ```
    

#### 瓦片金字塔逻辑模型构建

瓦片金字塔需要又逻辑模型与物理模型共同构成，物理模型（即瓦片集）需要根据逻辑模型的定义才可进行构建。此处以常规瓦片金字塔逻辑模型为示例，通过上述程序模型，构建瓦片金字塔逻辑模型

```java
// Pixel size (to calculate scales). The default is 0.28mm/pixel, corresponding to 90.71428571428572 DPI.
public static GridSet buildGriDSet(SRS srs, double pixelSize) {
    return GridSetFactory.createGridSet(String.valueOf(srs.getNumber()), srs, BoundingBox.WORLD3857, false, 30, null,
            pixelSize, 256, 256, false);
}
// 需要将其转换为米
buildGriDSet(SRS.getEPSG900913(), 0.00028D);
```

```java
public static GridSet createGridSet(String name, SRS srs, BoundingBox extent, boolean alignTopLeft, int levels, Double metersPerUnit, double pixelSize, int tileWidth, int tileHeight, boolean yCoordinateFirst) {
    double extentWidth = extent.getWidth();
    double extentHeight = extent.getHeight();
    double resX = extentWidth / (double)tileWidth;
    double resY = extentHeight / (double)tileHeight;
    int tilesWide;
    int tilesHigh;
    // 计算调整的基数, 以小边为主
    if (resX <= resY) {
        tilesWide = 1;
        tilesHigh = (int)Math.round(resY / resX);
        resY /= (double)tilesHigh;
    } else {
        tilesHigh = 1;
        tilesWide = (int)Math.round(resX / resY);
        resX /= (double)tilesWide;
    }

    // 计算地图分辨率, 即单位像素内表示的地图单位(米或度)
    double res = Math.max(resX, resY);
    // 获取裁减后的范围
    double adjustedExtentWidth = (double)(tilesWide * tileWidth) * res;
    double adjustedExtentHeight = (double)(tilesHigh * tileHeight) * res;
    // 根据上述范围重新构建范围表达
    BoundingBox adjExtent = new BoundingBox(extent);
    adjExtent.setMaxX(adjExtent.getMinX() + adjustedExtentWidth);
    // 这里想要表达的就是原点在于左上角还是左下角（确定起算位置）, 因为这样会影响y方向上的范围计算。就是进行y方向上范围计算
    if (alignTopLeft) {
        adjExtent.setMinY(adjExtent.getMaxY() - adjustedExtentHeight);
    } else {
        adjExtent.setMaxY(adjExtent.getMinY() + adjustedExtentHeight);
    }

    // 根据给定的层级参数, 构建各层级下分辨率值
    double[] resolutions = new double[levels];
    // 设置0级的分辨率
    resolutions[0] = res;

    for(int i = 1; i < levels; ++i) {
        // 采用常规均匀四分（四叉树）方式进行构建
        resolutions[i] = resolutions[i - 1] / 2.0D;
    }

    return createGridSet(name, srs, adjExtent, alignTopLeft, resolutions, (double[])null, metersPerUnit, pixelSize, (String[])null, tileWidth, tileHeight, yCoordinateFirst);
}
```

```java
public static GridSet createGridSet(String name, SRS srs, BoundingBox extent, boolean alignTopLeft, double[] resolutions, double[] scaleDenoms, Double metersPerUnit, double pixelSize, String[] scaleNames, int tileWidth, int tileHeight, boolean yCoordinateFirst) {
    Assert.notNull(name, "name is null");
    Assert.notNull(srs, "srs is null");
    Assert.notNull(extent, "extent is null");
    Assert.isTrue(!extent.isNull() && extent.isSane(), "Extent is invalid: " + extent);
    Assert.isTrue(resolutions != null || scaleDenoms != null, "The gridset definition must have either resolutions or scale denominators");
    Assert.isTrue(resolutions == null || scaleDenoms == null, "Only one of resolutions or scaleDenoms should be provided, not both");

    int i;
    for(i = 1; resolutions != null && i < resolutions.length; ++i) {
        if (resolutions[i] >= resolutions[i - 1]) {
            throw new IllegalArgumentException("Each resolution should be lower than it's prior one. Res[" + i + "] == " + resolutions[i] + ", Res[" + (i - 1) + "] == " + resolutions[i - 1] + ".");
        }
    }

    for(i = 1; scaleDenoms != null && i < scaleDenoms.length; ++i) {
        if (scaleDenoms[i] >= scaleDenoms[i - 1]) {
            throw new IllegalArgumentException("Each scale denominator should be lower than it's prior one. Scale[" + i + "] == " + scaleDenoms[i] + ", Scale[" + (i - 1) + "] == " + scaleDenoms[i - 1] + ".");
        }
    }

    GridSet gridSet = baseGridSet(name, srs, tileWidth, tileHeight);
    // true：保留分辨率并计算 scaleDenominators
    // false：分辨率是根据 sacale 分母计算的
    gridSet.setResolutionsPreserved(resolutions != null);
    gridSet.setPixelSize(pixelSize);
    gridSet.setOriginalExtent(extent);
    // tileOrigin()的y坐标是在顶部（true）还是在底部（false），相应的标记原点位置
    gridSet.yBaseToggle = alignTopLeft;
    // 轴顺序, 默认经度优先
    gridSet.setyCoordinateFirst(yCoordinateFirst);
    // 设置单位, 每个单位内表示多少米
    // 经纬度直投的情况需要特殊处理
    if (metersPerUnit == null) {
        if (srs.equals(SRS.getEPSG4326())) {
            gridSet.setMetersPerUnit(111319.49079327358D);
        } else if (srs.equals(SRS.getEPSG3857())) {
            gridSet.setMetersPerUnit(1.0D);
        } else {
            if (resolutions == null) {
                log.config("GridSet " + name + " was defined without metersPerUnit, assuming 1m/unit. All scales will be off if this is incorrect.");
            } else {
                log.config("GridSet " + name + " was defined without metersPerUnit. Assuming 1m per SRS unit for WMTS scale output.");
                gridSet.setScaleWarning(true);
            }

            gridSet.setMetersPerUnit(1.0D);
        }
    } else {
        gridSet.setMetersPerUnit(metersPerUnit);
    }

    if (resolutions == null) {
        gridSet.setGridLevels(new Grid[scaleDenoms.length]);
    } else {
        gridSet.setGridLevels(new Grid[resolutions.length]);
    }

    for(i = 0; i < gridSet.getNumLevels(); ++i) {
        Grid curGrid = new Grid();
        if (scaleDenoms != null) {
            curGrid.setScaleDenominator(scaleDenoms[i]);
            curGrid.setResolution(pixelSize * (scaleDenoms[i] / gridSet.getMetersPerUnit()));
        } else {
            curGrid.setResolution(resolutions[i]);
            // 计算比例尺 (单位像素下表示的实际空间距离 * 每个单位情况表示多少米) / (像素大小，或称像元大小)
            // 约去像元, 即获取到比例尺分母
            curGrid.setScaleDenominator(resolutions[i] * gridSet.getMetersPerUnit() / 2.8E-4D);
        }

        double mapUnitWidth = (double)tileWidth * curGrid.getResolution();
        double mapUnitHeight = (double)tileHeight * curGrid.getResolution();
        long tilesWide = (long)Math.ceil((extent.getWidth() - mapUnitWidth * 0.01D) / mapUnitWidth);
        long tilesHigh = (long)Math.ceil((extent.getHeight() - mapUnitHeight * 0.01D) / mapUnitHeight);
        curGrid.setNumTilesWide(tilesWide);
        curGrid.setNumTilesHigh(tilesHigh);
        if (scaleNames != null && scaleNames[i] != null) {
            curGrid.setName(scaleNames[i]);
        } else {
            curGrid.setName(gridSet.getName() + ":" + i);
        }

        gridSet.setGrid(i, curGrid);
    }

    return gridSet;
}
```

### 矢量瓦片编解码模块

参考GeoServer实现，使用第三方编解码组件：`java-vector-tile`

[https://github.com/ElectronicChartCentre/java-vector-tile](https://github.com/ElectronicChartCentre/java-vector-tile)

### 矢量数据查询

为了更快的实现开发，此处选择使用GeoTools提供的JDBC相关组件进行数据查询，核心类如下：

- JDBCDataStore
- VirtualTable：可以支持自定义SQL
- MathTransform
- ContentFeatureSource
- SimpleFeatureCollection

主要逻辑步骤如下所示：

- 通过JDBCDataStore创建VirtualTable实例
- 根据GridSet将传入参数转为BoundingBox
- 使用MathTransform将BoudingBox转换到源数据所对应的坐标系下
- 构建查询对象，并使用上述创建的虚拟表实例（ContentFeatureSource）进行数据检索
- 将检索的数据结果应用于矢量瓦片编码并返回结果

### 服务验证

叠加底图进行验证

![Result 1](https://img.zhoujian.site/knowledge-base/program/map/result1.png)
![Result 2](https://img.zhoujian.site/knowledge-base/program/map/result2.png)

## 参考

- [Mapbox Vector Tile Specification](https://github.com/mapbox/vector-tile-spec)
- [awesome-vector-tiles](https://github.com/mapbox/awesome-vector-tiles)
- [Vector tiles standards](https://docs.mapbox.com/data/tilesets/guides/vector-tiles-standards/)
- [矢量瓦片概述](https://help.supermap.com/iDesktop/zh/tutorial/MapTiles/VectorTilesOverview/)
- [WebGIS数据不切片或是时代必然](https://zhuanlan.zhihu.com/p/512298212)
- [PostGIS矢量切片技术助力GIS可视化](https://zhuanlan.zhihu.com/p/358192568)
- [Geoserver](https://github.com/geoserver/geoserver)
- [Buffer around Vectortiles](https://blog.cyclemap.link/2020-01-25-tilebuffer/)
- [Gridsets and Gridsubsets](https://www.geowebcache.org/docs/current/concepts/gridsets.html)
- [Tiles à la Google Maps Coordinates, Tile Bounds and Projection](https://www.maptiler.com/google-maps-coordinates-tile-bounds-projection/#3/15.00/50.00)
- [国内主要地图瓦片坐标系定义及计算原理](https://cntchen.github.io/2016/05/09/%E5%9B%BD%E5%86%85%E4%B8%BB%E8%A6%81%E5%9C%B0%E5%9B%BE%E7%93%A6%E7%89%87%E5%9D%90%E6%A0%87%E7%B3%BB%E5%AE%9A%E4%B9%89%E5%8F%8A%E8%AE%A1%E7%AE%97%E5%8E%9F%E7%90%86/)
- [瓦片(Tile)地图原理](https://xcsf.github.io/blog/2020/06/12/%E7%93%A6%E7%89%87Tile%E5%9C%B0%E5%9B%BE%E5%8E%9F%E7%90%86/)