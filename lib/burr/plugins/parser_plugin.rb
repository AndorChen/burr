module Burr
  class ParserPlugin < Plugin

    # Do something after parsed the item content.
    def after_parse
      #replace_br
    end

    private

    # Replace <br> by <br/> (it causes problems for epub books)
    def replace_br
      item = self.book.current_item
      item['content'].gsub!('<br>', '<br />')
    end

  end
end
