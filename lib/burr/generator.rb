module Burr
  class Generator < Thor::Group

    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__) + '/../../generators'
    end

    def copy_gemfile
      copy_file 'Gemfile.txt', 'Gemfile'
    end

    def copy_config_file
      copy_file 'config.yml'
    end

    def copy_contents
      directory 'contents'
    end

    def outputs_dir
      empty_directory 'outputs/pdf'
      empty_directory 'outputs/site'
      empty_directory 'outputs/epub'
      empty_directory 'outputs/mobi'

      empty_directory 'outputs/site/figures'
    end

    def copy_stylesheets
      copy_file 'stylesheets/pdf.css', 'outputs/pdf/style.css'
      copy_file 'stylesheets/site.css', 'outputs/site/style.css'
    end

    def caches_dir
      empty_directory 'caches/code'
    end

  end
end
