module Kramdown
  module Parser
    class Bsmarkdown < Kramdown

      BOXES = %w(aside discussion error information question tip warning)

      def initialize(source, options)
        super
        @block_parsers.unshift(:gfm_codeblock_fenced, *BOXES.map{ |b| :"#{b}_box" })
      end

      GFM_FENCED_CODEBLOCK_START = /^`{3,}/
      GFM_FENCED_CODEBLOCK_MATCH = /^(`{3,})\s*?(\w+)?\s*?\n(.*?)^\1`*\s*?\n/m

      # Parser the GitHub Flavored Markdown fenced code block.
      #
      # Examples
      #
      #   ```ruby
      #   def hello
      #     puts 'Hello'
      #   end
      #   ```
      #
      def parse_gfm_codeblock_fenced
        if @src.check(GFM_FENCED_CODEBLOCK_MATCH)
          @src.pos += @src.matched_size
          el = new_block_el(:codeblock, @src[3])
          lang = @src[2].to_s.strip
          el.attr['class'] = "language-#{lang}" unless lang.empty?
          @tree.children << el
          true
        else
          false
        end
      end
      define_parser(:gfm_codeblock_fenced, GFM_FENCED_CODEBLOCK_START)

      ASIDE_BOX_START = /^#{OPT_SPACE}A> ?/u
      DISCUSSION_BOX_START = /^#{OPT_SPACE}D> ?/
      ERROR_BOX_START = /^#{OPT_SPACE}E> ?/
      INFORMATION_BOX_START = /^#{OPT_SPACE}I> ?/
      QUESTION_BOX_START = /^#{OPT_SPACE}Q> ?/
      TIP_BOX_START = /^#{OPT_SPACE}T> ?/
      WARNING_BOX_START = /^#{OPT_SPACE}W> ?/

      BOXES.each do |box|
        define_method("parse_#{box}_box") do
          result = @src.scan(PARAGRAPH_MATCH)
          while !@src.match?(self.class::LAZY_END)
            result << @src.scan(PARAGRAPH_MATCH)
          end
          result.gsub!(self.class.const_get("#{box.upcase}_BOX_START"), '')

          el = new_block_el(:"#{box}_box")
          @tree.children << el
          parse_blocks(el, result)
          true
        end
        define_parser(:"#{box}_box", self.const_get("#{box.upcase}_BOX_START"))
      end

    end
  end
end
