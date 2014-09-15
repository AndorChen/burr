# burr

[![Dependency Status](https://gemnasium.com/AndorChen/burr.png)](https://gemnasium.com/AndorChen/burr)

burr 是一个电子书制作工具（命令行）。使用 Markdown 编写书籍内容，burr 可以将其转换成 PDF，ePub 和 Mobi 格式电子书。还能生成 HTML 格式，提供书籍在线阅读。

## 注意

这个项目我已经停止开发！

## 目的

一份文稿，四种输出。

## 示例

《Ruby on Rails 教程》这本书的电子书，以及在线阅读版就是使用 burr 制作的。

<http://railstutorial-china.org>

## 特性

### 整体

- 章节自动编号；
- 图片自动编号；
- 表格自动编号；
- 代码片段自动编号；

### PDF 格式

- 自动生成目录；
- 自动生成书签；
- 自动生成交叉引用；
- 样式可定制；

### ePub 格式

- 元信息完整；
- 支持图书封面；
- 兼容各主要阅读器（多看，Kindle 等）；
- 自动生成目录；
- 自动生成交叉引用；
- 样式可定制；

### mobi 格式

- 元信息完整；
- 支持图书封面；
- 兼容各主要阅读器（Kindle 等）；
- 自动生成目录；
- 自动生成交叉引用；

### HTML 在线阅读

- 自动生成各章内容；
- 自动生成各章目录；
- 自动生成交叉引用；
- 样式可定制；

## 安装

### 依赖程序

burr 只是一个 wrapper，电子书都是通过其他程序生成的。其中 PDF 使用 [PrinceXML](http://www.princexml.com/)，ePub 使用 [eeepub](https://github.com/jugyo/eeepub)，mobi 使用 [kindlegen](http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211)。所以在使用 burr 之前，请确保安装了这些程序。具体的安装过程请参照相应程序的安装说明。

### burr 本身

burr 是一个 Ruby gem，可以像其他 gem 一样安装。但是由于没有推送到 Rubygems.org，所以无法使用 `gem install` 命令安装。

在项目的 `Gemfile` 中加入以下代码：

```ruby
gem 'burr', git:'git@github.com:AndorChen/burr.git'
```

然后执行 `bundle` 命令安装。

## 使用方法

### 生成新项目

执行 `burr new [path]` 命令会生成一个新项目，生成的目录结构如下：

```text
- Gemfile
- config.yml               # 项目设置
- contents                 # 书稿文件夹
  |- contents/chapter1.md
  |- contents/chapter2.md
- outputs                  # 电子书输出文件夹
  |- pdf/
     |- style.css
  |- site/
     |- figures/           # 书中所用图片
     |- style.css
  |- epub/
  |- mobi/
  |- caches/               # 缓存文件夹，暂时未用
     |- code/
```

### 安装gem

在项目的Gemfile中增加:

```ruby
gem 'rubyzip', '< 1.0.0'
```

执行`bundle`

### 生成电子书

```sh
$ burr export pdf
$ burr export epub
$ burr export mobi
$ burr export site
```

### 帮助

更多命令请执行 `burr help` 命令查看。

## 原理

1. 使用 Markdown 语法（[kramdown](http://kramdown.rubyforge.org/index.html)）撰写文稿；
2. burr 根据 `config.yml` 中的设置，套用模板将 Markdown 转换成 HTML 文档；
3. 电子书生成工具将 HTML 文档转换成电子书。

## 文稿格式

burr 使用 kramdown 的语法，并做了适当扩展。

### burr 的扩展

#### 附加信息（来自 Leanpub）

```text
A> #### 旁注标题
A>
A> 注意 > 符号后面要留一个空格。
A>
A> 如果旁注中有脚注，一定要写在旁注内。[^fn-1]
A>
A> [^fn-1]: 这是一个脚注。
```

```text
W> #### 警告
W>
W> 这是一则警告：侵权必究！
```

```text
T> #### 小贴士
T>
T> 夏天空调温度不要开的过低哟。
```

其他附加信息类型，请参考 [Leanpub 的帮助文档](https://leanpub.com/help/manual#leanpub-auto-asidessidebars)。

#### 代码块

kramdown 原生支持的代码块由 `~~~` 分隔，但我更习惯使用 GitHub 的句法，所以 burr 提供了对后者的支持。除此之外，因为计算机书籍经常会为代码块加入说明及所在文件位置，所以 burr 利用 kramdown 的 [Block Inline Attribute Lists](http://kramdown.rubyforge.org/syntax.html#block-ials) 实现了这一功能，使用方法如下：


	```ruby
	def hello
  	  puts "Hello, burr!"
	end
	```
	{:caption="Ruby 方法定义示例" file="/path/to/file.rb"}

代码高亮通过 [rouge](http://rubygems.org/gems/rouge) 实现。

### 图片题注

```text
![alt text](path/to/image.jpg){:caption="示例图片"}
```

## 作者

[Andor Chen](http://about.ac)

## 发布协议

[MIT](LICENSE.md)

## 致谢

在 burr 开发中借鉴了 [easybook](https://github.com/javiereguiluz/easybook/) 的很多思路，特此感谢。
