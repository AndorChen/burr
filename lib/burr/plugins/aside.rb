module Burr
  class AsidePlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      add_label
    end

    private

    # Adds label and id to Aside block.
    #
    def add_label
      item = self.book.current_item
      return unless self.book.config['formats']["#{self.book.format}"]['label']['elements'].include?('aside')

      counter = 1
      number = if item['number']
        item['number']
      else
        item['element']
      end

      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.css('div.aside').each do |aside|
        # add id
        aside['id'] = "aside-#{number}-#{counter}"

        # add label
        caption = aside.css('h4').first
        unless caption.blank?
          label = self.book.render_label('aside', { 'item' => { 'number' => number, 'counter' => counter } })
          caption_html = "<span>#{label}</span>#{caption.inner_html}"
          caption.children = ::Nokogiri::HTML.fragment(caption_html, 'utf-8')
        end

        counter += 1
      end

      item['content'] = dom.to_xhtml
    end

  end
end
