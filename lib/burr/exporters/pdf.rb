module Burr
  class PDF < Exporter

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

        item['content'] = self.book.render(self.book.template_for(item['element']), { 'item' => item, 'toc' => toc_html })

        self.run_plugins_of_type(:after_decorate)

        decorated_items << self.book.current_item
      end

      self.book.items = decorated_items
    end

    def assemble_book
      base = File.join(self.book.outputs_dir, 'pdf')
      html_path = File.join(base, "#{self.book.slug}.html")
      pdf_path = File.join(base, "#{self.book.slug}-#{Time.new.strftime('%Y%m%d')}.pdf")

      html = self.book.render(self.book.template_for('book'), {
               'frontmatter' => self.frontmatter,
               'bodymatter'  => self.bodymatter,
               'backmatter'  => self.backmatter
              })
      File.open(html_path, 'w') { |f| f.puts html }

      system "prince #{html_path} -o #{pdf_path}"

      File.unlink html_path
    end

    private

    def toc_html
      html = '<ol class="toc-list">'
      self.book.items.each do |item|
        # editions define the *tocable* items
        if self.book.config['formats']['pdf']['toc']['elements'].include?(item['element'])
          # item has several elements in its toc
          if item['toc'].size > 0
            item['toc'].each do |entry|
              if entry['level'] <= self.book.config['formats'][self.book.format]['toc']['deep']
                html << <<-LI1
                  <li class="#{ item['matter'] } #{ item['element'] } level-#{ entry['level'] }">
                    <a href="\##{ entry['id'] }">#{ entry['label'] } #{ entry['title'] }</a>
                  </li>
                LI1
              end
            end
          end

        # empty or special item (anything different from 'chapter' and 'appendix')
        elsif !%w(cover blank toc).include?(item['element'])
          html << <<-LI2
            <li class="#{ item['matter'] } #{ item['element'] } level-1">
              <a href="\##{ item['id'] }">#{ item['label'] } #{ item['title'] }</a>
            </li>
          LI2
        end
      end
      html << '</ol>'
    end

  end
end
