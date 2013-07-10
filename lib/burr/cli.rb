module Burr
  class Cli < Thor

    desc 'new [PATH]', 'Create a new book'
    def new(path)
      generator = Burr::Generator.new
      generator.destination_root = path
      generator.invoke_all
    end

    desc 'export [FORMAT]', 'Export a book format, or all formats'
    def export(format)
      valid = %w(site pdf epub mobi all)

      if valid.include?(format)
        book = Burr::Book.new(config, format)
        case format
        when 'site'
          book.export_site
        when 'pdf'
          unless Dependency.prince_installed?
            book.ui.warn "Please install PrinceXML first."
            exit 1
          end
          book.export_pdf
        when 'epub'
          book.export_epub
        when 'mobi'
          unless Dependency.kindlegen_installed?
            book.ui.warn "Please install kindelgen first."
            exit 1
          end
          book.export_mobi
        when 'all'
          puts 'pending'
          # book.export_all
        end
      else
        raise "ERROR: invalid format. Formats: #{valid.join(', ')}."
      end
    end

    desc 'server', 'Site preview'
    def server
      Burr::Server.start!
    end

    desc 'version', 'Show the burr version'
    def version
      puts Burr::Version::STRING
    end

    private

    def config
      @config ||= Burr.configuration
    end

    def book_root
      @root ||= Dir.pwd
    end

  end
end
