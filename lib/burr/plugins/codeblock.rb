module Burr
  class CodeblockPlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      add_label
    end

    private

    # Adds label and id to code block.
    #
    def add_label
      item = self.book.current_item
      return unless self.book.config['formats']["#{self.book.format}"]['label']['elements'].include?('codeblock')

      counter = 1
      number = if item['number']
        item['number']
      else
        item['element']
      end

      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.css('.codeblock.has-caption').each do |codeblock|
        # add id
        codeblock.set_attribute('id', "codeblock-#{number}-#{counter}")

        # add label
        caption = codeblock.css('.caption').first
        label = self.book.render_label('codeblock', { 'item' => { 'number' => number, 'counter' => counter } })
        caption_html = "<span>#{label}</span>#{caption.inner_html}"
        caption.children = ::Nokogiri::HTML.fragment(caption_html, 'utf-8')

        counter += 1
      end

      item['content'] = dom.to_xhtml
    end

  end
end
