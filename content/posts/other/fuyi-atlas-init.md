---
title: "Fuyi Atlas Init"
date: 2023-02-19T22:29:01+08:00
draft: false
categories: 
  - other
  - fuyi atlas
tags: 
  - fuyi atlas
---

## 前言

I have a dream too!

开源技术赋予我们站在巨人的肩膀上做到更高更强的可能，我想通过开源技术来构建一个地理信息的世界（such as: one personal cloud gis），愿给地理信息数据带来更多的使用价值。当前主要关注空间数据库、数据处理与应用以及数据渲染，由内到外，逐步构建。既然都说人类活动所接触、产生的信息80%以上都与地理空间位置有关，那么这些空间数据就应该很容易的被使用，而不是仅被围困在专业领域内，不是吗？

Fuyi Atlas（拂衣志），取自 《侠客行》、[Cloud Atlas](https://cloud-atlas.readthedocs.io/zh_CN/latest/index.html)以及Discovery Atlas。愿自己也能行此间小事，而非蹉跎岁月。

Fuyi Atlas Website将会使用Hugo + Github Pages进行构建，本文用于记录Fuyi Atlas的初始构建过程。

## HUGO是什么

Hugo is one of the most popular open-source static site generators. With its amazing speed and flexibility, Hugo makes building websites fun again.

Hugo是一个使用GO语言编写的，开源的，静态站点生成器。

也就是说，你可以使用Hugo来快速构建你自己的静态站点。比如个人博客、知识库、产品介绍、文档等等。

我此前使用vuepress来构建我的个人站点，接触Hugo之后，更愿意使用Hugo。那么我将使用Hugo代替vuepress来构建我的个人站点。理由有那么几个：

- Hugo是一个纯粹的生成器
- Hugo没有过多的生态依赖
- Hugo更轻
- 据说更快，其LiveReload可以实现近实时的内容刷新
- 挺多可选的开源主题
- 使用更加简单

> 我也不是很喜欢node_modules

## Fuyi Atlas Site Build

### Hugo Install

Hugo is available in two editions: standard and extended. With the extended edition you can:

- Encode WebP images (you can decode WebP images with both editions)
- Transpile Sass to CSS using the embedded LibSass transpiler

We recommend that you install the extended edition.

Hugo提供两种版本：标准版和拓展版，官方更加推荐使用拓展版本

#### **Repository packages**

Most Linux distributions maintain a repository for commonly installed applications. Please note that these repositories may not contain the [latest release](https://github.com/gohugoio/hugo/releases/latest).

我的主机操作系统是Fedora Linux 37(Workstation Edition)，所以直接使用存储库进行安装

Derivatives of the [Fedora](https://getfedora.org/)distribution of Linux include [CentOS](https://www.centos.org/), [Red Hat Enterprise Linux](https://www.redhat.com/), and others. This will install the extended edition of Hugo:

```bash
sudo dnf install hugo

gudo version

# hugo v0.98.0+extended linux/amd64 BuildDate=unknown
```

这里可以看到版本是0.98，这已经是一个比较旧的版本了，是22年4月份发布的，最新版本是0.110.0。那么我打算换一种方式安装

#### **Build from source**

To build Hugo from source you must:

1. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
2. Install [Go](https://go.dev/doc/install) version 1.18 or later
3. Update your PATH environment variable as described in the [Go documentation](https://go.dev/doc/code#Command)

> The install directory is controlled by the GOPATH and GOBIN environment variables. If GOBIN is set, binaries are installed to that directory. If GOPATH is set, binaries are installed to the bin 
subdirectory of the first directory in the GOPATH list. Otherwise, binaries are installed to the bin subdirectory of the default GOPATH ($HOME/go or %USERPROFILE%\go).
> 

Then build and test:

```bash
go install -tags extended github.com/gohugoio/hugo@latest

hugo version
```

```bash
# 使用root账户
sudo su -
# 设置一下代理（clash for windwos）
export https_proxy=http://127.0.0.1:7890;export http_proxy=http://127.0.0.1:7890;export all_proxy=socks5://127.0.0.1:7890

# 设置一下安装使用的环境变量
export GOBIN=/usr/local/go/bin/

# 安装hugo
go install -tags extended github.com/gohugoio/hugo@latest

# 验证

hugo version
# hugo v0.110.0+extended linux/amd64 BuildDate=unknown
```

> 好了，目前已经是最新版本了

### Site Build

根据个人喜好（挑了许久），我最终选择**PaperMod**主题。

后续的计划是：Hugo + **PaperMod** + Github Pages

那么github仓库名称为：fuyi-atlas.github.io

参见Quick Start以及**PaperMod** Installation说明，下面开始进行构建

1. Git Clone
    
    ```bash
    git clone https://github.com/fuyi-atlas/fuyi-atlas.github.io.git
    ```
    
2. Create a site
    
    ```bash
    hugo new site fuyi-atlas.github.io --force
    ```
    
3. Install theme
    
    ```bash
    cd fuyi-atlas.github.io
    
    git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
    ```
    
4. 将config.toml修改为hugo.yaml，并作出基础
    
    ```bash
    mv config.toml hugo.yaml
    
    # 将其中语法修改为yaml格式
    ```
    
    ```yaml
    baseURL: https://fuyi-atlas.github.io/
    languageCode: en-us
    title: Fuyi Atlas
    theme: PaperMod
    ```

5. 将config.toml修改为hugo.yaml，并作出基础

    ```bash
    hugo server
    ```
    ![fuyi-atlas-init.png](http://img.zhoujian.site/knowledge-base/other/fuyi-atlas-init.png)

    至此，Fuyi Atlas的初始构建便结束了。