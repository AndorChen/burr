module Burr
  class LinkPlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      extend_url if %w(site epub).include?(self.book.format)
    end

    private

    # Extends cross link url.
    #
    def extend_url
      item = self.book.current_item
      dom = ::Nokogiri::HTML::DocumentFragment.parse(item['content'])
      dom.css('a[href]').each do |link|
        href = link['href']
        next unless cross_link?(href)

        parts = href.split('-')

        next if parts[0].start_with?('#fn')

        if href.start_with?('#chapter')
          new_href = "chapter#{parts[1]}.html"
        elsif href.start_with?('#section', '#figure', '#codeblock', '#table', '#aside')
          new_href = "chapter#{parts[1]}.html#{parts.join('-')}"
        else
          new_href = "#{href[1..-1]}.html"
        end

        link['href'] = new_href
      end

      item['content'] = dom.to_xhtml

      nil
    end

    def cross_link?(url)
      return true if url.start_with?('#')

      false
    end

  end
end
