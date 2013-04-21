module Burr
  class Converter

    attr_accessor :book

    def initialize(book)
      @book = book
    end

    def convert(text)
        ::Kramdown::Document.new(text,
                                 :input    => 'Bsmarkdown',
                                 :auto_ids => false,
                                 :register => self.book
                                ).to_bshtml
    end

  end
end
