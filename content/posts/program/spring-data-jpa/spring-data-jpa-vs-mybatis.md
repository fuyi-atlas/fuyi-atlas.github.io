---
title: "Spring Data JPA 与 Mybatis 对比分析"
date: 2020-07-14T21:49:59+08:00
draft: false
categories: 
  - program
  - spring data jpa
tags: 
  - spring data jpa
  - mybatis
  - analysis
---

![](https://b3logfile.com/bing/20190625.jpg?imageView2/1/w/960/h/540/interlace/1/q/100)

## 前言

> 其实，手写jdbc也是蛮好玩的...
>
> 在企业开发过程中，除去一些特殊的要求外，基本上都会使用全自动或半自动的ORM框架代替原生JDBC进行数据库的访问。而在具体项目设计时，常常会根据项目业务情况进行技术选型。其中常用的ORM框架有：
>
> - **Mybatis**
> - **Hibernate**
> - **Spring Data JPA**
> - **JdbcTemplate**
>
> 在这里我们主要讨论**Mybatis**与**Spring Data JPA**。

<!-- more -->

## Spring Data JPA

### 1、JPA是什么

> [维基百科](https://zh.wikipedia.org/wiki/Java%E6%8C%81%E4%B9%85%E5%8C%96API)：JPA（Java Persistence API，Java持久化API）是一个Java应用程序接口规范，描述了使用Java标准平台（Java SE）和Java企业版平台（Java EE）的应用中的关系数据的管理。

> [Spring Data JPA 全面解析](https://segmentfault.com/a/1190000015047290)：JPA (Java Persistence API) 是 Sun 官方提出的 Java 持久化规范。它为 Java 开发人员提供了一种对象/关联映射工具来管理 Java 应用中的关系数据。他的出现主要是为了简化现有的持久化开发工作和整合 ORM 技术，结束现在 Hibernate，TopLink，JDO 等 ORM 框架各自为营的局面。值得注意的是，JPA 是在充分吸收了现有 Hibernate，TopLink，JDO 等ORM框架的基础上发展而来的，具有易于使用，伸缩性强等优点。从目前的开发社区的反应上看，JPA 受到了极大的支持和赞扬，其中就包括了 Spring 与 EJB3.0 的开发团队

> **JPA**所维护的核心是实体（Entity Bean），而它是通过一个持久化上下文（Persistence Context）来使用的。持久化上下文包含了以前3个部分：
>
> - 对象关系映射（Object Relational Mapping，简称ORM）描述，JPA支持注解或XML两种形式的描述。
> - 实体操作API，内置通用CRUD操作，来完成对象的持久化与查询。
> - 查询语言，约定了面向对象的查询语句JPQL。

> 简单来说，JPA就是一种接口规范，一种定义了对象关系映射（ORM）以及实体对象的持久化接口标准的规范，并不是一套直接可用的产品（如：Hibernate）。

### 2、什么是Spring Data JPA

> [spring-data-jpa](https://spring.io/projects/spring-data-jpa)：Spring Data JPA是Spring Data系列的一个组成部分，可以轻松快捷的实现数据访问层的增强支持，这使得基于Spring且使用了数据库访问技术的应用程序更加容易构建。
> Spring Data JPA 内置了简单数据库读写操作，包括分页查询，并提供接口以待增强。

> Spring Data JPA 是基于Hibernate（在3.2版本中便对JPA提供了完全的支持）、JPA规范的基础上封装的一套ORM框架，可以说就是JPA规范的一个实践落地的产品。Spring Data JPA的内置实现中提供了包括增删改查、分页、自定义SQL的常用功能，且提供接口以待拓展增强。基于Spring Data JPA可以简洁的代码，快速的实现对数据库的访问。

## Mybatis

### 1、Mybatis是什么

> [Mybatis](https://mybatis.org/mybatis-3/zh/index.html)：Mybatis是一款优秀的持久层框架，他支持自定义SQL、存储过程以及高级映射。Mybatis免除了几乎所有的JDBC代码以及设置参数和获取结果集的工作。Mybatis可以通过简单的XML或注解来配置和映射原始类型、接口和Java POJO（Plain Old Java Objects，普通老式Java对象）为数据库中的记录。

> Mybatis的关注点在于：
>
> - SQL与POJO的映射，或者说查询结果集与POJO的映射
> - 数据的高效存储于读写
> - 可定制化SQL，支持原生SQL

> 虽然一直都在使用Mybatis作为项目中的orm框架，但是始终没有深入的去了解。Mybatis就是一个ORM框架，是一个半自动的ORM框架，是一个面向查询结果集的ORM框架，一个关注实体与查询结果集之间的映射关系的ORM框架，且支持自定义SQL、存储过程、高级映射。在此基础上存在二次开发的开源产品：Mybatis-Plus，其在Mybatis的基础上进行了增强。

## 对比分析

### 1、功能性对比

| **序号** | **功能项** | **Spring Data JPA** | **Mybatis** |
| :-: | :- | :- | :- |
| **1** | 启动配置 | 数据库连接+JPA相关配置 | 数据库连接+Mybatis相关配置 |
| **2** | 映射关系 | 注解方式实现**POJO与数据表**之间的映射 | XML配置结合自动映射（或驼峰映射），实现**POJO与SQL**之间的映射 |
| **3** | 类型转换 | Convert，多用于如枚举值的存取 | TypeHandle，多用于枚举类型数据存储 |
| **4** | 读写接口 | 内置提供CRUD、分页、排序、 Example等基础接口，可自我拓展 | 默认不提供实现，由使用者实现，但是Mybatis-Plus提供通用mapper、分页 |
| **5** | 查询语言 | 提供约定的查询语言JPQL，同时支持原生SQL | 支持原生SQL，支持动态SQL |
| **6** | 其他 | 1、支持对象模型正向创建数据库模型；2、提供缓存机制；3、提供乐观锁指定 | 1、提供Interceptor，可以拦截SQL进行一定的处理；2、Mybatis-Plus提供代码生成器、支持数据库模型逆向生成对象模型 |

### 2、理论分析

- Spring Data JPA与Mybatis的设计原理不一样，前置根据领域设计进行建模，提倡面向对象思想，但是为了提供兼容性，提供自定义查询方法，可接入其他ORM框架；后者根据数据设计进行建模，多数实现为贫血模型。
- Spring Data JPA：先有对象关系，后有数据表关系；Mybatis：先有数据表关系，后有对象关系。
- Spring Data JPA（面向对象设计）：强调对象，以及对象的特性（如：封装），考虑的是对象的整个生命周期（包括对象的创建、持久化、状态的变更和行为等），对象的持久化只是对象的一种状态，所有操作皆由对象来完成，是对象的行为引发状态的改变，从而引起持久化状态数据的变化；Mybatis（面向关系设计）：强调数据的高效存取，开放数据表的操作，并不受实体的限制，可以随意进行表的关联，持久化的数据类似于某个事物的快照，事物状态的变化后引发对于快照的修改，有点直接面向数据库开发的感觉。
- Spring Data JPA：SQL为动态创建，创建后存在SQL缓存；Mybatis：SQL为静态文件。
- 面向对象设计试图为动态的世界建模，它要描述的是世界的过程和规律，进而适应发展和变化，面向对象总是在变化中处理各种各样的变化；关系型模型是为静态世界建模，它通过数据快照记录了世界在某一时刻的状态，它是静止的。

> 综合分析主要内容来自[Spring Data JPA与Mybatis简单对比](https://www.jianshu.com/p/3927c2b6acc0)

### 3、性能分析

> 待测试

### 4、综合分析

> 待更新

> 参考链接：
>
> - [Spring Data JPA与Mybatis简单对比](https://www.jianshu.com/p/3927c2b6acc0)
> - [技术专题讨论第二期总结：如何对 JPA 或者 MyBatis 进行技术选型](http://www.spring4all.com/article/391)

