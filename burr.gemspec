Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name              = 'burr'
  s.version           = '0.0.1'
  s.license           = 'MIT'
  s.date              = '2013-04-21'

  s.summary     = "电子书制作工具"
  s.description = "使用 Markdown 编写书籍内容，通过 burr 将其转换成 PDF，ePub 和 Mobi 格式电子书。"

  s.authors  = ["Andor Chen"]
  s.email    = 'andor.chen.27@gmail.com'
  s.homepage = 'https://github.com/AndorChen/burr'

  s.require_paths = %w[lib]

  s.executables = ["burr"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE.md]

  s.add_runtime_dependency('nokogiri',    '1.5.6')
  s.add_runtime_dependency('thor',        '0.16.0')
  s.add_runtime_dependency('liquid',      '2.4.1')
  s.add_runtime_dependency('kramdown',    '1.0.1')
  s.add_runtime_dependency('pygments.rb', '0.3.7')
  s.add_runtime_dependency('eeepub',     '0.8.1')

  # = MANIFEST =
  s.files = %w[
    Gemfile
    LICENSE.md
    README.md
    Rakefile
    bin/burr
    burr.gemspec
    generators/Gemfile.txt
    generators/config.yml
    generators/contents/chapter1.md
    generators/contents/chapter2.md
    generators/stylesheets/pdf.css
    generators/stylesheets/site.css
    lib/burr.rb
    lib/burr/book.rb
    lib/burr/cli.rb
    lib/burr/converter.rb
    lib/burr/core_ext/blank.rb
    lib/burr/dependency.rb
    lib/burr/eeepub_ext/maker.rb
    lib/burr/exporter.rb
    lib/burr/exporters/epub.rb
    lib/burr/exporters/pdf.rb
    lib/burr/exporters/site.rb
    lib/burr/generator.rb
    lib/burr/kramdown_ext/converter.rb
    lib/burr/kramdown_ext/options.rb
    lib/burr/kramdown_ext/parser.rb
    lib/burr/liquid_ext/block.rb
    lib/burr/liquid_ext/extends.rb
    lib/burr/plugin.rb
    lib/burr/plugins/aside.rb
    lib/burr/plugins/codeblock.rb
    lib/burr/plugins/figure.rb
    lib/burr/plugins/link.rb
    lib/burr/plugins/parser_plugin.rb
    lib/burr/plugins/table.rb
    lib/burr/plugins/toc.rb
    lib/burr/ui.rb
    lib/burr/version.rb
    resources/locales/labels/en.yml
    resources/locales/labels/zh_CN.yml
    resources/locales/titles/en.yml
    resources/locales/titles/zh_CN.yml
    resources/templates/epub/_layout.liquid
    resources/templates/epub/acknowledgement.liquid
    resources/templates/epub/afterword.liquid
    resources/templates/epub/appendix.liquid
    resources/templates/epub/author.liquid
    resources/templates/epub/chapter.liquid
    resources/templates/epub/conclusion.liquid
    resources/templates/epub/cover.liquid
    resources/templates/epub/dedication.liquid
    resources/templates/epub/edition.liquid
    resources/templates/epub/epilogue.liquid
    resources/templates/epub/foreword.liquid
    resources/templates/epub/glossary.liquid
    resources/templates/epub/introduction.liquid
    resources/templates/epub/license.liquid
    resources/templates/epub/lof.liquid
    resources/templates/epub/lot.liquid
    resources/templates/epub/part.liquid
    resources/templates/epub/preface.liquid
    resources/templates/epub/prologue.liquid
    resources/templates/epub/table.liquid
    resources/templates/epub/title.liquid
    resources/templates/epub/toc.liquid
    resources/templates/pdf/_item.liquid
    resources/templates/pdf/acknowledgement.liquid
    resources/templates/pdf/afterword.liquid
    resources/templates/pdf/appendix.liquid
    resources/templates/pdf/author.liquid
    resources/templates/pdf/blank.liquid
    resources/templates/pdf/book.liquid
    resources/templates/pdf/chapter.liquid
    resources/templates/pdf/code.liquid
    resources/templates/pdf/conclusion.liquid
    resources/templates/pdf/cover.liquid
    resources/templates/pdf/dedication.liquid
    resources/templates/pdf/edition.liquid
    resources/templates/pdf/epilogue.liquid
    resources/templates/pdf/foreword.liquid
    resources/templates/pdf/glossary.liquid
    resources/templates/pdf/introduction.liquid
    resources/templates/pdf/license.liquid
    resources/templates/pdf/lof.liquid
    resources/templates/pdf/lot.liquid
    resources/templates/pdf/part.liquid
    resources/templates/pdf/preface.liquid
    resources/templates/pdf/prologue.liquid
    resources/templates/pdf/table.liquid
    resources/templates/pdf/title.liquid
    resources/templates/pdf/toc.liquid
    resources/templates/site/_layout.liquid
    resources/templates/site/author.liquid
    resources/templates/site/chapter.liquid
    resources/templates/site/foreword.liquid
    resources/templates/site/preface.liquid
  ]
  # = MANIFEST =
end
