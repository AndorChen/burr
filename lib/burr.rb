$:.unshift File.dirname(__FILE__)

# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

require 'nokogiri'
require 'kramdown'
require 'liquid'
require 'thor'
require 'thor/group'
require 'eeepub'

require 'yaml'

require_all 'burr/core_ext'
require_all 'burr/kramdown_ext'
require 'burr/cli'
require 'burr/dependency'
require 'burr/generator'
require 'burr/version'
require 'burr/ui'
require 'burr/converter'
require 'burr/exporter'
require_all 'burr/exporters'
require 'burr/plugin'
require_all 'burr/plugins'
require_all 'burr/liquid_ext'
require_all 'burr/eeepub_ext'
require 'burr/book'

Encoding.default_internal = 'utf-8'
Encoding.default_external = 'utf-8'

module Burr

  def self.configuration
    path = "#{Dir.pwd}/config.yml"

    begin
      YAML.load_file path
    rescue => e
      puts "#{e.message}"
    end
  end

end
