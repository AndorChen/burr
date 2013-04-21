module Burr
  class TablePlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      add_label
    end

    private

    # Adds label and id to table block.
    #
    def add_label
      item = self.book.current_item
      return unless self.book.config['formats']["#{self.book.format}"]['label']['elements'].include?('table')

      counter = 1
      number = if item['number']
        item['number']
      else
        item['element']
      end

      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.css('.table.has-caption').each do |table|
        # add id
        table.set_attribute('id', "table-#{number}-#{counter}")

        # add label
        caption = table.css('.caption').first
        label = self.book.render_label('table', { 'item' => { 'number' => number, 'counter' => counter } })
        caption_html = "<span>#{label}</span>#{caption.inner_html}"
        caption.children = ::Nokogiri::HTML.fragment(caption_html, 'utf-8')

        counter += 1
      end

      item['content'] = dom.to_xhtml
    end

  end
end
