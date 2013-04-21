module Burr
  class Exporter

    FRONTMATTER = %w(acknowledgement author cover dedication edition foreword
                     introduction license preface prologue title toc)
    BODYMATTER  = %w(appendix blank chapter conclusion part)
    BACKMATTER  = %w(afterword epilogue glossary lof lot)

    attr_accessor :book, :config
    attr_accessor :frontmatter, :bodymatter, :backmatter

    def initialize(book)
      @book = book
      @config = book.config

      @frontmatter = []
      @bodymatter  = []
      @backmatter  = []

      prepare_output_dir
    end

    # Run all hooks of a type.
    #
    # type - The plugin name in Symbol, valid options are: :before_parse, :after_parse
    #        :before_decorate, :after_decorate.
    #
    # Returns nothing.
    def run_plugins_of_type(type)
      type = type.to_sym

      Burr::Plugin.subclasses.each do |k|
        k_obj = k.new(self.book)
        Burr::Plugin::VALIDS.each do |h|
          k_obj.send(type) if k_obj.respond_to?(h) && h == type
        end
      end

      nil
    end

    # Run exporter.
    #
    # The details should implement in subclass.
    def run
      self.load_contents
      self.parse_contents
      self.decorate_contents
      self.assemble_book
    end

    # Load book contents
    def load_contents
      special_elements = %w(cover toc blank)

      self.config['contents'].each do |content_config|
        item = initialize_item(content_config)

        # if the element defines its own content file (usually: `chapter`, `appendix`)
        if !item['file'].blank?
          content_file = File.join(self.book.contents_dir, item['file'])

          # check that content file exists and is readable
          if !File.readable? content_file
            raise <<-MESSAGE % content_config['file'], item['element'], "outputs/#{content_config['file']}"
            The '%s' content associated with '%s' element doesn't exist\n
            or is not readable.\n\n
            Check that '%s'\n
            file exists and check its permissions.
            MESSAGE
          end

          item['original'] = File.read(content_file)
        elsif item['file'].blank? && special_elements.include?(item['element'])
          item['skip'] = true
        else
          # look for a default content defined by burr for this element
          # e.g. `cover.md`, `license.md`, `title.md`
          default_content_file = File.join(self.book.contents_dir, "#{item['element']}.md")
          if File.exist?(default_content_file)
            item['original'] = File.read(default_content_file)
          else
            self.book.ui.error("Missing file for #{item['element']}")
            exit 1
          end
        end

        self.frontmatter << item if item['matter'] == 'frontmatter'
        self.bodymatter  << item if item['matter'] == 'bodymatter'
        self.backmatter  << item if item['matter'] == 'backmatter'
        self.book.items  << item
      end
    end

    private

    def initialize_item(configs)
      item = {
        'element'  => '', # the type of this content (`chapter', `appendix', `toc', `license', ...)
        'number'   => '', # the number/letter of the content (useful for `chapter', `part' and `appendix')
        'c_title'  => '', # the title of the content defined in `config.yml' (usually only `part' defines it)
        'title'    => '', # the `title' of this file, the first h1 in `content'
        'original' => '', # original content as written by book author
        'content'  => '', # transformed content of the element (HTML usually)
        'file'     => '', # the name of this item contents file (it's a relative path from book's `contents/')
        'toc'      => [], # the table of contents of this element
        'skip'     => false, # some elements, like `toc', do not need to covert, so just skip
      }

      item.merge!(configs)

      # set the matter
      if FRONTMATTER.include?(item['element'])
        item['matter'] = 'frontmatter'
      elsif BODYMATTER.include?(item['element'])
        item['matter'] = 'bodymatter'
      elsif BACKMATTER.include?(item['element'])
        item['matter'] = 'backmatter'
      else
        self.book.ui.error("Element #{ item['element'] } not defined!")
        exit 1
      end

      item
    end

    # If the outpus directory for current format not exists, create it!
    #
    def prepare_output_dir
      dir = File.join(self.book.outputs_dir, self.book.format)
      if !File.exist?(dir)
        FileUtils.mkdir_p dir
      end
    end

  end
end
