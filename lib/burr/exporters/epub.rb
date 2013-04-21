module Burr
  class Epub < Exporter

    # Convert original contents into HTML
    #
    def parse_contents
      parsed_items = []
      self.book.items.each do |item|
        self.book.current_item = item

        # 'blank' element not include in epub
        next if item['element'] == 'blank'

        self.run_plugins_of_type(:before_parse)

        unless item['skip']
          item['content'] = Burr::Converter.new(self.book).convert(item['original'])
        end

        self.run_plugins_of_type(:after_parse)

        parsed_items << self.book.current_item
      end
      self.book.items = parsed_items
    end

    # Decorate the contents with template
    #
    def decorate_contents
      decorated_items = []
      self.book.items.each do |item|
        self.book.current_item = item
        self.run_plugins_of_type(:before_decorate)
        self.run_plugins_of_type(:after_decorate)
        decorated_items << self.book.current_item
      end
      self.book.items = decorated_items
    end

    def assemble_book
      # 1. create html files
      special_elements = %w(blank)
      base = File.join(self.book.outputs_dir, 'epub')
      included_files = []
      tmp_files = []

      self.book.items.each do |item|
        next if special_elements.include?(item['element'])

        basename = if item['file'].blank?
          item['element']
        else
          item['file'].split('.')[0..-2].join('.')
        end
        html_path = File.join(base, "#{ basename }.html")
        included_files << html_path
        tmp_files << html_path

        File.open(html_path, 'w') do |f|
          f.puts self.book.render(self.book.template_for(item['element']), { 'item' => item, 'toc' => html_toc })
        end
      end

      # 2. add other files
      included_files << File.join(base, 'style.css')
      Dir.glob(File.join(self.book.outputs_dir, 'site', 'figures', '*.*')) do |figure|
        included_files << { figure => 'figures' }
      end
      included_files << File.join(base, 'cover.jpg')

      # 3. build epub file
      config = self.book.config
      nav = ncx_toc
      guide = build_guide

      epub = Burr::EpubMaker.new do
        title      config['title']
        creator    config['translator'].blank? ? config['author'] : config['translator']
        publisher  config['publisher']
        date       config['pubdate']
        identifier config['identifier'], :scheme => config['id_scheme'], :id => config['slug']
        uid        config['slug']
        language   config['language']
        cover      'cover.jpg'

        files included_files
        nav nav
        guide guide
      end

      epub.save(File.join(base, "#{self.book.config['slug']}-#{Time.new.strftime('%Y%m%d')}.epub"))

      # 4. remove useless files
      tmp_files.each do |file|
        FileUtils.remove_entry(file)
      end
    end

    private

    def ncx_toc
      nav = []
      self.book.items.each do |item|
        special_elements = %w(cover toc blank)
        next if special_elements.include?(item['element'])
        level_1 = item['toc'].first
        next unless level_1['level'] == 1
        basename = if item['file'].blank?
          item['element']
        else
          item['file'].split('.')[0..-2].join('.')
        end
        html_path = "#{ basename }.html"
        nav_label = if level_1['label'].blank?
          "#{level_1['title']}"
        else
          "#{level_1['label']} #{level_1['title']}"
        end
        nav << { :label => nav_label, :content => html_path }
      end

      nav
    end

    def html_toc
      html = '<ol class="toc-list">'
      self.book.items.each do |item|
        # editions define the *tocable* items
        if self.book.config['formats']['epub']['toc']['elements'].include?(item['element'])
          # item has several elements in its toc
          if item['toc'].size > 0
            item['toc'].each do |entry|
              if entry['level'] <= self.book.config['formats'][self.book.format]['toc']['deep']
                anchor = "#{item['element']}#{entry['id'].split('-')[1]}.html"
                html << <<-LI1
                  <li class="#{ item['matter'] } #{ item['element'] } level-#{ entry['level'] }">
                    <a href="#{ anchor }##{ entry['id']}">#{ entry['label'] } #{ entry['title'] }</a>
                  </li>
                LI1
              end
            end
          end

        # empty or special item (anything different from 'chapter' and 'appendix')
        elsif !%w(cover blank toc).include?(item['element'])
          html << <<-LI2
            <li class="#{ item['matter'] } #{ item['element'] } level-1">
              <a href="#{ item['id'] }.html">#{ item['title'] }</a>
            </li>
          LI2
        end
      end
      html << '</ol>'
    end

    def build_guide
      o = []
      o << { :type => 'toc', :href => "toc.html", :title => 'Table of Contents' }
      o << { :type => 'cover', :href => "cover.html", :title => 'Cover' }
    end

  end
end
