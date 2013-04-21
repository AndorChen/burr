module Burr
  class Book

    attr_accessor :config, :format, :ui
    attr_accessor :gem_dir, :root_dir, :outputs_dir, :caches_dir, :contents_dir, :plugins_dir, :templates_dir
    attr_accessor :items, :toc, :images, :tables, :current_item
    attr_accessor :labels, :titles, :ids
    attr_accessor :uid, :slug

    def initialize(config, format)
      @config = config
      @format = format
      @ui = Burr::UI.new

      # directory location
      @gem_dir       = File.expand_path('../../../' ,__FILE__)
      @root_dir      = Dir.pwd
      @outputs_dir   = "#{@root_dir}/outputs"
      @caches_dir    = "#{@root_dir}/caches"
      @contents_dir  = "#{@root_dir}/contents"
      @plugins_dir   = "#{@root_dir}/plugins"
      @templates_dir = "#{@root_dir}/templates"

      # publishing process variables
      @items  = []
      @toc    = ''
      @images = []
      @tables = []
      @current_item = []

      # labels and titles
      book_labels  # @labels = {}, @ids = []
      book_titles  # @titles = {}

      # book information
      book_uid  # @uid  = ''
      book_slug # @slug = ''
    end

    # Export site files in outputs/site
    #
    def export_site
      exporter = Burr::Site.new(self)
      self.ui.confirm "Start exporting site files...."
      exporter.run
      self.ui.confirm "Exported site!"
    end

    # Export PDF files in outputs/pdf
    #
    def export_pdf
      exporter = Burr::PDF.new(self)
      self.ui.confirm "Start exporting pdf file...."
      exporter.run
      self.ui.confirm "Exported PDF!"
    end

    # Export Epub files in outputs/epub
    #
    def export_epub
      exporter = Burr::Epub.new(self)
      self.ui.confirm "Start exporting epub file...."
      exporter.run
      self.ui.confirm "Exported Epub!"
    end

    # Export Mobi files in outputs/mobi
    #
    def export_mobi
      dest = File.join(self.outputs_dir, 'mobi')
      FileUtils.mkdir_p(dest) unless File.exist?(dest)

      self.ui.confirm "Start exporting mobi file...."

      FileUtils.cd(File.join(self.outputs_dir, 'epub')) do
        base = "#{self.config['slug']}-#{Time.new.strftime('%Y%m%d')}"
        epub = "#{base}.epub"
        mobi = "#{base}.mobi"
        unless File.exist?(epub)
          self.ui.error('Please export Epub first!')
          exit 1
        end

        system "kindlegen #{epub} -c2"
        FileUtils.cp(mobi, dest)
        FileUtils.rm(mobi)
      end

      self.ui.confirm "Exported Mobi!"
    end

    # Export all formats
    #
    def export_all
      self.export_pdf
      self.export_epub
      self.export_mobi
    end

    # Gets the template file for an element.
    #
    # - element The element name, such as 'chapter', 'appendix'
    #
    # Returns The absolute path of this element's template file.
    #
    def template_for(element)
      base = File.join('templates', self.format, "#{element}.liquid")
      default = File.join(self.gem_dir, 'resources', base)
      custom = File.join(self.root_dir, base)

      if File.exist?(custom)
        custom
      elsif !File.exist?(custom) && File.exist?(default)
        default
      else
        self.ui.error("ERROR: Template #{self.format}/#{element}.liquid not found!")
        exit 1
      end
    end

    # Get the stylesheet file for a format.
    #
    # @param [String] format The format name, could be 'pdf', 'epub', 'site' and 'mobi'
    # @return [String] The absolute path to this format's stylesheet
    def stylesheet_for(format)
      if %w(pdf epub site mobi).include?(format)
        css = File.join(self.outputs_dir, format, "style.css")

        if File.exist?(css)
          css
        else
          self.ui.error("ERROR: Not found stylesheet for format #{format}.")
          exit 1
        end
      else
        self.ui.error("ERROR: #{format} is not support!")
        exit 1
      end
    end

    # Shortcut method to get the label of any element type.
    #
    # element   -  The element type (`chapter', `foreword', ...) in String format.
    # variables -  A variables Hash used to render the label.
    #
    # Returns the label String of the element or an empty String.
    def render_label(element, variables = {})
      c_labels = self.labels.include?(element) ? self.labels[element] : ''
      # some elements (mostly chapters and appendices) have a different label for each level (h1, ..., h6)
      if c_labels.is_a? Array
        index = variables['item']['level'] - 1
        if index == 0
          label = c_labels[0]
        else
          label = c_labels[1]
        end
      else
        label = c_labels
      end

      self.render_string(label, variables)
    end

    # Shortcut method to get the id of headings.
    #
    # variables -  A variables Hash used to render the id.
    #
    # Returns the id String of the heading.
    def render_id(variables = {})
      index = variables['item']['level'] - 1
      if index == 0
        id = self.ids[0]
      else
        id = self.ids[1]
      end

      self.render_string(id, variables)
    end

    # Renders any string as a Liquid template.
    #
    # @param  [String] text      The original content to render
    # @param  [Array]  variables Optional variables passed to the template
    def render_string(text, variables = {})
      registers = { :registers => { :book => self } }
      Liquid::Template.parse(text).render(variables, registers)
    end


    # Renders any template (currently only supports Liquid templates).
    #
    # @param [String] template The template name, without the extension
    # @param [Hash] parameters Optional variables passed to the template
    # @param [String] target Optional output file path. If set, the rendered template is saved in this file.
    # @return [String] The rendered content
    def render(template, parameters = {}, target = nil)
      defaults = {
        'config'    => self.config,
        'format'    => self.format,
        'generator' => { 'name' => 'Burr', 'version' => Burr::Version::STRING }
      }
      text = File.read(template)
      registers = { :registers => { :book => self } }
      content = Liquid::Template.parse(text).render(defaults.merge(parameters), registers)

      if target
        File.open(target, 'wb') { |f| f.puts content }
      end

      content
    end

    # Makes the liquid tags live.
    #
    # Returns Hash.
    def to_liquid
      #{ 'book' => self }
    end

    private

    # Generates `@labels' for chapters, appendixes, etc.
    #
    # Returns nil.
    def book_labels
      base    = File.join('locales', 'labels', "#{self.config['language']}.yml")
      default = File.join(self.gem_dir, 'resources', base)
      custom  = File.join(self.root_dir, base)

      labels = YAML::load_file(default)

      #books can define their own labels files
      if File.exist? custom
        custom_labels = YAML::load_file(custom)
        labels.merge!(custom_labels)
      end

      self.labels = labels
      self.ids    = labels['id']
      nil
    end

    # Generates `@titles' for chapters, appendixes, etc.
    #
    # Returns nil.
    def book_titles
      base    = File.join('locales', 'titles', "#{self.config['language']}.yml")
      default = File.join(self.gem_dir, 'resources', base)
      custom  = File.join(self.root_dir, base)

      titles = YAML::load_file(default)

      #books can define their own titles files
      if File.exist? custom
        custom_titles = YAML::load_file(custom)
        return titles.merge(custom_titles)
      end

      self.titles = titles
      nil
    end

    # Generates a unique `@uid' for the book.
    #
    # Returns nil.
    def book_uid
      if @config['isbn']
        @uid = @config['isbn']
      else
        @uid = Digest::MD5.hexdigest("#{Time.now}--#{rand}")
      end
    end

    # Generates a `@slug' for the book.
    #
    # Uses the current directory name as slug, if no `slug' in `config.yml' provided.
    #
    # Returns String of the book's slug.
    def book_slug
      if @config['slug']
        @slug = @config['slug']
      else
        dir = File.basename(self.root_dir)
        @slug = CGI.escape(dir)
      end
    end

  end
end
