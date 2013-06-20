$:.unshift File.expand_path('../lib', __FILE__)

require 'burr/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name              = 'burr'
  s.version           = Burr::Version::STRING
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

  s.add_runtime_dependency('nokogiri',    '1.6.0')
  s.add_runtime_dependency('thor',        '0.18.1')
  s.add_runtime_dependency('liquid',      '2.5.0')
  s.add_runtime_dependency('kramdown',    '1.0.2')
  s.add_runtime_dependency('pygments.rb', '0.5.0')
  s.add_runtime_dependency('eeepub',      '0.8.1')

  s.files = `git ls-files`.split($/)
end
