module Burr
  class FigurePlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      fix_src_for_pdf if self.book.format == 'pdf'

      add_label
    end

    private

    # Replaces figure src for pdf.
    #
    # 'figures/sample.png' => '<root_dir>/figures/sample.png'
    #
    def fix_src_for_pdf
      item = self.book.current_item
      prefix = File.join(self.book.outputs_dir, 'site')
      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.search('img').each do |img|
        ori_src = img.get_attribute('src')
        new_src = File.join(prefix, ori_src)
        img.set_attribute('src', new_src)
      end
      item['content'] = dom.to_xhtml

      nil
    end

    # Adds label and id to figure block.
    #
    def add_label
      item = self.book.current_item
      return unless self.book.config['formats']["#{self.book.format}"]['label']['elements'].include?('figure')

      counter = 1
      number = if item['number']
        item['number']
      else
        item['element']
      end

      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.css('div.figure').each do |figure|
        # add id
        figure.set_attribute('id', "figure-#{number}-#{counter}")

        # add label
        caption = figure.css('.caption').first
        label = self.book.render_label('figure', { 'item' => { 'number' => number, 'counter' => counter } })
        caption_html = "<span>#{label}</span>#{caption.inner_html}"
        caption.children = ::Nokogiri::HTML.fragment(caption_html, 'utf-8')

        counter += 1
      end

      item['content'] = dom.to_xhtml
    end

  end
end
