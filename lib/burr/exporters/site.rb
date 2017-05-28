module Burr
  class Site < Exporter

    # Convert original contents into HTML
    #
    def parse_contents
      parsed_items = []
      self.book.items.each do |item|
        self.book.current_item = item

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
      [nil, *flatten_items(self.book.items), nil].each_cons(3) do |pre, item, nxt|
        item['toc'] = item_toc_html(item['toc'])

        unless pre.nil?
          item['pre'] = ''
          item['pre'] << "#{pre['label']}" unless pre['label'].blank?
          item['pre'] << "#{pre['title']}"
          item['pre_url'] = get_html_path_of(pre['element'], pre['file'])
        end

        unless nxt.nil?
          item['nxt'] = ''
          item['nxt'] << "#{nxt['label']}" unless nxt['label'].blank?
          item['nxt'] << "#{nxt['title']}"
          item['nxt_url'] = get_html_path_of(nxt['element'], nxt['file'])
        end

        File.open(get_html_path_of(item['element'], item['file'], false), 'w') do |f|
          f.puts self.book.render(self.book.template_for(item['element']), { 'item' => item })
        end
      end
    end

    private

    # Deletes item if item['element'] includes in %w(cover toc blank).
    #
    def flatten_items(items)
      items.delete_if { |item| %w(cover toc blank).include?(item['element']) }
    end

    # Gets toc HTML for a single item.
    #
    def item_toc_html(toc)
      # do not need the first element(level 1) in output
      toc.shift

      html = '<ol class="toc">'
      toc.each do |entry|
        next if entry['level'] - 1 > self.book.config['formats']['site']['toc']['deep']
        html << <<-LI
          <li class="level-#{ entry['level'] }">
            <a href="\##{ entry['id'] }">#{ entry['label'] } #{ entry['title'] }</a>
          </li>
        LI
      end
      html << '</ol>'
    end

    def get_html_path_of(element, path, relative = true)
      base = File.join(self.book.outputs_dir, 'site')
      basename = if path.blank?
        element
      else
        path.split('.')[0..-2].join('.')
      end

      return "./#{ basename }.html" if relative

      File.join(base, "#{ basename }.html")
    end

  end
end
